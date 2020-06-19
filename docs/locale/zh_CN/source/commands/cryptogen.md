# cryptogen

`cryptogen` 是用来生成 Hyperledger Fabric 密钥材料的工具。它为测试提供了一种预配置网络的工具。通常它不应使用在生产环境中。

## 语法

``cryptogen`` 有如下五个子命令:

  * help
  * generate
  * showtemplate
  * extend
  * version

## cryptogen help
```
usage: cryptogen [<flags>] <command> [<args> ...]

生成 Hyperledger Fabric 密钥材料的工具。

Flags:
  --help  查看完整的帮助（可以尝试 --help-long 和 --help-man）。

Commands:
  help [<command>...]
    显示帮助。

  generate [<flags>]
    生成密钥材料。

  showtemplate
    显示默认配置模板。

  version
    显示版本信息。

  extend [<flags>]
    扩展现有网络。
```


## cryptogen generate
```
usage: cryptogen generate [<flags>]

生成密钥材料

Flags:
  --help                    查看完整的帮助（可以尝试 --help-long 和 --help-man）。
  --output="crypto-config"  用来存放构件的输出目录。
  --config=CONFIG           使用的配置模板。

```


## cryptogen showtemplate
```
usage: cryptogen showtemplate

显示默认配置模板。

Flags:
  --help  查看完整的帮助（可以尝试 --help-long 和 --help-man）。
```


## cryptogen extend
```
usage: cryptogen extend [<flags>]

扩展现有网络。

Flags:
  --help                   查看完整的帮助（可以尝试 --help-long 和 --help-man）。
  --input="crypto-config"  存放现有网络的输入目录。、existing network place
  --config=CONFIG          使用的配置模板。

```


## cryptogen version
```
usage: cryptogen version

显示版本信息。

Flags:
  --help  查看完整的帮助（可以尝试 --help-long 和 --help-man）。

```

## 用法

这里有一个例子，在 ``cryptogen extend`` 命令上使用不同的标识（flag）。

```
    cryptogen extend --input="crypto-config" --config=config.yaml

    org3.example.com
```

这里 config.yaml 添加了一个新组织 ``org3.example.com``。

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.