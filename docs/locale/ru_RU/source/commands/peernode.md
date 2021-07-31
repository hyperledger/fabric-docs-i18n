# Команда peer node

Команда `peer node` позволяет администраторами запускать одноранговые узлы, сбрасывать каналы на одноранговых узлах
к первичному блоку или откатывать каналы к указанному блоку.

## Синтаксис

Команда `peer node` имеет следующие подкоманды:

  * start
  * reset
  * rollback

## Команда peer node start
```
Starts a node that interacts with the network.

Usage:
  peer node start [flags]

Flags:
  -h, --help                help for start
      --peer-chaincodedev   start peer in chaincode development mode
```


## Команда peer node reset
```
Resets all channels to the genesis block. When the command is executed, the peer must be offline. When the peer starts after the reset, it will receive blocks starting with block number one from an orderer or another peer to rebuild the block store and state database.

Usage:
  peer node reset [flags]

Flags:
  -h, --help   help for reset
```


## Команда peer node rollback
```
Rolls back a channel to a specified block number. When the command is executed, the peer must be offline. When the peer starts after the rollback, it will receive blocks, which got removed during the rollback, from an orderer or another peer to rebuild the block store and state database.

Usage:
  peer node rollback [flags]

Flags:
  -b, --blockNumber uint   Block number to which the channel needs to be rolled back to.
  -c, --channelID string   Channel to rollback.
  -h, --help               help for rollback
```

## Примеры использования

### Пример использования команды peer node start

Следующая команда запускает одноранговый узел в режиме разработки чейнкода. 

```
peer node start --peer-chaincodedev
```

Обычно контейнеры чейнкода запускаются и обслуживаются одноранговым узлом. Однако в режиме разработки чейнкод создается
и запускается пользователем. Этот режим полезен на этапе разработки чейнкода для итеративной разработки.


### Пример использования команды peer node reset

Следующая команде сбрасывает все каналы в одноранговом узле до первичного блока.
```
peer node reset
```

Перед выполнением сброса команда сохраняет количество блоков каждого канала в файловой системе.
Обратите внимание, что при выполнении этой команды процесс однорангового узла (peer) должен быть остановлен.
Если процесс однорангового узла запущен, команда вернет ошибку вместо выполнения сброса. При запуске однорангового
узла после выполнения сброса, узел запросит блоки всех каналов, которые были удалены командой сброса
(от других одноранговых узлов или службы упорядочения), в количестве, сохраненном для каждого канала 
перед сбросом. До тех пор, пока все сброшенные каналы не восстановят количество блоков, которое было в них до сброса,
одноранговый узел не сможет одобрять никакие транзакции.

### Пример использования peer node rollback

Следующая команда откатывает канал ch1 к блоку номер 150.

```
peer node rollback -c ch1 -b 150
```

Команда также сохраняет количество блоков канала ch1 перед откатом в файловой системе. Обратите внимание,
что при выполнении этой команды процесс однорангового узла (peer) должен быть остановлен. Если процесс
однорангового узла запущен, команда вернет ошибку вместо выполнения отката. При запуске однорангового
узла после выполнения отката, узел запросит блоки канала ch1, которые были удалены командой отката
(от других одноранговых узлов или службы упорядочения), и запишет блоки до сохраненного перед откатом количества.
До тех пор, пока канал ch1 не восстановит количество блоков, которое было в нем до отката,
одноранговый узел не сможет одобрять никакие транзакции в этом канале.
