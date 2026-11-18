# platforms/cantina — 抓 scope（Cantina）

URL host = `cantina.xyz` 时走本文件。URL 形态 `cantina.xyz/bounties/<UUID>`。

## 抓 scope

scope、impacts、OOS 在页面内嵌 JSON 或后端 API、不在初始 HTML（JS 渲染）。逐档取：

1. WebFetch bounty 页，取 overview（impacts、rewards、rules、out-of-scope）与 assets-in-scope。
2. 拿不全，转 `curl` 原始 HTML，反序列化内嵌 state（`__NEXT_DATA__`、`self.__next_f`、`window.__*`）；或调 JSON API（`cantina.xyz/api/...`，端点从页面网络请求/源码推断）。
3. 仍不全，按 SKILL.md「partial 契约」记缺漏。

官方来源限本 bounty 页、页面内嵌 JSON、Cantina API、页面直链的官方 scope 文档；来源边界与禁止 WebSearch 新增资产见 SKILL.md。

asset 映射：repo 写 `{type:"repo", owner, repo, url, refs, subpaths, asset_type}`；链上写 `{type:"onchain", vm, chain, address, label, asset_type}`（`vm`/`chain` 按 SKILL.md 分类，`asset_type` 缺省按 `null` 规则）。写 `scope.json`（`platform="cantina"`、`kind="bounty"`、`source_url` 指 bounty 页）。

## SECURITY.md

平台差异：取 Impacts/Rewards 表；Known Issues（Cantina 常把 previously reported 列在 OOS）。统一格式、逐条誊抄、TODO 见 SKILL.md。
