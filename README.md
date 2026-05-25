# taptap-access

Access TapTap website programmatically by bypassing Alibaba Cloud WAF's JS Challenge.

## Problem

TapTap (taptap.cn) sits behind Alibaba Cloud WAF, which returns an obfuscated JavaScript challenge page to non-browser HTTP clients. Direct `curl` or `requests` calls get:

```html
<textarea id="renderData" style="display:none">
  {"l1":"var arg1='5d39c3c5...';", "l2":"GET"}
</textarea>
<meta name="aliyun_waf_aa" content="...">
<script name="aliyunwaf_6a6f5ea8">...</script>
```

The JS computes an `acw_sc__v2` cookie value. Without this cookie, the real content is unreachable.

## Solution

Use Playwright (headless Chromium) to execute the challenge naturally. The browser runs the WAF's JavaScript, sets the cookie automatically, and the real page loads.

## Quick Start

### 1. Install dependencies

```bash
pip install -r requirements.txt
playwright install chromium
```

### 2. Install system libraries

**With sudo (recommended):**
```bash
playwright install-deps chromium
```

**Without sudo:**
```bash
bash scripts/install-deps.sh
export LD_LIBRARY_PATH="$(pwd)/libs/usr/lib/x86_64-linux-gnu"
```

### 3. Run the example

```bash
LD_LIBRARY_PATH="$(pwd)/libs/usr/lib/x86_64-linux-gnu" python example.py
```

Output:
```
Title: TapTap - 发现好游戏
WAF blocked: False
WAF cookie: 1234cf0d46...
Page text (137138 chars):
根据你的 IP，TapTap 为你准备了体验更好的国际版 ...
```

## How It Works

1. **Playwright launches headless Chromium** — a real browser, not an HTTP client
2. **Chromium executes the WAF's JS challenge** — the obfuscated script computes `acw_sc__v2`
3. **The cookie is set automatically** — subsequent requests inside the same browser context carry it
4. **TapTap serves real content** — the page renders normally as if a user was browsing

No cookie algorithm reverse-engineering needed. The WAF updates its challenge freely, and this approach continues to work.

## Project Structure

```
taptap-access/
  README.md
  requirements.txt
  .gitignore
  example.py              # Demo: fetch taptap.cn homepage
  scripts/
    install-deps.sh        # Install Chromium system deps without sudo
  libs/                    # (gitignored) Extracted .so files for no-sudo setups
```

## API Usage

```python
from example import fetch_taptap_page

result = fetch_taptap_page("https://www.taptap.cn")
print(result["title"])       # "TapTap - 发现好游戏"
print(result["waf_blocked"]) # False
print(result["text"][:500])  # Page content
```

## Requirements

- Python 3.8+
- Playwright
- Chromium (installed via `playwright install chromium`)
- Ubuntu 22.04 system libraries (see `scripts/install-deps.sh`)

## Disclaimer

This project is for educational and research purposes. When accessing TapTap or any website programmatically:

- Respect the website's Terms of Service and robots.txt
- Rate-limit your requests to avoid causing server load
- Consider using official APIs when available
- This is not a scraping tool — it only demonstrates WAF bypass technique

## License

MIT
