## 账本工具（ledgerutil）

`ledgerutil` 或者账本工具套件是一组在 Fabric 网络上排除故障的工具，用于处理通道上节点的账本故障问题。这些工具可以单独或按顺序在各种故障场景中使用，目的是帮助用户定位故障的根本原因。

## 语法（Syntax）

`ledgerutil` 命令有三个子命令

  * `compare`

  * `identifytxs`

  * `verify`

## 比较（compare）

`ledgerutil compare` 命令允许管理员比较来自两个不同节点的通道快照。虽然相同高度的通道快照在所有节点上应该是相同的，但如果快照文件指示不同的状态哈希（如从每个快照的 `_snapshot_signable_metadata.json` 文件中看到的），则表明至少一个节点的状态数据库与区块链不正确，并且可能已经损坏。

如果快照不相同，则 `ledgerutil compare` 命令将输出一个目录，其中包含一组 JSON 文件，以协助在这些情况下进行故障排除。两个输出 JSON 文件将包括按键排序的任何键/值差异，一个用于公共键/值差异，一个用于私有键/值差异。第三个 JSON 文件将包括按块和交易高度排序的任何键/值差异（公共或私有），以便用户可以确定可能首次发生分歧的高度。有序的键/值差异 JSON 文件将包含最早的 n 个差异，其中 n 是作为标志传递给 `ledgerutil compare` 命令的用户选择的数字，或者在未传递标志时默认值为10。

输出文件可以帮助管理员了解状态数据库问题的范围，并确定哪些键受到影响。可以比较来自其他节点的快照以确定哪个节点的状态不正确。第一个差异的区块和交易高度可以用作参考点，以便在查看节点日志时理解可能发生了什么。以下是一个有序差异输出 JSON 文件的示例：

```
{
  "ledgerid":"mychannel",
  "diffRecords":[
    {
      "namespace":"_lifecycle$$h_implicit_org_Org1MSP",
      "key":"f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b",
      "hashed":true,
      "snapshotrecord1":null,
      "snapshotrecord2":{
        "value":"0c52a3dbc7b322ff35728afdd691244cfc0fc9c4743c254b57059a2394e14daf",
        "blockNum":1,
        "txNum":0
      }
    },
    {
      "namespace":"_lifecycle$$h_implicit_org_Org1MSP",
      "key":"e01e1c4304282cc5eda5d51c41795bbe49636fbf174514dbd4b98dc9b9ecf5da",
      "hashed":true,
      "snapshotrecord1":{
        "value":"0c52a3dbc7b322ff35728afdd691244cfc0fc9c4743c254b57059a2394e14daf",
        "blockNum":1,
        "txNum":0
      },
      "snapshotrecord2":null
    },
    {
      "namespace":"marbles",
      "key":"marble1",
      "hashed":false,
      "snapshotrecord1":{
        "value":"{\"docType\":\"marble\",\"name\":\"marble1\",\"color\":\"blue\",\"size\":35,\"owner\":\"tom\"}"
        "blockNum":3,
        "txNum":0
      },
      "snapshotrecord2":{
        "value":"{\"docType\":\"marble\",\"name\":\"marble1\",\"color\":\"blue\",\"size\":35,\"owner\":\"jerry\"}",
        "blockNum":4,
        "txNum":0
      }
    }
  ]
}
```

字段 `ledgerid` 指示比较发生的通道的名称。字段 `diffRecords` 提供了在比较的快照之间找到的键/值差异列表。比较工具发现3个差异。第一个 diffRecord 对于字段 `snapshotrecord1` 具有 null 值，表示该键存在于第二个快照中，但在第一个快照中缺失。第二个 diffRecord 对于字段 `snapshotrecord2` 具有 null 值，表示相反的情况。两个 diffRecord 都具有 hashed 值为 true，表示它们是私有键/值差异。第三个 diffRecord 在两个快照字段中都包含数据，表示快照对于相同键具有不同的数据。进一步检查发现，快照在关于键 `marbles marble1` 的所有者和设置该值的高度方面存在分歧。`hashed` 字段设置为 false，表示这是公共键/值差异。

## 识别交易（identifytxs）

`ledgerutil identifytxs` 命令允许管理员识别已写入节点本地区块存储区的一组键的交易列表。该命令接受一个 JSON 文件输入，其中包含一组键，并针对每个键输出一个 JSON 文件，每个文件包含一个交易列表（如果可用的区块范围有效）。在排除故障时，当与 `ledgerutil compare` 命令配对使用时，该命令最有效，即通过将针对键差异生成的 `ledger compare` 输出 JSON 文件作为输入，使 `ledgerutil identifytxs` 能够确定与有疑问的键相关的区块链上的交易。该命令不一定必须与 `ledgerutil compare` 命令配合使用，可以使用用户生成的 JSON 键列表或编辑后的 `ledgerutil compare` 输出 JSON 文件，以更一般的方法过滤交易。

如前所述，`ledgerutil identifytxs` 命令的设计是接受 `ledgerutil compare` 命令的输出，但该工具与任何格式相同的 JSON 文件兼容。这使得用户可以在更了解差异原因的情况下进行更直接的故障排除。输入的 JSON 文件应包含一个 `ledgerid`，该标识指示工具在哪个通道上进行搜索，以及一个 `diffRecords` 列表，提供要在交易中搜索的键列表。下面是一个有效的输入 JSON 文件的示例：

```
{
  "ledgerid":"mychannel",
  "diffRecords":[
    {
      "namespace":"marbles",
      "key":"marble1",
      "snapshotrecord1":{
        "value":"{\"docType\":\"marble\",\"name\":\"marble1\",\"color\":\"blue\",\"size\":35,\"owner\":\"tom\"}","blockNum":3,
        "txNum":0
      },
      "snapshotrecord2":{
        "value":"{\"docType\":\"marble\",\"name\":\"marble1\",\"color\":\"blue\",\"size\":35,\"owner\":\"jerry\"}","blockNum":4,
        "txNum":0
      }
    }
    {
      "namespace":"marbles",
      "key":"marble2"
    }
  ]
}
```

请注意，在上面的示例中，对于键 `marbles marble2`，输出 JSON 文件中由 `ledgerutil compare` 命令生成的快照记录和键发现分歧的高度字段被省略。在这种情况下，将搜索整个可用的区块存储，因为没有已知的分歧高度。

`ledgerutil identifytxs` 命令的输出是一个目录，其中包含一组 JSON 文件，每个文件对应一个输入键。继续上面的示例，如果将示例 JSON 用作 `ledgerutil identifytxs` 命令的输入文件，则生成的输出将是一个目录，其中包含两个名为 `txlist1.json` 和 `txlist2.json` 的 JSON 文件。输出的 JSON 文件按照它们在输入 JSON 文件中出现的顺序命名，因此 `txlist1.json` 将包含写入命名空间键 `marbles marble1` 的交易列表，而 `txlist2.json` 将包含写入命名空间键 `marbles marble2` 的交易列表。下面是 `txlist1.json` 内容的示例：

```
{
  "namespace":"marbles",
  "key":"marble1",
  "txs": [
    {
      "txid":"9ccb0d0bf19f143b29f17254364ccae987a8d89317f8e8dd81228762fef9da5f",
      "blockNum":2,
      "txNum":2,
      "txValidationStatus":"VALID",
      "keyWrite":"{\"docType\":\"marble\",\"name\":\"marble1\",\"color\":\"blue\",\"size\":35,\"owner\":\"john\"}"
    },
    {
      "txid":"a67c735fa1ef3390199aa2669a4f8023ea469cfe213afebf1014e57bceaf0a57",
      "blockNum":4,
      "txNum":0,
      "txValidationStatus":"VALID",
      "keyWrite":"{\"docType\":\"marble\",\"name\":\"marble1\",\"color\":\"blue\",\"size\":35,\"owner\":\"tom\"}"
    }
  ],
  "blockStoreHeightSufficient":true
}
```

上面的输出 JSON 文件指示，对于键 `marbles marble1`，找到了两个写入 `marbles marble1` 的交易，第一个交易发生在区块2交易2处，第二个交易发生在区块4交易0处。字段 `blockStoreHeightSufficient` 用于告知用户可用区块范围是否足够针对给定键的高度进行完整搜索。如果为 true，则区块存储区中最后一个可用块至少在分歧高度的高度处，表示区块存储区高度足够。如果为 false，则块存储区中最后一个可用区块不在分歧高度的高度处，表示可能存在与该键相关的交易未出现。在示例中，`blockStoreHeightSufficient` 指示区块存储区的块高至少为4，并且任何超过此高度的交易都与故障排除的目的无关。由于未为键 `marbles marble2` 提供分歧高度，因此 `txlist2.json` 文件中的 `blockStoreHeightSufficient` 将默认为 true，并成为较少有用的故障排除信息。

如果本地区块存储区中最早可用的区块高度低于最高输入键的高度，则区块范围有效；否则，搜索区块存储区中的输入键将是徒劳的，并且该命令将抛出错误。重要的是要了解，在最早可用区块高度大于区块1的情况下（这是通过快照引导的节点区块存储区的典型情况），命令的输出可能不是相关交易的详尽列表，因为最早的区块不可搜索。在这种情况下，可能需要进一步进行排除故障。

## 验证（verify）

`ledgerutil verify` 命令允许管理员检查节点本地区块存储区中账本的完整性。虽然区块链账本具有一种内在的结构，如哈希链，可以指示其是否已损坏，但节点通常在区块被处理和持久化到账本后不进行验证。该子命令通过使用哈希值验证本地账本是否存在完整性错误。

`ledgerutil verify` 接受区块存储区路径作为输入，并输出一个目录，其中包含一个或多个目录，每个目录包含区块存储区中一个通道的结果 JSON 文件。JSON 文件将包含在通道的账本中检测到的错误。如果验证成功（即区块头中的所有哈希值与区块内容一致），则该文件将只包含一个空数组，如下所示：

```json
[
]
```

但是，如果它检测到错误，数组的每个元素将包含具有错误的块号和找到的错误类型，如下所示：

```json
[
{"blockNum":0,"valid":false,"errors":["DataHash mismatch"]}
,
{"blockNum":1,"valid":false,"errors":["PreviousHash mismatch"]}
]
```

上面输出 JSON 文件的第一个元素指示区块0（创世区块）头中的哈希值 `DataHash` 与从区块内容计算出的哈希值不匹配。第二个元素指示区块1头中的 “previous” 哈希值 `PreviousHash` 与从前一个区块的头（即区块0）计算出的哈希值不匹配。这意味着区块0的头存在某些数据损坏。然后管理员可能需要使用上面的其他 `ledgerutil` 子命令比较多个节点的账本进行进一步检查，或者可能需要丢弃并重建节点。
