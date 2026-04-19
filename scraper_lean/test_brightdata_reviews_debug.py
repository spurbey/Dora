"""Debug: what does BrightData render after clicking Reviews tab?"""
import sys, os, time, re
if sys.stdout.encoding != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
from pathlib import Path
from playwright.sync_api import sync_playwright, TimeoutError as PWTimeout

try:
    from dotenv import load_dotenv
    load_dotenv(Path(__file__).parent / ".env")
except ImportError:
    pass

BRIGHTDATA_WS = os.getenv("BRIGHTDATA_WS_ENDPOINT", "")
DEBUG_DIR = Path(__file__).parent / "debug" / "bd_reviews_debug"
DEBUG_DIR.mkdir(parents=True, exist_ok=True)
QUERY = "Malaka Spice Koregaon Park Pune"


def run():
    with sync_playwright() as p:
        print("Connecting to BrightData...")
        browser = p.chromium.connect_over_cdp(BRIGHTDATA_WS)
        context = browser.contexts[0] if browser.contexts else browser.new_context(
            locale="en-US", viewport={"width": 1400, "height": 1000},
        )
        page = context.pages[0] if context.pages else context.new_page()

        # Navigate
        page.goto("https://www.google.com/maps?hl=en", wait_until="domcontentloaded", timeout=30_000)
        time.sleep(1)
        for sel in ['button[aria-label*="Accept all"]', '#L2AGLb']:
            try:
                btn = page.query_selector(sel)
                if btn and btn.is_visible():
                    btn.click()
                    time.sleep(1)
                    break
            except Exception:
                pass

        box = page.query_selector("input#searchboxinput") or page.query_selector('input[name="q"]')
        box.click()
        box.fill("")
        box.type(QUERY, delay=40)
        page.keyboard.press("Enter")

        try:
            page.wait_for_selector("h1.DUwDvf, a.hfpxzc", timeout=15_000)
        except PWTimeout:
            print("Search timed out")
            context.close()
            browser.close()
            return
        time.sleep(1)

        title_el = page.query_selector("h1.DUwDvf")
        if not title_el:
            print("No place found")
            context.close()
            browser.close()
            return
        print(f"Place: {title_el.inner_text().strip()}")

        # Find and click reviews
        buttons = page.query_selector_all("button")
        clicked = False
        for btn in buttons:
            try:
                if not btn.is_visible():
                    continue
                aria = (btn.get_attribute("aria-label") or "").lower()
                if aria.startswith("reviews for") or aria.startswith("reviews"):
                    if "write" not in aria and "add" not in aria:
                        print(f"Clicking: aria='{aria}'")
                        btn.scroll_into_view_if_needed()
                        btn.click()
                        clicked = True
                        break
            except Exception:
                continue

        if not clicked:
            print("Reviews button not found")
            context.close()
            browser.close()
            return

        # Wait progressively and snapshot at each point
        for wait_s in [2, 5, 8, 12]:
            print(f"\nAfter {wait_s}s wait:")
            time.sleep(wait_s if wait_s == 2 else (wait_s - 2))  # cumulative

            # Check for review cards
            cards_rid = page.query_selector_all("div[data-review-id]")
            cards_jftiEf = page.query_selector_all("div.jftiEf")
            feed = page.query_selector('div[role="feed"]')
            feed_children = feed.query_selector_all(":scope > div") if feed else []

            print(f"  div[data-review-id]: {len(cards_rid)}")
            print(f"  div.jftiEf: {len(cards_jftiEf)}")
            print(f"  div[role='feed']: {'YES' if feed else 'NO'} ({len(feed_children)} children)")

            # Check what tab is active
            tabs = page.query_selector_all("button[role='tab']")
            for tab in tabs:
                try:
                    t_aria = tab.get_attribute("aria-label") or ""
                    t_sel = tab.get_attribute("aria-selected") or ""
                    t_text = tab.inner_text().strip()
                    if "review" in t_aria.lower() or "review" in t_text.lower():
                        print(f"  Reviews tab: aria-selected='{t_sel}'")
                except Exception:
                    pass

            page.screenshot(path=str(DEBUG_DIR / f"after_{wait_s}s.png"))

        # Dump HTML snippet around reviews area
        html = page.content()
        (DEBUG_DIR / "full_page.html").write_text(html, encoding="utf-8")

        # Look for any div that might contain reviews
        print("\n--- Searching for review-like containers ---")
        for sel in [
            "div[data-review-id]",
            "div.jftiEf",
            'div[role="feed"]',
            "div.m6QErb",
            "div.DxyBCb",
            "div[jsaction*='review']",
            "div.fontBodyMedium",
        ]:
            els = page.query_selector_all(sel)
            if els:
                print(f"  {sel}: {len(els)} found")

        context.close()
        browser.close()
        print(f"\nDebug saved to: {DEBUG_DIR}")


if __name__ == "__main__":
    run()
