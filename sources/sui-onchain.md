# sources/sui-onchain — 取源（Sui 链上 package 反编译）

asset 是 Sui package（`vm=move`、`chain=sui`）且无 repo 覆盖时走本文件；有 repo 用 `sources/repo.md`。成功档 `source_status=decompiled`。package id 用完整 `0x`+64hex。守 SKILL.md「onchain 落盘约定」。

## 取源

工具 `decompile_sui.py` 用 gRPC 拉 BCS、再 `move decompile`（自带 `bin/move`），依赖 `grpcio`。用带 grpc 的解释器 `/Users/lime/Workdir/python3-env/bin/python3`（裸 `python3` 缺 grpc）。network 按 scope/explorer 定：默认 mainnet，testnet 加 `--net testnet`，自有节点 `--rpc <host:port>`。`--latest` 解析升级血缘、反编译线上最新版 package（scope 的 address 仍记 suiscan url 的原始/类型根 id）。

```bash
/Users/lime/Workdir/python3-env/bin/python3 \
  /Users/lime/Workdir/infsec/sui-indexer/sui-decompile/decompile_sui.py \
  <package_id> --latest --out <tmp_dir> --net <network>
```

产出 `<tmp_dir>/mv/<module>.mv` 与反编译源。当前布局 `<tmp_dir>/src/<full_pkgid>/<module>.move`，旧版工具直接 `<tmp_dir>/src/<module>.move`。

## 落盘

落 `onchain/sui/<Label>__<pkg前10>/`，摆成标准 Move package（仅供 recon 识别组件）：

```text
onchain/sui/<Label>__<pkg前10>/
  Move.toml          # 顶部注释 "# decompiled, not rebuildable"; [package] name=<Label 合法标识符> / [addresses] <name>="<package_id>"
  sources/*.move     # 把 <tmp>/src 下所有 *.move 平搬过来 (兼容 src/<pkgid>/*.move 与 src/*.move)
  mv/*.mv            # 取自 <tmp>/mv/*.mv
  meta.json
```

`meta.json` Sui 专属字段（公共字段见 SKILL.md schema）：`{package_id:<原始/scope id>, decompiled_package:<latest id>, decompiled_version:<N>, modules:[<module 名…>], decompiled_not_rebuildable:true}`。

## 兜底

- 工具 import/依赖/gRPC 失败、`.mv` 一个没写出：`source_status:"address_only"`，`meta.json` 记 `decompile_error:{exit_code, stderr}`。失败串如缺 grpc、对象取不到、"对象 type != package"、"BCS tag != Package"。
- `.mv` 已写出、`move decompile` 子步失败：保留 `mv/` 与 partial `sources/`，`source_status:"bytecode_only"`、记 `decompile_error`。
- 弱产物（可选）：手动 JSON-RPC `sui_getNormalizedMoveModulesByPackage` 取 module 结构存 `meta.json`，`source_status:"modules_only"`。该调用独立于 `decompile_sui.py`（已 gRPC-only），只当 module 轮廓。
