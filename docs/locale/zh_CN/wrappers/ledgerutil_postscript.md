## 退出状态（Exit Status）

### 账本工具比较（ledgerutil compare）

- `0` 表示快照相同
- `2` 表示快照不同
- `1` 表示发生错误

### 账本工具识别交易（ledgerutil identifytxs）

- `0` 表示成功在区块存储中搜索交易
- `1` 表示发生错误或块范围无效

### 账本工具验证（ledgerutil verify）

- `0` 表示区块存储中所有账本的检查都成功
- `1` 表示发生错误

## 示例用法

### 账本工具比较示例（ledgerutil compare example）

这是 `ledgerutil compare` 命令的示例。

  * 比较两个不同的 peer 节点在快照高度5处的 mychannel 的快照。

    ```
    ledgerutil compare -o ./compare_output -f 10 ./peer0.org1.example.com/snapshots/completed/mychannel/5 ./peer1.org1.example.com/snapshots/completed/mychannel/5

    Both snapshot public state and private state hashes were the same. No results were generated.
    ```

    上面的响应表明快照是相同的。如果快照不相同，则命令结果将指示比较输出文件写在哪里，例如：

    ```
    Successfully compared snapshots. Results saved to compare_output/mychannel_5_comparison. Total differences found: 3
    ```    

  * 请注意，命令必须可以访问两个快照位置，例如通过从两个不同的 peer 节点挂载卷，或通过将快照复制到共同位置。

### 账本工具识别交易示例（ledgerutil identifytxs example）

这是 `ledgerutil identifytxs` 命令的示例。

  * 在允许的块范围内，从区块存储中识别 mychannel 中的相关交易。输入 JSON 文件包含要在区块存储中搜索的键列表。块范围从区块存储中最早的块到输入 JSON 文件中任何键的最高块高度。区块存储的高度必须至少等于输入 JSON 文件中最高键的高度，才能视为有效的块范围。

    ```
    ledgerutil identifytxs compare_output/mychannel_5_comparison/first_diffs_by_height.json -o identifytxs_output

    Successfully ran identify transactions tool. Transactions were checked between blocks 1 and 4.
    ```

    以上响应表明本地区块存储已成功搜索。这意味着已识别块范围内写入与比较命令 JSON 输出中找到的键相关的交易。在新创建的目录 identifytxs_output 中，生成了一个包含从比较命令 JSON 输出中每个键的已识别交易的 JSON 文件的 mychannel_identified_transactions 目录。

### 账本工具验证示例（ledgerutil verify example）

这是 `ledgerutil verify` 命令的示例。

  * 检查区块存储中块的完整性。

    ```
    ledgerutil verify ./peer0.org1.example.com/ledgersData/chains -o ./verify_output
    ```

    当没有错误时，它将简单地输出：

    ```
    Successfully executed verify tool. No error is found.
    ```

    否则，它将显示如下：

    ```
    Successfully executed verify tool. Some error(s) are found.
    ```

    详细的错误信息可以在结果目录下的 JSON 文件中找到（如上例中的 `./verify_output`）。

  * 请注意，由于 `ledgerutil verify` 命令使用区块存储中的索引，因此建议对区块存储的副本运行该命令，而不是直接针对运行中的 peer 节点的区块存储运行该命令。

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.
