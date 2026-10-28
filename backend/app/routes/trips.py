from datetime import datetime, timezone
from typing import Optional

from bson import ObjectId
from fastapi import APIRouter, Header, HTTPException, Query, status
from pymongo.errors import PyMongoError

from ..database import trips_collection
from ..schemas.trip import TripCreate, TripUpdate, TripResponse


router = APIRouter()


def get_current_user_id(
    x_user_id: Optional[str] = Header(default=None)
) -> str:
    """
    TEMPORARY DEVELOPMENT-ONLY USER IDENTIFICATION.

    Replace this with Firebase ID token verification
    before production use.
    """
    if not x_user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing X-User-ID header"
        )

    return x_user_id


def serialize_trip(trip: dict) -> dict:
    """
    Convert MongoDB-specific fields into API-friendly values.
    """
    return {
        "id": str(trip["_id"]),
        "title": trip["title"],
        "destination": trip["destination"],
        "start_date": trip["start_date"].date(),
        "end_date": trip["end_date"].date(),
        "budget": trip["budget"],
        "travelers": trip["travelers"],
        "notes": trip.get("notes"),
        "created_at": trip["created_at"],
        "updated_at": trip["updated_at"],
    }


@router.post(
    "",
    response_model=TripResponse,
    status_code=status.HTTP_201_CREATED
)
def create_trip(
    trip_data: TripCreate,
    user_id: str = Header(alias="X-User-ID")
):
    now = datetime.now(timezone.utc)

    trip_document = trip_data.model_dump()

    # Store Python date values as MongoDB-compatible datetimes.
    trip_document["start_date"] = datetime.combine(
        trip_data.start_date,
        datetime.min.time(),
        tzinfo=timezone.utc
    )

    trip_document["end_date"] = datetime.combine(
        trip_data.end_date,
        datetime.min.time(),
        tzinfo=timezone.utc
    )

    trip_document["user_id"] = user_id
    trip_document["created_at"] = now
    trip_document["updated_at"] = now

    try:
        result = trips_collection.insert_one(trip_document)

        saved_trip = trips_collection.find_one(
            {
                "_id": result.inserted_id,
                "user_id": user_id
            }
        )

        return serialize_trip(saved_trip)

    except PyMongoError:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not save trip to the database"
        )


@router.get("", response_model=list[TripResponse])
def list_trips(
    user_id: str = Header(alias="X-User-ID"),
    limit: int = Query(default=50, ge=1, le=100),
    skip: int = Query(default=0, ge=0)
):
    try:
        cursor = (
            trips_collection
            .find({"user_id": user_id})
            .sort("created_at", -1)
            .skip(skip)
            .limit(limit)
        )

        return [serialize_trip(trip) for trip in cursor]

    except PyMongoError:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not retrieve trips"
        )


@router.get("/{trip_id}", response_model=TripResponse)
def get_trip(
    trip_id: str,
    user_id: str = Header(alias="X-User-ID")
):
    if not ObjectId.is_valid(trip_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid trip ID"
        )

    try:
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

        return serialize_trip(trip)

    except PyMongoError:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not retrieve trip"
        )


@router.put("/{trip_id}", response_model=TripResponse)
def update_trip(
    trip_id: str,
    trip_data: TripUpdate,
    user_id: str = Header(alias="X-User-ID")
):
    if not ObjectId.is_valid(trip_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid trip ID"
        )

    updates = trip_data.model_dump(exclude_unset=True)

    if not updates:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Provide at least one field to update"
        )

    # Prevent an explicit null value for required fields.
    required_fields = {
        "title",
        "destination",
        "start_date",
        "end_date",
        "budget",
        "travelers"
    }

    for field in required_fields:
        if field in updates and updates[field] is None:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail=f"{field} cannot be null"
            )

    # Convert date values to MongoDB-compatible datetimes.
    for field in ("start_date", "end_date"):
        if field in updates and updates[field] is not None:
            updates[field] = datetime.combine(
                updates[field],
                datetime.min.time(),
                tzinfo=timezone.utc
            )

    try:
        existing_trip = trips_collection.find_one(
            {
                "_id": ObjectId(trip_id),
                "user_id": user_id
            }
        )

        if existing_trip is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Trip not found"
            )

        # Validate the final date combination, including
        # dates that were not included in this update.
        final_start = updates.get(
            "start_date",
            existing_trip["start_date"]
        )
        final_end = updates.get(
            "end_date",
            existing_trip["end_date"]
        )

        if final_end < final_start:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="End date cannot be earlier than start date"
            )

        updates["updated_at"] = datetime.now(timezone.utc)

        trips_collection.update_one(
            {
                "_id": ObjectId(trip_id),
                "user_id": user_id
            },
            {"$set": updates}
        )

        updated_trip = trips_collection.find_one(
            {
                "_id": ObjectId(trip_id),
                "user_id": user_id
            }
        )

        return serialize_trip(updated_trip)

    except PyMongoError:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not update trip"
        )


@router.delete("/{trip_id}")
def delete_trip(
    trip_id: str,
    user_id: str = Header(alias="X-User-ID")
):
    if not ObjectId.is_valid(trip_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid trip ID"
        )

    try:
        result = trips_collection.delete_one(
            {
                "_id": ObjectId(trip_id),
                "user_id": user_id
            }
        )

        if result.deleted_count == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Trip not found"
            )

        return {
            "message": "Trip deleted successfully",
            "trip_id": trip_id
        }

    except PyMongoError:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not delete trip"
        )
