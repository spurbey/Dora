"""
Step 2: Review Extraction Test

Only run this AFTER step1_acquire.py confirms Reviews entry exists.

Goal: Open reviews panel, extract first 5 visible reviews (author, rating, date, text).
No scrolling yet — just what's visible on first load.

Run: python step2_extract.py "Taj Mahal Agra"
"""

import sys
import os
import re
import time
import json

# Fix Windows console encoding for Unicode review text
if sys.stdout.encoding != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
from pathlib import Path
from datetime import datetime
from playwright.sync_api import sync_playwright, TimeoutError as PWTimeout

PROFILE_DIR = str(Path(__file__).parent / "profile")
DEBUG_DIR = Path(__file__).parent / "debug"


def save_snapshot(page, label: str, run_dir: Path):
    safe = re.sub(r"[^a-zA-Z0-9_]", "_", label)
    page.screenshot(path=str(run_dir / f"{safe}.png"), full_page=True)
    (run_dir / f"{safe}.html").write_text(page.content(), encoding="utf-8")


def navigate_to_place(page, query: str) -> bool:
    """Search-click flow to reach place page."""
    page.goto("https://www.google.com/maps?hl=en", wait_until="domcontentloaded", timeout=30_000)
    time.sleep(2)

    # Dismiss consent
    for sel in ['button[aria-label*="Accept all"]', 'button[aria-label*="Accept"]', '#L2AGLb']:
        try:
            btn = page.query_selector(sel)
            if btn and btn.is_visible():
                btn.click()
                time.sleep(1.5)
                break
        except Exception:
            pass

    # Search
    box = (page.query_selector("input#searchboxinput")
           or page.query_selector('input[name="q"]')
           or page.query_selector('input[aria-label*="Search"]'))
    if not box:
        return False
    box.click()
    box.fill("")
    time.sleep(0.2)
    box.type(query, delay=50)
    time.sleep(0.3)
    page.keyboard.press("Enter")
    time.sleep(3)

    # Check if we landed on place directly
    title = page.query_selector("h1.DUwDvf") or page.query_selector("h1")
    if title and title.inner_text().strip():
        return True

    # Click first search result
    for sel in ["div.Nv2PK", 'a.hfpxzc[href*="/maps/place/"]']:
        try:
            results = page.query_selector_all(sel)
            for r in results[:3]:
                if r.is_visible():
                    r.click()
                    time.sleep(3)
                    return True
        except Exception:
            pass
    return False


def open_reviews(page) -> bool:
    """Find and click the reviews entry point."""
    buttons = page.query_selector_all("button")
    for btn in buttons:
        try:
            if not btn.is_visible():
                continue
            aria = (btn.get_attribute("aria-label") or "").lower()
            text = (btn.inner_text() or "").strip().lower()
            role = (btn.get_attribute("role") or "").lower()

            is_reviews = False
            if aria.startswith("reviews for") or aria.startswith("reviews"):
                if "write" not in aria and "add" not in aria:
                    is_reviews = True
            if role == "tab" and "review" in (aria or text):
                if "write" not in aria:
                    is_reviews = True

            if is_reviews:
                btn.scroll_into_view_if_needed()
                btn.click()
                print(f"  Clicked reviews: aria='{aria}' text='{text}'")
                time.sleep(2)
                return True
        except Exception:
            continue
    return False


def extract_visible_reviews(page) -> list[dict]:
    """Extract reviews from visible DOM. No scrolling."""
    reviews = []

    # Primary: cards with data-review-id
    cards = page.query_selector_all("div[data-review-id]")

    if not cards:
        # Fallback: review feed container children
        feed = page.query_selector('div[role="feed"]')
        if feed:
            cards = feed.query_selector_all(":scope > div")
        if not cards:
            # Another fallback: jftiEf class (Google's review card class)
            cards = page.query_selector_all("div.jftiEf")

    print(f"  Found {len(cards)} review card(s)")

    for card in cards[:10]:  # Cap at 10 for this test
        review = {}
        try:
            # Review ID
            review["review_id"] = card.get_attribute("data-review-id") or ""

            # Author
            for sel in ["div.d4r55", "span.X43Kjb", "button.WEBjve"]:
                el = card.query_selector(sel)
                if el:
                    review["author"] = el.inner_text().strip()
                    break

            # Rating
            for sel in ["span[aria-label*='star']", "span[role='img'][aria-label*='star']"]:
                el = card.query_selector(sel)
                if el:
                    label = el.get_attribute("aria-label") or ""
                    nums = re.findall(r"\d+", label)
                    if nums:
                        review["rating"] = int(nums[0])
                    break

            # Date
            for sel in ["span.rsqaWe", "span[class*='dehysf']"]:
                el = card.query_selector(sel)
                if el:
                    review["date"] = el.inner_text().strip()
                    break

            # Text
            for sel in ["span.wiI7pd", "div.Jtu6Td span", "div.MyEned span"]:
                el = card.query_selector(sel)
                if el:
                    review["text"] = el.inner_text().strip()
                    break

            # Only keep if we got at least author or text
            if review.get("author") or review.get("text"):
                reviews.append(review)

        except Exception as e:
            print(f"  Card extraction error: {e}")
            continue

    return reviews


def run(query: str):
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    run_dir = DEBUG_DIR / ts
    run_dir.mkdir(parents=True, exist_ok=True)

    print(f"\n{'='*60}")
    print(f"Step 2: Review Extraction Test")
    print(f"Query: {query}")
    print(f"{'='*60}\n")

    with sync_playwright() as p:
        context = p.chromium.launch_persistent_context(
            PROFILE_DIR,
            headless=False,
            locale="en-US",
            timezone_id="Asia/Kolkata",
            viewport={"width": 1400, "height": 1000},
            args=["--disable-blink-features=AutomationControlled"],
        )

        page = context.pages[0] if context.pages else context.new_page()

        # Phase 1: Navigate to place
        print("[1] Navigating to place...")
        if not navigate_to_place(page, query):
            save_snapshot(page, "nav_failed", run_dir)
            print("  FAIL: Could not reach place page")
            context.close()
            return

        title_el = page.query_selector("h1.DUwDvf") or page.query_selector("h1")
        place_name = title_el.inner_text().strip() if title_el else "Unknown"
        print(f"  Place: {place_name}")
        save_snapshot(page, "1_place_page", run_dir)

        # Check limited view
        html_lower = page.content().lower()
        if "limited view" in html_lower:
            save_snapshot(page, "1_limited_view", run_dir)
            print("  BLOCKED: Limited view. Run step1 more times to build trust.")
            time.sleep(3)
            context.close()
            return

        # Phase 2: Open reviews
        print("\n[2] Opening reviews panel...")
        if not open_reviews(page):
            save_snapshot(page, "2_no_reviews_entry", run_dir)
            print("  FAIL: No reviews entry point found")
            time.sleep(3)
            context.close()
            return

        time.sleep(2)
        save_snapshot(page, "2_reviews_panel", run_dir)
        print("  Reviews panel opened")

        # Phase 3: Extract
        print("\n[3] Extracting visible reviews...")
        reviews = extract_visible_reviews(page)

        save_snapshot(page, "3_extraction_done", run_dir)

        # Save results
        output_path = run_dir / "reviews.json"
        output_path.write_text(json.dumps(reviews, indent=2, ensure_ascii=False), encoding="utf-8")

        # Summary
        print(f"\n{'='*60}")
        print("EXTRACTION RESULT")
        print(f"  Place:    {place_name}")
        print(f"  Reviews:  {len(reviews)}")
        for i, r in enumerate(reviews[:5]):
            author = r.get("author", "?")
            rating = r.get("rating", "?")
            date = r.get("date", "?")
            text = (r.get("text") or "")[:80]
            print(f"  [{i+1}] {author} | {rating}* | {date} | {text}...")
        print(f"  Saved:    {output_path}")
        print(f"{'='*60}")

        if reviews:
            print("\n>>> Extraction PASSED. Ready for step3_scroll.py")
        else:
            print("\n>>> No reviews extracted. Check screenshots + HTML in debug/")

        time.sleep(5)
        context.close()


if __name__ == "__main__":
    place = sys.argv[1] if len(sys.argv) > 1 else "KFC Connaught Place Delhi"
    run(place)
