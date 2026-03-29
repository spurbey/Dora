"""
dedupe_store.py — Layer 8: SQLite storage with upsert + change tracking

Schema:
  places  — one row per place
  reviews — one row per review (upsert on review_id)
  review_changes — append-only log when text/rating/owner_response changes

Design: SQLite for portability. Swap the backend by replacing _conn()
and the upsert methods — the interface stays the same.
"""
import sqlite3, os, json
from contextlib import contextmanager
from datetime import datetime
from typing import List, Optional, Tuple
from loguru import logger

from .models import PlaceInfo, Review


class DedupeStore:
    def __init__(self, db_path: Optional[str] = None):
        self._path = db_path or os.getenv("DB_PATH", "data/reviews.db")
        os.makedirs(os.path.dirname(self._path), exist_ok=True)
        self._init_schema()

    @contextmanager
    def _conn(self):
        conn = sqlite3.connect(self._path)
        conn.row_factory = sqlite3.Row
        try:
            yield conn
            conn.commit()
        except Exception:
            conn.rollback()
            raise
        finally:
            conn.close()

    def _init_schema(self):
        with self._conn() as conn:
            conn.executescript("""
                CREATE TABLE IF NOT EXISTS places (
                    place_id        TEXT PRIMARY KEY,
                    canonical_url   TEXT,
                    name            TEXT,
                    address         TEXT,
                    rating          REAL,
                    total_reviews   INTEGER,
                    first_crawled   TEXT,
                    last_crawled    TEXT
                );

                CREATE TABLE IF NOT EXISTS reviews (
                    review_id           TEXT PRIMARY KEY,
                    place_id            TEXT NOT NULL,
                    author_name         TEXT,
                    author_id           TEXT,
                    rating              INTEGER,
                    text                TEXT,
                    language            TEXT,
                    review_date         TEXT,
                    review_date_iso     TEXT,
                    crawl_date          TEXT,
                    owner_response      TEXT,
                    owner_response_date TEXT,
                    has_photos          INTEGER DEFAULT 0,
                    photo_count         INTEGER DEFAULT 0,
                    source              TEXT,
                    payload_hash        TEXT
                );

                CREATE TABLE IF NOT EXISTS review_changes (
                    id              INTEGER PRIMARY KEY AUTOINCREMENT,
                    review_id       TEXT NOT NULL,
                    place_id        TEXT NOT NULL,
                    changed_at      TEXT NOT NULL,
                    field_name      TEXT NOT NULL,
                    old_value       TEXT,
                    new_value       TEXT
                );

                CREATE INDEX IF NOT EXISTS idx_reviews_place ON reviews(place_id);
                CREATE INDEX IF NOT EXISTS idx_changes_review ON review_changes(review_id);
            """)

    # ─── Places ──────────────────────────────────────────────────────────────

    def upsert_place(self, place: PlaceInfo) -> None:
        now = datetime.utcnow().isoformat()
        with self._conn() as conn:
            existing = conn.execute(
                "SELECT first_crawled FROM places WHERE place_id = ?", (place.place_id,)
            ).fetchone()

            first_crawled = existing["first_crawled"] if existing else now

            conn.execute("""
                INSERT INTO places
                    (place_id, canonical_url, name, address, rating, total_reviews, first_crawled, last_crawled)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                ON CONFLICT(place_id) DO UPDATE SET
                    name          = excluded.name,
                    address       = excluded.address,
                    rating        = excluded.rating,
                    total_reviews = excluded.total_reviews,
                    last_crawled  = excluded.last_crawled
            """, (
                place.place_id, place.canonical_url, place.name,
                place.address, place.rating, place.total_reviews,
                first_crawled, now,
            ))

    # ─── Reviews ─────────────────────────────────────────────────────────────

    def upsert_reviews(self, reviews: List[Review]) -> Tuple[int, int]:
        """
        Upsert a batch of reviews.
        Returns (inserted_count, updated_count).
        """
        inserted = updated = 0
        now = datetime.utcnow().isoformat()

        with self._conn() as conn:
            for r in reviews:
                existing = conn.execute(
                    "SELECT payload_hash, text, rating, owner_response FROM reviews WHERE review_id = ?",
                    (r.review_id,)
                ).fetchone()

                if not existing:
                    conn.execute("""
                        INSERT INTO reviews VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
                    """, (
                        r.review_id, r.place_id, r.author_name, r.author_id,
                        r.rating, r.text, r.language, r.review_date, r.review_date_iso,
                        r.crawl_date.isoformat(), r.owner_response, r.owner_response_date,
                        int(r.has_photos), r.photo_count, r.source, r.payload_hash,
                    ))
                    inserted += 1
                else:
                    # Check for content changes
                    changes = []
                    for field, old, new in [
                        ("text",           existing["text"],           r.text),
                        ("rating",         existing["rating"],         r.rating),
                        ("owner_response", existing["owner_response"], r.owner_response),
                    ]:
                        if old != new:
                            changes.append((field, old, new))

                    if changes:
                        for field, old, new in changes:
                            conn.execute("""
                                INSERT INTO review_changes
                                    (review_id, place_id, changed_at, field_name, old_value, new_value)
                                VALUES (?, ?, ?, ?, ?, ?)
                            """, (r.review_id, r.place_id, now, field, str(old), str(new)))

                        conn.execute("""
                            UPDATE reviews SET
                                text = ?, rating = ?, owner_response = ?,
                                crawl_date = ?, payload_hash = ?
                            WHERE review_id = ?
                        """, (r.text, r.rating, r.owner_response, now, r.payload_hash, r.review_id))
                        updated += 1

        logger.info(f"[store] {inserted} inserted, {updated} updated for place {reviews[0].place_id if reviews else '?'}")
        return inserted, updated

    def count_reviews(self, place_id: str) -> int:
        with self._conn() as conn:
            row = conn.execute(
                "SELECT COUNT(*) as c FROM reviews WHERE place_id = ?", (place_id,)
            ).fetchone()
            return row["c"] if row else 0

    def get_reviews(self, place_id: str) -> List[dict]:
        with self._conn() as conn:
            rows = conn.execute(
                "SELECT * FROM reviews WHERE place_id = ?", (place_id,)
            ).fetchall()
            return [dict(r) for r in rows]

    def stats(self) -> dict:
        with self._conn() as conn:
            places = conn.execute("SELECT COUNT(*) as c FROM places").fetchone()["c"]
            reviews = conn.execute("SELECT COUNT(*) as c FROM reviews").fetchone()["c"]
            changes = conn.execute("SELECT COUNT(*) as c FROM review_changes").fetchone()["c"]
        return {"places": places, "reviews": reviews, "changes_logged": changes}