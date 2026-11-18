# platforms/immunefi — 抓 scope（Immunefi）

URL host = `immunefi.com` 时走本文件。URL 形态 `…/bug-bounty/<slug>/`、`…/<slug>/scope/`、`…#top`。

## 抓 scope

抓两个子页：overview `https://immunefi.com/bug-bounty/<slug>/` 取 impacts、rules、out-of-scope；scope `https://immunefi.com/bug-bounty/<slug>/scope/` 取 assets-in-scope。

资产数据在页面 flight、不在初始 HTML（Next.js CSR）。逐档取：

1. WebFetch 拿不全，转 `curl` 原始 HTML。
2. 解码 `self.__next_f.push([n,"…"])`：各 chunk 经 `json.loads('"'+chunk+'"')` 反转义后拼接，再 `json.loads`；或读 `__NEXT_DATA__`。
3. 仍不全，按 SKILL.md「partial 契约」记缺漏。

官方来源限本页、页面内嵌数据、Immunefi API、页面直链的官方 scope 文档；来源边界与禁止 WebSearch 新增资产见 SKILL.md。每个 asset 取 `asset_type`、`subpaths`、url，写 `scope.json`（`platform="immunefi"`、`kind="bounty"`、`source_url` 指 scope 页）。

## SECURITY.md

平台差异：Out of Scope 收 Immunefi 平台默认条款、项目自定义、Known Issues（带链接）。统一格式、逐条誊抄、TODO 见 SKILL.md。
