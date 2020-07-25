# configtxlator

`configtxlator` 命令允许用户在 protobuf 和 JSON 版本的 fabric 数据结构之间进行转换，并创建配置更新。该命令可以启动 REST 服务器并通过 HTTP 公开，也可以直接用作命令行工具。

The `configtxlator` command allows users to translate between protobuf and JSON
versions of fabric data structures and create config updates.  The command may
either start a REST server to expose its functions over HTTP or may be utilized
directly as a command line tool.

## 语法

## Syntax

`configtxlator` 工具有五个子命令，如下：

The `configtxlator` tool has five sub-commands, as follows:

  * start
  * proto_encode
  * proto_decode
  * compute_update
  * version

## configtxlator start
```
usage: configtxlator start [<flags>]

启动 configtxlator REST 服务。

Start the configtxlator REST server

Flags:
  --help                查看完整的帮助（可以尝试 --help-long 和 --help-man）。
  --hostname="0.0.0.0"  REST 服务器监听的主机名或者 IP。
  --port=7059           REST 服务器监听的端口。
  --CORS=CORS ...       允许跨域的域名, 例如 ‘*’ 或者 ‘www.example.com’ （可能是重复的）。
```

Flags:
  --help                Show context-sensitive help (also try --help-long and
                        --help-man).
  --hostname="0.0.0.0"  The hostname or IP on which the REST server will listen
  --port=7059           The port on which the REST server will listen
  --CORS=CORS ...       Allowable CORS domains, e.g. '*' or 'www.example.com'
                        (may be repeated).
```


## configtxlator proto_encode
```
usage: configtxlator proto_encode --type=TYPE [<flags>]

将 JSON 文档转换为 protobuf。

Converts a JSON document to protobuf.

Flags:
  --help                查看完整的帮助（可以尝试 --help-long 和 --help-man）。
  --type=TYPE           要将 protobuf 编码成的类型。例如‘common.Config’。
  --input=/dev/stdin    包含 JSON 文档的文件。
  --output=/dev/stdout  要将输出写入的文件。
```

Flags:
  --help                Show context-sensitive help (also try --help-long and
                        --help-man).
  --type=TYPE           The type of protobuf structure to encode to. For
                        example, 'common.Config'.
  --input=/dev/stdin    A file containing the JSON document.
  --output=/dev/stdout  A file to write the output to.
```


## configtxlator proto_decode
```
usage: configtxlator proto_decode --type=TYPE [<flags>]

将 proto 消息转换为 JSON。

Converts a proto message to JSON.

Flags:
  --help                查看完整的帮助（可以尝试 --help-long 和 --help-man）。
  --type=TYPE           要将 protobuf 解码成的类型。例如‘common.Config’。
  --input=/dev/stdin    包含 proto 消息的文件。
  --output=/dev/stdout  要将 JSON 文档写入的文件。
```

Flags:
  --help                Show context-sensitive help (also try --help-long and
                        --help-man).
  --type=TYPE           The type of protobuf structure to decode from. For
                        example, 'common.Config'.
  --input=/dev/stdin    A file containing the proto message.
  --output=/dev/stdout  A file to write the JSON document to.
```


## configtxlator compute_update
```
usage: configtxlator compute_update --channel_id=CHANNEL_ID [<flags>]

比较两个封送（marshaled）的 common.Config 信息，并计算它们的更新。

Takes two marshaled common.Config messages and computes the config update which
transitions between the two.

Flags:
  --help                   查看完整的帮助（可以尝试 --help-long 和 --help-man）。
  --original=ORIGINAL      原始配置信息。
  --updated=UPDATED        更新的配置信息。
  --channel_id=CHANNEL_ID  本次更新的通道名。
  --output=/dev/stdout     要将 JSON 文档写入的文件。
```

Flags:
  --help                   Show context-sensitive help (also try --help-long and
                           --help-man).
  --original=ORIGINAL      The original config message.
  --updated=UPDATED        The updated config message.
  --channel_id=CHANNEL_ID  The name of the channel for this update.
  --output=/dev/stdout     A file to write the JSON document to.
```


## configtxlator version
```
usage: configtxlator version

显示版本信息。

Show version information

Flags:
  --help  查看完整的帮助（可以尝试 --help-long 和 --help-man）。

Flags:
  --help  Show context-sensitive help (also try --help-long and --help-man).
```

```

## Examples

## 示例

### Decoding

### 解码

Decode a block named `fabric_block.pb` to JSON and print to stdout.

将一个名为 `fabric_block.pb` 的块解码为 JSON 并打印到标准输出。

```
configtxlator proto_decode --input fabric_block.pb --type common.Block
```

```
configtxlator proto_decode --input fabric_block.pb --type common.Block
```

Alternatively, after starting the REST server, the following curl command
performs the same operation through the REST API.

或者，在启动 REST 服务器之后，使用下面的 curl 命令通过 REST API 执行相同的操作。

```
curl -X POST --data-binary @fabric_block.pb "${CONFIGTXLATOR_URL}/protolator/decode/common.Block"
```

```
curl -X POST --data-binary @fabric_block.pb "${CONFIGTXLATOR_URL}/protolator/decode/common.Block"
```

### Encoding

### 编码

Convert a JSON document for a policy from stdin to a file named `policy.pb`.

将策略的 JSON 文档从标准输入转换为名为 `policy.pb` 的文件。

```
configtxlator proto_encode --type common.Policy --output policy.pb
```

```
configtxlator proto_encode --type common.Policy --output policy.pb
```

Alternatively, after starting the REST server, the following curl command
performs the same operation through the REST API.

或者，在启动 REST 服务器之后，使用下面的 curl 命令通过 REST API 执行相同的操作。

```
curl -X POST --data-binary /dev/stdin "${CONFIGTXLATOR_URL}/protolator/encode/common.Policy" > policy.pb
```

```
curl -X POST --data-binary /dev/stdin "${CONFIGTXLATOR_URL}/protolator/encode/common.Policy" > policy.pb
```

### Pipelines

### Pipelines

Compute a config update from `original_config.pb` and `modified_config.pb` and decode it to JSON to stdout.

从 `original_config.pb` 和 `modified_config.pb` 计算配置更新，然后将其解码为 JSON，再将其打印到标准输出。

```
configtxlator compute_update --channel_id testchan --original original_config.pb --updated modified_config.pb | configtxlator proto_decode --type common.ConfigUpdate
```

```
configtxlator compute_update --channel_id testchan --original original_config.pb --updated modified_config.pb | configtxlator proto_decode --type common.ConfigUpdate
```

Alternatively, after starting the REST server, the following curl commands
perform the same operations through the REST API.

或者，在启动 REST 服务器之后，使用下面的 curl 命令通过 REST API 执行相同的操作。

```
curl -X POST -F channel=testchan -F "original=@original_config.pb" -F "updated=@modified_config.pb" "${CONFIGTXLATOR_URL}/configtxlator/compute/update-from-configs" | curl -X POST --data-binary /dev/stdin "${CONFIGTXLATOR_URL}/protolator/decode/common.ConfigUpdate"
```

```
curl -X POST -F channel=testchan -F "original=@original_config.pb" -F "updated=@modified_config.pb" "${CONFIGTXLATOR_URL}/configtxlator/compute/update-from-configs" | curl -X POST --data-binary /dev/stdin "${CONFIGTXLATOR_URL}/protolator/encode/common.ConfigUpdate"
```

## Additional Notes

## 附加笔记

The tool name is a portmanteau of *configtx* and *translator* and is intended to
convey that the tool simply converts between different equivalent data
representations. It does not generate configuration. It does not submit or
retrieve configuration. It does not modify configuration itself, it simply
provides some bijective operations between different views of the configtx
format.

该工具名称是 *configtx* 和 *translator* 的组合，旨在表示该工具只是在不同的等效数据表示之间进行转换。它不生成配置。它不提交或检索配置。它不修改配置本身，只是在 configtx 格式的不同视图之间提供一些双射操作。

There is no configuration file `configtxlator` nor any authentication or
authorization facilities included for the REST server.  Because `configtxlator`
does not have any access to data, key material, or other information which
might be considered sensitive, there is no risk to the owner of the server in
exposing it to other clients.  However, because the data sent by a user to
the REST server might be confidential, the user should either trust the
administrator of the server, run a local instance, or operate via the CLI.

对于 REST 服务器，既没有配置文件 `configtxlator`，也没有包含任何身份验证或授权工具。因为 `configtxlator` 不能访问任何可能被认为敏感的数据、关键材料或其他信息，所以服务器的所有者将其暴露给其他客户端没有风险。但是，由于用户发送到 REST 服务器的数据可能是机密的，所以用户应该信任服务器的管理员、运行本地实例或者通过 CLI 进行操作。
