# Deploy Troubleshooting Quickstart (Beginner-Friendly)

## Purpose
Use this when a Coolify deploy fails and you need fast, practical checks.

## 30-second mental model
- **Server (EC2):** your cloud Linux machine.
- **Docker image:** packaged app blueprint (code + deps).
- **Docker container:** running app process from an image.
- **Docker network:** private LAN so containers can talk to each other.
- **Coolify:** UI that builds and starts your containers.

Important:
- Build success means images were created.
- App still fails if runtime needs (network/env/DB) are missing.

## Where to run commands
Run these on the EC2 host terminal (prefer AWS SSM session).

## 1) Check Docker health
```bash
docker ps
```
If this fails, Docker itself is unhealthy.

## 2) Check Coolify core containers
```bash
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "coolify|proxy|redis|db|realtime"
```
If core Coolify containers are missing/down, fix Coolify first.

## 3) Check required external network
If deploy error says:
`network <name> declared as external, but could not be found`

check:
```bash
docker network ls
```

create missing network:
```bash
docker network create <network_name>
```

Example from Dora incident:
```bash
docker network create oweg8231w4f615fwkxhil9r2
```

## 4) Verify app containers after redeploy
```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
```
App containers should be present and stay `Up`.

## 5) If deploy succeeded but behavior is still old
- Confirm deployed branch/commit in Coolify.
- Confirm **Production** env vars are set (not Preview env vars).
- Check logs for the failing app container and read the first error line.

## 6) Common pattern: build ok, start fails
Most common causes:
- missing external Docker network
- bad/missing env var
- DB URL/credentials mismatch
- internal service name/port mismatch

## 7) Fast recovery flow
1. Fix missing runtime dependency (network/env).
2. Redeploy from Coolify.
3. Re-check `docker ps`.
4. Verify app endpoint/API health.

## Notes for operators
- Keep external network names stable for a project.
- Avoid deleting Docker networks during host cleanup unless you know they are unused.
- Prefer SSM access for emergency recovery when SSH is unstable.
