from datetime import date
from typing import Optional

from pydantic import BaseModel, Field


class ExpenseCreate(BaseModel):
    trip_id: str = Field(..., min_length=1)
    category: str = Field(..., min_length=1)
    description: str = Field(..., min_length=1)
    amount: float = Field(..., gt=0)
    date: date
    note: Optional[str] = None


class ExpenseUpdate(BaseModel):
    category: str = Field(..., min_length=1)
    description: str = Field(..., min_length=1)
    amount: float = Field(..., gt=0)
    date: date
    note: Optional[str] = None


class ExpenseResponse(BaseModel):
    id: str
    trip_id: str
    user_id: str
    category: str
    description: str
    amount: float
    date: date
    note: Optional[str] = None


class ExpenseSummaryResponse(BaseModel):
    trip_id: str
    budget: float
    total_expense: float
    remaining_budget: float
    budget_used_percentage: float
    category_totals: dict[str, float]