"""Debug: does scrolling the reviews panel trigger card rendering on BrightData?"""
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
DEBUG_DIR = Path(__file__).parent / "debug" / "bd_scroll_debug"
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

        # Navigate to place
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
            page.wait_for_selector("h1.DUwDvf", timeout=15_000)
        except PWTimeout:
            print("Search timed out")
            context.close(); browser.close()
            return
        time.sleep(1)
        print(f"Place: {page.query_selector('h1.DUwDvf').inner_text().strip()}")

        # Click Reviews tab
        buttons = page.query_selector_all("button")
        for btn in buttons:
            try:
                if not btn.is_visible():
                    continue
                aria = (btn.get_attribute("aria-label") or "").lower()
                if aria.startswith("reviews for"):
                    btn.scroll_into_view_if_needed()
                    btn.click()
                    print(f"Clicked reviews tab")
                    break
            except Exception:
                continue

        time.sleep(3)
        page.screenshot(path=str(DEBUG_DIR / "01_after_click.png"))

        # Try scrolling the left panel (div.m6QErb with overflow)
        print("\nAttempting scroll strategies...")

        # Strategy 1: Find scrollable container and scroll via JS
        scroll_result = page.evaluate("""() => {
            // Find the scrollable panel - m6QErb class with overflow
            const panels = document.querySelectorAll('div.m6QErb.DxyBCb');
            if (panels.length === 0) return 'no m6QErb.DxyBCb found';
            const panel = panels[panels.length - 1];
            panel.scrollTop = 500;
            return `scrolled m6QErb.DxyBCb to 500, scrollHeight=${panel.scrollHeight}, clientHeight=${panel.clientHeight}`;
        }""")
        print(f"  Strategy 1 (m6QErb.DxyBCb scroll): {scroll_result}")
        time.sleep(3)

        cards = page.query_selector_all("div[data-review-id]")
        print(f"  After scroll 1: {len(cards)} review cards")
        page.screenshot(path=str(DEBUG_DIR / "02_after_scroll1.png"))

        # Strategy 2: Scroll any scrollable ancestor of the reviews area
        scroll_result2 = page.evaluate("""() => {
            // Try scrolling every scrollable element
            const results = [];
            const all = document.querySelectorAll('div.m6QErb');
            for (const el of all) {
                if (el.scrollHeight > el.clientHeight + 10) {
                    const before = el.scrollTop;
                    el.scrollTop += 400;
                    results.push(`m6QErb scrollHeight=${el.scrollHeight} clientH=${el.clientHeight} scrolled ${before}->${el.scrollTop}`);
                }
            }
            return results.length ? results.join(' | ') : 'no scrollable m6QErb found';
        }""")
        print(f"  Strategy 2 (all m6QErb scroll): {scroll_result2}")
        time.sleep(3)

        cards = page.query_selector_all("div[data-review-id]")
        jft = page.query_selector_all("div.jftiEf")
        print(f"  After scroll 2: {len(cards)} data-review-id, {len(jft)} jftiEf")
        page.screenshot(path=str(DEBUG_DIR / "03_after_scroll2.png"))

        # Strategy 3: Click "Sort" button which may trigger review loading
        print("\n  Strategy 3: Click sort button...")
        sort_btn = page.query_selector('button[aria-label="Sort reviews"]') or \
                   page.query_selector('button[data-value="Sort"]')
        if not sort_btn:
            # Try finding by text
            for b in page.query_selector_all("button"):
                try:
                    t = b.inner_text().strip().lower()
                    if t == "sort" or "sort" in (b.get_attribute("aria-label") or "").lower():
                        if b.is_visible():
                            sort_btn = b
                            break
                except Exception:
                    pass

        if sort_btn:
            sort_btn.click()
            time.sleep(1)
            # Click "Newest" or first menu item
            menu_items = page.query_selector_all('div[role="menuitemradio"], li[role="menuitemradio"]')
            print(f"  Sort menu items: {len(menu_items)}")
            for mi in menu_items:
                try:
                    txt = mi.inner_text().strip()
                    print(f"    - {txt}")
                except Exception:
                    pass
            if len(menu_items) >= 2:
                menu_items[1].click()  # Usually "Newest"
                print("  Clicked sort option")
                time.sleep(5)

            cards = page.query_selector_all("div[data-review-id]")
            jft = page.query_selector_all("div.jftiEf")
            print(f"  After sort: {len(cards)} data-review-id, {len(jft)} jftiEf")
            page.screenshot(path=str(DEBUG_DIR / "04_after_sort.png"))
        else:
            print("  Sort button not found")

        # Strategy 4: mouse wheel on the panel
        print("\n  Strategy 4: mouse wheel...")
        page.mouse.move(300, 500)
        page.mouse.wheel(0, 600)
        time.sleep(3)
        cards = page.query_selector_all("div[data-review-id]")
        jft = page.query_selector_all("div.jftiEf")
        print(f"  After wheel: {len(cards)} data-review-id, {len(jft)} jftiEf")
        page.screenshot(path=str(DEBUG_DIR / "05_after_wheel.png"))

        # Final HTML dump
        html = page.content()
        (DEBUG_DIR / "final.html").write_text(html, encoding="utf-8")

        print(f"\nDebug saved to: {DEBUG_DIR}")
        context.close()
        browser.close()


if __name__ == "__main__":
    run()
