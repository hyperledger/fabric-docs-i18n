# Команда peer lifecycle chaincode

Команда `peer lifecycle chaincode` позволяет администраторам использовать жизненный цикл чейнкода Fabric для упаковки чейнкода, 
установки его на одноранговые узлы, одобрения определения чейнкода в рамках организации, а затем отправку определений в канал.
Чейнкод можно использовать после успешной записи его определения в канале. 
Более подробно это описано в разделе [Жизненный цикл чейнкода Fabric](../chaincode_lifecycle.html).

*Обратите внимание, что в этом разделе описывается жизненный цикл чейнкода Fabric версии 2.0. 
Если необходимо использовать жизненный цикл предыдущей версии для установки и создания чейнкода, 
смотрите раздел, посвященный командам [peer chaincode](peerchaincode.html).*

## Синтаксис

Команда `peer lifecycle chaincode` имеет следующие подкоманды:

  * package
  * install
  * queryinstalled
  * getinstalledpackage
  * approveformyorg
  * queryapproved
  * checkcommitreadiness
  * commit
  * querycommitted

Каждая подкоманда `peer lifecycle` описана вместе с ее опциями в последующих разделах этой статьи.

## peer lifecycle

Выполнение операций жизненного цикла Fabric.

```
Perform _lifecycle operations

Usage:
  peer lifecycle [command]

Available Commands:
  chaincode   Perform chaincode operations: package|install|queryinstalled|getinstalledpackage|approveformyorg|queryapproved|checkcommitreadiness|commit|querycommitted

Flags:
  -h, --help   help for lifecycle

Use "peer lifecycle [command] --help" for more information about a command.
```


## peer lifecycle chaincode

Выполнение операций с жизненным циклом чейнкода.

```
Perform chaincode operations: package|install|queryinstalled|getinstalledpackage|approveformyorg|queryapproved|checkcommitreadiness|commit|querycommitted

Usage:
  peer lifecycle chaincode [command]

Available Commands:
  approveformyorg      Approve the chaincode definition for my org.
  checkcommitreadiness Check whether a chaincode definition is ready to be committed on a channel.
  commit               Commit the chaincode definition on the channel.
  getinstalledpackage  Get an installed chaincode package from a peer.
  install              Install a chaincode.
  package              Package a chaincode
  queryapproved        Query an org's approved chaincode definition from its peer.
  querycommitted       Query the committed chaincode definitions by channel on a peer.
  queryinstalled       Query the installed chaincodes on a peer.

Flags:
      --cafile string                       Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --certfile string                     Path to file containing PEM-encoded X509 public key to use for mutual TLS communication with the orderer endpoint
      --clientauth                          Use mutual TLS when communicating with the orderer endpoint
      --connTimeout duration                Timeout for client to connect (default 3s)
  -h, --help                                help for chaincode
      --keyfile string                      Path to file containing PEM-encoded private key to use for mutual TLS communication with the orderer endpoint
  -o, --orderer string                      Ordering service endpoint
      --ordererTLSHostnameOverride string   The hostname override to use when validating the TLS connection to the orderer.
      --tls                                 Use TLS when communicating with the orderer endpoint

Use "peer lifecycle chaincode [command] --help" for more information about a command.
```


## peer lifecycle chaincode package

Упаковка чейнкода и сохранение пакета в файл.

```
Package a chaincode and write the package to a file.

Usage:
  peer lifecycle chaincode package [outputfile] [flags]

Flags:
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -h, --help                           help for package
      --label string                   The package label contains a human-readable description of the package
  -l, --lang string                    Language the chaincode is written in (default "golang")
  -p, --path string                    Path to the chaincode
      --peerAddresses stringArray      The addresses of the peers to connect to
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag

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


## peer lifecycle chaincode install

Установка чейнкода на одноранговый узел.

```
Install a chaincode on a peer.

Usage:
  peer lifecycle chaincode install [flags]

Flags:
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -h, --help                           help for install
      --peerAddresses stringArray      The addresses of the peers to connect to
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag

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


## peer lifecycle chaincode queryinstalled

Запрос списка чейнкодов, установленных на одноранговом узле.

```
Query the installed chaincodes on a peer.

Usage:
  peer lifecycle chaincode queryinstalled [flags]

Flags:
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -h, --help                           help for queryinstalled
  -O, --output string                  The output format for query results. Default is human-readable plain-text. json is currently the only supported format.
      --peerAddresses stringArray      The addresses of the peers to connect to
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag

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


## peer lifecycle chaincode getinstalledpackage

Получение пакета установленного чейнкода с однорангового узла.

```
Get an installed chaincode package from a peer.

Usage:
  peer lifecycle chaincode getinstalledpackage [outputfile] [flags]

Flags:
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -h, --help                           help for getinstalledpackage
      --output-directory string        The output directory to use when writing a chaincode install package to disk. Default is the current working directory.
      --package-id string              The identifier of the chaincode install package
      --peerAddresses stringArray      The addresses of the peers to connect to
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag

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


## peer lifecycle chaincode approveformyorg

Одобрение определения чейнкода для своей организации.

```
Approve the chaincode definition for my organization.

Usage:
  peer lifecycle chaincode approveformyorg [flags]

Flags:
      --channel-config-policy string   The endorsement policy associated to this chaincode specified as a channel config policy reference
  -C, --channelID string               The channel on which this command should be executed
      --collections-config string      The fully qualified path to the collection JSON file including the file name
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -E, --endorsement-plugin string      The name of the endorsement plugin to be used for this chaincode
  -h, --help                           help for approveformyorg
      --init-required                  Whether the chaincode requires invoking 'init'
  -n, --name string                    Name of the chaincode
      --package-id string              The identifier of the chaincode install package
      --peerAddresses stringArray      The addresses of the peers to connect to
      --sequence int                   The sequence number of the chaincode definition for the channel
      --signature-policy string        The endorsement policy associated to this chaincode specified as a signature policy
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag
  -V, --validation-plugin string       The name of the validation plugin to be used for this chaincode
  -v, --version string                 Version of the chaincode
      --waitForEvent                   Whether to wait for the event from each peer's deliver filtered service signifying that the transaction has been committed successfully (default true)
      --waitForEventTimeout duration   Time to wait for the event from each peer's deliver filtered service signifying that the 'invoke' transaction has been committed successfully (default 30s)

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


## peer lifecycle chaincode queryapproved

Запрос одобренного организацией определения чейнкода с ее одрорангового узла.

```
Query an organization's approved chaincode definition from its peer.

Usage:
  peer lifecycle chaincode queryapproved [flags]

Flags:
  -C, --channelID string               The channel on which this command should be executed
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -h, --help                           help for queryapproved
  -n, --name string                    Name of the chaincode
  -O, --output string                  The output format for query results. Default is human-readable plain-text. json is currently the only supported format.
      --peerAddresses stringArray      The addresses of the peers to connect to
      --sequence int                   The sequence number of the chaincode definition for the channel
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag

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


## peer lifecycle chaincode checkcommitreadiness

Проверка готовности определения чейнкода к отправке в канал.

```
Check whether a chaincode definition is ready to be committed on a channel.

Usage:
  peer lifecycle chaincode checkcommitreadiness [flags]

Flags:
      --channel-config-policy string   The endorsement policy associated to this chaincode specified as a channel config policy reference
  -C, --channelID string               The channel on which this command should be executed
      --collections-config string      The fully qualified path to the collection JSON file including the file name
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -E, --endorsement-plugin string      The name of the endorsement plugin to be used for this chaincode
  -h, --help                           help for checkcommitreadiness
      --init-required                  Whether the chaincode requires invoking 'init'
  -n, --name string                    Name of the chaincode
  -O, --output string                  The output format for query results. Default is human-readable plain-text. json is currently the only supported format.
      --peerAddresses stringArray      The addresses of the peers to connect to
      --sequence int                   The sequence number of the chaincode definition for the channel
      --signature-policy string        The endorsement policy associated to this chaincode specified as a signature policy
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag
  -V, --validation-plugin string       The name of the validation plugin to be used for this chaincode
  -v, --version string                 Version of the chaincode

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


## peer lifecycle chaincode commit

Отправка определения чейнкода в канал.

```
Commit the chaincode definition on the channel.

Usage:
  peer lifecycle chaincode commit [flags]

Flags:
      --channel-config-policy string   The endorsement policy associated to this chaincode specified as a channel config policy reference
  -C, --channelID string               The channel on which this command should be executed
      --collections-config string      The fully qualified path to the collection JSON file including the file name
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -E, --endorsement-plugin string      The name of the endorsement plugin to be used for this chaincode
  -h, --help                           help for commit
      --init-required                  Whether the chaincode requires invoking 'init'
  -n, --name string                    Name of the chaincode
      --peerAddresses stringArray      The addresses of the peers to connect to
      --sequence int                   The sequence number of the chaincode definition for the channel
      --signature-policy string        The endorsement policy associated to this chaincode specified as a signature policy
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag
  -V, --validation-plugin string       The name of the validation plugin to be used for this chaincode
  -v, --version string                 Version of the chaincode
      --waitForEvent                   Whether to wait for the event from each peer's deliver filtered service signifying that the transaction has been committed successfully (default true)
      --waitForEventTimeout duration   Time to wait for the event from each peer's deliver filtered service signifying that the 'invoke' transaction has been committed successfully (default 30s)

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


## peer lifecycle chaincode querycommitted

Запрос списка определений чейнкодов, отправленных в канал и развернутых на однограногом узле. Опционально можно указать
имя чейнкода для получения конкретного определения.

```
Query the committed chaincode definitions by channel on a peer. Optional: provide a chaincode name to query a specific definition.

Usage:
  peer lifecycle chaincode querycommitted [flags]

Flags:
  -C, --channelID string               The channel on which this command should be executed
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -h, --help                           help for querycommitted
  -n, --name string                    Name of the chaincode
  -O, --output string                  The output format for query results. Default is human-readable plain-text. json is currently the only supported format.
      --peerAddresses stringArray      The addresses of the peers to connect to
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag

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


## Примеры использования

### Пример использования команды peer lifecycle chaincode package

Перед установкой на одноранговые узлы чейнкод должен быть упакован. Для упаковки чейнкода, написанного на языке Go,
можно воспользоваться командой `peer lifecycle chaincode package`.

  * Флаг `--path` указывает путь к чейнкоду. Путь должен быть полным или относительным для текущего рабочего каталога.
  * Флаг `--label` указывает метку пакета чейнкода `myccv1`, которая будет использоваться организацией для идентификации пакета.

    ```
    peer lifecycle chaincode package mycc.tar.gz --path $CHAINCODE_DIR --lang golang --label myccv1
    ```

### Пример использования команды peer lifecycle chaincode install

После упаковки чейнкода можно использовать команду `peer lifecycle chaincode install` для установки чейнкода на одноранговые узлы.

  * Устанавливает пакет `mycc.tar.gz ` на узле `peer0.org1.example.com:7051` (узел, указанный с флагом `--peerAddresses`).

    ```
    peer lifecycle chaincode install mycc.tar.gz --peerAddresses peer0.org1.example.com:7051
    ```
    При успешном выполнении команда возвращает идентификатор пакета, представляющий собой метку пакета 
    в сочетании с хешем пакета чейнкода, который устанавливается на одноранговый узел.
    
    ```
    2019-03-13 13:48:53.691 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 001 Installed remotely: response:<status:200 payload:"\nEmycc:ebd89878c2bbccf62f68c36072626359376aa83c36435a058d453e8dbfd894cc" >
    2019-03-13 13:48:53.691 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 002 Chaincode code package identifier: mycc:a7ca45a7cc85f1d89c905b775920361ed089a364e12a9b6d55ba75c965ddd6a9
    ```

### Пример использования команды peer lifecycle chaincode queryinstalled

Идентификатор пакета чейнкода используется для одобрения определения чейнкода организацией. Идентификаторы можно 
получить с помощью команды `peer lifecycle chaincode queryinstalled` для всех установленных чейнкодов:

```
peer lifecycle chaincode queryinstalled --peerAddresses peer0.org1.example.com:7051
```

Успешное выполнение команды возвращает идентификатор пакета, соответствующий метке пакета.

```
Get installed chaincodes on peer:
Package ID: myccv1:a7ca45a7cc85f1d89c905b775920361ed089a364e12a9b6d55ba75c965ddd6a9, Label: myccv1
```

  * Флаг `--output` позволяет получить результат в формате JSON.

    ```
    peer lifecycle chaincode queryinstalled --peerAddresses peer0.org1.example.com:7051 --output json
    ```

    При успешном выполнении команда возвращает установленный чейнкод в формате JSON.

    ```
    {
      "installed_chaincodes": [
        {
          "package_id": "mycc_1:aab9981fa5649cfe25369fce7bb5086a69672a631e4f95c4af1b5198fe9f845b",
          "label": "mycc_1",
          "references": {
            "mychannel": {
              "chaincodes": [
                {
                  "name": "mycc",
                  "version": "1"
                }
              ]
            }
          }
        }
      ]
    }
    ```

### Пример использования команды peer lifecycle chaincode getinstalledpackage

Получить пакет установленного на одноранговый узел чейнкода можно с помощью команды `peer lifecycle chaincode getinstalledpackage`. 
В этой команде следует использовать идентификатор пакета, возвращаемый командой с опцией `queryinstalled`.

  * Флаг `--package-id` предназначен для передачи идентификатора пакета чейнкода. Флаг `--output-directory` позволяет 
    указать путь размещения пакета чейнкода. Если этот каталог не указан, пакет чейнкода будет размещен в текущем каталоге.

  ```
  peer lifecycle chaincode getinstalledpackage --package-id myccv1:a7ca45a7cc85f1d89c905b775920361ed089a364e12a9b6d55ba75c965ddd6a9 --output-directory /tmp --peerAddresses peer0.org1.example.com:7051
  ```


### Пример использования команды peer lifecycle chaincode approveformyorg

После установки пакета чейнкода на одноранговых узлах вы можете одобрить определение чейнкода для своей организации.
Определение чейнкода включает в себя важные параметры управления чейнкодом, включая имя, версию и правила одобрения.

Ниже приводится пример использования команды  `peer lifecycle chaincode approveformyorg`, которая одобряет определение 
чейнкода с именем `mycc` и версией `1.0` в канале `mychannel`.

  * Флаг `--package-id` предназначен для передачи идентификатора пакета чейнкода. Флаг `--signature-policy`
    позволяет указать правила одобрения для чейнкода. Флаг `init-required` требует выполнение функции `Init` для инициализации чейнкода.

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    peer lifecycle chaincode approveformyorg  -o orderer.example.com:7050 --tls --cafile $ORDERER_CA --channelID mychannel --name mycc --version 1.0 --init-required --package-id myccv1:a7ca45a7cc85f1d89c905b775920361ed089a364e12a9b6d55ba75c965ddd6a9 --sequence 1 --signature-policy "AND ('Org1MSP.peer','Org2MSP.peer')"

    2019-03-18 16:04:09.046 UTC [cli.lifecycle.chaincode] InitCmdFactory -> INFO 001 Retrieved channel (mychannel) orderer endpoint: orderer.example.com:7050
    2019-03-18 16:04:11.253 UTC [chaincodeCmd] ClientWait -> INFO 002 txid [efba188ca77889cc1c328fc98e0bb12d3ad0abcda3f84da3714471c7c1e6c13c] committed with status (VALID) at peer0.org1.example.com:7051
    ```

  * Также можно указать флаг `--channel-config-policy`, чтобы использовать правила в конфигурации канала в качестве правил одобрения чейнкода. 
    Правилами одобрения по умолчанию являются правила `Channel/Application/Endorsement`.

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    peer lifecycle chaincode approveformyorg -o orderer.example.com:7050 --tls --cafile $ORDERER_CA --channelID mychannel --name mycc --version 1.0 --init-required --package-id myccv1:a7ca45a7cc85f1d89c905b775920361ed089a364e12a9b6d55ba75c965ddd6a9 --sequence 1 --channel-config-policy Channel/Application/Admins

    2019-03-18 16:04:09.046 UTC [cli.lifecycle.chaincode] InitCmdFactory -> INFO 001 Retrieved channel (mychannel) orderer endpoint: orderer.example.com:7050
    2019-03-18 16:04:11.253 UTC [chaincodeCmd] ClientWait -> INFO 002 txid [efba188ca77889cc1c328fc98e0bb12d3ad0abcda3f84da3714471c7c1e6c13c] committed with status (VALID) at peer0.org1.example.com:7051
    ```

### Пример использования команды peer lifecycle chaincode queryapproved

Для получения одобренного организацией определения чейнкода предусмотрена команда `peer lifecycle chaincode queryapproved`.
Эта команда позволяет посмотреть подробности (включая идентификатор пакета) одобренных определений чейнкода.

  * Ниже приведен пример использования команды `peer lifecycle chaincode queryapproved`, которая запрашивает одобренное 
    определение чейнкода с именем `mycc` и порядковым номером `1`, записанное в канале `mychannel`.

    ```
    peer lifecycle chaincode queryapproved -C mychannel -n mycc --sequence 1

    Approved chaincode definition for chaincode 'mycc' on channel 'mychannel':
    sequence: 1, version: 1, init-required: true, package-id: mycc_1:d02f72000e7c0f715840f51cb8d72d70bc1ba230552f8445dded0ec8b6e0b830, endorsement plugin: escc, validation plugin: vscc
    ```

    Если для одобренного определения не указан пакет, эта команда вернет пустой идентификатор пакета.

  * Также можно использовать эту команду без указания порядкового номера, чтобы запросить последнее одобренное определение
    (более новое, чем текущий указанный порядковый номер и следующий порядковый номер).

    ```
    peer lifecycle chaincode queryapproved -C mychannel -n mycc

    Approved chaincode definition for chaincode 'mycc' on channel 'mychannel':
    sequence: 3, version: 3, init-required: false, package-id: mycc_1:d02f72000e7c0f715840f51cb8d72d70bc1ba230552f8445dded0ec8b6e0b830, endorsement plugin: escc, validation plugin: vscc
    ```

  * Также можно использовать флаг `--output`, чтобы выходная информация командной строки выводилась в формате JSON.

    - При запросе одобренного определения чейнкода, для которого указан пакет.

      ```
      peer lifecycle chaincode queryapproved -C mychannel -n mycc --sequence 1 --output json
      ```

      При успешном выполнении команда вернет информацию в формате JSON, содержащую одобренное определение чейнкода `mycc` с порядковым номером `1`, записанного в канале `mychannel`.

      ```
      {
        "sequence": 1,
        "version": "1",
        "endorsement_plugin": "escc",
        "validation_plugin": "vscc",
        "validation_parameter": "EiAvQ2hhbm5lbC9BcHBsaWNhdGlvbi9FbmRvcnNlbWVudA==",
        "collections": {},
        "init_required": true,
        "source": {
          "Type": {
            "LocalPackage": {
              "package_id": "mycc_1:d02f72000e7c0f715840f51cb8d72d70bc1ba230552f8445dded0ec8b6e0b830"
            }
          }
        }
      }
      ```

    - При запросе одобренного определения чейнкода, для которого НЕ указан пакет.

      ```
      peer lifecycle chaincode queryapproved -C mychannel -n mycc --sequence 2 --output json
      ```

      При успешном выполнении команда вернет информацию в формате JSON, содержащую одобренное определение чейнкода `mycc` с порядковым номером `2`, записанного в канале `mychannel`.

      ```
      {
        "sequence": 2,
        "version": "2",
        "endorsement_plugin": "escc",
        "validation_plugin": "vscc",
        "validation_parameter": "EiAvQ2hhbm5lbC9BcHBsaWNhdGlvbi9FbmRvcnNlbWVudA==",
        "collections": {},
        "source": {
          "Type": {
            "Unavailable": {}
          }
        }
      }
      ```

### Пример использования команды peer lifecycle chaincode checkcommitreadiness

Проверить готовность определения чейнкода к записи в канал можно проверить с помощью команды `lifecycle chaincode checkcommitreadiness`, 
которая успешно завершается, если определение чейнкода готово к записи (и будет успешно записано). Также команда возвращает список организаций,
которые одобрили определение чейнкода. Если организация одобрила указанное в команде определение чейнкода, команда вернет значение true.
Эту команду можно использовать, чтобы узнать — достаточное ли количество членов канала одобрили определение чейнкода для удовлетворения
требований правил `Application/Channel/Endorsement` (по умолчанию большинство) и записи определения в канал.

  Ниже приводится пример использования команды `peer lifecycle chaincode checkcommitreadiness`, которая проверяет чейнкода с названием `mycc` версии `1.0` в канале `mychannel`.

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    peer lifecycle chaincode checkcommitreadiness -o orderer.example.com:7050 --channelID mychannel --tls --cafile $ORDERER_CA --name mycc --version 1.0 --init-required --sequence 1
    ```

    При успешном выполнении команда возвращает список организаций, которые одобрили определение чейнкода.

    ```
    Chaincode definition for chaincode 'mycc', version '1.0', sequence '1' on channel
    'mychannel' approval status by org:
    Org1MSP: true
    Org2MSP: true
    ```

  * Можно использовать флаг `--output`, чтобы выходная информация командной строки выводилась в формате JSON.

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    peer lifecycle chaincode checkcommitreadiness -o orderer.example.com:7050 --channelID mychannel --tls --cafile $ORDERER_CA --name mycc --version 1.0 --init-required --sequence 1 --output json
    ```

    При успешном выполнении команда вернет коллекцию в формате JSON, в которой указывается одобрение определений чейнкода организацией.

    ```
    {
       "Approvals": {
          "Org1MSP": true,
          "Org2MSP": true
       }
    }
    ```

### Пример использования команды peer lifecycle chaincode commit

После получения достаточного количества одобрений определения чейнкода от организаций (большинство по умолчанию),
одна организация может отправить определение в канал с помощью команды `peer lifecycle chaincode commit`:

  * В этой команде указываются одноранговые узлы других организаций в канале для получения одобрения определения чейнкода от этих организаций.

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID mychannel --name mycc --version 1.0 --sequence 1 --init-required --tls --cafile $ORDERER_CA --peerAddresses peer0.org1.example.com:7051 --peerAddresses peer0.org2.example.com:9051

    2019-03-18 16:14:27.258 UTC [chaincodeCmd] ClientWait -> INFO 001 txid [b6f657a14689b27d69a50f39590b3949906b5a426f9d7f0dcee557f775e17882] committed with status (VALID) at peer0.org2.example.com:9051
    2019-03-18 16:14:27.321 UTC [chaincodeCmd] ClientWait -> INFO 002 txid [b6f657a14689b27d69a50f39590b3949906b5a426f9d7f0dcee557f775e17882] committed with status (VALID) at peer0.org1.example.com:7051
    ```

### Пример использования команды peer lifecycle chaincode querycommitted

Для получения записанных в канале определений чейнкода используйте команду `peer lifecycle chaincode querycommitted`. 
Эту команду можно использовать для получения текущего порядкового номера определения перед обновлением чейнкода.

  * Необходимо указать название чейнкода и канала для получения конкретного определения чейнкода, а также перечня организаций, которые одобрили это определение.

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    peer lifecycle chaincode querycommitted -o orderer.example.com:7050 --channelID mychannel --name mycc --tls --cafile $ORDERER_CA --peerAddresses peer0.org1.example.com:7051

    Committed chaincode definition for chaincode 'mycc' on channel 'mychannel':
    Version: 1, Sequence: 1, Endorsement Plugin: escc, Validation Plugin: vscc
    Approvals: [Org1MSP: true, Org2MSP: true]
    ```

  * Также можно указать только название канала, чтобы запросить все определения чейнкода в этом канале.

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    peer lifecycle chaincode querycommitted -o orderer.example.com:7050 --channelID mychannel --tls --cafile $ORDERER_CA --peerAddresses peer0.org1.example.com:7051

    Committed chaincode definitions on channel 'mychannel':
    Name: mycc, Version: 1, Sequence: 1, Endorsement Plugin: escc, Validation Plugin: vscc
    Name: yourcc, Version: 2, Sequence: 3, Endorsement Plugin: escc, Validation Plugin: vscc
    ```

  * Можно использовать флаг `--output`, чтобы информация командной строки выводилась в формате JSON.

    - Для запроса конкретного определения чейнкода

      ```
      export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

      peer lifecycle chaincode querycommitted -o orderer.example.com:7050 --channelID mychannel --name mycc --tls --cafile $ORDERER_CA --peerAddresses peer0.org1.example.com:7051 --output json
      ```

      При успешном выполнении команда вернет определение чейнкода `mycc`, записанного в канале `mychannel`, в формате JSON.

      ```
      {
        "sequence": 1,
        "version": "1",
        "endorsement_plugin": "escc",
        "validation_plugin": "vscc",
        "validation_parameter": "EiAvQ2hhbm5lbC9BcHBsaWNhdGlvbi9FbmRvcnNlbWVudA==",
        "collections": {},
        "init_required": true,
        "approvals": {
          "Org1MSP": true,
          "Org2MSP": true
        }
      }
      ```

      Параметр `validation_parameter` закодирован в формате base64. Ниже приведен пример команды для декодирования этого параметра.

      ```
      echo EiAvQ2hhbm5lbC9BcHBsaWNhdGlvbi9FbmRvcnNlbWVudA== | base64 -d

       /Channel/Application/Endorsement
      ```

    - Для получения всех определений чейнкода в этом канале

      ```
      export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

      peer lifecycle chaincode querycommitted -o orderer.example.com:7050 --channelID mychannel --tls --cafile $ORDERER_CA --peerAddresses peer0.org1.example.com:7051 --output json
      ```

      При успешном выполнении команда вернет определение чейнкода, записанного в канале `mychannel`, в формате JSON.

      ```
      {
        "chaincode_definitions": [
          {
            "name": "mycc",
            "sequence": 1,
            "version": "1",
            "endorsement_plugin": "escc",
            "validation_plugin": "vscc",
            "validation_parameter": "EiAvQ2hhbm5lbC9BcHBsaWNhdGlvbi9FbmRvcnNlbWVudA==",
            "collections": {},
            "init_required": true
          },
          {
            "name": "yourcc",
            "sequence": 3,
            "version": "2",
            "endorsement_plugin": "escc",
            "validation_plugin": "vscc",
            "validation_parameter": "EiAvQ2hhbm5lbC9BcHBsaWNhdGlvbi9FbmRvcnNlbWVudA==",
            "collections": {}
          }
        ]
      }
      ```

