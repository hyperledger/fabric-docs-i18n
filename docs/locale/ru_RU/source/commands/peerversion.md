# Команда peer version

Команда `peer version` позволяет получить данные о версии однорангового узла. Команда отображает версию,
SHA-хэш коммита, версию Go, ОС/архитектуру и информацию о чейнкоде. Например:

```
 peer:
   Version: 2.1.0
   Commit SHA: b78d79b
   Go version: go1.14.1
   OS/Arch: linux/amd64
   Chaincode:
    Base Docker Label: org.hyperledger.fabric
    Docker Namespace: hyperledger
```

## Синтаксис

Команда `peer version` не принимает аргументов.

## Команда peer version
```
Print current version of the fabric peer server.

Usage:
  peer version [flags]

Flags:
  -h, --help   help for version
```
