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


def test_database_connection():
    try:
        client.admin.command("ping")
        print("MongoDB connection successful!")
        return True
    except Exception as e:
        print("MongoDB connection failed!")
        print(e)
        return False