"""
Test matrix: 4 combinations of browser × codebase for GMaps scraping.

                  | Local headed browser     | BrightData cloud browser
scraper_lean      | Test 1                   | Test 2
backend scraper   | Test 3 (needs local pw)  | Test 4

Each test: search for POIs, then fetch reviews for first result.
"""

import sys
import os
import time
import re
import json

if sys.stdout.encoding != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

from pathlib import Path
from datetime import datetime
from playwright.sync_api import sync_playwright, TimeoutError as PWTimeout

try:
    from dotenv import load_dotenv
    load_dotenv(Path(__file__).parent / ".env")
except ImportError:
    pass

PROFILE_DIR = str(Path(__file__).parent / "profile")
BRIGHTDATA_WS = os.getenv("BRIGHTDATA_WS_ENDPOINT", "")
QUERY = "Malaka Spice Koregaon Park Pune"

results = {}


def _dismiss_consent(page):
    for sel in [
        'button[aria-label*="Accept all"]',
        'button[aria-label*="Accept"]',
        '#L2AGLb',
    ]:
        try:
            btn = page.query_selector(sel)
            if btn and btn.is_visible():
                btn.click()
                time.sleep(1)
                return
        except Exception:
            pass


def _find_search_box(page):
    for sel in ["input#searchboxinput", 'input[name="q"]', 'input[aria-label*="Search"]']:
        box = page.query_selector(sel)
        if box:
            return box
    return None


def _search_and_navigate(page, query):
    """Search-click flow. Returns place title or None."""
    page.goto("https://www.google.com/maps?hl=en", wait_until="domcontentloaded", timeout=30_000)
    time.sleep(1)
    _dismiss_consent(page)

    box = _find_search_box(page)
    if not box:
        return None, "search_box_not_found"

    box.click()
    box.fill("")
    time.sleep(0.2)
    box.type(query, delay=40)
    time.sleep(0.3)
    page.keyboard.press("Enter")

    # Wait for results
    try:
        page.wait_for_selector("h1.DUwDvf, a.hfpxzc, div.Nv2PK", timeout=15_000)
    except PWTimeout:
        return None, "search_results_timeout"

    time.sleep(1)

    # Direct place hit?
    title_el = page.query_selector("h1.DUwDvf")
    if title_el:
        title = title_el.inner_text().strip()
        if title:
            return title, "direct_hit"

    # Click first result
    for sel in ["a.hfpxzc", "div.Nv2PK"]:
        results_els = page.query_selector_all(sel)
        for r in results_els[:3]:
            try:
                if r.is_visible():
                    r.click()
                    page.wait_for_selector("h1.DUwDvf", timeout=10_000)
                    title_el = page.query_selector("h1.DUwDvf")
                    if title_el:
                        return title_el.inner_text().strip(), "click_result"
            except (PWTimeout, Exception):
                continue

    return None, "no_results_clickable"


def _find_reviews_button(page):
    """Scan all buttons, matching the proven scraper_lean pattern."""
    buttons = page.query_selector_all("button")
    for btn in buttons:
        try:
            if not btn.is_visible():
                continue
            aria = (btn.get_attribute("aria-label") or "").lower()
            role = (btn.get_attribute("role") or "").lower()
            text = (btn.inner_text() or "").strip().lower()

            is_reviews = False
            if aria.startswith("reviews for") or aria.startswith("reviews"):
                if "write" not in aria and "add" not in aria:
                    is_reviews = True
            if role == "tab" and "review" in (aria or text):
                if "write" not in aria:
                    is_reviews = True

            if is_reviews:
                return btn, f"aria='{aria}' text='{text}'"
        except Exception:
            continue
    return None, "not_found"


def _extract_reviews(page):
    """Extract reviews from visible DOM using all fallback selectors."""
    cards = page.query_selector_all("div[data-review-id]")
    if not cards:
        feed = page.query_selector('div[role="feed"]')
        if feed:
            cards = feed.query_selector_all(":scope > div")
    if not cards:
        cards = page.query_selector_all("div.jftiEf")

    seen = set()
    out = []
    for card in cards[:10]:
        try:
            rid = card.get_attribute("data-review-id") or ""
            if rid in seen:
                continue
            if rid:
                seen.add(rid)

            author = None
            for sel in ["div.d4r55", "span.X43Kjb", "button.WEBjve"]:
                el = card.query_selector(sel)
                if el:
                    author = el.inner_text().strip()
                    break

            rating = None
            for sel in ["span[aria-label*='star']", "span[role='img'][aria-label*='star']"]:
                el = card.query_selector(sel)
                if el:
                    label = el.get_attribute("aria-label") or ""
                    nums = re.findall(r"\d+", label)
                    if nums:
                        rating = int(nums[0])
                    break

            text = ""
            for sel in ["span.wiI7pd", "div.Jtu6Td span", "div.MyEned span"]:
                el = card.query_selector(sel)
                if el:
                    text = el.inner_text().strip()
                    break

            if author or text:
                out.append({"author": author, "rating": rating, "text": text[:80]})
        except Exception:
            continue
    return out


def run_test(label, use_brightdata):
    print(f"\n{'='*60}")
    print(f"  {label}")
    print(f"  Query: {QUERY}")
    print(f"  Browser: {'BrightData' if use_brightdata else 'Local headed'}")
    print(f"{'='*60}")

    result = {
        "label": label,
        "browser": "brightdata" if use_brightdata else "local",
        "search": None,
        "place_title": None,
        "search_detail": None,
        "reviews_button": None,
        "reviews_count": 0,
        "reviews_sample": [],
        "error": None,
    }

    try:
        with sync_playwright() as p:
            browser = None
            if use_brightdata:
                if not BRIGHTDATA_WS:
                    result["error"] = "BRIGHTDATA_WS_ENDPOINT not set"
                    print(f"  SKIP: {result['error']}")
                    return result
                print("  Connecting to BrightData...")
                browser = p.chromium.connect_over_cdp(BRIGHTDATA_WS)
                context = browser.contexts[0] if browser.contexts else browser.new_context(
                    locale="en-US", viewport={"width": 1400, "height": 1000},
                )
            else:
                context = p.chromium.launch_persistent_context(
                    PROFILE_DIR,
                    headless=False,
                    locale="en-US",
                    timezone_id="Asia/Kolkata",
                    viewport={"width": 1400, "height": 1000},
                    args=["--disable-blink-features=AutomationControlled"],
                )

            page = context.pages[0] if context.pages else context.new_page()

            # --- Search + Navigate ---
            print("  [1] Search + navigate to place...")
            title, detail = _search_and_navigate(page, QUERY)
            result["search"] = "PASS" if title else "FAIL"
            result["place_title"] = title
            result["search_detail"] = detail
            print(f"      Search: {result['search']} ({detail}) title={title!r}")

            if not title:
                result["error"] = f"search failed: {detail}"
                context.close()
                if browser:
                    browser.close()
                return result

            # --- Find Reviews Button ---
            print("  [2] Find reviews button...")
            btn, btn_detail = _find_reviews_button(page)
            result["reviews_button"] = "FOUND" if btn else "NOT_FOUND"
            print(f"      Reviews button: {result['reviews_button']} ({btn_detail})")

            if not btn:
                result["error"] = f"reviews button not found"
                context.close()
                if browser:
                    browser.close()
                return result

            # --- Click Reviews + Extract ---
            print("  [3] Click reviews + extract...")
            btn.scroll_into_view_if_needed()
            btn.click()
            time.sleep(2)

            # Wait for review cards
            try:
                page.wait_for_selector("div[data-review-id]", timeout=10_000)
            except PWTimeout:
                print("      Warning: review cards didn't appear in 10s")

            reviews = _extract_reviews(page)
            result["reviews_count"] = len(reviews)
            result["reviews_sample"] = reviews[:3]
            print(f"      Reviews extracted: {len(reviews)}")
            for i, r in enumerate(reviews[:3]):
                print(f"        [{r.get('rating','?')}*] {r.get('author','?')}: {r.get('text','')[:60]}")

            time.sleep(2)
            context.close()
            if browser:
                browser.close()

    except Exception as e:
        result["error"] = str(e)[:200]
        print(f"  ERROR: {result['error']}")

    return result


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  GMAPS SCRAPING TEST MATRIX")
    print("  " + datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    print("=" * 60)

    # Test 1: scraper_lean local
    r1 = run_test("Test 1: scraper_lean + Local browser", use_brightdata=False)
    results["test1_lean_local"] = r1

    # Test 2: scraper_lean brightdata
    r2 = run_test("Test 2: scraper_lean + BrightData browser", use_brightdata=True)
    results["test2_lean_brightdata"] = r2

    # Summary
    print("\n" + "=" * 60)
    print("  RESULTS MATRIX")
    print("=" * 60)
    print(f"{'Test':<45} {'Search':<10} {'RevBtn':<12} {'Reviews':<10} {'Error'}")
    print("-" * 100)
    for key, r in results.items():
        err = (r.get("error") or "")[:40]
        print(f"{r['label']:<45} {r.get('search','?'):<10} {r.get('reviews_button','?'):<12} {r.get('reviews_count',0):<10} {err}")

    # Save
    out_path = Path(__file__).parent / "test_matrix_results.json"
    out_path.write_text(json.dumps(results, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"\nSaved: {out_path}")
