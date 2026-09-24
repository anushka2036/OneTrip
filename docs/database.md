# Example:

{
  "_id": "ObjectId",
  "firebase_uid": "firebase-user-123",
  "name": "Anushka",
  "email": "anushka@example.com",
  "profile_image": null,
  "preferences": {
    "interests": [
      "nature",
      "food",
      "adventure"
    ],
    "travel_style": "budget",
    "preferred_accommodation": "hotel"
  },
  "created_at": "2026-09-23T10:00:00Z",
  "updated_at": "2026-09-23T10:00:00Z"
}

# trips:
{
  "_id": "ObjectId",
  "user_id": "ObjectId",
  "title": "Goa Trip",
  "destination": "Goa",
  "start_date": "2026-10-25",
  "end_date": "2026-10-29",
  "travellers": 2,
  "budget": 15000,
  "travel_style": "budget",
  "status": "upcoming",
  "created_at": "2026-09-23T10:00:00Z",
  "updated_at": "2026-09-23T10:00:00Z"
}

# Tickets
 
{
  "_id": "ObjectId",
  "user_id": "ObjectId",
  "trip_id": "ObjectId",
  "source": "Pune",
  "destination": "Goa",
  "travel_date": "2026-10-25",
  "travel_time": "08:30",
  "transport_type": "train",
  "booking_id": "ABC123",
  "passenger_name": "Anushka Singh",
  "raw_text": "Pune to Goa...",
  "processing_status": "completed",
  "created_at": "2026-09-23T10:00:00Z"
}

# itineraries

{
  "_id": "ObjectId",
  "trip_id": "ObjectId",
  "user_id": "ObjectId",
  "destination": "Goa",
  "budget": 15000,
  "duration": 5,
  "generated_by": "ai_planner",
  "days": [
    {
      "day": 1,
      "activities": [
        {
          "name": "Baga Beach",
          "category": "beach",
          "estimated_cost": 0
        },
        {
          "name": "Local Restaurant",
          "category": "food",
          "estimated_cost": 600
        }
      ]
    }
  ],
  "created_at": "2026-09-23T10:00:00Z"
}

# expenses

{
  "_id": "ObjectId",
  "trip_id": "ObjectId",
  "user_id": "ObjectId",
  "category": "food",
  "amount": 500,
  "description": "Lunch",
  "date": "2026-10-25",
  "created_at": "2026-10-25T13:30:00Z"
}

# community posts

{
  "_id": "ObjectId",
  "user_id": "ObjectId",
  "itinerary_id": "ObjectId",
  "title": "Budget Goa Trip",
  "destination": "Goa",
  "budget": 15000,
  "duration": 5,
  "travel_style": "budget",
  "description": "A five-day Goa itinerary.",
  "likes_count": 10,
  "created_at": "2026-09-23T10:00:00Z"
}
