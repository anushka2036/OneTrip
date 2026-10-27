from datetime import datetime, timezone

from bson import ObjectId
from fastapi import APIRouter, Header, HTTPException, status
from pymongo.errors import PyMongoError

from ..database import expenses_collection, trips_collection
from ..schemas.expense import (
    ExpenseCreate,
    ExpenseUpdate,
    ExpenseResponse,
    ExpenseSummaryResponse,
)


router = APIRouter()


def serialize_expense(expense: dict) -> dict:
    """
    Convert MongoDB expense document into API-friendly values.
    """
    return {
        "id": str(expense["_id"]),
        "trip_id": expense["trip_id"],
        "user_id": expense["user_id"],
        "category": expense["category"],
        "description": expense["description"],
        "amount": float(expense["amount"]),
        "date": expense["date"].date(),
        "note": expense.get("note"),
    }


def get_trip_for_user(
    trip_id: str,
    user_id: str
) -> dict:
    """
    Find a trip belonging to the current user.
    """

    if not ObjectId.is_valid(trip_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid trip ID"
        )

    trip = trips_collection.find_one(
        {
            "_id": ObjectId(trip_id),
            "user_id": user_id
        }
    )

    if trip is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Trip not found"
        )

    return trip


@router.post(
    "",
    response_model=ExpenseResponse,
    status_code=status.HTTP_201_CREATED
)
def create_expense(
    expense_data: ExpenseCreate,
    user_id: str = Header(alias="X-User-ID")
):
    """
    Create a new expense for a trip.
    """

    # Make sure the trip exists and belongs to this user.
    get_trip_for_user(
        expense_data.trip_id,
        user_id
    )

    expense_document = {
        "trip_id": expense_data.trip_id,
        "user_id": user_id,
        "category": expense_data.category,
        "description": expense_data.description,
        "amount": expense_data.amount,
        "date": datetime.combine(
            expense_data.date,
            datetime.min.time(),
            tzinfo=timezone.utc
        ),
        "note": expense_data.note,
        "created_at": datetime.now(timezone.utc),
        "updated_at": datetime.now(timezone.utc),
    }

    try:
        result = expenses_collection.insert_one(
            expense_document
        )

        saved_expense = expenses_collection.find_one(
            {
                "_id": result.inserted_id,
                "user_id": user_id
            }
        )

        if saved_expense is None:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Expense was created but could not be retrieved"
            )

        return serialize_expense(saved_expense)

    except PyMongoError:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not save expense to the database"
        )


@router.get(
    "/trip/{trip_id}",
    response_model=list[ExpenseResponse]
)
def list_expenses(
    trip_id: str,
    user_id: str = Header(alias="X-User-ID")
):
    """
    Get all expenses belonging to a particular trip.
    """

    get_trip_for_user(
        trip_id,
        user_id
    )

    try:
        expenses = (
            expenses_collection
            .find(
                {
                    "trip_id": trip_id,
                    "user_id": user_id
                }
            )
            .sort("date", -1)
        )

        return [
            serialize_expense(expense)
            for expense in expenses
        ]

    except PyMongoError:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not retrieve expenses"
        )


@router.get(
    "/{expense_id}",
    response_model=ExpenseResponse
)
def get_expense(
    expense_id: str,
    user_id: str = Header(alias="X-User-ID")
):
    """
    Get one expense.
    """

    if not ObjectId.is_valid(expense_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid expense ID"
        )

    try:
        expense = expenses_collection.find_one(
            {
                "_id": ObjectId(expense_id),
                "user_id": user_id
            }
        )

        if expense is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Expense not found"
            )

        return serialize_expense(expense)

    except PyMongoError:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not retrieve expense"
        )


@router.put(
    "/{expense_id}",
    response_model=ExpenseResponse
)
def update_expense(
    expense_id: str,
    expense_data: ExpenseUpdate,
    user_id: str = Header(alias="X-User-ID")
):
    """
    Update an existing expense.
    """

    if not ObjectId.is_valid(expense_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid expense ID"
        )

    try:
        existing_expense = expenses_collection.find_one(
            {
                "_id": ObjectId(expense_id),
                "user_id": user_id
            }
        )

        if existing_expense is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Expense not found"
            )

        updates = {
            "category": expense_data.category,
            "description": expense_data.description,
            "amount": expense_data.amount,
            "date": datetime.combine(
                expense_data.date,
                datetime.min.time(),
                tzinfo=timezone.utc
            ),
            "note": expense_data.note,
            "updated_at": datetime.now(timezone.utc),
        }

        expenses_collection.update_one(
            {
                "_id": ObjectId(expense_id),
                "user_id": user_id
            },
            {
                "$set": updates
            }
        )

        updated_expense = expenses_collection.find_one(
            {
                "_id": ObjectId(expense_id),
                "user_id": user_id
            }
        )

        return serialize_expense(updated_expense)

    except PyMongoError:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not update expense"
        )


@router.delete("/{expense_id}")
def delete_expense(
    expense_id: str,
    user_id: str = Header(alias="X-User-ID")
):
    """
    Delete an expense.
    """

    if not ObjectId.is_valid(expense_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid expense ID"
        )

    try:
        result = expenses_collection.delete_one(
            {
                "_id": ObjectId(expense_id),
                "user_id": user_id
            }
        )

        if result.deleted_count == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Expense not found"
            )

        return {
            "message": "Expense deleted successfully",
            "expense_id": expense_id
        }

    except PyMongoError:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not delete expense"
        )


@router.get(
    "/trip/{trip_id}/summary",
    response_model=ExpenseSummaryResponse
)
def get_expense_summary(
    trip_id: str,
    user_id: str = Header(alias="X-User-ID")
):
    """
    Calculate total expenses and category-wise spending
    for a particular trip.
    """

    trip = get_trip_for_user(
        trip_id,
        user_id
    )

    try:
        expenses = list(
            expenses_collection.find(
                {
                    "trip_id": trip_id,
                    "user_id": user_id
                }
            )
        )

        total_expense = sum(
            float(expense["amount"])
            for expense in expenses
        )

        budget = float(trip["budget"])

        remaining_budget = budget - total_expense

        if budget > 0:
            budget_used_percentage = (
                total_expense / budget
            ) * 100
        else:
            budget_used_percentage = 0.0

        category_totals = {}

        for expense in expenses:
            category = expense["category"]
            amount = float(expense["amount"])

            category_totals[category] = (
                category_totals.get(category, 0.0)
                + amount
            )

        return {
            "trip_id": trip_id,
            "budget": budget,
            "total_expense": total_expense,
            "remaining_budget": remaining_budget,
            "budget_used_percentage": budget_used_percentage,
            "category_totals": category_totals,
        }

    except PyMongoError:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not calculate expense summary"
        )