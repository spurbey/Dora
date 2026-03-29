"""
scraper.py — Main orchestrator

Wires all 9 layers together in the correct order.
Usage:
    python scraper.py --url "https://maps.google.com/?cid=..." [--max-reviews 200]
    python scraper.py --place-id ChIJ... [--max-reviews 200]
"""
import asyncio, argparse, os, sys, time
from typing import Optional, List
from loguru import logger
from dotenv import load_dotenv
from playwright.async_api import async_playwright

from layers import (
    FingerprintManager, ProxyRouter, SessionPolicy,
    Navigator, ChallengeHandler, NetworkSniffer,
    ProtoDecoder, ScrollEngine, DomFallback,
    ReviewParser, DedupeStore, RunMonitor,
    PlaceInfo, Review,
)

load_dotenv()


async def scrape_place(
    url: str,
    max_reviews: int = 200,
    place_id: Optional[str] = None,
) -> dict:
    """
    Full pipeline for one Google Maps place URL.
    Returns summary dict with counts and any errors.
    """
    # Derive place_id from URL if not provided
    if not place_id:
        import re
        m = re.search(r"(?:place/[^/]+/)?(@[-\d.]+,[-\d.]+)", url)
        place_id = re.sub(r"[^a-zA-Z0-9]", "_", url.split("?")[0].split("/")[-1]) or "unknown"

    # ── Init layers ──────────────────────────────────────────────────────────
    fp_manager  = FingerprintManager()
    fp_manager.lock()

    proxy       = ProxyRouter()
    monitor     = RunMonitor()
    store       = DedupeStore()
    parser      = ReviewParser()
    session     = SessionPolicy(proxy, fp_manager)

    metrics = monitor.start_run(place_id)

    async with async_playwright() as pw:
        browser = await pw.chromium.launch(
            headless=True,
            args=[
                "--no-sandbox",
                "--disable-blink-features=AutomationControlled",
                "--disable-dev-shm-usage",
            ],
        )

        context = await session.get_context(browser)
        page = await context.new_page()

        # ── Layer 3 setup: challenge rotation callback ───────────────────────
        async def on_session_rotate():
            nonlocal context, page
            metrics.session_rotated = True
            await page.close()
            context = await session.rotate(browser, mark_proxy_blocked=True)
            page = await context.new_page()

        challenge = ChallengeHandler(page, on_session_rotate=on_session_rotate)

        # ── Layer 4: start network capture ───────────────────────────────────
        sniffer = NetworkSniffer(page)
        proto_reviews: List[Review] = []
        decoder = ProtoDecoder(place_id)

        def on_capture(cap):
            reviews = decoder.decode_response(cap.body)
            if reviews:
                proto_reviews.extend(reviews)
                metrics.proto_extracted += len(reviews)
            metrics.network_captured += 1

        sniffer.on_capture(on_capture)
        await sniffer.start()

        try:
            # ── Layer 2: navigate ────────────────────────────────────────────
            ok = await Navigator(page).goto_place(url)
            if not ok:
                monitor.log_error("Navigation failed")
                return monitor.finish_run(metrics).__dict__

            # ── Layer 3: handle consent/captcha ──────────────────────────────
            resolved = await challenge.handle()
            if not resolved:
                monitor.log_error("Challenge not resolved, session rotated")
                await monitor.take_snapshot(page, "challenge")
                return monitor.finish_run(metrics).__dict__

            nav = Navigator(page)

            # Get total review count from UI for drift detection
            metrics.ui_total = await nav.get_total_review_count()
            place_name = await nav.get_place_name()
            logger.info(f"[main] Place: {place_name} | UI reviews: {metrics.ui_total}")

            # Open reviews tab
            ok = await nav.open_reviews_tab()
            if not ok:
                monitor.log_error("Could not open reviews tab")
                await monitor.take_snapshot(page, "no_reviews_tab")
                return monitor.finish_run(metrics).__dict__

            # Sort by newest
            await nav.sort_by_newest()

            # ── Layer 6a: scroll to load reviews ────────────────────────────
            scroll = ScrollEngine(page, max_reviews=max_reviews)
            visible = await scroll.scroll_to_load_all(target_count=metrics.ui_total)
            logger.info(f"[main] Scroll complete. {visible} cards visible, {len(proto_reviews)} from proto")

            # ── Layer 3: final challenge check after scroll ──────────────────
            await challenge.handle()

            # ── Layer 6b: DOM fallback if proto got nothing ──────────────────
            dom_reviews: List[Review] = []
            if not proto_reviews:
                logger.warning("[main] Proto extraction empty — activating DOM fallback")
                dom_fb = DomFallback(page, place_id)
                dom_reviews = await dom_fb.extract_reviews()
                metrics.dom_extracted = len(dom_reviews)

            # ── Layer 7: merge + normalise ───────────────────────────────────
            all_reviews = parser.merge(proto_reviews, dom_reviews)
            metrics.total_extracted = len(all_reviews)

            # ── Layer 8: upsert to store ─────────────────────────────────────
            if all_reviews:
                place_info = PlaceInfo(
                    place_id=place_id,
                    canonical_url=url,
                    name=place_name or "",
                    total_reviews=metrics.ui_total,
                )
                store.upsert_place(place_info)
                inserted, updated = store.upsert_reviews(all_reviews)
                metrics.stored = inserted + updated

            # Final snapshot
            await monitor.take_snapshot(page, "done")

        except Exception as e:
            monitor.log_error(f"Unhandled exception: {e}")
            logger.exception("[main] Unhandled error")
            await monitor.take_snapshot(page, "error")

        finally:
            await sniffer.stop()
            await page.close()
            await browser.close()

    result = monitor.finish_run(metrics)
    logger.info(f"[main] DB stats: {store.stats()}")
    return result.__dict__


# ── CLI entry point ──────────────────────────────────────────────────────────

async def main():
    parser = argparse.ArgumentParser(description="Google Maps review scraper")
    parser.add_argument("--url", required=True, help="Google Maps place URL")
    parser.add_argument("--max-reviews", type=int, default=200)
    parser.add_argument("--place-id", default=None)
    args = parser.parse_args()

    result = await scrape_place(
        url=args.url,
        max_reviews=args.max_reviews,
        place_id=args.place_id,
    )
    print("\n=== Run Result ===")
    for k, v in result.items():
        print(f"  {k}: {v}")


if __name__ == "__main__":
    asyncio.run(main())