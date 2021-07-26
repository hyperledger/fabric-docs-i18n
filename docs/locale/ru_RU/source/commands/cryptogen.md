# Команда cryptogen

Инструмент `cryptogen` - утилита для генерации криптографических ключей в сетях Hyperledger Fabric.
Он используется для предварительной настройки сети в целях тестирования. В работающей сети этот инструмент обычно не применяется.

## Синтаксис

Команда ``cryptogen`` включает следующие пять подкоманд:

  * help
  * generate
  * showtemplate
  * extend
  * version

## Команда cryptogen help
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


## Команда cryptogen generate
```
Использование: cryptogen generate [<флаги>]

Generate key material

Flags:
  --help                    Show context-sensitive help (also try --help-long
                            and --help-man).
  --output="crypto-config"  The output directory in which to place artifacts
  --config=CONFIG           The configuration template to use
```


## Команда cryptogen showtemplate
```
usage: cryptogen showtemplate

Show the default configuration template

Flags:
  --help  Show context-sensitive help (also try --help-long and --help-man).
```


## Команда cryptogen extend
```
usage: cryptogen extend [<flags>]

Extend existing network

Flags:
  --help                   Show context-sensitive help (also try --help-long and
                           --help-man).
  --input="crypto-config"  The input directory in which existing network place
  --config=CONFIG          The configuration template to use
```


## Команда cryptogen version
```
usage: cryptogen version

Show version information

Flags:
  --help  Show context-sensitive help (also try --help-long and --help-man).
```

## Использование

Ниже приводится пример использования разных флагов с командой ``cryptogen extend``.

```
    cryptogen extend --input="crypto-config" --config=config.yaml

    org3.example.com
```

Здесь добавляется новая организация ``org3.example.com``, описанная вместе с ее одноранговыми узлами в файле config.yaml.
