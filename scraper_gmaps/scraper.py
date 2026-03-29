"""
scraper.py - Main orchestrator

Wires all layers together with a page-acquisition-first flow:
1) acquire full place UI
2) open reviews
3) extract
"""
import argparse
import asyncio
import os
from typing import List, Optional

from dotenv import load_dotenv
from loguru import logger
from playwright.async_api import async_playwright

from layers import (
    ChallengeHandler,
    DedupeStore,
    DomFallback,
    FingerprintManager,
    Navigator,
    NetworkSniffer,
    PlaceInfo,
    ProtoDecoder,
    ProxyRouter,
    Review,
    ReviewParser,
    RunMonitor,
    ScrollEngine,
    SessionPolicy,
)
from layers.navigator import PageState

load_dotenv()


async def scrape_place(
    url: str,
    max_reviews: int = 200,
    place_id: Optional[str] = None,
) -> dict:
    """Full pipeline for one Google Maps place URL."""

    if not place_id:
        import re

        m = re.search(r"/place/([^/@]+)", url)
        if m:
            place_id = re.sub(r"[^a-zA-Z0-9_]", "_", m.group(1))
        else:
            place_id = "unknown_place"

    place_query = place_id.replace("_", " ")

    fp_manager = FingerprintManager()
    fp_manager.lock()
    proxy = ProxyRouter()
    monitor = RunMonitor()
    store = DedupeStore()
    parser = ReviewParser()
    session = SessionPolicy(proxy, fp_manager)

    metrics = monitor.start_run(place_id)
    headless = os.getenv("MAPS_HEADLESS", "true").lower() == "true"

    async with async_playwright() as pw:
        browser = await pw.chromium.launch(
            headless=headless,
            args=[
                "--no-sandbox",
                "--disable-blink-features=AutomationControlled",
                "--disable-dev-shm-usage",
            ],
        )

        context = await session.get_context(browser)
        page = await context.new_page()

        nav = Navigator(page, timeout=15_000)
        challenge: Optional[ChallengeHandler] = None
        sniffer: Optional[NetworkSniffer] = None

        async def on_session_rotate():
            nonlocal context, page, challenge, sniffer
            metrics.session_rotated = True
            try:
                if sniffer:
                    await sniffer.stop()
            except Exception:
                pass

            try:
                await page.close()
            except Exception:
                pass

            context = await session.rotate(browser, mark_proxy_blocked=True)
            page = await context.new_page()

            nav.page = page
            if challenge:
                challenge.page = page
            if sniffer:
                sniffer.page = page
                await sniffer.start()

        challenge = ChallengeHandler(page, on_session_rotate=on_session_rotate)

        sniffer = NetworkSniffer(page)
        proto_reviews: List[Review] = []
        decoder = ProtoDecoder(place_id)

        def on_capture(cap):
            reviews = decoder.decode_response(cap.body)
            if reviews:
                proto_reviews.extend(reviews)
                metrics.proto_extracted += len(reviews)
                logger.info(
                    f"[main] Proto decoded {len(reviews)} reviews "
                    f"(total so far: {len(proto_reviews)})"
                )
            metrics.network_captured += 1

        sniffer.on_capture(on_capture)
        await sniffer.start()

        async def update_acquisition_metrics():
            state = await nav.classify_page_state()
            metrics.page_state = state.value
            metrics.final_url = page.url
            metrics.limited_view_found = state == PageState.LIMITED_PLACE
            metrics.search_results_found = state == PageState.SEARCH_RESULTS
            place_name_local = await nav.get_place_name()
            metrics.place_title_found = bool(place_name_local)
            metrics.reviews_entry_found = await nav.has_reviews_entrypoint()
            return state, place_name_local

        try:
            # 1) Acquire place page
            ok = await nav.goto_place(url)
            if not ok:
                logger.warning("[main] Direct URL path failed; trying search-click flow")
                ok = await nav.recover_full_place_via_search(
                    query=place_query, place_hint=place_query
                )
                if not ok:
                    monitor.log_error("Serving failure: could not acquire place page")
                    await monitor.take_snapshot(page, "serving_nav_failed")
                    return monitor.finish_run(metrics).__dict__

            # 2) Resolve interrupts
            resolved = await challenge.handle()
            if not resolved:
                monitor.log_error("Challenge not resolved")
                await monitor.take_snapshot(page, "challenge")
                return monitor.finish_run(metrics).__dict__

            # 3) Classify and recover if wrong variant
            state, place_name = await update_acquisition_metrics()
            if state in (PageState.LIMITED_PLACE, PageState.SEARCH_RESULTS, PageState.UNKNOWN):
                logger.warning(f"[main] State={state.value}; retrying search-click acquisition")
                recovered = await nav.recover_full_place_via_search(
                    query=place_name or place_query,
                    place_hint=place_name or place_query,
                )
                if not recovered:
                    monitor.log_error(f"Serving failure: {state.value}")
                    await monitor.take_snapshot(page, f"serving_{state.value}")
                    return monitor.finish_run(metrics).__dict__

                await challenge.handle()
                state, place_name = await update_acquisition_metrics()

            if state == PageState.LIMITED_PLACE:
                monitor.log_error("Serving failure: limited view variant")
                await monitor.take_snapshot(page, "limited_view")
                return monitor.finish_run(metrics).__dict__

            if state == PageState.CONSENT:
                monitor.log_error("Serving failure: consent page still active")
                await monitor.take_snapshot(page, "consent_stuck")
                return monitor.finish_run(metrics).__dict__

            if state == PageState.BLOCKED:
                monitor.log_error("Serving failure: blocked/rate-limited")
                await monitor.take_snapshot(page, "blocked")
                return monitor.finish_run(metrics).__dict__

            # 4) Metadata after serving is correct
            metrics.ui_total = await nav.get_total_review_count()
            logger.info(
                f"[main] State={state.value} | Place={place_name} | "
                f"UI reviews={metrics.ui_total}"
            )

            # 5) Open reviews panel
            ok = await nav.open_reviews_tab()
            if not ok:
                monitor.log_error("Could not open reviews tab")
                await monitor.take_snapshot(page, "no_reviews_tab")
                return monitor.finish_run(metrics).__dict__

            await challenge.handle()

            # 6) Sorting and scrolling
            await nav.sort_by_newest()
            scroll = ScrollEngine(page, max_reviews=max_reviews)
            visible = await scroll.scroll_to_load_all(target_count=metrics.ui_total)
            logger.info(
                f"[main] Scroll done: {visible} cards visible, {len(proto_reviews)} from proto"
            )

            await asyncio.sleep(2.0)

            # 7) DOM fallback if proto is empty
            dom_reviews: List[Review] = []
            if not proto_reviews:
                logger.warning("[main] Proto empty - activating DOM fallback")
                dom_fb = DomFallback(page, place_id)
                dom_reviews = await dom_fb.extract_reviews()
                metrics.dom_extracted = len(dom_reviews)

            # 8) Merge + store
            all_reviews = parser.merge(proto_reviews, dom_reviews)
            metrics.total_extracted = len(all_reviews)

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
                logger.info(f"[main] Stored: {inserted} new, {updated} updated")

            await monitor.take_snapshot(page, "done")
            session.record_place_done()

        except Exception as e:
            monitor.log_error(f"Unhandled exception: {e}")
            logger.exception("[main] Unhandled error")
            await monitor.take_snapshot(page, "error")

        finally:
            try:
                await sniffer.stop()
            except Exception:
                pass
            try:
                await page.close()
            except Exception:
                pass
            await browser.close()

    result = monitor.finish_run(metrics)
    logger.info(f"[main] DB stats: {store.stats()}")
    return result.__dict__


async def main():
    p = argparse.ArgumentParser(description="Google Maps review scraper")
    p.add_argument("--url", required=True, help="Google Maps place URL")
    p.add_argument("--max-reviews", type=int, default=200)
    p.add_argument("--place-id", default=None)
    args = p.parse_args()

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
