# sources/aptos-onchain — 取源（Aptos 链上 package）

asset 是 Aptos Move package（`vm=move`、`chain=aptos`）时走本文件。无本地反编译工具，repo 优先。守 SKILL.md「onchain 落盘约定」。

## 取源

- **有覆盖 repo**：源码用 `sources/repo.md`（`Move.toml` 当组件清单）；链上 module 仅作交叉验证，不另落组件源。
- **无 repo**：公共 RPC（免 key）`GET <fullnode>/v1/accounts/<addr>/modules` 取各 module 的 bytecode/ABI 结构，`source_status:"modules_only"`。fullnode 限流时换付费节点才需 key，按 env「有则用无则跳过」。

## 落盘

无 repo 时落 `onchain/aptos/<Label>__<addr前10>/`。`meta.json` Aptos 专属字段（公共字段见 SKILL.md schema）：`{package, modules:[…]}`。

## 兜底

取不到 module：`source_status:"address_only"`。

TODO：接 Aptos Move 反编译工具后，把"无 repo"分支升级为反编译近似源 + Move package 布局，`source_status:"decompiled"`。
