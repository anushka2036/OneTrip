from fastapi import FastAPI
from .database import test_database_connection

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

