from fastapi import FastAPI

from .database import test_database_connection
from .routes.trips import router as trips_router
from fastapi.middleware.cors import CORSMiddleware


app = FastAPI(
    title="OneTrip API",
    description="Backend API for the OneTrip Smart Travel Companion",
    version="1.0.0"
)


@app.get("/")
def root():
    return {
        "message": "OneTrip API is running"
    }


@app.get("/health")
def health_check():
    database_status = test_database_connection()

    return {
        "status": "healthy",
        "database_connected": database_status
    }


app.include_router(
    trips_router,
    prefix="/api/trips",
    tags=["Trips"]
)
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
