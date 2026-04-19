# Scraping Runtime README

This folder documents the hosted scraping runtime used by advisory Google Maps scraping.

## Documents

- Setup + architecture: `docs/scraping/hosted-chromium-cdp-setup.md`
- AWS/EC2 terminal skill playbook: `docs/aws/ec2-terminal-agent-skill.md`

---

## Quick start (developer/operator)

## 1) Confirm backend endpoint

In `backend/.env`:

```env
BRIGHTDATA_WS_ENDPOINT=http://13.234.231.218:9222
```

Then restart backend/advisory worker processes.

## 2) Verify CDP endpoint from backend machine

```powershell
Invoke-WebRequest -UseBasicParsing http://13.234.231.218:9222/json/version
```

Expected: HTTP 200 JSON response.

## 3) Run scraper verification from backend venv

From `backend/`:

```powershell
@'
import asyncio
from app.services.scrapers.gmaps_scraper import scrape_gmaps_search, scrape_gmaps_reviews

async def main():
    pois = await scrape_gmaps_search("vegetarian restaurant", "Pune", max_pois=3)
    print("POIS", len(pois))
    for p in pois:
        print("POI", p.name, "|", p.place_id)
    if pois:
        reviews = await scrape_gmaps_reviews(pois[0].name, limit=3)
        print("REVIEWS", len(reviews))
        for r in reviews:
            print("R", (r.text or "").replace("\\n", " ")[:120])

asyncio.run(main())
'@ | .\venv\Scripts\python.exe -
```

Expected:
- `POIS >= 1`
- `REVIEWS >= 1`
- Non-empty review text snippets

---

## Operational checks (EC2 side)

Use SSM/SSH and run:

```bash
systemctl is-active chrome-cdp.service
systemctl is-active chrome-cdp-proxy.service
ss -ltnp | egrep '9222|9223'
docker ps
```

---

## Troubleshooting checklist

- `POIS 0`:
  - Confirm `BRIGHTDATA_WS_ENDPOINT` points to hosted CDP.
  - Confirm SG allows `9222` from backend runner IP.
  - Confirm Chrome/proxy services are `active`.
- Connection timeout:
  - Check EC2 health + network ACL/SG.
  - Probe `http://<server>:9222/json/version`.
- Intermittent extraction:
  - Retry query with locality variation.
  - Review advisory worker logs around `gmaps_scrape`.

---

## Notes

- The config key name remains `BRIGHTDATA_WS_ENDPOINT` for compatibility, but it now points to self-hosted CDP.
- Keep this runtime doc updated when instance ID/IP/security policy changes.
