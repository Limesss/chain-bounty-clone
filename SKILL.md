---
name: bounty-clone
description: 给定 bug bounty program URL（Immunefi/Cantina）或链上 object URL（suiscan 等），把 in-scope 智能合约资产拉到 `<target_name>/`：按平台抓 scope，按 `asset_type` 只留智能合约，repo 走 sparse-checkout，EVM 取链上已验证源码，Sui package 反编译，其它非 EVM 无 repo 时取链上 module/bytecode，并把 Impacts/Out-of-Scope 写入 `SECURITY.md`。用户给出 bounty 链接、要求拉 scope/clone 资产/生成 SECURITY.md/bounty-clone 时触发。
argument-hint: "<bounty-program-url> [<target-name>]"
---

# Bounty Clone

把 bug bounty program 的 in-scope 智能合约资产拉到 `<target_name>/`。按 `asset_type` 把 web 和链下节点滤掉，只留链上合约。

## 调用形式

```text
/bounty-clone <bounty-program-url> [<target-name>]
```

入参为 bounty program 页 URL（Immunefi `…/bug-bounty/<slug>/`、`…/<slug>/scope/`、`…#top`；Cantina `cantina.xyz/bounties/<UUID>`），或直接的链上 object / explorer URL（`suiscan.xyz/…/object/0x…` 等，见判定）。给出第二参数 `target_name` 时，原样用作落盘目录名，不要再自取。未给第二参数时才自取：URL 末段可读就用它，是 UUID/hash（Cantina）则按项目名取（小写连字符，例 `Reserve Protocol`→`reserve-protocol`）。

## 判定（先分派，再取）

先认入参：bounty scope 列表页（immunefi/cantina），还是区块浏览器的单合约/package 页（suiscan 等，无 bounty 页）。据此选平台，再逐 asset 选取源。

**平台**（抓 scope）按 URL host：

- `immunefi.com` → `platforms/immunefi.md`
- `cantina.xyz` → `platforms/cantina.md`
- 区块浏览器单 object 页（`suiscan.xyz/…/object/0x…` 等）→ `platforms/onchain.md`

**取源类型**（每个 asset 落源码）按「分类」定 `vm`/`chain`：

- repo → `sources/repo.md`
- EVM 部署 → `sources/evm-onchain.md`
- Sui 链上 package → `sources/sui-onchain.md`
- Aptos 链上 package → `sources/aptos-onchain.md`
- Solana 链上 program → `sources/sol-onchain.md`

## 步骤

**非交互执行：中途不停下问用户确认、不列清单待批。** 解析按固定路径走；链/chainid/端点不确定时 WebSearch。

1. **抓 scope** — 读 `platforms/<平台>.md`（直连 object 退化为单一资产）。bounty 页 in-scope 只认官方来源（bounty 页、页面内嵌数据、平台 API、页面直链的官方 scope 文档）；WebSearch 仅用于定位 bounty 页或确认解析方式，不新增资产。解析不全时只记确证的：`scope.json.parse_status:"partial"`，缺漏写进 `todos[]`/`parse_errors[]`/`missing_sections[]`。每个 asset 取 `asset_type` 与 `subpaths`。
2. **过滤 + 分类**（通用，见下）— 按 `asset_type` 滤到合约，给每个保留 asset 定 `type`/`vm`/`chain`、`origin`、取源类型。
3. **取源** — 每个 asset 读 `sources/<取源类型>.md` 落盘；落盘守「onchain 落盘约定」（含 index 两层、每个链上 asset 不论有无源都记）。
4. **写 SECURITY.md**（来源见 `platforms/<平台>.md` 的「SECURITY.md」节）— bounty 页统一格式：Impacts in Scope 按 severity 列表；Out of Scope 收平台默认条款、项目自定义、Known Issues（带链接）；注明来源 URL 和抓取日期；逐条誊抄原文，缺失标 TODO。

### 步骤 2 过滤 + 分类（通用）

**过滤** 按各 asset 自己的 `asset_type`（不整 repo 一刀切）：踢 `websites_and_applications`（前端/SDK/链下节点）、`blockchain_dlt`（链/节点软件）；保留 `smart_contract`；`null` 仅当资产形态是 repo 合约路径、链上地址、explorer URL、Move package / program id 时视同 `smart_contract` 保留，普通网站 URL 仍剔除或标 `unclassified_non_contract`。

**定 `vm`/`chain`** 分类优先级（高到低）：① 平台明确标的 `chain`/`vm` 字段；② 区块浏览器 URL host 推导 `chain`（etherscan/arbiscan/basescan→evm 链、suiscan→sui、aptoscan/explorer.aptoslabs→aptos、solscan/explorer.solana→solana），`vm` 由 chain 定（sui/aptos→move、各 EVM 链→evm）；③ 页面标注的链名 / API 字段；④ 地址形状（仅最后兜底）：`0x`+40hex→evm、`0x`+64hex→move(需 chain 佐证)、base58→solana。

**定 `origin`**：`self`（项目方代码：在 in-scope repo / scope 页明确列为项目方部署）、`external`（外部依赖：第三方库、非项目方 license）、`unknown`（证据不足）。unknown 与 self 同落 `onchain/<chain>/`，回报标出待人工确认。

**repo 覆盖判定**：仅当有明确证据（scope 页显式把该 repo 与该部署关联、或链上已验证源码路径/合约名/版本与 repo 子路径吻合）才算"该部署被 repo 覆盖"；覆盖才免去重复存链上源码、`source_status:"repo_ref"`。无证据不要跳过链上 verified source。repo 优先只在已确认覆盖时生效。

## onchain 落盘约定（跨链共用，所有 `sources/*-onchain.md` 都守）

落盘位置只看 **`origin`**，源码状态另记 **`source_status`**：

- `origin ∈ {self, external, unknown}`。`source_status ∈ {verified, decompiled, repo_ref, bytecode_only, modules_only, address_only}`：链上已验证源 / 反编译近似源 / 源在 in-scope repo / 只字节码 / 只 module 结构 / 只有地址。

约定：

- **按 origin 落位**：`self`/`unknown` → `onchain/<chain>/<Label>__<addr前10>/`；`external` → `onchain/_external/<chain>/<Label>__<addr前10>/`（只留 `meta.json`、`abi.json`）。**in-scope 自有合约即便无源（bytecode_only/modules_only/address_only）也是 `origin=self`，留 `onchain/<chain>/`、不进 `_external/`**。
- **去重副本**：同源副本（多链/多实例同源、非 interop）只物理保留代表的 `src`/`lib`，其余删 `src`/`lib`、各自留 `meta.json` 与 `implementation/`、`source_ref` 指代表，`index.json.groups` 记映射。proxy 后的 `implementation/` 逐部署留。
- **交互全保**：跨链/跨实例的信任边界合约（消息接收、桥适配、治理/timelock）逐部署全取源、`interop:true`、不去重删。
- **标记组件**：写该生态标准包清单（evm `foundry.toml`、move `Move.toml`、solana/anchor `Anchor.toml`/`Cargo.toml`）。部署多则按合约族/攻击面分子目录、各放一份。
- **index 两层**：所有链上 asset（含无源）进 `index.json.deployments[]`；只有可审源（`source_status ∈ {verified, decompiled, repo_ref}`）的进 `index.json.groups[]`（recon 据 groups 建组件，无源不建空组件）。`summary.no_source` 计 `bytecode_only/modules_only/address_only` 之和。

## 结果

```text
<target_name>/scope.json
<target_name>/SECURITY.md
<target_name>/repos/<owner>__<repo>/                                              # type=repo
<target_name>/onchain/<chain>/<Label>__<addr前10>/{src,lib,meta.json,abi.json[,implementation/]}   # origin=self/unknown
<target_name>/onchain/sui/<Label>__<pkg前10>/{Move.toml,sources/*.move,mv/*.mv,meta.json}          # source_status=decompiled
<target_name>/onchain/_external/<chain>/<Label>__<addr前10>/{meta.json,abi.json}                   # origin=external
<target_name>/onchain/index.json        # deployments[](全部) + groups[](有源组件)
<target_name>/onchain/<pkg-manifest>    # 生态标准包清单(foundry.toml/Move.toml/Anchor.toml…)
```

回报用中文，聚焦状态、产物路径、数量；URL、地址、文件路径、合约名保持原样。结束时报：target 名、SC 资产数（repo / 各链）、self/external/unknown 份数、跨链交互逐链部署数、按 `asset_type` 踢掉的 web/链下资产数、各 `source_status` 计数（尤其 `summary.no_source`）、`parse_status` 与 `todos[]`。

## scope.json

字段清单：`target_name`、`source_url`、`platform`、`kind`、`parse_status`、`todos[]`、`parse_errors[]`、`missing_sections[]`、`assets[]`、`impacts_in_scope[]`、`out_of_scope{}`、`known_issues[]`、`rules?`。

```json
{
  "target_name": "veda",
  "source_url": "https://immunefi.com/bug-bounty/veda/scope/",
  "platform": "immunefi",
  "kind": "bounty",
  "parse_status": "complete",
  "todos": [],
  "parse_errors": [],
  "missing_sections": [],
  "assets": [
    {"type":"repo","owner":"veda-Labs","repo":"boring-vault","url":"...","asset_type":"smart_contract","refs":[],"subpaths":[]},
    {"type":"onchain","vm":"evm","chain":"ethereum","chainid":1,"address":"0x...","label":"LiquidETH-boring_vault","asset_type":"smart_contract"},
    {"type":"onchain","vm":"move","chain":"sui","address":"0x<64hex>","label":"airdrop_vault","asset_type":"smart_contract"}
  ],
  "impacts_in_scope": [{"severity":"critical","type":"smart_contract","title":"..."}],
  "out_of_scope": {"Smart Contract / Blockchain":"...","General":"...","Web & Applications":"..."},
  "known_issues": [{"description":"...","link":"..."}]
}
```

字段契约：

- `platform ∈ {immunefi, cantina}`；直接链上 object 入参时记 explorer host（如 `suiscan.xyz`）
- `kind ∈ {bounty, onchain}`：bounty 程序页（immunefi/cantina/…）记 `bounty`；直连链上 object（suiscan/etherscan/… explorer）记 `onchain`。下游据此选审计 lens
- `parse_status ∈ {complete, partial}`；`partial` 时缺漏进 `todos[]`/`parse_errors[]`/`missing_sections[]`
- `assets[].type ∈ {repo, onchain}`；`vm ∈ {evm, move, solana}`；`chain` 区分 sui/aptos 等同 vm 不同链
- `asset_type ∈ {smart_contract, websites_and_applications, blockchain_dlt, null}`：原始分类，步骤 2 据此过滤

## meta.json / index.json schema

`meta.json` 每部署记 `address`、`explorer`、`contract_name`、`chain`、`origin`(self|external|unknown)、`source_status`、`interop`、`source_ref`（repo_ref 时指 `repos/<owner>__<repo>/<subpath>`，同源非代表部署指代表目录；代表与 interop 留空）+ 该 vm 的编译元：

- evm：`compiler`、`optimization`(+runs)、`evm_version`、`constructor_args`、`abi`、`is_proxy`、`implementation`
- move/solana：`package_id`/`program_id`、`modules[]`；`source_status=decompiled` 加 `decompiled_not_rebuildable:true`；失败档加 `decompile_error:{exit_code,stderr}`

`index.json`：顶层 `schema_version`、`target`、`summary`（`total_deployments`、`source_groups`、`interop_deployments`、`no_source`）+ `deployments[]` 与 `groups[]`（**收录规则见上「onchain 落盘约定·index 两层」**）。字段结构：

- `deployments[]` 每项 `{dir, address, chain, label, origin, source_status, interop, is_proxy, source_ref}`。
- `groups[]` 每组 `{source_digest, representative, members:[dir…]}`；`repo_ref` 组 `representative` = `repos/<owner>__<repo>/<subpath>`，`verified/decompiled` 组 = onchain 源目录。

下游按固定字段读，所有 target 产同一套字段。
