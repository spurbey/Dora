# Scraper Pipeline Test

This folder contains tests for the Crawl4AI + LLM scraping pipeline.

## Setup

```bash
# Install dependencies
pip install crawl4ai openai litellm

# Optional LLM key (OpenRouter or OpenAI)
export OPENROUTER_API_KEY="your-key-here"
# or
export LLM_API_KEY="your-key-here"

# Optional Google Maps URL probe target
export GOOGLE_MAPS_TEST_URL="https://www.google.com/maps/place/..."
```

## Files

- `config.py` - Configuration and models
- `trip_analyzer.py` - Analyzes trip metadata → decides what to search
- `crawl4ai_wrapper.py` - Crawl4AI wrapper with proxy, session, stealth
- `llm_processor.py` - LLM processing (classification, sentiment, scoring)
- `test_pipeline.py` - Main test file

## Running Tests

```bash
python test_pipeline.py
```
