# platforms/onchain — 直连链上 object

入参是区块浏览器的单合约/package 页（`suiscan.xyz/…/object/0x…` 等）、非 bounty 程序页时走本文件。

## 抓 scope

in-scope asset 只有一个：该 object。写 `scope.json`：`platform` 记 explorer host（如 `suiscan.xyz`）、`kind="onchain"`、`source_url` 记该 URL、`parse_status:"complete"`、`assets` 仅此一项。按 SKILL.md「分类」定 `vm`/`chain`（suiscan→sui）。`impacts_in_scope`、`out_of_scope` 留空。

## SECURITY.md

无 bounty 页、无 impacts/OOS。把本 skill 的 `onchain-security-template.md` 拷为 `<target>/SECURITY.md`。
