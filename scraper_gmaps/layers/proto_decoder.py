"""
proto_decoder.py — Layer 5: Decode binary protobuf review responses

This is the hardest layer. Google Maps sends reviews as binary protobuf
without publishing the .proto schema. We use blackboxprotobuf to
speculatively decode field tags, then map them to known fields.

FIELD TAG MAPPING — update this when Google shuffles tags.
Run `python layers/proto_decoder.py --probe <raw_bytes_file>` to see
raw decoded structure after a Google update.

How to re-map after a tag change:
  1. Save a raw response with run_monitor.py
  2. Run: python layers/proto_decoder.py --probe data/raw_bytes/<file>
  3. Look for the field containing a known review text string
  4. Update FIELD_MAP below
"""
import json, os, sys
from typing import Optional, List, Dict, Any
from loguru import logger

try:
    import blackboxprotobuf
    _HAS_BLACKBOX = True
except ImportError:
    _HAS_BLACKBOX = False
    logger.warning(
        "[proto] blackboxprotobuf not installed. "
        "Run: pip install blackboxprotobuf  — falling back to DOM only."
    )

from .models import Review


# ─── Field tag mapping ─────────────────────────────────────────────────────
# These are the protobuf field numbers observed in Google Maps review responses.
# Google shuffles these periodically (roughly 2x per year).
# When extraction count diverges from captured count, re-probe and update here.
FIELD_MAP = {
    "review_id":          [1, 3],       # try field 1, fallback to field 3
    "author_name":        [6, 2],
    "author_id":          [7],
    "rating":             [4],
    "text":               [2, 18],
    "date_string":        [5, 11],
    "owner_response":     [9, 10],
    "owner_resp_date":    [12],
    "photo_count":        [14],
}

# Minimum bytes to attempt proto decode (avoid noise from tiny responses)
MIN_BODY_SIZE = 200


class ProtoDecoder:
    def __init__(self, place_id: str):
        self.place_id = place_id
        self._raw_dir = os.path.join("data", "raw_bytes")
        os.makedirs(self._raw_dir, exist_ok=True)

    def decode_response(self, body: bytes, save_raw: bool = True) -> List[Review]:
        """
        Attempt to decode a captured response body into Review objects.
        Returns empty list if decode fails (triggers DOM fallback).
        """
        if not _HAS_BLACKBOX:
            return []

        if len(body) < MIN_BODY_SIZE:
            logger.debug(f"[proto] Body too small ({len(body)}B), skipping")
            return []

        if save_raw:
            self._save_raw(body)

        # Try JSON first (Maps sometimes sends JSON-wrapped proto)
        json_reviews = self._try_json_parse(body)
        if json_reviews:
            return json_reviews

        # Binary protobuf decode
        try:
            message, _ = blackboxprotobuf.decode_message(body)
            return self._extract_reviews_from_message(message)
        except Exception as e:
            logger.debug(f"[proto] blackboxprotobuf decode failed: {e}")
            return []

    def _try_json_parse(self, body: bytes) -> List[Review]:
        """Some endpoints return )]}'\n<json> — strip the XSSI prefix."""
        try:
            text = body.decode("utf-8", errors="ignore")
            # Strip XSSI prefix
            if text.startswith(")]}'"):
                text = text[4:].lstrip("\n")
            data = json.loads(text)
            return self._extract_from_json(data)
        except (json.JSONDecodeError, UnicodeDecodeError):
            return []

    def _extract_from_json(self, data: Any) -> List[Review]:
        """Walk JSON structure looking for review arrays."""
        reviews = []
        if isinstance(data, list):
            for item in data:
                r = self._json_item_to_review(item)
                if r:
                    reviews.append(r)
        return reviews

    def _json_item_to_review(self, item: Any) -> Optional[Review]:
        """Convert a JSON review item to a Review object."""
        if not isinstance(item, (list, dict)):
            return None
        try:
            # Google Maps JSON structure varies; try common patterns
            if isinstance(item, list) and len(item) > 5:
                return Review(
                    review_id=str(self._safe_get(item, 0, "")),
                    place_id=self.place_id,
                    author_name=str(self._safe_get(item, 1, "Unknown")),
                    author_id=str(self._safe_get(item, 2, "")),
                    rating=self._safe_int(self._safe_get(item, 3)),
                    text=str(self._safe_get(item, 4, "")),
                    language=None,
                    review_date=str(self._safe_get(item, 5, "")),
                    review_date_iso=None,
                    source="proto_json",
                )
        except Exception:
            pass
        return None

    def _extract_reviews_from_message(self, message: Dict) -> List[Review]:
        """
        Walk the decoded protobuf message tree to find review records.
        Reviews are usually in a repeated field 2-3 levels deep.
        """
        reviews = []
        candidates = self._find_review_arrays(message)
        for candidate in candidates:
            r = self._proto_record_to_review(candidate)
            if r:
                reviews.append(r)
        logger.debug(f"[proto] Extracted {len(reviews)} reviews from proto message")
        return reviews

    def _find_review_arrays(self, obj: Any, depth: int = 0) -> List[Dict]:
        """Recursively find lists of dicts that look like review records."""
        if depth > 6:
            return []
        results = []
        if isinstance(obj, list):
            for item in obj:
                if self._looks_like_review(item):
                    results.append(item)
                else:
                    results.extend(self._find_review_arrays(item, depth + 1))
        elif isinstance(obj, dict):
            for v in obj.values():
                results.extend(self._find_review_arrays(v, depth + 1))
        return results

    def _looks_like_review(self, obj: Any) -> bool:
        """Heuristic: a review record has at least 4 fields and contains a string."""
        if not isinstance(obj, dict) or len(obj) < 4:
            return False
        has_string = any(isinstance(v, str) and len(v) > 5 for v in obj.values())
        has_number = any(isinstance(v, int) for v in obj.values())
        return has_string and has_number

    def _proto_record_to_review(self, record: Dict) -> Optional[Review]:
        """Map proto field numbers to Review fields using FIELD_MAP."""
        try:
            def get_field(keys):
                for k in keys:
                    # blackboxprotobuf uses string keys
                    v = record.get(str(k)) or record.get(k)
                    if v is not None:
                        return v
                return None

            text = get_field(FIELD_MAP["text"])
            author = get_field(FIELD_MAP["author_name"])

            # Skip records without text or author (not a review)
            if not text and not author:
                return None

            review_id_raw = get_field(FIELD_MAP["review_id"])
            rating_raw = get_field(FIELD_MAP["rating"])

            return Review(
                review_id=str(review_id_raw) if review_id_raw else f"{self.place_id}_{hash(str(text))}",
                place_id=self.place_id,
                author_name=str(author) if author else "Unknown",
                author_id=str(get_field(FIELD_MAP["author_id"]) or ""),
                rating=self._safe_int(rating_raw),
                text=str(text) if text else None,
                language=None,
                review_date=str(get_field(FIELD_MAP["date_string"]) or ""),
                review_date_iso=None,
                owner_response=str(get_field(FIELD_MAP["owner_response"]) or "") or None,
                has_photos=bool(get_field(FIELD_MAP["photo_count"])),
                photo_count=self._safe_int(get_field(FIELD_MAP["photo_count"])) or 0,
                source="proto",
            )
        except Exception as e:
            logger.debug(f"[proto] Record conversion failed: {e}")
            return None

    def _save_raw(self, body: bytes):
        """Save raw bytes for later re-probing if field tags shift."""
        import time
        fname = os.path.join(self._raw_dir, f"{self.place_id}_{int(time.time())}.bin")
        try:
            with open(fname, "wb") as f:
                f.write(body)
            logger.debug(f"[proto] Raw bytes saved: {fname}")
        except Exception as e:
            logger.debug(f"[proto] Could not save raw bytes: {e}")

    @staticmethod
    def _safe_get(lst, idx, default=None):
        try:
            return lst[idx]
        except (IndexError, TypeError):
            return default

    @staticmethod
    def _safe_int(val) -> Optional[int]:
        try:
            return int(val)
        except (TypeError, ValueError):
            return None


# ─── CLI probe mode ────────────────────────────────────────────────────────
if __name__ == "__main__":
    """
    Usage: python -m layers.proto_decoder --probe data/raw_bytes/somefile.bin
    Prints the raw decoded structure so you can re-map FIELD_MAP after a Google update.
    """
    if len(sys.argv) >= 3 and sys.argv[1] == "--probe":
        path = sys.argv[2]
        with open(path, "rb") as f:
            raw = f.read()
        if _HAS_BLACKBOX:
            msg, typedef = blackboxprotobuf.decode_message(raw)
            print(json.dumps(msg, indent=2, default=str))
        else:
            print("Install blackboxprotobuf first: pip install blackboxprotobuf")