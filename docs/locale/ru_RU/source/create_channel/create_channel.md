# Создание нового канала 

В этом руководстве вы научитесь использовать инструмент командной строки [configtxgen](../commands/configtxgen.html),
а также команды [peer channel](../commands/peerchannel.html) для добавления одноранговых узлов в канал. Хотя в этом 
руководстве для создания нового канала используется тестовая сеть Fabric, все рассмотренные действия могут
использоваться операторами сети в производственной среде.

В рамках процесса создания канала будут рассмотрены следующие этапы:

- [Настройка инструмента configtxgen](#setting-up-the-configtxgen-tool)
- [Использование файла configtx.yaml](#the-configtx-yaml-file)
- [Системный канал службы упорядочения](#the-orderer-system-channel)
- [Создание канала приложений](#creating-an-application-channel)
- [Добавление одноранговых узлов в канал](#join-peers-to-the-channel)
- [Установка якорных узлов](#set-anchor-peers)

## Настройка инструмента configtxgen

Для создания канала сперва создается транзакция создания канала и отравляется в службу упорядочения. В транзакции 
создания канала указывается начальная конфигурация канала, которая используется службой упорядочения для записи
первичного блока канала. Несмотря на то, что файл транзакции создания канала можно создать вручную, легче воспользоваться
инструментом [configtxgen](../commands/configtxgen.html). Инструмент configtxgen считывает файл `configtx.yaml`,
в котором содержится конфигурация канала, а затем записывает соответствующую информацию в транзакцию создания канала. 
Прежде чем рассматривать файл `configtx.yaml`, загрузим и настроим инструмент `configtxgen`.

Исполняемые файлы для инструмента `configtxgen` можно скачать и установить, следуя инструкциям из [этого раздела](../install.html).
Инструмент `configtxgen` будет загружен в каталог `bin` локального репозитория `fabric-samples` вместе с другими инструментами Fabric.

В рамках этого учебного примера мы будем работать из подкаталога `test-network` каталога `fabric-samples`. Перейдите 
к каталогу `test-network`, используя следующую команду:
```
cd fabric-samples/test-network
```
До конца этого руководства мы будем использовать этот каталог. Используйте следующую команду для добавления инструмента configtxgen в путь интерфейса командной строки:
```
export PATH=${PWD}/../bin:$PATH
```

Для использования инструмента `configtxgen` необходимо в переменной среды `FABRIC_CFG_PATH` указать путь к каталогу,
в котором находится локальная копия файла `configtx.yaml`. В рамках этого руководства будем ссылаться на файл `configtx.yaml`
в каталоге ` configtx`, используемый для настройки примера сети Fabric:
```
export FABRIC_CFG_PATH=${PWD}/configtx
```

Для проверки того, что инструмент `configtxgen` работает, используйте следующую команду:
```
configtxgen --help
```


## Файл configtx.yaml

В файле `configtx.yaml` содержится информация, которая требуется для создания **конфигурация канала**,
в удобном для чтения и редактирования формате. Инструмент `configtxgen` использует профили каналов,
указанные в файле `configtx.yaml`, для создания конфигурации и сохранения ее в
[формате protobuf](https://developers.google.com/protocol-buffers), который считывается сетью Fabric.

Файл `configtx.yaml`, используемый для развертывания примера сети, расположен в подкаталоге `configtx` каталога `test-network`.
Файл содержит следующую информацию, которая будет использоваться для создания нового канала:

- **Organizations:** организации, которые могут стать членами канала. Каждая организация имеет ссылку на криптографические ключи, которые используются для создания [провайдера службы членства канала](../membership/membership.html).
- **Ordering service:** здесь указываются узлы, которые войдут в состав службы упорядочения сети, а также метод консенсуса для согласования порядка транзакций. В файле также указываются организации, которые станут администраторами службы упорядочения.
- **Channel policies:** в различных разделах файла указываются правила, которые будут управлять тем, как организации взаимодействуют с каналом, а также какие организации должны одобрять обновления канала. В рамках настоящего руководства будем использовать правила по умолчанию, используемые в сетях Fabric.
- **Channel profiles:** каждый профиль канала использует информацию из других разделов файла `configtx.yaml` для создания конфигурации канала. Профили используются при создании первичных блоков системного канала службы упорядочения и каналов, которые будут использоваться организациями с одноранговыми узлами. В отличие от системного канала, каналы, используемые организациями с одноранговыми узлами, часто называют каналами приложений.

  Инструмент `configtxgen` использует файл `configtx.yaml` для создания полноценного первичного блока системного канала. Т.е. в профиле системного канала должна быть указана полная конфигурация системного канала. Профиль канала, используемый для создания транзакции создания канала, должен содержать дополнительную информацию о конфигурации, необходимую для создания канала приложения.

Чтобы узнать больше об этом файле, смотрите раздел [Использование файла configtx.yaml для создания конфигурации канала](create_channel_config.html).
Теперь перейдем непосредственно к процессу создания канала, хотя мы будем возвращаться к этому файлу еще много раз.

## Запуск сети

Для создания канала нам понадобится тестовая сеть Fabric. В рамках этого учебного примера в качестве 
начального состояния будем использовать вновь созданную сеть. Следующая команда удалит любые активные или устаревшие контейнеры,
а также ранее созданные артефакты. Убедитесь, что вы находитесь в подкаталоге `test-network` локального клона `fabric-samples`.
```
./network.sh down
```
Следующая команда запустит пример сети:
```
./network.sh up
```
Эта команда создаст сеть Fabric с двумя организациями-членами и одной организацией службы упорядочения, определенной 
в файле `configtx.yaml`. У организаций-членов будет по одному одноранговому узлу, а организация-администратор службы 
упорядочения будет иметь один узел упорядочения. При выполнении этой команды сценарий выведет журналы создаваемых узлов:
```
Creating network "net_test" with the default driver
Creating volume "net_orderer.example.com" with default driver
Creating volume "net_peer0.org1.example.com" with default driver
Creating volume "net_peer0.org2.example.com" with default driver
Creating orderer.example.com    ... done
Creating peer0.org2.example.com ... done
Creating peer0.org1.example.com ... done
CONTAINER ID        IMAGE                               COMMAND             CREATED             STATUS                  PORTS                              NAMES
8d0c74b9d6af        hyperledger/fabric-orderer:latest   "orderer"           4 seconds ago       Up Less than a second   0.0.0.0:7050->7050/tcp             orderer.example.com
ea1cf82b5b99        hyperledger/fabric-peer:latest      "peer node start"   4 seconds ago       Up Less than a second   0.0.0.0:7051->7051/tcp             peer0.org1.example.com
cd8d9b23cb56        hyperledger/fabric-peer:latest      "peer node start"   4 seconds ago       Up 1 second             7051/tcp, 0.0.0.0:9051->9051/tcp   peer0.org2.example.com
```

В нашем случае пример сети развернут без создания канала приложения. Тем не менее скрипт примера сети создает системный
канал в случае использования команды `./network.sh up`. Точнее, скрипт использует инструмент `configtxgen` и файл `configtx.yaml` 
для создания первичного блока системного канала. Поскольку системный канал используется для создания других каналов,
следует уделить системному каналу службы упорядочения особое внимание, прежде чем переходить к созданию каналов приложений.

## Системный канал службы упорядочения

Системный канал является первым каналом, который создается в сети Fabric. В системном канале указываются узлы, 
формирующие службу упорядочения, а также набор организаций, которые являются администраторами службы упорядочения.

Системный канал также включает в себя организации с одноранговыми узлами, принадлежащие к [консорциуму](../glossary.html#consortium) блокчейна.
Консорциум представляет собой набор организаций-членов системного канала, которые не являются администраторами службы упорядочения.
Члены консорциума имеют возможность создавать новые каналы и добавлять в канал другие организации консорциума.

Первичный блок системного канала требуется для развертывания новой службы упорядочения. Скрипт запуска тестовой сети уже
создал первичный блок при выполнении команды `./network.sh up`. Первичный блок использовался при запуске одного
узла службы упорядочения для создания системного канала и службы упорядочения сети. Если посмотреть результат выполнения 
скрипта `./network.sh` в журнале, можно увидеть команду, которая создала первичный блок:
```
configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock ./system-genesis-block/genesis.block
```

Инструмент `configtxgen` использовал профиль канала `TwoOrgsOrdererGenesis` из файла `configtx.yaml` для записи первичного 
блока в каталог `system-genesis-block`. Профиль `TwoOrgsOrdererGenesis` показан ниже:
```yaml
TwoOrgsOrdererGenesis:
    <<: *ChannelDefaults
    Orderer:
        <<: *OrdererDefaults
        Organizations:
            - *OrdererOrg
        Capabilities:
            <<: *OrdererCapabilities
    Consortiums:
        SampleConsortium:
            Organizations:
                - *Org1
                - *Org2
```

Раздел `Orderer:` профиля создает один узел службы упорядочения Raft, используемой в примере сети, а также организацию `OrdererOrg`, 
в качестве администратора службы упорядочения. Раздел `Consortiums` профиля создает консорциум организаций с одноранговыми узлами
с именем `SampleConsortium:`. Обе организации с одноранговыми узлами, Org1 и Org2, являются членами консорциума. В результате мы 
можем добавить обе организации в новые каналы, созданные в тестовой сети. В случае необходимости добавления другой организации 
в канал без добавления этой организации в консорциум, сперва нужно создать канал, который включает организации Org1 и Org2,
а затем добавить другую организацию путем [обновления конфигурации канала](../channel_update_tutorial.html).

## Создание канала приложений

Теперь, когда узлы сети уже развернуты и создан канал службы упорядочения с помощью скрипта `network.sh`, можно приступить
к созданию нового канала для организаций с одноранговыми узлами. Мы уже установили переменные среды, которые необходимы 
для использования инструмента `configtxgen`. Выполните следующую команду для создания транзакции создания канала `channel1`:
```
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel1.tx -channelID channel1
```

В параметре `-channelID` указывается имя создаваемого канала. Имя канала должно содержать только строчные буквы и быть
не длиннее 250 символов, а также соответствовать регулярному выражению ``[a-z][a-z0-9.-]*``. Через флаг `-profile` команда
получает имя профиля `TwoOrgsChannel` из файла `configtx.yaml`, который используется тестовой сетью для создания каналов приложений:
```yaml
TwoOrgsChannel:
    Consortium: SampleConsortium
    <<: *ChannelDefaults
    Application:
        <<: *ApplicationDefaults
        Organizations:
            - *Org1
            - *Org2
        Capabilities:
            <<: *ApplicationCapabilities
```

В профиле указывается имя `SampleConsortium` из системного канала, а также две организации с одноранговыми узлами из консорциума 
в качестве членов канала. Так как системный канал используется в качестве шаблона при создании каналов приложений, 
узлы службы упорядочения, которые определенные в нем, становятся [упорядочивающими узлами канала](../glossary.html#consenter-set)
по умолчанию для новых каналов, в то время как администраторы службы упорядочения становятся администраторами службы упорядочения канала.
Набор узлов службы упорядочения канала может быть изменен при обновлении канала.

При успешном выполнении команды в журнале будет показана загрузка файла `configtx.yaml` инструментом `configtxgen`,
а также сохранение транзакции создания канала:
```
2020-03-11 16:37:12.695 EDT [common.tools.configtxgen] main -> INFO 001 Loading configuration
2020-03-11 16:37:12.738 EDT [common.tools.configtxgen.localconfig] Load -> INFO 002 Loaded configuration: /Usrs/fabric-samples/test-network/configtx/configtx.yaml
2020-03-11 16:37:12.740 EDT [common.tools.configtxgen] doOutputChannelCreateTx -> INFO 003 Generating new channel configtx
2020-03-11 16:37:12.789 EDT [common.tools.configtxgen] doOutputChannelCreateTx -> INFO 004 Writing new channel tx
```

Отправить транзакцию создания канала в службу упорядочивания можно, воспользовавшись инструментом командной строки.
Для этого необходимо указать в переменной среды `FABRIC_CFG_PATH` путь к файлу `core.yaml`, который находится в каталоге
`fabric-samples/config`. Установите значение для переменной среды `FABRIC_CFG_PATH` с помощью следующей команды:
```
export FABRIC_CFG_PATH=$PWD/../config/
```

Прежде чем служба упорядочения создаст канал, будет произведена проверка полномочий идентификатора, который отправил запрос.
По умолчанию создавать новые каналы могут только идентификаторы с ролью администратора организаций, принадлежащих к консорциуму
системного канала. Выполните следующие команды с помощью интерфейса командной строки одноранговых узлов от имени администратора организации Org1:
```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```

Теперь можно создать канал с помощью следующей команды:
```
peer channel create -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com -c channel1 -f ./channel-artifacts/channel1.tx --outputBlock ./channel-artifacts/channel1.block --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```

В приведенной выше команде путь к файлу транзакции создания канала указывается с помощью флага `-f`, а флаг `-c` позволяет 
указать имя канала. Флаг `-o` предназначен для выбора узла службы упорядочения, который будет использоваться при создании канала.
Флаг `--cafile` содержит путь к сертификату TLS узла службы упорядочения. При выполнении команды `peer channel create` 
интерфейс командной строки одноранговых узлов выдаст следующий результат:
```
2020-03-06 17:33:49.322 EST [channelCmd] InitCmdFactory -> INFO 00b Endorser and orderer connections initialized
2020-03-06 17:33:49.550 EST [cli.common] readBlock -> INFO 00c Received block: 0
```
Поскольку в рамках этого руководства используется служба упорядочения Raft, могут появиться сообщения о недоступности 
некоторых узлов, которые можно проигнорировать. Команда поместит первичный блок нового канала в файл, указанный с помощью флага `--outputBlock`.

### Присоединение одноранговых узлов к каналу 

После создания канала можно присоединять одноранговые узлы к каналу. Организации-члены канала могут получить первичный блок
канала от службы упорядочения с помощью команды [peer channel fetch](../commands/peerchannel.html#peer-channel-fetch) и
использовать его для присоединения однорангового узла к каналу с помощью команды [peer channel join](../commands/peerchannel.html#peer-channel-join).
После присоединения однорангового узла к каналу, узел создаст копию реестра блокчейн, получив присутствующие в канале блоки от службы упорядочения.

Поскольку мы используем интерфейс командной строки от имени администратора организации Org1, можно присоединить одноранговый узел этой
организации к каналу. Так как организация Org1 отправляла транзакцию создания канала, в нашей файловой системе уже хранится первичный блок канала.
Присоединим одноранговый узел организации Org1 к каналу с помощью следующей команды.
```
peer channel join -b ./channel-artifacts/channel1.block
```

В переменной среды `CORE_PEER_ADDRESS` указан адрес ``peer0.org1.example.com``. В случае успешного выполнения команды
будет получен ответ о добавлении узла ``peer0.org1.example.com`` в канал:
```
2020-03-06 17:49:09.903 EST [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
2020-03-06 17:49:10.060 EST [channelCmd] executeJoin -> INFO 002 Successfully submitted proposal to join channel
```

Чтобы проверить, что одноранговый узел присоединился к каналу, используйте команду [peer channel getinfo](../commands/peerchannel.html#peer-channel-getinfo):
```
peer channel getinfo -c channel1
```
Команда выведет на экран количество блоков канала и хеш последнего блока. Поскольку первичный блок является единственным блоком в канале,
количество блоков в канале (длина канала) будет равно единице:
```
2020-03-13 10:50:06.978 EDT [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
Blockchain info: {"height":1,"currentBlockHash":"kvtQYYEL2tz0kDCNttPFNC4e6HVUFOGMTIDxZ+DeNQM="}
```

Теперь добавим одноранговый узел организации Org2 к каналу. Установите следующие переменные среды для работы с интерфейсом 
командной строки одноранговых узлов от имени администратора организации Org2. Одноранговый узел ``peer0.org2.example.com``
организации Org2 также будет указан в переменных среды в качестве целевого узла.
```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
```

Хотя первичный блок канала еще по-прежнему хранится в файловой системе, в реальной сети организации Org2 потребуется получить 
этот блок от службы упорядочения. Используйте команду `peer channel fetch` для получения первичного блока для организации Org2:
```
peer channel fetch 0 ./channel-artifacts/channel_org2.block -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```

Указанный `0` в команде подразумевает запрос первичного блока, который требуется для присоединения к каналу. Если команда завершена успешно,
будет отображен следующий результат:
```
2020-03-13 11:32:06.309 EDT [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
2020-03-13 11:32:06.336 EDT [cli.common] readBlock -> INFO 002 Received block: 0
```

Команда возвращает первичный блок канала и называет его `channel_org2.block`, что позволяет отличить его от блока,
полученного организацией Org1. Теперь используем этот блок для присоединения однорангового узла организации Org2 к каналу.
```
peer channel join -b ./channel-artifacts/channel_org2.block
```

## Установка якорных узлов

После присоединения одноранговых узлов к каналу организации должны выбрать хотя бы один из своих узлов в качестве якорного.
[Якорные узлы](../gossip.html#anchor-peers) в полной мере раскрывают возможности использования закрытых данных и обнаружения служб.
Каждая организация должна установить несколько якорных узлов в канале в качестве резервных. Более подробная информация о протоколе
gossip и якорных узлах приведена в разделе [Протокол распространения данных gossip](../gossip.html).

Адреса якорных узлов каждой из организаций хранятся в конфигурации канала. Члены канала могут указать свои якорные узлы во время
обновления конфигурации канала. Воспользуйтесь инструментом [configtxlator](../commands/configtxlator.html) для обновления конфигурации
канала и выбора якорных узлов для организации Org1 и Org2. Процесс установки якорного узла аналогичен процессу обновления конфигурации 
канала и является хорошей возможностью попробовать инструмент `configtxlator` в действии для [обновления конфигурации канала](../config_update.html).
Также потребуется установить [инструмент jq](https://stedolan.github.io/jq/) на вашем компьютере.

Начнем с выбора якорного узла от имени организации Org1. Сперва получим последний блок конфигурации канала, используя команду `peer channel fetch`.
Установите следующие переменные среды для работы с интерфейсом командной строки одноранговых узлов от имени администратора организации Org1:
```
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```

Выполните следующую команду для получения конфигурации канала:
```
peer channel fetch config channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```
Поскольку последний блок конфигурации канала является первичным блоком канала, команда вернет блок 0 из канала.
```
2020-04-15 20:41:56.595 EDT [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
2020-04-15 20:41:56.603 EDT [cli.common] readBlock -> INFO 002 Received block: 0
2020-04-15 20:41:56.603 EDT [channelCmd] fetch -> INFO 003 Retrieving last config block: 0
2020-04-15 20:41:56.608 EDT [cli.common] readBlock -> INFO 004 Received block: 0
```

Блок конфигурации канала хранится в каталоге `channel-artifacts`, чтобы отделить процесс обновления от других артефактов.
Перейдите в каталог `channel-artifacts` для осуществления последующих действий:
```
cd channel-artifacts
```
Теперь можно воспользоваться инструментом `configtxlator`, чтобы начать работу с конфигурацией канала. 
Сперва сконвертируйте блок из формата protobuf в объект JSON, который можно легко прочитать и отредактировать.
Также удалите ненужные данные блока, оставив только конфигурацию канала.

```
configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
jq .data.data[0].payload.data.config config_block.json > config.json
```

Эти команды преобразуют блок конфигурации канала в упорядоченный файл формата JSON (`config.json`),
который послужит исходником для обновления. Поскольку этот файл понадобится дальше в неизменном виде,
сделаем копию для возможности редактирования. Оригинальная конфигурация канала понадобится на следующих этапах.
```
cp config.json config_copy.json
```

Воспользуйтесь инструментом `jq`, чтобы добавить якорный узел организации Org1 в конфигурацию канала.
```
jq '.channel_group.groups.Application.groups.Org1MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.org1.example.com","port": 7051}]},"version": "0"}}' config_copy.json > modified_config.json
```

Эта операция создаст обновленную версию конфигурации канала в файле `modified_config.json` формата JSON.
Теперь можно преобразовать оригинальную и измененную конфигурации канала в формат protobuf и рассчитать разницу между ними.
```
configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id channel1 --original config.pb --updated modified_config.pb --output config_update.pb
```

Новый файл формата protobuf `channel_update.pb` содержит обновление с новыми якорными узлами, которое необходимо применить 
к конфигурации канала. Оберните обновление конфигурации в конверт транзакции, чтобы создать транзакцию обновления конфигурации канала.

```
configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"channel1", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json
configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb
```

Теперь для обновления конфигурации канала можно использовать артифакт `config_update_in_envelope.pb`. Перейдите обратно к каталогу `test-network`:
```
cd ..
```

Добавьте якорный узел, указав новую конфигурацию канала в команде `peer channel update`.
Поскольку мы обновляем раздел конфигурации канала, который влияет только на организацию Org1, нет необходимости в
одобрении изменений другими членами канала.
```
peer channel update -f channel-artifacts/config_update_in_envelope.pb -c channel1 -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```

Если команда выполнена успешно, будет отображен следующий результат:
```
2020-01-09 21:30:45.791 UTC [channelCmd] update -> INFO 002 Successfully submitted channel update
```

Теперь настройте якорные узлы для организации Org2. Так как процесс идентичен предыдущим действиям, не будем слишком подробно останавливаться на каждом из шагов.
Установите следующие переменные среды для работы с интерфейсом командной строки одноранговых узлов от имени администратора организации Org2:
```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
```

Запросите последний блок конфигурации канала, который сейчас является вторым блоком в канале:
```
peer channel fetch config channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```

Перейдите к каталогу `channel-artifacts`:
```
cd channel-artifacts
```

Далее можно сконвертировать и скопировать блок конфигурации.
```
configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
jq .data.data[0].payload.data.config config_block.json > config.json
cp config.json config_copy.json
```

Укажите узел организации Org2, который был добавлен в канал в качестве якорного узла в конфигурации канала:
```
jq '.channel_group.groups.Application.groups.Org2MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.org2.example.com","port": 9051}]},"version": "0"}}' config_copy.json > modified_config.json
```

Теперь можно преобразовать оригинальную и измененную конфигурации канала в формат protobuf и рассчитать разницу между ними.
```
configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id channel1 --original config.pb --updated modified_config.pb --output config_update.pb
```

Оберните обновление конфигурации в конверт транзакции, чтобы создать транзакцию обновления конфигурации канала.
```
configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"channel1", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json
configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb
```

Перейдите обратно к каталогу `test-network`:
```
cd ..
```

Обновите канал, указав якорный узел организации Org2, с помощью следующей команды:
```
peer channel update -f channel-artifacts/config_update_in_envelope.pb -c channel1 -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```

Чтобы убедиться, что канал успешно обновлен, выполните команду `peer channel info`:
```
peer channel getinfo -c channel1
```
Теперь, после обновления канала путем добавления двух блоков конфигурации канала в дополнение к первичному блоку, количество блоков в канале выросло до трех:
```
Blockchain info: {"height":3,"currentBlockHash":"eBpwWKTNUgnXGpaY2ojF4xeP3bWdjlPHuxiPCTIMxTk=","previousBlockHash":"DpJ8Yvkg79XHXNfdgneDb0jjQlXLb/wxuNypbfHMjas="}
```

## Развертывание чейнкода в новом канале

Чтобы убедиться в успешном создании канала, разверните чейнкод в канале. Можно воспользоваться скриптом `network.sh`
для развертывания чейнкода Fabcar в любом канале тестовой сети. Разверните чейнкод в новом канале с помощью следующей команды:
```
./network.sh deployCC -c channel1
```

После выполнения команды в журнале можно увидеть, что чейнкод развернут в канале. Чейнкод вызывается для добавления
данных в реестр канала, а затем – для чтения этих данных.
```
[{"Key":"CAR0","Record":{"make":"Toyota","model":"Prius","colour":"blue","owner":"Tomoko"}},
{"Key":"CAR1","Record":{"make":"Ford","model":"Mustang","colour":"red","owner":"Brad"}},
{"Key":"CAR2","Record":{"make":"Hyundai","model":"Tucson","colour":"green","owner":"Jin Soo"}},
{"Key":"CAR3","Record":{"make":"Volkswagen","model":"Passat","colour":"yellow","owner":"Max"}},
{"Key":"CAR4","Record":{"make":"Tesla","model":"S","colour":"black","owner":"Adriana"}},
{"Key":"CAR5","Record":{"make":"Peugeot","model":"205","colour":"purple","owner":"Michel"}},
{"Key":"CAR6","Record":{"make":"Chery","model":"S22L","colour":"white","owner":"Aarav"}},
{"Key":"CAR7","Record":{"make":"Fiat","model":"Punto","colour":"violet","owner":"Pari"}},
{"Key":"CAR8","Record":{"make":"Tata","model":"Nano","colour":"indigo","owner":"Valeria"}},
{"Key":"CAR9","Record":{"make":"Holden","model":"Barina","colour":"brown","owner":"Shotaro"}}]
===================== Query successful on peer0.org1 on channel 'channel1' =====================
```
