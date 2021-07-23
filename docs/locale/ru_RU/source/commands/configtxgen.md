# Команда configtxgen

Команда `configtxgen` позволяет пользователям создавать и просматривать артефакты, связанные с конфигурацией канала.
Содержимое генерируемых артефактов соответствует содержимому файла `configtx.yaml`.

## Синтаксис

Команда `configtxgen` не имеет подкоманд, однако поддерживает флаги, предназначенные для выполнения ряда задач.

## configtxgen
```
Usage of configtxgen:
  -asOrg string
    	Performs the config generation as a particular organization (by name), only including values in the write set that org (likely) has privilege to set
  -channelCreateTxBaseProfile string
    	Specifies a profile to consider as the orderer system channel current state to allow modification of non-application parameters during channel create tx generation. Only valid in conjunction with 'outputCreateChannelTx'.
  -channelID string
    	The channel ID to use in the configtx
  -configPath string
    	The path containing the configuration to use (if set)
  -inspectBlock string
    	Prints the configuration contained in the block at the specified path
  -inspectChannelCreateTx string
    	Prints the configuration contained in the transaction at the specified path
  -outputAnchorPeersUpdate string
    	[DEPRECATED] Creates a config update to update an anchor peer (works only with the default channel creation, and only for the first update)
  -outputBlock string
    	The path to write the genesis block to (if set)
  -outputCreateChannelTx string
    	The path to write a channel creation configtx to (if set)
  -printOrg string
    	Prints the definition of an organization as JSON. (useful for adding an org to a channel manually)
  -profile string
    	The profile from configtx.yaml to use for generation.
  -version
    	Show version information
```

## Использование

### Получение первичного блока

Запись первичного блока для канала `orderer-system-channel` из профиля `SampleSingleMSPRaftV1_1` в файл `genesis_block.pb`.

```
configtxgen -outputBlock genesis_block.pb -profile SampleSingleMSPRaftV1_1 -channelID orderer-system-channel
```

### Получение транзакции создания канала

Запись транзакции создания канала из профиля `SampleSingleMSPChannelV1_1` в файл `create_chan_tx.pb`.

```
configtxgen -outputCreateChannelTx create_chan_tx.pb -profile SampleSingleMSPChannelV1_1 -channelID application-channel-1
```

### Просмотр первичного блока

Вывод содержимого первичного блока из файла `genesis_block.pb` в терминал в формате JSON.

```
configtxgen -inspectBlock genesis_block.pb
```

### Просмотр транзакции создания канала

Вывод транзакции создания канала из файла `create_chan_tx.pb` в терминал в формате JSON.

```
configtxgen -inspectChannelCreateTx create_chan_tx.pb
```

### Вывод определения организации

Формирует определение организации на основе таких параметров, как MSPDir из файла `configtx.yaml`, и выводит его 
в формате JSON в терминал (это удобно при изменении конфигурации канала, например, при добавлении нового члена).

```
configtxgen -printOrg Org1
```

### Вывод транзакции якорного узла (устаревшая)

Вывод из файла `anchor_peer_tx.pb` транзакции обновления определения якорных узлов для организации Org1 и 
профиля канала SampleSingleMSPChannelV1_1 в файле `configtx.yaml`. Транзакция устанавливает якорные узлы 
для организации Org1, если они еще не установлены в канале.
```
configtxgen -outputAnchorPeersUpdate anchor_peer_tx.pb -profile SampleSingleMSPChannelV1_1 -asOrg Org1
```

Флаг вывода `-outputAnchorPeersUpdate` является устаревшим. Для настройки якорных узлов в канале и обновления
конфигурации канала используется инструмент [configtxlator](configtxlator.html).

## Конфигурация

Результат работы инструмента `configtxgen` в значительной степени определяется содержимым файла `configtx.yaml`.
Этот файл является необходимым для работы `configtxgen` и по умолчанию должен находиться в директории, определенной
переменной окружения `FABRIC_CFG_PATH`.

В примере файла `configtx.yaml`, который входит состав Fabric, приводятся все возможные параметры конфигурации.
Этот файл находится в каталоге `config` tar-архива релиза. Также его можно найти в каталоге `sampleconfig` при
сборке из исходного кода.
