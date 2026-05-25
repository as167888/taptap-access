"""
Example: Access TapTap with Playwright to bypass Alibaba Cloud WAF.

The WAF serves a JS challenge page that requires browser-level execution.
Playwright runs a real Chromium that automatically solves the challenge
and obtains the acw_sc__v2 cookie.
"""
from playwright.sync_api import sync_playwright


def fetch_taptap_page(url: str = "https://www.taptap.cn", timeout: int = 30000):
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        page.goto(url, wait_until="domcontentloaded", timeout=timeout)
        page.wait_for_timeout(5000)  # Allow JS challenge + React to render

        title = page.title()
        content = page.content()
        has_waf = "aliyun_waf" in content

        # Extract visible text via JS (more reliable than Playwright's inner_text)
        text = page.evaluate("() => document.body.textContent || ''")

        # Get the WAF challenge cookie
        cookies = page.context.cookies()
        acw = [c for c in cookies if "acw_sc" in c["name"]]

        browser.close()

        return {
            "title": title,
            "waf_blocked": has_waf,
            "text_length": len(text),
            "text": text,
            "acw_cookie": acw[0]["value"] if acw else None,
        }


if __name__ == "__main__":
    result = fetch_taptap_page()
    print(f"Title: {result['title']}")
    print(f"WAF blocked: {result['waf_blocked']}")
    print(f"WAF cookie: {result['acw_cookie'][:60] if result['acw_cookie'] else 'N/A'}...")
    print(f"Page text ({result['text_length']} chars):")
    print(result["text"][:1000])
