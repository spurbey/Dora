"""
Step 1: Page Acquisition Test

Goal: Can we reach the FULL place page (not limited view) with Reviews tab visible?

Strategy:
  - Persistent context (preserves cookies/storage across runs — builds trust)
  - Headed mode (visible browser — Google is less suspicious)
  - Search-click flow (more human-like than direct URL)
  - Screenshot + HTML snapshot every step for diagnosis

Success criteria:
  - Place title visible
  - Reviews tab/button exists in DOM
  - NOT "limited view"

Run: python step1_acquire.py "Taj Mahal Agra"
Run again to build cookie/profile trust over multiple runs.
"""

import sys
import time
import re
from pathlib import Path
from datetime import datetime
from playwright.sync_api import sync_playwright, TimeoutError as PWTimeout

PROFILE_DIR = str(Path(__file__).parent / "profile")
DEBUG_DIR = Path(__file__).parent / "debug"


def save_snapshot(page, label: str, run_dir: Path):
    """Save screenshot + HTML for debugging."""
    safe = re.sub(r"[^a-zA-Z0-9_]", "_", label)
    page.screenshot(path=str(run_dir / f"{safe}.png"), full_page=True)
    (run_dir / f"{safe}.html").write_text(page.content(), encoding="utf-8")
    print(f"  [snapshot] {safe}.png + .html saved")


def find_reviews_entry(page) -> dict:
    """
    Scan all buttons for a reviews entry point.
    Returns {found: bool, element, label} or {found: False, all_buttons: [...]}.
    """
    buttons = page.query_selector_all("button")
    all_labels = []

    for btn in buttons:
        try:
            text = (btn.inner_text() or "").strip()
            aria = btn.get_attribute("aria-label") or ""
            role = btn.get_attribute("role") or ""
            visible = btn.is_visible()
            label = f"text='{text}' | aria='{aria}' | role='{role}' | visible={visible}"
            all_labels.append(label)

            if not visible:
                continue

            # Match: "Reviews for ...", "Reviews", tab with "review" in aria
            aria_lower = aria.lower()
            text_lower = text.lower()

            if aria_lower.startswith("reviews for") or aria_lower.startswith("reviews"):
                # Exclude "Write a review" type buttons
                if "write" not in aria_lower and "add" not in aria_lower:
                    return {"found": True, "element": btn, "label": label}

            if role == "tab" and "review" in aria_lower:
                if "write" not in aria_lower:
                    return {"found": True, "element": btn, "label": label}

            # Also check tab text content
            if role == "tab" and "review" in text_lower:
                if "write" not in text_lower:
                    return {"found": True, "element": btn, "label": label}

        except Exception:
            continue

    return {"found": False, "all_buttons": all_labels}


def check_limited_view(page) -> bool:
    """Check if Google is serving the stripped limited view."""
    html = page.content().lower()
    markers = [
        "you're seeing a limited view",
        "limited view of google maps",
        "learn more about limited view",
    ]
    return any(m in html for m in markers)


def get_place_title(page) -> str | None:
    """Get the place title from the page."""
    for sel in ["h1.DUwDvf", 'h1[class*="fontHeadline"]', "h1"]:
        try:
            el = page.query_selector(sel)
            if el:
                text = el.inner_text().strip()
                if text:
                    return text
        except Exception:
            pass
    return None


def run(query: str):
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    run_dir = DEBUG_DIR / ts
    run_dir.mkdir(parents=True, exist_ok=True)

    print(f"\n{'='*60}")
    print(f"Step 1: Page Acquisition Test")
    print(f"Query: {query}")
    print(f"Debug: {run_dir}")
    print(f"{'='*60}\n")

    with sync_playwright() as p:
        # Persistent context — this is the key difference from scraper_gmaps
        # Preserves cookies, localStorage, history across runs
        # Each run builds more "trust" with Google
        context = p.chromium.launch_persistent_context(
            PROFILE_DIR,
            headless=False,
            locale="en-US",
            timezone_id="Asia/Kolkata",
            viewport={"width": 1400, "height": 1000},
            args=[
                "--disable-blink-features=AutomationControlled",
            ],
        )

        page = context.pages[0] if context.pages else context.new_page()

        # --- Phase A: Open Maps home ---
        print("[A] Opening Google Maps...")
        try:
            page.goto(
                "https://www.google.com/maps?hl=en",
                wait_until="domcontentloaded",
                timeout=30_000,
            )
            time.sleep(2)

            # Handle consent dialog if present
            for sel in [
                'button[aria-label*="Accept all"]',
                'button[aria-label*="Accept"]',
                '#L2AGLb',
            ]:
                try:
                    btn = page.query_selector(sel)
                    if btn and btn.is_visible():
                        btn.click()
                        print("  [consent] Dismissed cookie dialog")
                        time.sleep(1.5)
                        break
                except Exception:
                    pass

            save_snapshot(page, "A_maps_home", run_dir)
            print("  [A] Maps home loaded OK")

        except PWTimeout:
            save_snapshot(page, "A_maps_home_timeout", run_dir)
            print("  [A] FAIL: Maps home timed out")
            context.close()
            return

        # --- Phase B: Search for place ---
        print(f"\n[B] Searching for: {query}")
        search_box = None
        for sel in [
            "input#searchboxinput",
            'input[name="q"]',
            'input[aria-label*="Search Google Maps" i]',
            'input.UGojuc',
        ]:
            try:
                search_box = page.query_selector(sel)
                if search_box:
                    break
            except Exception:
                pass

        if not search_box:
            save_snapshot(page, "B_no_search_box", run_dir)
            print("  [B] FAIL: Search box not found")
            context.close()
            return

        search_box.click()
        search_box.fill("")
        time.sleep(0.2)
        search_box.type(query, delay=50)
        time.sleep(0.3)
        page.keyboard.press("Enter")
        time.sleep(3)
        save_snapshot(page, "B_search_results", run_dir)
        print("  [B] Search executed")

        # --- Phase C: Click into place (if we landed on search results) ---
        print("\n[C] Checking page state...")

        title = get_place_title(page)
        if title:
            print(f"  [C] Direct place hit: '{title}'")
        else:
            # We might be on search results — click first result
            print("  [C] No place title yet, trying to click first result...")
            result_selectors = [
                "div.Nv2PK",
                'a.hfpxzc[href*="/maps/place/"]',
            ]
            clicked = False
            for sel in result_selectors:
                try:
                    results = page.query_selector_all(sel)
                    for r in results[:3]:
                        if r.is_visible():
                            r.click()
                            clicked = True
                            break
                except Exception:
                    pass
                if clicked:
                    break

            if clicked:
                time.sleep(3)
                title = get_place_title(page)
                print(f"  [C] Clicked result, place: '{title}'")
            else:
                save_snapshot(page, "C_no_results", run_dir)
                print("  [C] FAIL: No clickable results found")

        save_snapshot(page, "C_place_page", run_dir)

        # --- Phase D: Diagnose page state ---
        print("\n[D] Diagnosing page state...")

        is_limited = check_limited_view(page)
        print(f"  Limited view: {is_limited}")
        print(f"  Place title: {title or 'NOT FOUND'}")
        print(f"  URL: {page.url}")

        # --- Phase E: Find Reviews entry ---
        print("\n[E] Looking for Reviews entry point...")
        result = find_reviews_entry(page)

        if result["found"]:
            print(f"  [E] FOUND Reviews entry: {result['label']}")
            save_snapshot(page, "E_reviews_found", run_dir)
        else:
            print(f"  [E] NO Reviews entry found.")
            print(f"  All buttons on page ({len(result['all_buttons'])}):")
            for i, label in enumerate(result["all_buttons"]):
                print(f"    [{i}] {label}")
            save_snapshot(page, "E_no_reviews", run_dir)

        # --- Summary ---
        print(f"\n{'='*60}")
        print("RESULT SUMMARY")
        print(f"  Place title:    {title or 'MISSING'}")
        print(f"  Limited view:   {is_limited}")
        print(f"  Reviews entry:  {'YES' if result['found'] else 'NO'}")
        print(f"  Final URL:      {page.url}")
        print(f"  Debug folder:   {run_dir}")
        print(f"{'='*60}")

        if result["found"]:
            print("\n>>> Page acquisition PASSED. Ready for step2_extract.py")
        elif is_limited:
            print("\n>>> BLOCKED: Limited view. Run again to build profile trust.")
            print("    Or manually browse Maps in the profile/ browser to build cookies.")
        else:
            print("\n>>> Page loaded but no reviews entry. Check screenshots.")

        # Keep browser open briefly so you can inspect
        print("\nBrowser stays open 5s for inspection...")
        time.sleep(5)
        context.close()


if __name__ == "__main__":
    place = sys.argv[1] if len(sys.argv) > 1 else "Taj Mahal Agra"
    run(place)
