# sources/evm-onchain — 取源（EVM 链上合约，穿透代理取最新实现）

asset `type=onchain`、`vm=evm` 且无 repo 覆盖时走本文件；有 repo 用 `sources/repo.md`。成功档 `source_status=verified`（已验证源）/`decompiled`（heimdall 近似源）/`bytecode_only`（evmole ABI 面）/`address_only`（无字节码）。address 用 `0x`+40hex。守 SKILL.md「onchain 落盘约定」。

## 取源

工具 `decompile_eth.py` 用 web3 穿透代理（EIP-1967/zeppelinos/1822/beacon/1167/Safe `masterCopy`/EIP-2535 Diamond）到**链上最新实现**，拉已验证源（Sourcify 免 key / Etherscan V2 有 `$ETHERSCAN_API_KEY` 才用），未验证则 heimdall 近似反编译、再退 evmole 抽 ABI 面。依赖 web3/evmole，用其 venv 解释器 `/Users/lime/Workdir/infsec/eth-indexer/eth-query/.venv/bin/python3`（裸 `python3` 缺依赖）。chain 按 scope/explorer 定（ethereum/base/arbitrum/optimism/polygon/bsc）；自有节点 `--rpc <url>`。穿透是默认（**scope 的 address 仍记原始代理地址，钱在它上面**；最新实现才是审计代码）。

```bash
/Users/lime/Workdir/infsec/eth-indexer/eth-query/.venv/bin/python3 \
  /Users/lime/Workdir/infsec/eth-indexer/eth-decompile/decompile_eth.py \
  <address> --chain <chain> --out <tmp_dir>
```

产出 `<tmp_dir>/meta.json`（解析事实 + 各合约源码状态）、`<tmp_dir>/bytecode/<addr>.bin`，与源：普通代理/合约的最新实现落 `<tmp_dir>/src/`（verified 重建工程树，未验证为 `<addr>.abi.txt`）；Diamond 本体 + 各 facet 落 `<tmp_dir>/src/<facet_addr>/`。

## 落盘

落 `onchain/<chain>/<Label>__<addr前10>/`，把 `<tmp>/src` 整树搬过来（= 穿透后的**最新实现**代码，审计看这里；Diamond 各 facet 在 `src/<facet_addr>/` 子目录）：

```text
onchain/<chain>/<Label>__<addr前10>/
  src/               # <tmp>/src 整树（最新 impl 工程；Diamond 为各 facet 子目录）
  lib/               # 依赖库源（工程含则有）
  meta.json
  abi.json           # 取自 <tmp>/meta.json 的 contracts[].abi（Etherscan 路径有；Sourcify 无则略）
```

`meta.json` 直接读 `<tmp>/meta.json`（公共字段见 SKILL.md schema，补 EVM 专属）：`{is_proxy, proxy_kind, implementation:<最新 impl 或 null(Diamond)>, facets:[<facet…>或 null]}`。`address` 仍记**原始代理地址**（与 scope 一致），`contracts[]` 逐合约记 `{address, source_status, via, compiler}`。

## 兜底

`<tmp>/meta.json` 的 `source_status` 直接映射落盘 `source_status`：

- `verified` — 已验证源，工程树在 `src/`。
- `decompiled` — heimdall 近似 Solidity（标识符占位、不保证可编译），在 `src/`。
- `bytecode_only` — 仅 evmole ABI 面 `<addr>.abi.txt`（selector + 参数 + 可变性 + openchain 还原函数名）。
- `address_only` — 无字节码（EOA/自毁）或工具崩溃；后者 `meta.json` 记 `decompile_error:{exit_code, stderr}`。
