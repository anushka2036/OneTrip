from pymongo import MongoClient
from pymongo.server_api import ServerApi

from .config import settings


client = MongoClient(
    settings.mongodb_uri,
    server_api=ServerApi(
        "1",
        strict=True,
        deprecation_errors=True
    )
)


database = client[settings.database_name]


# MongoDB collection for storing trips
trips_collection = database["trips"]


# MongoDB collection for storing expenses
expenses_collection = database["expenses"]


def test_database_connection() -> bool:
    try:
        client.admin.command("ping")
        print("MongoDB connection successful!")
        return True

    except Exception as e:
        print("MongoDB connection failed!")
        print(e)
        return False