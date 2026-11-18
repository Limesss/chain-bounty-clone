# sources/sol-onchain — 取源（Solana 链上 program）

asset 是 Solana program（`vm=solana`、`chain=solana`）时走本文件。无本地反编译工具，repo 优先。守 SKILL.md「onchain 落盘约定」。

## 取源

- **有覆盖 repo**：源码用 `sources/repo.md`（Anchor 工程，`Anchor.toml`/`Cargo.toml` 当组件清单）；链上 program 仅作交叉验证，不另落组件源。
- **无 repo**：公共 RPC（免 key）`getAccountInfo` 取 program bytecode，`source_status:"bytecode_only"`。RPC 限流时换付费节点（Helius/QuickNode）才需 key，按 env「有则用无则跳过」。

## 落盘

无 repo 时落 `onchain/solana/<Label>__<addr前10>/`。`meta.json` Solana 专属字段（公共字段见 SKILL.md schema）：`{program_id}`。

## 兜底

取不到 bytecode：`source_status:"address_only"`。

TODO：接 Solana 反编译/反汇编工具后，把"无 repo"分支升级为 sBPF 反汇编/近似源 + Anchor 包布局，`source_status:"decompiled"`。
