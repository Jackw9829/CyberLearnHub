# Appendix: Local Fallback Lab Environment

CyberLearnHub's primary lab environment is browser-based (Apache Guacamole,
no local setup required). If the hosted lab infrastructure is temporarily
unavailable, the network-based CTF labs can still be completed locally using
this self-contained Docker bundle. Flag submission on the web platform works
exactly the same either way — the platform only checks the submitted flag
hash, not where it was found.

**This fallback is not required for the file-based challenges** (steganography,
EXIF metadata, hidden PDF text, password-protected ZIP) — those can be solved
with no attack box at all, hosted or local.

## Requirements

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed
  and running (Windows/Mac/Linux)
- ~3 GB free disk space
- Admin rights on the machine to install Docker

## Setup

```bash
cd kali-fallback
docker compose up -d --build
```

This starts two containers on an isolated internal network:

- **`clh-dvwa-fallback`** — the vulnerable target, reachable at
  `http://localhost:8080`
- **`clh-kali-fallback`** — the attack box, with `nmap`, `sqlmap`, `nikto`,
  `hydra`, `gobuster`, `dirb`, `steghide`, `binwalk`, `exiftool`, and `john`
  preinstalled

## Usage

1. Open `http://localhost:8080` in a browser and log into DVWA
   (default: `admin` / `password`), then click **Create / Reset Database**
   on first run.
2. Open a shell inside the attack box:
   ```bash
   docker exec -it clh-kali-fallback bash
   ```
3. Attack the target using its container name as the hostname, e.g.:
   ```bash
   nmap dvwa
   sqlmap -u "http://dvwa/vulnerabilities/sqli/?id=1&Submit=Submit" --cookie="..."
   ```
4. Submit the recovered flag on the CyberLearnHub web platform as normal
   (the web app itself only needs to be reachable — see the platform's own
   fallback runbook if it's also down).

## Tear down

```bash
docker compose down
```

## Notes

- This bundle is intentionally minimal and unrelated to the hosted
  Guacamole/Kali/Target EC2 instances — it does not require AWS access or
  credentials.
- Not all labs map 1:1 to DVWA's vulnerability set; this covers general
  network/web attack practice, not necessarily the exact scenario in every
  hosted lab.
