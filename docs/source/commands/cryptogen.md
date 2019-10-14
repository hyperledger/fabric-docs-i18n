# cryptogen


`cryptogen`是用来生成 Hyperledger Fabric 密钥的工具。它是作为一种预配置网络的工具，以测试为目的而提供的。它通常不应在生产环境中被使用。

## 语法

``cryptogen``有如下五个子命令:

  * help
  * generate
  * showtemplate
  * extend
  * version


## cryptogen help
```
usage: cryptogen [<flags>] <command> [<args> ...]

Utility for generating Hyperledger Fabric key material

Flags:
  --help  Show context-sensitive help (also try --help-long and --help-man).

Commands:
  help [<command>...]
    Show help.

  generate [<flags>]
    Generate key material

  showtemplate
    Show the default configuration template

  version
    Show version information

  extend [<flags>]
    Extend existing network


```


## cryptogen generate
```
usage: cryptogen generate [<flags>]

Generate key material

Flags:
  --help                    Show context-sensitive help (also try --help-long
                            and --help-man).
  --output="crypto-config"  The output directory in which to place artifacts
  --config=CONFIG           The configuration template to use

```


## cryptogen showtemplate
```
usage: cryptogen showtemplate

Show the default configuration template

Flags:
  --help  Show context-sensitive help (also try --help-long and --help-man).

```


## cryptogen extend
```
usage: cryptogen extend [<flags>]

Extend existing network

Flags:
  --help                   Show context-sensitive help (also try --help-long and
                           --help-man).
  --input="crypto-config"  The input directory in which existing network place
  --config=CONFIG          The configuration template to use

```


## cryptogen version
```
usage: cryptogen version

Show version information

Flags:
  --help  Show context-sensitive help (also try --help-long and --help-man).

```

## 用法


这里有一个例子，在``cryptogen extend``命令上使用不同的flags。

```
    cryptogen extend --input="crypto-config" --config=config.yaml

    org3.example.com
```

这里 config.yaml 添加了一个新的peer组织``org3.example.com``