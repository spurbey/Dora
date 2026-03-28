"""
LLM Processor - Handles classification, sentiment, and scoring.
"""

import json
from typing import Optional
try:
    from .config import (
        Config, ScrapedSignal, ProcessedSignal,
        SignalSource, SignalCategory, SentimentType, SignalTiming
    )
except ImportError:
    from config import (
        Config, ScrapedSignal, ProcessedSignal,
        SignalSource, SignalCategory, SentimentType, SignalTiming
    )


class LLMProcessor:
    """
    Processes scraped signals through LLM for:
    - Classification (category, tags)
    - Sentiment analysis
    - Relevance scoring
    - Deduplication
    """
    
    def __init__(self, config: Config = None):
        self.config = config or Config()
        self.client = None
        self._init_client()
    
    def _init_client(self):
        """Initialize OpenAI client."""
        api_key = self.config.OPENAI_API_KEY or self.config.LLM_API_KEY
        if api_key:
            try:
                from openai import OpenAI
                client_kwargs = {"api_key": api_key}
                if self.config.LLM_BASE_URL:
                    client_kwargs["base_url"] = self.config.LLM_BASE_URL
                self.client = OpenAI(**client_kwargs)
            except Exception as e:
                print(f"Warning: Could not initialize OpenAI client: {e}")
    
    async def classify(self, signal: ScrapedSignal) -> tuple[SignalCategory, list[str]]:
        """
        Classify signal into category and tags.
        
        Returns:
            (category, tags)
        """
        if not self.client:
            return SignalCategory.ATTRACTION, []
        
        prompt = f"""Classify this travel signal.

Title: {signal.title}
Content: {signal.content}
Source: {signal.source.value if signal.source else 'unknown'}

Categories (choose one):
restaurant, cafe, bar, street_food, hotel, hostel, resort, attraction, landmark, museum, park, shopping, market, transport, nature, warning, hazard, scam_alert, travel_info, activities, utility

Tags (choose multiple from):
veg-friendly, non-veg, budget, moderate, premium, luxury, family, couples, solo, groups, breakfast, lunch, dinner, drinks, coffee, must-visit, avoid, hidden-gem, tourist-trap, famous

Return as JSON:
{{"category": "...", "tags": ["...", "..."]}}
"""
        try:
            response = self.client.chat.completions.create(
                model=self.config.LLM_CLASSIFICATION_MODEL,
                messages=[{"role": "user", "content": prompt}],
                response_format={"type": "json_object"}
            )
            
            result = json.loads(response.choices[0].message.content)
            
            # Map category string to enum
            category_str = result.get("category", "attraction").upper()
            try:
                category = SignalCategory[category_str]
            except KeyError:
                category = SignalCategory.ATTRACTION
            
            tags = result.get("tags", [])
            
            return category, tags
            
        except Exception as e:
            print(f"Error in classification: {e}")
            return SignalCategory.ATTRACTION, []
    
    async def analyze_sentiment(self, signal: ScrapedSignal) -> tuple[SentimentType, float]:
        """
        Analyze sentiment of reviews/content.
        
        Returns:
            (sentiment_type, score)
        """
        if not self.client:
            return SentimentType.NEUTRAL, 0.0
        
        prompt = f"""Analyze sentiment of this travel signal.

Title: {signal.title}
Content: {signal.content}
Rating: {signal.rating}

Consider:
- Sarcasm and irony
- Mixed reviews (some good, some bad)
- Context

Return as JSON:
{{
    "sentiment": "positive | negative | mixed | neutral",
    "score": -1.0 to 1.0
}}
"""
        try:
            response = self.client.chat.completions.create(
                model=self.config.LLM_SENTIMENT_MODEL,
                messages=[{"role": "user", "content": prompt}],
                response_format={"type": "json_object"}
            )
            
            result = json.loads(response.choices[0].message.content)
            
            sentiment_str = result.get("sentiment", "neutral").upper()
            try:
                sentiment = SentimentType[sentiment_str]
            except KeyError:
                sentiment = SentimentType.NEUTRAL
            
            score = float(result.get("score", 0.0))
            
            return sentiment, score
            
        except Exception as e:
            print(f"Error in sentiment analysis: {e}")
            return SentimentType.NEUTRAL, 0.0
    
    async def score_recommendation(
        self, 
        signal: ScrapedSignal,
        category: SignalCategory,
        sentiment: SentimentType,
        trip_context: dict
    ) -> tuple[bool, int, str]:
        """
        Score how relevant this signal is for the trip.
        
        Returns:
            (should_show, priority, reason)
        """
        if not self.client:
            # Default scoring without LLM
            priority = 5
            if sentiment == SentimentType.POSITIVE:
                priority += 2
            return True, priority, "Based on rating"
        
        prompt = f"""Decide if this signal should be shown to the user.

Trip Context:
- Destination: {trip_context.get('destination', 'unknown')}
- Day: {trip_context.get('day', 'unknown')} of trip
- Current location: {trip_context.get('location', 'unknown')}

Signal:
- Title: {signal.title}
- Category: {category.value}
- Sentiment: {sentiment.value}
- Rating: {signal.rating}
- Distance from route: {trip_context.get('distance_km', 'unknown')} km

Should this be shown to the user RIGHT NOW?

Return as JSON:
{{
    "should_show": true/false,
    "priority": 1-10,
    "reason": "short reason"
}}
"""
        try:
            response = self.client.chat.completions.create(
                model=self.config.LLM_RANKING_MODEL,
                messages=[{"role": "user", "content": prompt}],
                response_format={"type": "json_object"}
            )
            
            result = json.loads(response.choices[0].message.content)
            
            should_show = result.get("should_show", True)
            priority = int(result.get("priority", 5))
            reason = result.get("reason", "Based on analysis")
            
            return should_show, priority, reason
            
        except Exception as e:
            print(f"Error in scoring: {e}")
            return True, 5, "Default scoring"
    
    async def process_signal(
        self, 
        signal: ScrapedSignal,
        trip_context: dict
    ) -> ProcessedSignal:
        """Process a scraped signal through the full pipeline."""
        
        # Classify
        category, tags = await self.classify(signal)
        
        # Sentiment
        sentiment, score = await self.analyze_sentiment(signal)
        
        # Score
        should_show, priority, reason = await self.score_recommendation(
            signal, category, sentiment, trip_context
        )
        
        return ProcessedSignal(
            source=signal.source,
            original_id=signal.original_id,
            url=signal.url,
            title=signal.title,
            content=signal.content,
            rating=signal.rating,
            category=category,
            tags=tags,
            sentiment=sentiment,
            sentiment_score=score,
            should_show=should_show,
            priority=priority,
            reason=reason,
            trip_id=signal.trip_id
        )


# Test
if __name__ == "__main__":
    import asyncio
    
    async def test():
        # Create test signal
        signal = ScrapedSignal(
            source=SignalSource.REDDIT,
            original_id="reddit-123",
            url="https://reddit.com/r/india/comments/abc",
            title="Amazing street food at Chandni Chowk!",
            content="Best paratha I've ever had! Must visit for breakfast.",
            rating=4.5,
            review_count=150,
            trip_id="test-trip"
        )
        
        processor = LLMProcessor()
        
        # Test classification
        category, tags = await processor.classify(signal)
        print(f"Category: {category.value}, Tags: {tags}")
        
        # Test sentiment
        sentiment, score = await processor.analyze_sentiment(signal)
        print(f"Sentiment: {sentiment.value}, Score: {score}")
    
    asyncio.run(test())
