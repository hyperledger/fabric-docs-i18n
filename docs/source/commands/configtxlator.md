# configtxlator - 配置文件转换工具

The `configtxlator` command allows users to translate between protobuf and JSON
versions of fabric data structures and create config updates.  The command may
either start a REST server to expose its functions over HTTP or may be utilized
directly as a command line tool.



 `configtxlator` 命令使得用户可以用它把fabric的数据结构在protobuf和JSON版本之间进行转换，也可以用来创建配置的更新文件。 这个命令可以启动REST服务器，通过HTTP公开其函数，也可以直接作为命令行工具使用。

## Syntax - 语法

The `configtxlator` tool has five sub-commands, as follows:

 `configtxlator` 工具有五个子命令，如下：

  * start
  * proto_encode
  * proto_decode
  * compute_update
  * version

## configtxlator start - 启动REST Server 的子命令
```
usage: configtxlator start [<flags>]

Start the configtxlator REST server

Flags:
  --help                Show context-sensitive help (also try --help-long and
                        --help-man).
  --hostname="0.0.0.0"  The hostname or IP on which the REST server will listen
  --port=7059           The port on which the REST server will listen

```


## configtxlator proto_encode - 编码的子命令
```
usage: configtxlator proto_encode --type=TYPE [<flags>]

Converts a JSON document to protobuf.

Flags:
  --help                Show context-sensitive help (also try --help-long and
                        --help-man).
  --type=TYPE           The type of protobuf structure to encode to. For
                        example, 'common.Config'.
  --input=/dev/stdin    A file containing the JSON document.
  --output=/dev/stdout  A file to write the output to.

```


## configtxlator proto_decode - 解码的子命令
```
usage: configtxlator proto_decode --type=TYPE [<flags>]

Converts a proto message to JSON.

Flags:
  --help                Show context-sensitive help (also try --help-long and
                        --help-man).
  --type=TYPE           The type of protobuf structure to decode from. For
                        example, 'common.Config'.
  --input=/dev/stdin    A file containing the proto message.
  --output=/dev/stdout  A file to write the JSON document to.

```


## configtxlator compute_update - 创建更新补丁的子命令
```
usage: configtxlator compute_update --channel_id=CHANNEL_ID [<flags>]

Takes two marshaled common.Config messages and computes the config update which
transitions between the two.

Flags:
  --help                   Show context-sensitive help (also try --help-long and
                           --help-man).
  --original=ORIGINAL      The original config message.
  --updated=UPDATED        The updated config message.
  --channel_id=CHANNEL_ID  The name of the channel for this update.
  --output=/dev/stdout     A file to write the JSON document to.

```


## configtxlator version - 版本
```
usage: configtxlator version

Show version information

Flags:
  --help  Show context-sensitive help (also try --help-long and --help-man).

```

## Examples - 举例说明

### Decoding - 解码

Decode a block named `fabric_block.pb` to JSON and print to stdout.

将一个叫 `fabric_block.pb` 的块解码成JSON格式，并且打印到标准输出。这里指明其数据结构，是fabric里面正常的区块结构common.Block。

```
configtxlator proto_decode --input fabric_block.pb --type common.Block
```

Alternatively, after starting the REST server, the following curl command
performs the same operation through the REST API.

或者，在启动REST服务器之后，执行下面的curl命令通过REST API执行相同的操作。

```
curl -X POST --data-binary @fabric_block.pb "${CONFIGTXLATOR_URL}/protolator/decode/common.Block"
```

### Encoding - 编码

Convert a JSON document for a policy from stdin to a file named `policy.pb`.

从标准输入获取的一个关于策略的JSON文档转换成一个命名为 `policy.pb`的protobuf文件。

```
configtxlator proto_encode --type common.Policy --output policy.pb
```

Alternatively, after starting the REST server, the following curl command
performs the same operation through the REST API.

或者，在启动REST服务器之后，执行下面的curl命令通过REST API执行相同的操作。

```
curl -X POST --data-binary /dev/stdin "${CONFIGTXLATOR_URL}/protolator/encode/common.Policy" > policy.pb
```

### Pipelines - 管道

Compute a config update from `original_config.pb` and `modified_config.pb` and decode it to JSON to stdout.

从 `original_config.pb` 和 `modified_config.pb` 计算配置的更新内容。然后把它解码成JSON格式的标准输出。

```
configtxlator compute_update --channel_id testchan --original original_config.pb --updated modified_config.pb | configtxlator proto_decode --type common.ConfigUpdate
```

Alternatively, after starting the REST server, the following curl commands
perform the same operations through the REST API.

或者，在启动REST服务器之后，执行下面的curl命令通过REST API执行相同的操作。

```
curl -X POST -F channel=testchan -F "original=@original_config.pb" -F "updated=@modified_config.pb" "${CONFIGTXLATOR_URL}/configtxlator/compute/update-from-configs" | curl -X POST --data-binary /dev/stdin "${CONFIGTXLATOR_URL}/protolator/encode/common.ConfigUpdate"
```

## Additional Notes - 附记

The tool name is a portmanteau of *configtx* and *translator* and is intended to
convey that the tool simply converts between different equivalent data
representations. It does not generate configuration. It does not submit or
retrieve configuration. It does not modify configuration itself, it simply
provides some bijective operations between different views of the configtx
format.

该工具的名称是*configtx*和*translator*的合成词，这么命名的目的是为了表明该工具只是在不同的等效数据之间进行转换表示。它不生成配置。它不提交或检索配置。它不修改配置本身，它只是简单地在configtx的不同视图之间提供一些双射操作格式。

There is no configuration file `configtxlator` nor any authentication or
authorization facilities included for the REST server.  Because `configtxlator`
does not have any access to data, key material, or other information which
might be considered sensitive, there is no risk to the owner of the server in
exposing it to other clients.  However, because the data sent by a user to
the REST server might be confidential, the user should either trust the
administrator of the server, run a local instance, or operate via the CLI.

`configtxlator`没有配置文件，也没有为REST服务器提供任何认证或授权设施。因为`configtxlator`没有任何访问数据、密钥资料或其他敏感信息的权限，所以将其公开给其他客户对服务器的所有者没有风险。但是，因为数据是由用户发送到REST服务器，数据可能是机密的，所以用户应该信任服务器的管理员，或者运行本地实例，或者通过CLI操作。

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.
