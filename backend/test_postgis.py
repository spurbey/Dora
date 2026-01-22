"""
Test PostGIS Geography column and spatial queries.

Tests:
    - Can insert place with lat/lng
    - Geography column is populated correctly
    - ST_Distance calculates distance
    - GIST index exists
"""

from app.database import SessionLocal
from app.models.place import TripPlace
from app.models.trip import Trip
from app.models.user import User
from sqlalchemy import text, func
from geoalchemy2 import Geography
import uuid


def test_postgis():
    """Test PostGIS functionality using a single transaction."""
    db = SessionLocal()

    try:
        # 🔐 Start a single transaction
        db.begin()

        # Create test user (NO commit)
        user = User(
            id=uuid.uuid4(),
            email=f"test_{uuid.uuid4().hex}@example.com",
            username=f"testuser_{uuid.uuid4().hex[:8]}",
            hashed_password="dummy"
        )
        db.add(user)
        db.flush()

        # Create test trip (FK works without commit)
        trip = Trip(
            id=uuid.uuid4(),
            user_id=user.id,
            title="Test Trip"
        )
        db.add(trip)
        db.flush()

        # Create test place with PostGIS geography
        place = TripPlace(
            id=uuid.uuid4(),
            trip_id=trip.id,
            user_id=user.id,
            name="India Gate",
            lat=28.6129,
            lng=77.2295,
            location="SRID=4326;POINT(77.2295 28.6129)"
        )
        db.add(place)

        # 🔄 Flush sends SQL to DB without committing
        db.flush()

        print("✅ Place inserted with PostGIS Geography column")

        # Test distance calculation (~2 km)
        cp_lat, cp_lng = 28.6315, 77.2167

        result = db.query(
            TripPlace.name,
            (
                func.ST_Distance(
                    TripPlace.location,
                    func.ST_SetSRID(
                        func.ST_MakePoint(cp_lng, cp_lat),
                        4326
                    ).cast(Geography)
                ) / 1000
            ).label("distance_km")
        ).filter(TripPlace.id == place.id).first()

        print(
            f"✅ Distance from {result[0]} to Connaught Place: {result[1]:.2f} km"
        )

        # Verify GIST index exists
        index_check = db.execute(text("""
            SELECT indexname
            FROM pg_indexes
            WHERE tablename = 'trip_places'
              AND indexname = 'idx_trip_places_location'
        """)).fetchone()

        if index_check:
            print(f"✅ GIST spatial index exists: {index_check[0]}")
        else:
            raise RuntimeError("❌ GIST index NOT found!")

        print("\n✅ All PostGIS tests passed!")

    except Exception as e:
        print(f"❌ PostGIS test failed: {e}")
        raise

    finally:
        # 🔥 Rollback EVERYTHING (no pollution, always)
        db.rollback()
        db.close()


if __name__ == "__main__":
    test_postgis()


# """
# Test PostGIS Geography column and spatial queries.

# Tests:
#     - Can insert place with lat/lng
#     - Geography column is populated correctly
#     - ST_Distance calculates distance
#     - GIST index exists and is used
# """

# from app.database import SessionLocal
# from app.models.place import TripPlace
# from app.models.trip import Trip
# from app.models.user import User
# from sqlalchemy import text, func
# import uuid


# def test_postgis():
#     """Test PostGIS functionality."""
#     db = SessionLocal()
    
#     try:
#         # Create test user
#         user = User(
#             id=uuid.uuid4(),
#             email="test@example.com",
#             username="testuser",
#             hashed_password="dummy"
#         )
#         db.add(user)
#         db.commit()
        
#         # Create test trip
#         trip = Trip(
#             id=uuid.uuid4(),
#             user_id=user.id,
#             title="Test Trip"
#         )
#         db.add(trip)
#         db.commit()
        
#         # Create test place with PostGIS
#         place = TripPlace(
#             id=uuid.uuid4(),
#             trip_id=trip.id,
#             user_id=user.id,
#             name="India Gate",
#             lat=28.6129,
#             lng=77.2295,
#             location=f"SRID=4326;POINT(77.2295 28.6129)"  # WKT format
#         )
#         db.add(place)
#         db.commit()
        
#         print("✅ Place inserted with PostGIS Geography column")
        
#         # Test distance calculation
#         # Distance from India Gate to Connaught Place (~2km)
#         cp_lat, cp_lng = 28.6315, 77.2167
        
#         result = db.query(
#             TripPlace.name,
#             func.ST_Distance(
#                 TripPlace.location,
#                 func.ST_SetSRID(
#                     func.ST_MakePoint(cp_lng, cp_lat),
#                     4326
#                 ).cast(Geography)
#             ) / 1000  # Convert to km
#         ).filter(TripPlace.id == place.id).first()
        
#         print(f"✅ Distance from {result[0]} to Connaught Place: {result[1]:.2f} km")
        
#         # Check GIST index exists
#         index_check = db.execute(text("""
#             SELECT indexname FROM pg_indexes 
#             WHERE tablename = 'trip_places' 
#             AND indexname = 'idx_trip_places_location'
#         """)).fetchone()
        
#         if index_check:
#             print(f"✅ GIST spatial index exists: {index_check[0]}")
#         else:
#             print("❌ GIST index NOT found!")
        
#         # Cleanup
#         db.delete(place)
#         db.delete(trip)
#         db.delete(user)
#         db.commit()
        
#         print("\n✅ All PostGIS tests passed!")
        
#     except Exception as e:
#         print(f"❌ PostGIS test failed: {e}")
#         db.rollback()
#     finally:
#         db.close()


# if __name__ == "__main__":
#     test_postgis()
