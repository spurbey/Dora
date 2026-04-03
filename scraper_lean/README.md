# scraper_lean — Google Maps Review Scraper (Lean Test Harness)

Created: 2026-04-03
Status: **Core acquisition + extraction proven. Scroll pagination partially done. Not yet integrated into backend.**

## Why This Exists

The previous scraper (`scraper_gmaps/`) had a sophisticated multi-layer architecture (fingerprinting, proto decoding, proxy rotation, session policies) but **could not scrape a single review**. Google Maps served a "limited view" — only Overview and About tabs, **no Reviews tab in the DOM at all**.

This directory was created to solve that problem from scratch with the leanest possible code, proving each step before adding complexity.

## The Root Cause (What Was Blocking `scraper_gmaps/`)

Google Maps detects fresh Playwright/Selenium browsers (no cookies, no history, no Google profile) and serves a stripped "limited view" page. Symptoms:

- `Overview` tab: present
- `About` tab: present
- `Write a review` button: present
- `Learn more about limited view` button: present
- **Reviews tab: MISSING from DOM entirely**

This is not a selector problem — the Reviews tab HTML does not exist on the page.

## The Fix

**`launch_persistent_context(PROFILE_DIR)`** — Playwright's persistent context preserves cookies, localStorage, and browser profile across runs in a `profile/` directory. Over multiple runs, the profile builds trust with Google (accumulated cookies, consistent fingerprint). Combined with:

- **Headed mode** (`headless=False`) — Google is less suspicious of visible browsers
- **Search-click flow** — navigate via Maps home → search → click result (more human-like than direct URL)
- **`--disable-blink-features=AutomationControlled`** — hides Playwright automation signal

Result: full place page with Reviews tab on the **second run** (first run builds initial cookies).

## What Was Tested and Proven (2026-04-03)

### Step 1: Page Acquisition (`step1_acquire.py`)
- **PASSED** — India Gate returned full place page, Reviews tab found with `aria-label="Reviews for India Gate"`, `role="tab"`
- Limited view: `False`
- First run built cookies; second run got full page

### Step 2: DOM Extraction (`step2_extract.py`)
- **PASSED** — 20 review cards found, 10 unique reviews extracted (duplicates are translation variants with same `data-review-id`)
- Fields extracted: `review_id`, `author`, `rating` (1-5), `date` (relative), `text` (full)
- Places tested: India Gate (New Delhi), Taj Mahal (Agra)

### Step 3: Scroll Pagination (`step3_scroll.py`)
- **PARTIALLY PASSED** — scroll container found (`div.m6QErb.DxyBCb.kA9KIf.dS8AEf.XiKgde`), new batches load (10→20→30 confirmed)
- Successfully extracted 30 unique Taj Mahal reviews with scroll
- **Known issue at 100+**: Google virtualizes the reviews list — old cards leave the DOM as new ones load. Extracting only at the end misses cards that were virtualized away. The fix (extract-while-scrolling) is documented below but not yet implemented.

### Sample Output (Taj Mahal, 30 reviews)

```json
{
  "review_id": "Ci9DQUlRQUN...",
  "author": "Abhishek Singh",
  "rating": 5,
  "date": "a month ago",
  "text": "Visiting the Taj Mahal in Agra is truly a once-in-a-lifetime experience..."
}
```

## File Structure

```
scraper_lean/
  step1_acquire.py    # Phase A: Can we reach the full place page?
  step2_extract.py    # Phase B: Can we open reviews and extract fields?
  step3_scroll.py     # Phase C: Can we scroll to load more reviews?
  requirements.txt    # playwright, playwright-stealth
  profile/            # Persistent browser profile (auto-created, DO NOT delete)
  debug/              # Timestamped screenshot + HTML + JSON per run
  README.md           # This file
```

## How to Run

```bash
# One-time setup
pip install playwright playwright-stealth
playwright install chromium

# Step 1: Test page acquisition (run 2x if first run gets limited view)
python step1_acquire.py "Taj Mahal Agra"

# Step 2: Test extraction (only after step 1 passes)
python step2_extract.py "Taj Mahal Agra"

# Step 3: Test scroll + extract (only after step 2 passes)
python step3_scroll.py "Taj Mahal Agra" --max 30
```

**Important:** Don't run many tests in quick succession from the same IP. Google will rate-limit or ban. One or two runs per test cycle is safe.

## Key Selectors That Work (as of 2026-04-03)

| Element | Selector | Notes |
|---------|----------|-------|
| Search box | `input[name="q"]` | Google changed from `#searchboxinput` to dynamic IDs like `#ucc-1` |
| Place title | `h1.DUwDvf` | Use this, NOT generic `h1` (which matches "Results" on search pages) |
| Reviews tab | `button` with `aria-label` starting `"Reviews for"` or `"Reviews"` | Must exclude "Write a review" buttons |
| Review cards | `div[data-review-id]` | Google renders 2x cards per review (original + translation). Dedupe by `data-review-id` |
| Author | `div.d4r55` or `span.X43Kjb` | |
| Rating | `span[aria-label*='star']` | Parse first number from aria-label like "Rated 5 out of 5" |
| Date | `span.rsqaWe` | Relative dates like "3 weeks ago" |
| Review text | `span.wiI7pd` | |
| Scroll container | Auto-detected via JS: walk up from review card to find first scrollable ancestor | Static class selectors break — use the JS detection approach |
| Limited view signal | Text match: `"limited view"` in `page.content().lower()` | |
| Consent dialog | `button[aria-label*="Accept all"]`, `#L2AGLb` | EU/UK cookie consent |

## What Is Left To Do

### 1. Extract-While-Scrolling (Fixes Virtualization Loss)

**Problem:** When scrolling past ~40 reviews, Google virtualizes the list — older `div[data-review-id]` cards are removed from DOM. Extracting only at the end misses them.

**Fix:** Change the scroll loop to extract visible reviews into a dict (keyed by `review_id`) on every scroll iteration, before scrolling further. Accumulate across iterations. The current `step3_scroll.py` has `extract_all_reviews()` called once at the end — this needs to become incremental.

**Pseudocode:**
```python
all_reviews = {}  # keyed by review_id
while len(all_reviews) < max_reviews:
    batch = extract_visible_cards(page)
    for r in batch:
        all_reviews[r["review_id"]] = r
    scroll_down()
    if no_new_reviews_for_N_rounds:
        break
```

**Also:** Use `scrollBy(0, 600-1000)` (incremental), NOT `scrollTop = scrollHeight` (jump-to-bottom). The jump causes too-aggressive virtualization.

### 2. "See More" Expansion for Truncated Reviews

Long reviews are truncated with a "See more" button (`button[aria-label="See more"]`). Currently not expanded during extraction. Should click these before reading `span.wiI7pd` text. Must be done per-card during the extract-while-scroll loop, not as a separate pass (cards may be virtualized away by then).

### 3. Owner Response Extraction

The DOM selector for owner responses is `div.CDe7pd span`. This field exists in `step3_scroll.py`'s `extract_all_reviews()` but was not verified in test runs. Should be validated.

### 4. Search Results Click-Through

When a search query returns multiple results (e.g., "KFC Connaught Place Delhi"), the scraper needs to click into the first result. The fix is in `step3_scroll.py`: use `a.hfpxzc[href*="/maps/place/"]` selector and verify `h1.DUwDvf` appears after click. This was fixed but only partially tested — "Starbucks Connaught Place New Delhi" failed because the click-through didn't fire. Needs more robust result selection (maybe match query hint against result labels).

### 5. Headless Mode Validation

All testing was done in headed mode (`headless=False`). Persistent context may work headless too once the profile has enough trust built up in headed mode. This needs to be tested carefully — start with headed runs to build profile, then try `headless=True`. If it breaks, headed mode is required.

### 6. Rate Limiting and Multi-Place Batching

No rate limiting between places. For multi-place scraping:
- Add configurable delay between places (minimum 30-60s)
- Track places-per-session count
- Rotate proxy after N places (integrate with `scraper_gmaps/layers/proxy_router.py`)

### 7. Consolidation Into Single Scraper

The three step files should be consolidated into one `scraper.py` that:
1. Navigates to place (search-click flow)
2. Verifies full page (not limited view)
3. Opens reviews
4. Scroll-extracts up to N reviews (incremental)
5. Returns structured JSON
6. Saves debug artifacts on failure

### 8. Integration With Backend Advisory Pipeline

Once the scraper reliably extracts reviews, it feeds into the Dora advisory pipeline:

- **Backend tables** (not yet created): `external_signal_runs`, `external_signals_raw`, `external_signals_normalized`, `trip_advisories`
- **Worker chain** (not yet built): ingestion worker → normalization worker → scoring worker → delivery worker
- **Place canonicalization**: map scraped place to Dora's canonical place graph via `place_resolution_links`
- **Trip-context scoring**: given user's lat/lng and trip metadata, score which reviews become advisories
- **Flutter side**: `advisory_inbox` table + Slice E UI (not started)

Architecture details: `docs/live-tracking-unified-system-architecture-plan.md` Section 7, Phase P4/P5.

## What NOT to Carry Forward From `scraper_gmaps/`

The old scraper has good code for individual concerns, but the orchestration approach was wrong:

| Keep (reference only) | Don't reuse |
|---|---|
| `proto_decoder.py` concept (for future network-layer extraction) | Fresh `browser.new_context()` per run |
| `dedupe_store.py` SQLite storage pattern | `fingerprint_manager.py` random UA rotation (breaks persistent profile trust) |
| `run_monitor.py` metrics/snapshot pattern | `session_policy.py` aggressive context rotation |
| `dom_fallback.py` selectors (some still valid) | Proto field map (stale — `END_GROUP before START_GROUP` errors) |
| Challenge handler consent dismissal | Navigator's direct-URL-first approach |

## Relationship to Other Scrapers

- **`scraper_gmaps/`** — Previous attempt. Production-grade architecture but fundamentally broken by limited view problem. Code is reference material only.
- **`scraper_test/`** — General pipeline prototype using Crawl4AI for TripAdvisor, Reddit, etc. + LLM classification/scoring. Separate from Google Maps. Will be integrated alongside this scraper for multi-source advisory pipeline.

## Debug Artifacts

Each test run creates a timestamped folder in `debug/` with:
- `*.png` — screenshots at each phase (maps home, search results, place page, reviews panel)
- `*.html` — full page HTML snapshots
- `reviews.json` — extracted review data (when extraction succeeds)

Key debug runs from 2026-04-03:
- `20260403_194917` — first run, search box not found (selector was `#searchboxinput`, now fixed to `input[name="q"]`)
- `20260403_195032` — **first successful acquisition** (India Gate, Reviews tab found)
- `20260403_195353` — **first successful extraction** (India Gate, 10 unique reviews)
- `20260403_200319` — Taj Mahal, 10 reviews, confirmed quality
- `20260403_200451` — Taj Mahal with scroll, **30 unique reviews extracted**
- `20260403_200615` — Taj Mahal 100-target, 39 extracted (virtualization loss — see item 1 above)

## The `profile/` Directory

This is the persistent Chromium profile. **Do not delete it** — it contains the accumulated cookies and browser state that prevent Google from serving limited view. If deleted, you'll need 1-2 headed runs to rebuild trust.
