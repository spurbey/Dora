"""
Trip Analyzer - Analyzes trip metadata and decides what to search.
"""

try:
    from .config import TripMetadata, SearchQuery, SignalSource
except ImportError:
    from config import TripMetadata, SearchQuery, SignalSource


class TripAnalyzer:
    """
    Analyzes trip metadata → decides what to search and when.
    """

    def analyze(self, trip: TripMetadata) -> list[SearchQuery]:
        queries = []
        queries.extend(self._destination_queries(trip))
        queries.extend(self._interest_queries(trip))
        queries.extend(self._route_queries(trip))
        queries.extend(self._timing_queries(trip))
        return self._deduplicate_queries(queries)
    
    def _destination_queries(self, trip: TripMetadata) -> list[SearchQuery]:
        queries = []
        
        queries.append(SearchQuery(
            query=f"best restaurants in {trip.destination}",
            category="food",
            priority=9,
            sources=[SignalSource.GOOGLE_PLACES, SignalSource.REDDIT],
            when="before_trip"
        ))
        
        queries.append(SearchQuery(
            query=f"historical places to visit in {trip.destination}",
            category="attraction",
            priority=8,
            sources=[SignalSource.WIKIPEDIA, SignalSource.GOOGLE_PLACES],
            when="before_trip"
        ))
        
        queries.append(SearchQuery(
            query=f"things to do in {trip.destination}",
            category="activities",
            priority=7,
            sources=[SignalSource.GOOGLE_PLACES, SignalSource.REDDIT],
            when="before_trip"
        ))
        
        queries.append(SearchQuery(
            query=f"famous {trip.destination} local food dishes",
            category="food",
            priority=8,
            sources=[SignalSource.REDDIT],
            when="before_trip"
        ))
        
        return queries
    
    def _interest_queries(self, trip: TripMetadata) -> list[SearchQuery]:
        queries = []
        
        interest_handlers = {
            "food": self._food_interest,
            "photography": self._photography_interest,
            "history": self._history_interest,
            "nature": self._nature_interest,
            "adventure": self._adventure_interest,
            "shopping": self._shopping_interest,
        }
        
        for interest in trip.interests:
            handler = interest_handlers.get(interest.lower())
            if handler:
                queries.extend(handler(trip))
        
        return queries
    
    def _food_interest(self, trip: TripMetadata) -> list[SearchQuery]:
        return [
            SearchQuery(
                query=f"best street food in {trip.destination}",
                category="street_food",
                priority=9,
                sources=[SignalSource.REDDIT, SignalSource.GOOGLE_PLACES],
                when="during_trip"
            ),
            SearchQuery(
                query=f"famous dhabas near {trip.destination}",
                category="restaurant",
                priority=8,
                sources=[SignalSource.REDDIT],
                when="on_route"
            ),
        ]
    
    def _photography_interest(self, trip: TripMetadata) -> list[SearchQuery]:
        return [
            SearchQuery(
                query=f"best photography spots in {trip.destination}",
                category="attraction",
                priority=9,
                sources=[SignalSource.REDDIT],
                when="before_trip"
            ),
            SearchQuery(
                query=f"sunrise sunset viewpoints near {trip.destination}",
                category="nature",
                priority=8,
                sources=[SignalSource.REDDIT],
                when="during_trip"
            ),
        ]
    
    def _history_interest(self, trip: TripMetadata) -> list[SearchQuery]:
        return [
            SearchQuery(
                query=f"historical monuments {trip.destination}",
                category="attraction",
                priority=9,
                sources=[SignalSource.WIKIPEDIA, SignalSource.GOOGLE_PLACES],
                when="before_trip"
            ),
            SearchQuery(
                query=f"museums in {trip.destination}",
                category="attraction",
                priority=7,
                sources=[SignalSource.GOOGLE_PLACES],
                when="during_trip"
            ),
        ]
    
    def _nature_interest(self, trip: TripMetadata) -> list[SearchQuery]:
        return [
            SearchQuery(
                query=f"national parks near {trip.destination}",
                category="nature",
                priority=8,
                sources=[SignalSource.WIKIPEDIA, SignalSource.REDDIT],
                when="before_trip"
            ),
            SearchQuery(
                query=f"trekking places near {trip.destination}",
                category="adventure",
                priority=7,
                sources=[SignalSource.REDDIT],
                when="during_trip"
            ),
        ]
    
    def _adventure_interest(self, trip: TripMetadata) -> list[SearchQuery]:
        return [
            SearchQuery(
                query=f"adventure activities in {trip.destination}",
                category="adventure",
                priority=9,
                sources=[SignalSource.REDDIT, SignalSource.GOOGLE_PLACES],
                when="before_trip"
            ),
        ]
    
    def _shopping_interest(self, trip: TripMetadata) -> list[SearchQuery]:
        return [
            SearchQuery(
                query=f"famous markets in {trip.destination}",
                category="shopping",
                priority=8,
                sources=[SignalSource.GOOGLE_PLACES, SignalSource.REDDIT],
                when="during_trip"
            ),
            SearchQuery(
                query=f"best places to buy souvenirs {trip.destination}",
                category="shopping",
                priority=7,
                sources=[SignalSource.REDDIT],
                when="during_trip"
            ),
        ]
    
    def _route_queries(self, trip: TripMetadata) -> list[SearchQuery]:
        queries = []
        
        if trip.transport_mode == "car" or trip.transport_mode == "bike":
            queries.append(SearchQuery(
                query=f"famous dhabas on {trip.source} to {trip.destination} highway",
                category="food",
                priority=9,
                sources=[SignalSource.REDDIT],
                when="on_route"
            ))
            queries.append(SearchQuery(
                query=f"petrol pumps on {trip.source} to {trip.destination} route",
                category="utility",
                priority=8,
                sources=[SignalSource.GOOGLE_PLACES],
                when="on_route"
            ))
            queries.append(SearchQuery(
                query=f"rest stops on {trip.source} to {trip.destination}",
                category="utility",
                priority=7,
                sources=[SignalSource.GOOGLE_PLACES],
                when="on_route"
            ))
            queries.append(SearchQuery(
                query=f"road conditions {trip.source} to {trip.destination}",
                category="travel_info",
                priority=9,
                sources=[SignalSource.REDDIT],
                when="before_trip"
            ))
        
        for waypoint in trip.waypoints:
            queries.append(SearchQuery(
                query=f"things to do in {waypoint}",
                category="activities",
                priority=7,
                sources=[SignalSource.GOOGLE_PLACES],
                when="on_route"
            ))
        
        return queries
    
    def _timing_queries(self, trip: TripMetadata) -> list[SearchQuery]:
        return [
            SearchQuery(
                query=f"best breakfast places in {trip.destination}",
                category="food",
                priority=7,
                sources=[SignalSource.GOOGLE_PLACES, SignalSource.REDDIT],
                when="during_trip"
            ),
            SearchQuery(
                query=f"best nightlife {trip.destination}",
                category="bar",
                priority=6,
                sources=[SignalSource.REDDIT, SignalSource.GOOGLE_PLACES],
                when="during_trip"
            ),
        ]
    
    def _deduplicate_queries(self, queries: list[SearchQuery]) -> list[SearchQuery]:
        seen = set()
        unique = []
        
        for q in queries:
            key = q.query.lower().strip()
            if key not in seen:
                seen.add(key)
                unique.append(q)
        
        return unique


if __name__ == "__main__":
    trip = TripMetadata(
        trip_id="test-1",
        name="Delhi Jaipur Road Trip",
        source="Delhi",
        destination="Jaipur",
        start_date="2025-03-20",
        end_date="2025-03-25",
        waypoints=["Neemrana"],
        interests=["food", "photography", "history"],
        transport_mode="car"
    )
    
    analyzer = TripAnalyzer()
    queries = analyzer.analyze(trip)
    
    print(f"Generated {len(queries)} search queries:")
    for i, q in enumerate(queries, 1):
        print(f"{i}. [{q.category}] {q.query} (priority: {q.priority}, when: {q.when})")
