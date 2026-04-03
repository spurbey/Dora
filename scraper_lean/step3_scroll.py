"""
Step 3: Scroll + Extract More Reviews

Only run AFTER step2_extract.py confirms you can get visible reviews.

Goal: Scroll the reviews container to load more, extract up to N reviews.
Scrolls the inner container (not the window), detects stale/end conditions.

Run: python step3_scroll.py "KFC Connaught Place Delhi" --max 50
"""

import sys
import re
import time
import json
import argparse

if sys.stdout.encoding != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
from pathlib import Path
from datetime import datetime
from playwright.sync_api import sync_playwright

PROFILE_DIR = str(Path(__file__).parent / "profile")
DEBUG_DIR = Path(__file__).parent / "debug"


def save_snapshot(page, label: str, run_dir: Path):
    safe = re.sub(r"[^a-zA-Z0-9_]", "_", label)
    page.screenshot(path=str(run_dir / f"{safe}.png"), full_page=True)


def navigate_to_place(page, query: str) -> bool:
    page.goto("https://www.google.com/maps?hl=en", wait_until="domcontentloaded", timeout=30_000)
    time.sleep(2)
    for sel in ['button[aria-label*="Accept all"]', 'button[aria-label*="Accept"]', '#L2AGLb']:
        try:
            btn = page.query_selector(sel)
            if btn and btn.is_visible():
                btn.click()
                time.sleep(1.5)
                break
        except Exception:
            pass

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

    # Check if we landed directly on a place (not search results)
    title = page.query_selector("h1.DUwDvf")
    if title and title.inner_text().strip():
        return True

    # We're on search results — click first result
    for sel in ['a.hfpxzc[href*="/maps/place/"]', "div.Nv2PK a", "div.Nv2PK"]:
        try:
            for r in page.query_selector_all(sel)[:5]:
                if r.is_visible():
                    r.click()
                    time.sleep(3)
                    place_title = page.query_selector("h1.DUwDvf")
                    if place_title and place_title.inner_text().strip():
                        return True
        except Exception:
            pass
    return False


def open_reviews(page) -> bool:
    for btn in page.query_selector_all("button"):
        try:
            if not btn.is_visible():
                continue
            aria = (btn.get_attribute("aria-label") or "").lower()
            role = (btn.get_attribute("role") or "").lower()
            text = (btn.inner_text() or "").lower()

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
                time.sleep(2)
                return True
        except Exception:
            continue
    return False


def find_scroll_container(page):
    """Find the scrollable reviews container.

    Google Maps reviews live inside a scrollable div that is NOT the window.
    We need the innermost scrollable ancestor of the review cards.
    """
    # Try to find the scrollable parent by checking overflow style
    container_sel = page.evaluate("""
        () => {
            const card = document.querySelector('div[data-review-id]');
            if (!card) return null;
            let el = card.parentElement;
            while (el && el !== document.body) {
                const style = getComputedStyle(el);
                if ((style.overflowY === 'auto' || style.overflowY === 'scroll')
                    && el.scrollHeight > el.clientHeight) {
                    // Build a unique selector
                    if (el.id) return '#' + el.id;
                    const classes = Array.from(el.classList).join('.');
                    return el.tagName.toLowerCase() + (classes ? '.' + classes : '');
                }
                el = el.parentElement;
            }
            return null;
        }
    """)
    if container_sel:
        return container_sel

    # Fallback to known selectors
    for sel in [
        "div.m6QErb.DxyBCb.kA9KIf.dS8AEf",
        "div.m6QErb[aria-label]",
        'div[role="feed"]',
    ]:
        el = page.query_selector(sel)
        if el:
            return sel
    return None


def count_review_cards(page) -> int:
    """Count unique review cards by data-review-id (Google renders dupes for translations)."""
    return page.evaluate("""
        () => {
            const cards = document.querySelectorAll('div[data-review-id]');
            const ids = new Set();
            cards.forEach(c => ids.add(c.getAttribute('data-review-id')));
            return ids.size;
        }
    """)


def scroll_reviews(page, container_sel: str, max_reviews: int) -> int:
    """Scroll the reviews container until max reached or no new cards load."""
    import random

    prev_count = 0
    stale_rounds = 0
    max_stale = 5

    print(f"  Scrolling for up to {max_reviews} reviews...")

    while True:
        current = count_review_cards(page)
        print(f"    Cards: {current}", end="")

        if current >= max_reviews:
            print(" — target reached")
            break

        if current == prev_count:
            stale_rounds += 1
            print(f" (stale {stale_rounds}/{max_stale})", end="")
            if stale_rounds >= max_stale:
                print(" — no more loading")
                break
        else:
            stale_rounds = 0

        prev_count = current
        print()

        # Scroll every scrollable ancestor of review cards (Google nests them)
        scroll_px = random.randint(800, 1400)
        page.evaluate(f"""(() => {{
            const card = document.querySelector('div[data-review-id]');
            if (!card) return;
            let el = card.parentElement;
            let scrolled = false;
            while (el && el !== document.body) {{
                const style = getComputedStyle(el);
                const isScrollable = el.scrollHeight > el.clientHeight + 10;
                const hasOverflow = style.overflowY === 'auto' || style.overflowY === 'scroll'
                    || style.overflow === 'auto' || style.overflow === 'scroll';
                if (isScrollable || hasOverflow) {{
                    el.scrollTop = el.scrollHeight;
                    scrolled = true;
                }}
                el = el.parentElement;
            }}
            if (!scrolled) window.scrollBy(0, {scroll_px});
        }})()""")

        # Human-like delay
        time.sleep(random.uniform(1.5, 3.0))

    return count_review_cards(page)


def extract_all_reviews(page) -> list[dict]:
    reviews = []
    seen_ids = set()
    cards = page.query_selector_all("div[data-review-id]")

    for card in cards:
        review = {}
        try:
            rid = card.get_attribute("data-review-id") or ""
            if rid in seen_ids:
                continue  # Skip duplicate (translation variant)
            seen_ids.add(rid)
            review["review_id"] = rid

            for sel in ["div.d4r55", "span.X43Kjb", "button.WEBjve"]:
                el = card.query_selector(sel)
                if el:
                    review["author"] = el.inner_text().strip()
                    break

            for sel in ["span[aria-label*='star']", "span[role='img'][aria-label*='star']"]:
                el = card.query_selector(sel)
                if el:
                    label = el.get_attribute("aria-label") or ""
                    nums = re.findall(r"\d+", label)
                    if nums:
                        review["rating"] = int(nums[0])
                    break

            for sel in ["span.rsqaWe", "span[class*='dehysf']"]:
                el = card.query_selector(sel)
                if el:
                    review["date"] = el.inner_text().strip()
                    break

            # Expand truncated reviews first
            more_btns = card.query_selector_all('button[aria-label="See more"]')
            for mb in more_btns:
                try:
                    if mb.is_visible():
                        mb.click()
                        time.sleep(0.3)
                except Exception:
                    pass

            for sel in ["span.wiI7pd", "div.Jtu6Td span", "div.MyEned span"]:
                el = card.query_selector(sel)
                if el:
                    review["text"] = el.inner_text().strip()
                    break

            # Owner response
            owner_el = card.query_selector("div.CDe7pd span")
            if owner_el:
                review["owner_response"] = owner_el.inner_text().strip()

            if review.get("author") or review.get("text"):
                reviews.append(review)

        except Exception:
            continue

    return reviews


def run(query: str, max_reviews: int):
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    run_dir = DEBUG_DIR / ts
    run_dir.mkdir(parents=True, exist_ok=True)

    print(f"\n{'='*60}")
    print(f"Step 3: Scroll + Extract")
    print(f"Query: {query} | Max: {max_reviews}")
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

        # Navigate
        print("[1] Navigating...")
        if not navigate_to_place(page, query):
            print("  FAIL: navigation")
            context.close()
            return

        title = (page.query_selector("h1.DUwDvf") or page.query_selector("h1"))
        place = title.inner_text().strip() if title else "Unknown"
        print(f"  Place: {place}")

        if "limited view" in page.content().lower():
            print("  BLOCKED: limited view")
            context.close()
            return

        # Open reviews
        print("\n[2] Opening reviews...")
        if not open_reviews(page):
            save_snapshot(page, "no_reviews", run_dir)
            print("  FAIL: no reviews entry")
            context.close()
            return
        time.sleep(1)

        # Find scroll container
        print("\n[3] Finding scroll container...")
        container = find_scroll_container(page)
        if container:
            print(f"  Container: {container}")
        else:
            print("  WARNING: No specific container found, will try window scroll")
            container = "document.documentElement"

        # Scroll
        print("\n[4] Scrolling reviews...")
        final_count = scroll_reviews(page, container, max_reviews)
        save_snapshot(page, "4_scroll_done", run_dir)

        # Extract
        print(f"\n[5] Extracting {final_count} reviews...")
        reviews = extract_all_reviews(page)

        # Save
        output = run_dir / "reviews.json"
        output.write_text(json.dumps(reviews, indent=2, ensure_ascii=False), encoding="utf-8")

        # Summary
        print(f"\n{'='*60}")
        print(f"RESULT: {len(reviews)} reviews extracted from '{place}'")
        print(f"  Saved: {output}")
        for i, r in enumerate(reviews[:5]):
            a = r.get("author", "?")
            rt = r.get("rating", "?")
            d = r.get("date", "?")
            t = (r.get("text") or "")[:60]
            print(f"  [{i+1}] {a} | {rt}* | {d} | {t}...")
        if len(reviews) > 5:
            print(f"  ... and {len(reviews) - 5} more")
        print(f"{'='*60}")

        time.sleep(5)
        context.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("query", nargs="?", default="India Gate New Delhi")
    parser.add_argument("--max", type=int, default=50)
    args = parser.parse_args()
    run(args.query, args.max)
