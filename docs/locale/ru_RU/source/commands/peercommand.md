# Команда peer

## Описание

Команда `peer` включает несколько подкоманд, которые позволяют администраторам выполнять определенные операции на одноранговых узлах.
Например, для добавления однорангового узла в канал предназначена подкоманда `peer channel`, а подкоманда `peer chaincode` 
позволяет развернуть чейнкод со смарт-контрактом на одноранговом узле.

## Синтаксис

Команда `peer` включает следующие подкоманды:

```
peer chaincode [опция] [флаги]
peer channel   [опция] [флаги]
peer node      [опция] [флаги]
peer version   [опция] [флаги]
```

Подкоманды имеют разные опции, которые описаны в отдельных подразделах далее. Далее по тексту для простоты
под **командой** будем подразумевать непосредственно команду (`peer`), ее подкоманды (`channel`), а также
опции подкоманд (`fetch`).

Если подкоманда указывается без опций, в результате ее выполнения возвращается краткая справка, как описано подразделе про флаг `--help` ниже.

## Флаги

Подкоманды `peer` имеют соответствующие флаги, многие из которых являются *глобальными* и могут использоваться с другими подкомандами.
Флаги описываются отдельно для каждой конкретной подкоманды `peer`.

Непосредственно команда `peer` имеет единственный флаг:

* `--help`

  Флаг `--help` позволяет получить краткую справку по каждой из команд `peer`. Флаг `--help` очень удобен для получения
  справки как по самой команде, так и по подкомандам и их опциям.

  Например:
  ```
  peer --help
  peer channel --help
  peer channel list --help

  ```
  Более подробно это описано в подразделах о соответствующих подкомандах `peer`.

## Использование

Ниже приводится пример использования флага с командой `peer`.

* Использование флага `--help` с командой `peer channel join`.

  ```
  peer channel join --help

  Joins the peer to a channel.

  Usage:
    peer channel join [flags]

  Flags:
    -b, --blockpath string   Path to file containing genesis block
    -h, --help               help for join

  Global Flags:
        --cafile string                       Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
        --certfile string                     Path to file containing PEM-encoded X509 public key to use for mutual TLS communication with the orderer endpoint
        --clientauth                          Use mutual TLS when communicating with the orderer endpoint
        --connTimeout duration                Timeout for client to connect (default 3s)
        --keyfile string                      Path to file containing PEM-encoded private key to use for mutual TLS communication with the orderer endpoint
    -o, --orderer string                      Ordering service endpoint
        --ordererTLSHostnameOverride string   The hostname override to use when validating the TLS connection to the orderer.
        --tls                                 Use TLS when communicating with the orderer endpoint
  ```
  На этом обзор синтаксиса команды `peer channel join` можно считать завершенным.
