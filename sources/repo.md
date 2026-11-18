# sources/repo — 取源（git repo）

asset `type=repo`，或某链上部署经 SKILL.md「repo 覆盖判定」确认被 repo 覆盖时走本文件。

## 取源

同一 repo 的多个 asset 先并合所有合约子路径，一次 `set`（或 `git sparse-checkout add` 追加）。不逐 asset `set`。

```bash
git clone --depth 1 --filter=blob:none --sparse <url> repos/<owner>__<repo>
cd repos/<owner>__<repo>
git fetch --depth 1 origin <ref> && git checkout FETCH_HEAD   # 指定 commit/tag/非默认分支时才取
git sparse-checkout set <repo 全部 in-scope 子路径 空格分隔>
```

补仓库根构建清单（`foundry.toml`、`Move.toml`、`Cargo.toml`、`remappings.txt`、`hardhat.config.*`）与合约 import 的本地 `lib`/`interface`。`tests`、`docs`、`examples`、`node_modules` 不检出。

## 落盘

源码落 `repos/<owner>__<repo>/`，保持仓库原结构（含 `.git`）。

repo 覆盖某链上部署时，给该部署写 `onchain/<chain>/…/meta.json`，`source_status:"repo_ref"`、`source_ref` 指 `repos/<owner>__<repo>/<subpath>`，该子路径作 `index.json.groups` 这组的 representative。落位、index 两层、公共 meta 字段按 SKILL.md「onchain 落盘约定」。
