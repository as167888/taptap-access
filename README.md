# taptap-access

通过绕过阿里云 WAF 的 JS 挑战，以编程方式访问 TapTap 网站。

## 问题

TapTap（taptap.cn）部署在阿里云 WAF 之后，对于非浏览器的 HTTP 请求，WAF 会返回一段混淆后的 JavaScript 挑战页面。直接使用 `curl` 或 `requests` 只能拿到：

```html
<textarea id="renderData" style="display:none">
  {"l1":"var arg1='5d39c3c5...';", "l2":"GET"}
</textarea>
<meta name="aliyun_waf_aa" content="...">
<script name="aliyunwaf_6a6f5ea8">...</script>
```

这段 JS 会计算出一个 `acw_sc__v2` cookie 的值并写入浏览器。没有这个 cookie，永远拿不到真实内容。

## 解决方案

使用 Playwright（无头 Chromium）来正常执行 JS 挑战。浏览器会自然地运行 WAF 的 JavaScript，自动设置 cookie，然后真实页面就能正常加载。

## 快速开始

### 1. 安装 Python 依赖

```bash
pip install -r requirements.txt
playwright install chromium
```

### 2. 安装系统依赖库

**有 sudo 权限（推荐）：**
```bash
playwright install-deps chromium
```

**没有 sudo 权限：**
```bash
bash scripts/install-deps.sh
export LD_LIBRARY_PATH="$(pwd)/libs/usr/lib/x86_64-linux-gnu"
```

### 3. 运行示例

```bash
LD_LIBRARY_PATH="$(pwd)/libs/usr/lib/x86_64-linux-gnu" python example.py
```

输出示例：
```
Title: TapTap - 发现好游戏
WAF blocked: False
WAF cookie: 1234cf0d46...
Page text (137138 chars):
根据你的 IP，TapTap 为你准备了体验更好的国际版 ...
```

## 原理

1. **Playwright 启动无头 Chromium** — 它是一个真实的浏览器，不是 HTTP 客户端
2. **Chromium 执行 WAF 的 JS 挑战** — 混淆脚本被正常执行，计算出 `acw_sc__v2`
3. **Cookie 自动设置** — 同一浏览器上下文内的后续请求自动携带该 cookie
4. **TapTap 返回真实内容** — 页面像正常用户浏览一样渲染

无需逆向 cookie 生成算法。WAF 可以随时更新挑战逻辑，而这个方案持续有效。

## 项目结构

```
taptap-access/
  README.md
  requirements.txt
  .gitignore
  example.py              # 示例：拉取 TapTap 首页
  scripts/
    install-deps.sh        # 无 sudo 环境下安装 Chromium 系统依赖
  libs/                    # (已 gitignore) 提取的 .so 文件，用于无 sudo 环境
```

## 作为模块使用

```python
from example import fetch_taptap_page

result = fetch_taptap_page("https://www.taptap.cn")
print(result["title"])       # "TapTap - 发现好游戏"
print(result["waf_blocked"]) # False
print(result["text"][:500])  # 页面正文
```

## 环境要求

- Python 3.8+
- Playwright
- Chromium（通过 `playwright install chromium` 安装）
- Ubuntu 22.04 系统依赖库（见 `scripts/install-deps.sh`）

## 免责声明

本项目仅供学习和研究使用。以编程方式访问 TapTap 或任何网站时，请注意：

- 遵守目标网站的 Terms of Service 和 robots.txt
- 控制请求频率，避免对服务器造成压力
- 如果有官方 API，优先使用官方接口
- 本项目仅演示 WAF 绕过技术，并非爬虫工具

## 许可证

MIT
