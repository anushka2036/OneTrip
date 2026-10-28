# OneTrip AI Architecture

## 1. AI Trip Planning Pipeline

User Input
    ↓
Destination + Dates + Budget + Preferences
    ↓
Google Places / Maps Data
    ↓
Candidate Places
    ↓
Filtering
    ↓
Recommendation Model
    ↓
Budget Constraints
    ↓
Route Planning
    ↓
LLM
    ↓
Structured Itinerary
    ↓
MongoDB
    ↓
Flutter Application

## 2. Recommendation Layer

Scikit-learn will be used for recommendation and similarity-based
ranking of travel options.

Potential recommendation features:

- Category
- Location
- Price range
- User interests
- Travel style
- Popularity
- Distance

## 3. LLM Layer

The LLM will be used for:

- Extracting structured information from OCR text
- Generating natural-language itineraries
- Generating trip summaries
- Adapting shared itineraries

## 4. Important Design Principle

The LLM should not independently determine factual travel information.

Real-world information should come from reliable APIs or stored data.

The recommendation, filtering, budget, and route layers should operate
before the LLM produces the final human-readable itinerary.