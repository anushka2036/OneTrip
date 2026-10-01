from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel, Field, ConfigDict, model_validator


class TripCreate(BaseModel):
    title: str = Field(
        ...,
        min_length=1,
        max_length=100,
        description="Name of the trip"
    )

    destination: str = Field(
        ...,
        min_length=1,
        max_length=200,
        description="Destination of the trip"
    )

    start_date: date
    end_date: date

    budget: float = Field(
        ...,
        gt=0,
        description="Total planned budget"
    )

    travelers: int = Field(
        default=1,
        ge=1,
        description="Number of travelers"
    )

    notes: Optional[str] = Field(
        default=None,
        max_length=1000
    )

    @model_validator(mode="after")
    def validate_dates(self):
        if self.end_date < self.start_date:
            raise ValueError(
                "End date cannot be earlier than start date"
            )

        return self


class TripUpdate(BaseModel):
    title: Optional[str] = Field(
        default=None,
        min_length=1,
        max_length=100
    )

    destination: Optional[str] = Field(
        default=None,
        min_length=1,
        max_length=200
    )

    start_date: Optional[date] = None
    end_date: Optional[date] = None

    budget: Optional[float] = Field(
        default=None,
        gt=0
    )

    travelers: Optional[int] = Field(
        default=None,
        ge=1
    )

    notes: Optional[str] = Field(
        default=None,
        max_length=1000
    )

    @model_validator(mode="after")
    def validate_dates(self):
        if (
            self.start_date is not None
            and self.end_date is not None
            and self.end_date < self.start_date
        ):
            raise ValueError(
                "End date cannot be earlier than start date"
            )

        return self


class TripResponse(BaseModel):
    id: str
    title: str
    destination: str
    start_date: date
    end_date: date
    budget: float
    travelers: int
    notes: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(
        json_encoders={
            date: lambda value: value.isoformat(),
            datetime: lambda value: value.isoformat()
        }
    )
