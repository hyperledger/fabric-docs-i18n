# Развертывание смарт-контракта в канале

Конечные пользователи взаимодействуют с реестром блокчейн путем вызова смарт-контрактов. В Hyperledger Fabric смарт-контракты развертываются в пакетах под названием «чейнкод». Для проверки транзакций или обращения к реестру организациям необходимо установить чейнкод на своих одноранговых узлах. После установки чейнкода на узлах-участниках определенного канала, участники канала могут развернуть чейнкод в канале и использовать смарт-контракты чейнкода для создания или обновления активов в реестре канала.

Чейнкод развертывается в канале в ходе процесса, известного как жизненный цикл чейнкода Fabric. Жизненный цикл чейнкода Fabric позволяет нескольким организациям согласовывать особенности работы чейнкода перед его использованием для создания транзакций. Например, помимо того, что в правилах одобрения указываются организации, которым необходимо выполнить чейнкод для проверки транзакций, члены канала должны использовать жизненный цикл ченйкода Fabric для согласования правил одобрения чейнкода. Для более глубокого понимания процесса развертывания и управления чейнкодом в канале смотрите раздел [Жизненный цикл чейнкода Fabric](./chaincode_lifecycle.html).

В этом разделе объясняется, как использовать [команды одноранговых узлов жизненного цикла чейнкода](./commands/peerlifecycle.html) для развертывания чейнкода в канале примера сети Fabric. Ознакомившись с этими командами, вы сможете использовать инструкции этого раздела для развертывания собственного чейнкода в примере сети или в реальной сети. В этом учебном примере вы будете развертывать чейнкод Fabcar, который используется в разделе [Ваше первое приложение](./write_first_app.html).

**Примечание.** В инструкциях используется жизненный цикл чейнкода Fabric версии 2.0. Если необходимо использовать жизненный цикл предыдущей версии для установки и создания чейнкода, смотрите [документацию для версии Fabric 1.4](https://hyperledger-fabric.readthedocs.io/en/release-1.4).


## Запуск сети

Начнем с развертывания экземпляра примера сети Fabric. Сперва необходимо установить все компоненты из разделов [Предварительные требования](prereqs.html) и [Примеры, двоичные файлы и образы Docker](install.html). Используйте следующую команду для перехода к каталогу примера сети внутри вашего локального клона хранилища `fabric-samples`:
```
cd fabric-samples/test-network
```
В рамках этого учебного примера будем использовать известное начальное состояние. Следующая команда удалит любые активные или устаревшие контейнеры docker, а также ранее созданные артефакты.
```
./network.sh down
```
Следующая команда запустит пример сети:
```
./network.sh up createChannel
```

Команда `createChannel` создает канал с названием ``mychannel`` и двумя членами — организациями Org1 и Org2. Эта команда также добавит одноранговые узлы организаций в канал. При успешном создании сети и канала в журнал выведется следующее сообщение:
```
========= Channel successfully joined ===========
```

Теперь можно воспользоваться интерфейсом командной строки одноранговых узлов для развертывания чейнкода Fabcar в канале следующим образом:


- [Шаг первый: упаковка смарт-контракт](#package-the-smart-contract)
- [Шаг второй: установка пакет чейнкода](#install-the-chaincode-package)
- [Шаг третий: утверждение определения чейнкода](#approve-a-chaincode-definition)
- [Шаг четвертый: запись определения чейнкода в канале](#committing-the-chaincode-definition-to-the-channel)


## Установка инструмента журналирования Logspout (по желанию)

Этот шаг не обязателен, однако чрезвычайно полезен для поиска и устранения ошибок чейнкода. Содержимое журналов смарт-контрактов администратор может просматривать в обобщенной информации из контейнеров Docker с помощью [инструмента](https://logdna.com/what-is-logspout/) `logspout`. Этот инструмент собирает выходные потоки из разных контейнеров Docker в одном окне, позволяя быстро понять, что происходит. Администраторы могут использовать этот инструмент для отладки при установке смарт-контрактов, а разработчики — при вызове смарт-контрактов. Полезно иметь все журналы сети в одном месте, поскольку некоторые контейнеры создаются исключительно для запуска смарт-контрактов и существуют только короткое время.

Сценарий `monitordocker.sh` для установки и настройки инструмента Logspout уже включен в пример торговли коммерческими векселями `commercial-paper`. Этот сценарий также используется далее в этом разделе. Инструмент Logspout непрерывно отправляет журналы в терминал, поэтому нужно использовать отдельное окно терминала. Откройте новое окно терминала и перейдите к каталогу `test-network`.
```
cd fabric-samples/test-network
```

Сценарий `monitordocker.sh` можно запускать из любого каталога. Для простоты использования скопируем сценарий `monitordocker.sh` из примера `commercial-paper` в рабочий каталог:
```
cp ../commercial-paper/organization/digibank/configuration/cli/monitordocker.sh .
# если не уверены где находится этот файл используйте
find . -name monitordocker.sh
```

Далее, для запуска Logspout можно использовать следующую команду:
```
./monitordocker.sh net_test
```
В терминале должно появиться похожее сообщение:
```
Starting monitoring on all containers on the network net_basic
Unable to find image 'gliderlabs/logspout:latest' locally
latest: Pulling from gliderlabs/logspout
4fe2ade4980c: Pull complete
decca452f519: Pull complete
ad60f6b6c009: Pull complete
Digest: sha256:374e06b17b004bddc5445525796b5f7adb8234d64c5c5d663095fccafb6e4c26
Status: Downloaded newer image for gliderlabs/logspout:latest
1f99d130f15cf01706eda3e1f040496ec885036d485cb6bcc0da4a567ad84361

```
Сперва в терминале будет отсутствовать какая-либо информация, но это изменится после развертывания чейнкода. Для удобства окно терминала можно максимизировать и установить крупный шрифт.

## Упаковка смарт-контракта

Перед установкой на одноранговых узлах чейнкод следует упаковать. Последовательность действий отличается в случае, если необходимо установить смарт-контракт, написанный на языках [Go](#go), [Java](#java) или [JavaScript](#javascript).

### Go

Перед упаковкой чейнкода необходимо установить зависимости чейнкода. Перейдите к каталогу, который содержит версию Go чейнкода Fabcar.
```
cd fabric-samples/chaincode/fabcar/go
```

В примере используется модуль Go для установки зависимостей чейнкода. Зависимости указаны в файле `go.mod`, расположенном в каталоге `fabcar/go`. Рекомендуем изучить содержимое этого файла.
```
$ cat go.mod
module github.com/hyperledger/fabric-samples/chaincode/fabcar/go

go 1.13

require github.com/hyperledger/fabric-contract-api-go v1.1.0
```
Файл `go.mod` импортирует API-интерфейс контрактов Fabric в пакет смарт-контракта. Открыв файл `fabcar.go` в текстовом редакторе можно увидеть, как функции API-интерфейса контрактов используются для указания типа `SmartContract` в начале определения смарт-контракта:
```
// SmartContract provides functions for managing a car
type SmartContract struct {
	contractapi.Contract
}
```

Тип ``SmartContract`` затем используется для создания контекста транзакции для определенных в смарт-контракте функций, которые считывают и записывают данные в реестр блокчейн.
```
// CreateCar adds a new car to the world state with given details
func (s *SmartContract) CreateCar(ctx contractapi.TransactionContextInterface, carNumber string, make string, model string, colour string, owner string) error {
	car := Car{
		Make:   make,
		Model:  model,
		Colour: colour,
		Owner:  owner,
	}

	carAsBytes, _ := json.Marshal(car)

	return ctx.GetStub().PutState(carNumber, carAsBytes)
}
```
Больше информации о версии Go API-интерфейса контрактов Fabric предоставляется в [Документации API-интерфейса](https://github.com/hyperledger/fabric-contract-api-go) и в разделе [Обработка смарт-контрактов](developapps/smartcontract.html).

Чтобы установить зависимости смарт-контракта, выполните следующую команду из каталога `fabcar/go`.
```
GO111MODULE=on go mod vendor
```

При успешном выполнении команды пакеты Go будут установлены в каталоге `vendor`.

После установки зависимостей можно создать пакет чейнкода. Вернитесь к рабочему подкаталогу в каталоге `test-network` для упаковки чейнкода вместе с другими артефактами сети.
```
cd ../../../test-network
```

Для создания пакета чейнкода в требуемом формате можно использовать интерфейс командной строки одноранговых узлов. Двоичные файлы `одноранговых узлов` находятся в каталоге `bin` хранилища `fabric-samples`. Используйте следующую команду для добавления двоичных файлов в ваш путь интерфейса командной строки:
```
export PATH=${PWD}/../bin:$PATH
```
Также необходимо указать файл` core.yaml` в хранилище `fabric-samples` для пути `FABRIC_CFG_PATH`:
```
export FABRIC_CFG_PATH=$PWD/../config/
```
В рамках этого примера интерфейс командной строки одноранговых узлов можно использовать c версией двоичных файлов `2.0.0` или более поздней. Для проверки версии выполните следующую команду:
```
peer version
```

Теперь можно создать пакет чейнкода, используя команду одноранговых узлов для [пакета жизненного цикла чейнкода](commands/peerlifecycle.html#peer-lifecycle-chaincode-package):
```
peer lifecycle chaincode package fabcar.tar.gz --path ../chaincode/fabcar/go/ --lang golang --label fabcar_1
```

Эта команда создаст пакет с именем ``fabcar.tar.gz`` в текущем каталоге.
Флаг `--lang` используется для указания языка чейнкода, а с помощью флага `--path` указывается расположение кода смарт-контракта. Путь должен быть полным, или относительным для текущего рабочего каталога.
Флаг `--label` используется для указания метки чейнкода, которую можно использовать для идентификации чейнкода после установки. В метке рекомендуется указывать название и версию чейнкода.

После создания пакета чейнкода, его можно [установить](#install-the-chaincode-package) на одноранговых узлах примера сети.

### JavaScript

Перед упаковкой чейнкода необходимо установить зависимости чейнкода. Перейдите к каталогу с JavaScript-версией чейнкода Fabcar.
```
cd fabric-samples/chaincode/fabcar/javascript
```

Зависимости указаны в файле `package.json`, расположенном в каталоге `fabcar/javascript`. Рекомендуем изучить содержимое этого файла. Так выглядит раздел зависимостей в этом файле:
```
"dependencies": {
		"fabric-contract-api": "^2.0.0",
		"fabric-shim": "^2.0.0"
```
Файл `package.json` импортирует класс контракта Fabric в пакет смарт-контракта. Файл `lib/fabcar.js` можно открыть в текстовом редакторе, чтобы изучить класс контракта, импортируемого в смарт-контракт и используемого для создания класса Fabcar.
```
const { Contract } = require('fabric-contract-api');

class FabCar extends Contract {
	...
}

```

Класс ``FabCar`` используется для создания контекста транзакции для определенных в смарт-контракте функций, которые считывают и записывают данные в реестр блокчейн.
```
async createCar(ctx, carNumber, make, model, color, owner) {
    console.info('============= START : Create Car ===========');

    const car = {
        color,
        docType: 'car',
        make,
        model,
        owner,
    };

  	await ctx.stub.putState(carNumber, Buffer.from(JSON.stringify(car)));
    console.info('============= END : Create Car ===========');
}
```
Больше информации о версии JavaScrip API-интерфейса контрактов Fabric предоставляется в [Документации API-интерфейса](https://hyperledger.github.io/fabric-chaincode-node/{BRANCH}/api/) и в разделе [Обработка смарт-контрактов](developapps/smartcontract.html).

Чтобы установить зависимости смарт-контракта, выполните следующую команду из каталога `fabcar/javascript`.
```
npm install
```

При успешном выполнении команды пакеты JavaScript будут установлены в каталоге `npm_modules`.

После установки зависимостей можно создать пакет чейнкода. Вернитесь к рабочему подкаталогу в каталоге `test-network` для упаковки чейнкода вместе с другими артефактами сети.
```
cd ../../../test-network
```

Для создания пакета чейнкода в требуемом формате можно использовать интерфейс командной строки одноранговых узлов. Двоичные файлы `одноранговых узлов` находятся в каталоге `bin` хранилища `fabric-samples`. Используйте следующую команду для добавления двоичных файлов в ваш путь интерфейса командной строки:
```
export PATH=${PWD}/../bin:$PATH
```
Также необходимо указать файл` core.yaml` в хранилище `fabric-samples` для параметра `FABRIC_CFG_PATH`:
```
export FABRIC_CFG_PATH=$PWD/../config/
```
В рамках этого примера интерфейс командной строки одноранговых узлов можно использовать c версией двоичных файлов `2.0.0` или более поздней. Для проверки версии выполните следующую команду:
```
peer version
```

Теперь можно создать пакет чейнкода, используя команду одноранговых узлов для [пакета жизненного цикла чейнкода](commands/peerlifecycle.html#peer-lifecycle-chaincode-package):
```
peer lifecycle chaincode package fabcar.tar.gz --path ../chaincode/fabcar/javascript/ --lang node --label fabcar_1
```

Эта команда создаст пакет с именем ``fabcar.tar.gz`` в текущем каталоге. Флаг `--lang` используется для указания языка чейнкода, а с помощью флага `--path` указывается расположение кода смарт-контракта. Флаг `--label` используется для указания метки чейнкода, которую можно использовать для идентификации чейнкода после установки. В метке рекомендуется указывать название и версию чейнкода.

После создания пакета чейнкода, его можно [установить](#install-the-chaincode-package) на одноранговых узлах примера сети.

### Java

Перед упаковкой чейнкода необходимо установить зависимости чейнкода. Перейдите к каталогу с Java-версией чейнкода Fabcar.
```
cd fabric-samples/chaincode/fabcar/java
```

В примере используется инструмент Gradle для установки зависимостей чейнкода. Зависимости указаны в файле `build.gradle`, расположенном в каталоге `fabcar/java`. Рекомендуем изучить содержимое этого файла. Так выглядит раздел зависимостей в этом файле:
```
dependencies {
    compileOnly 'org.hyperledger.fabric-chaincode-java:fabric-chaincode-shim:2.0.+'
    implementation 'com.owlike:genson:1.5'
    testImplementation 'org.hyperledger.fabric-chaincode-java:fabric-chaincode-shim:2.0.+'
    testImplementation 'org.junit.jupiter:junit-jupiter:5.4.2'
    testImplementation 'org.assertj:assertj-core:3.11.1'
    testImplementation 'org.mockito:mockito-core:2.+'
}
```
Файл `build.gradle` импортирует в пакет смарт-контракта Java-оболочку чейнкода, которая включает класс контракта. Смарт-контракт Fabcar находится в каталоге `src`. Рекомендуем открыть файл `FabCar.java` и изучить, каким образом класс ``FabCar`` используется для создания контекста транзакции для определенных в смарт-контракте функций, которые считывают и записывают данные в реестр блокчейн.

Больше информации о Java-оболочке чейнкода класса контракта Fabric предоставляется в [Документации к Java-версии чейнкода]((https://hyperledger.github.io/fabric-chaincode-java/{BRANCH}/api/) и в разделе [Обработка смарт-контрактов](developapps/smartcontract.html).

Чтобы установить зависимости смарт-контракта, выполните следующую команду из каталога `fabcar/java`.
```
./gradlew installDist
```

При успешном выполнении команды собранный смарт-контракт будет находится в каталоге `build`.

После установки зависимостей и сборки смарт-контракта можно создать пакет чейнкода. Вернитесь к рабочему подкаталогу в каталоге `test-network` для упаковки чейнкода вместе с другими артефактами сети.
```
cd ../../../test-network
```

Для создания пакета чейнкода в требуемом формате можно использовать интерфейс командной строки одноранговых узлов. Двоичные файлы `одноранговых узлов` находятся в каталоге `bin` хранилища `fabric-samples`. Используйте следующую команду для добавления двоичных файлов в ваш путь интерфейса командной строки:
```
export PATH=${PWD}/../bin:$PATH
```
Также необходимо указать файл` core.yaml` в хранилище `fabric-samples` для пути `FABRIC_CFG_PATH`:
```
export FABRIC_CFG_PATH=$PWD/../config/
```
В рамках этого примера интерфейс командной строки одноранговых узлов можно использовать c версией двоичных файлов `2.0.0` или более поздней. Для проверки версии выполните следующую команду:
```
peer version
```

Теперь можно создать пакет чейнкода, используя команду одноранговых узлов для [пакета жизненного цикла чейнкода](commands/peerlifecycle.html#peer-lifecycle-chaincode-package):
```
peer lifecycle chaincode package fabcar.tar.gz --path ../chaincode/fabcar/java/build/install/fabcar --lang java --label fabcar_1
```

Эта команда создаст пакет с именем ``fabcar.tar.gz`` в текущем каталоге. Флаг `--lang` используется для указания языка чейнкода, а с помощью флага `--path` указывается расположение кода смарт-контракта. Флаг `--label` используется для указания метки чейнкода, которую можно использовать для идентификации чейнкода после установки. В метке рекомендуется указывать название и версию чейнкода.

После создания пакета чейнкода, его можно [установить](#install-the-chaincode-package) на одноранговых узлах примера сети.

## Установка пакета чейнкода

После успешной упаковки смарт-контракта Fabcar можно установить чейнкод на одноранговых узлах. Чейнкод необходимо установить на всех одноранговых узлах, которые будут участвовать в одобрении транзакций. Так как в рамках этого примера правила одобрения будут требовать одобрения от организаций Org1 и Org2, чейнкод следует установит на одноранговые узлы обеих организаций:

- peer0.org1.example.com
- peer0.org2.example.com

Сперва установим чейнкод на одноранговый узел организации Org1. Установите следующие переменные среды для работы с интерфейсом командной строки одноранговых узлов от имени администратора организации Org1: В параметре `CORE_PEER_ADDRESS` будет указан одноранговый узел организации Org1 — `peer0.org1.example.com`.
```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```

Используйте команду [peer lifecycle chaincode install](commands/peerlifecycle.html#peer-lifecycle-chaincode-install) для установки чейнкода на одноранговом узле:
```
peer lifecycle chaincode install fabcar.tar.gz
```

При успешном выполнении команды одноранговый узел создаст и вернет идентификатор пакета. Этот идентификатор будет использоваться для утверждения чейнкода в следующем шаге. В терминале должно появиться похожее сообщение:
```
2020-02-12 11:40:02.923 EST [cli.lifecycle.chaincode] submitInstallProposal -> INFO 001 Installed remotely: response:<status:200 payload:"\nIfabcar_1:69de748301770f6ef64b42aa6bb6cb291df20aa39542c3ef94008615704007f3\022\010fabcar_1" >
2020-02-12 11:40:02.925 EST [cli.lifecycle.chaincode] submitInstallProposal -> INFO 002 Chaincode code package identifier: fabcar_1:69de748301770f6ef64b42aa6bb6cb291df20aa39542c3ef94008615704007f3
```

Теперь можно установить чейнкод на одноранговом узле организации Org2. Установите следующие переменные среды для работы с одноранговым узлом `peer0.org2.example.com` от имени администратора организации Org2:
```
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
```

Используйте следующую команду для установки чейнкода:
```
peer lifecycle chaincode install fabcar.tar.gz
```

Сборка производится одноранговым узлом при установке чейнкода. Команда установки возвращает ошибки сборки чейнкода, если возникает проблема с кодом смарт-контракта.

## Утверждение определения чейнкода

После установки пакета чейнкода необходимо утвердить определение чейнкода в рамках организации. Определение включает в себя важные параметры управления чейнкодом, такие как название, версия и правила одобрения чейнкода.

Члены канала, которые должны одобрить определение чейнкода перед его развертыванием, указываются в правилах `Application/Channel/lifeycleEndorsement`. По умолчанию эти правила подразумевают, что большинство членов канала должны одобрить чейнкод перед использованием этого чейнкода в канале. Поскольку в нашем примере в канале присутствуют только две организации, и большинством яв 2 из 2, определение чейнкода Fabcar должно быть одобрено организациями Org1 и Org2.

Если организация устанавливает чейнкод на своих одноранговых узлах, то в одобренном организацией определении чейнкода должен быть указан идентификатор пакета `packageID`. Идентификатор пакета используется для ассоциации установленного на одноранговом узле чейнкода с одобренным определением чейнкода, и позволяет организациям использовать чейнкод для одобрения транзакций. Идентификатор чейнкода можно получить с помощью команды [peer lifecycle chaincode queryinstalled](commands/peerlifecycle.html#peer-lifecycle-chaincode-queryinstalled), которая обращается к одноранговому узлу.
```
peer lifecycle chaincode queryinstalled
```

Идентификатор пакета — это комбинация метки чейнкода и хеша двоичных файлов чейнкода. Все одноранговые узлы возвращают один и тот же идентификатор пакета. В терминале должно появиться похожее сообщение:
```
Installed chaincodes on peer:
Package ID: fabcar_1:69de748301770f6ef64b42aa6bb6cb291df20aa39542c3ef94008615704007f3, Label: fabcar_1
```

Идентификатор пакета необходим при одобрении чейнкода, поэтому его можно сохранить в качестве переменной среды. Вставьте идентификатор пакета, полученный в результате выполнения команды `peer lifecycle chaincode queryinstalled`, в команду ниже. **Примечание.** Идентификатор пакета будет разным для разных пользователей, поэтому нужно выполнить этот шаг, используя идентификатор пакета из окна выполнения команды из предыдущего шага.
```
export CC_PACKAGE_ID=fabcar_1:69de748301770f6ef64b42aa6bb6cb291df20aa39542c3ef94008615704007f3
```

Поскольку переменные среды были установлены для работы с интерфейсом командной строки одноранговых узлов от имени администратора Org2, определение чейнкода Fabcar можно утердить для организации Org2. Чейнкод уже является одобренным на уровне организации, поэтому в команде можно указать только один одноранговый узел. Одобренное определение распределяется по всем одноранговым узлам в пределах организации с помощью протокола gossip. Утвердите определение чейнкода с помощью команды [peer lifecycle chaincode approveformyorg](commands/peerlifecycle.html#peer-lifecycle-chaincode-approveformyorg):
```
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name fabcar --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```

В этой команде используется флаг `--package-id` для включения идентификатора пакета в определении чейнкода. Параметр `--sequence` — это целое число, соответствующее количеству повторных определений или обновлений чейнкода. Поскольку чейнкод развертывается в канал в первый раз, его порядковый номер будет равен «1». При следующем обновлении чейнкода Fabcar порядковый номер увеличится до «2». При использовании функций низкого уровня, предоставляемых API-интерфейсом Fabric Chaincode Shim, можно добавить флаг  `--init-required` в команду выше, чтобы запросить выполнение функции Init для инициализации чейнкода. При первом вызове чейнкода должна вызываться функция Init, а также следует использовать флаг `--isinit` перед использованием других функции чейнкода для взаимодействия с реестром.

Также в команде `approveformyorg` можно указать правила одобрения чейнкода с помощью параметров ``--signature-policy`` или ``--channel-config-policy``. Правила одобрения определяют, сколько одноранговых узлов от различных участников канала должны одобрить транзакцию по рассматриваемому чейнкоду. Поскольку правила одобрения еще не заданы, определение чейнкода Fabcar будет использовать правила одобрения по умолчанию, которые требуют одобрения транзакций большинством членов канала, присутствующих в канале при создании транзакции. Это означает, что при добавлении или удалении новых организаций в канале, правила одобрения
будут автоматически обновлены для повышения или понижения количества членов, которые должны одобрить транзакцию. В этом примере правила по умолчанию потребуют одобрения большинством (2 из 2), то есть транзакции должны быть одобрены одноранговыми узлами организаций Org1 и Org2. Чтобы иметь возможность создавать собственные правила одобрения, рекомендуем изучить синтаксис правил одобрения в разделе [Правила одобрения](endorsement-policies.html).

Определение чейнкода утверждается пользователем с идентификатором, которому присвоена роль администратора. То есть в переменной `CORE_PEER_MSPCONFIGPATH` должен быть указан каталог провайдера службы членства (MSP), которая содержит идентификатор администратора. Определение чейнкода нельзя оформить обычным пользователем. Одобрение должно быть отправлено в службу упорядочения, которая подтвердит подпись администратора, а затем распространит одобрение среди одноранговых узлов.

Однако определение чейнкода должно быть еще одобрено на уровне организации Org1. Установите следующие переменные среды для работы от имени администратора организации ORG2:
```
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_ADDRESS=localhost:7051
```

Теперь можете утвердить определение чейнкода от лица организации Org1.
```
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name fabcar --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```

Теперь определение чейнкода имеет все необходимые одобрения для успешного развертывания в канале. Несмотря на то, что только большинство организаций должно одобрить определение цепочка (согласно правилам по умолчанию), любая организация, желающая использовать чейнкод на своих одноранговых узлах, должна также одобрить определение чейнкода. В случае записи определения чейнкода до одобрения участниками каналы, организации не смогут одобрять транзакции. Поэтому рекомендуется, чтобы все члены канала одобрили определение чейнкода перед записью в канал.

## Запись определения чейнкода в канал

После утверждения определения чейнкода достаточным количеством участников канала, одна организация может записать определение в канал. Если большинство членов каналов одобрили определение, транзакция записи чейнкода будет выполнена успешно, и согласованные в определении чейнкода параметры станут действовать в пределах канала.

Для проверки успешности одобрения определения чейнкода участниками канала используйте команду [peer lifecycle chaincode checkcommitreadiness](commands/peerlifecycle.html#peer-lifecycle-chaincode-checkcommitreadiness). Флаги команды `checkcommireadiness` идентичны флагам, используемым для одобрения чейнкода в пределах организации. Однако флаг `--package-id` указывать не нужно.
```
peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name fabcar --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json
```

Команда создаст карту JSON, в которой сохраняется подтверждение, что член канала одобрил параметры, указанные в команде `checkcommireadiness`:
```json
    {
            "Approvals": {
                    "Org1MSP": true,
                    "Org2MSP": true
            }
    }
```

Поскольку обе организации-члена канала одобрили одинаковые параметры, определение чейнкода готово быть записано в канале. Для записи определения чейнкода в канале используйте команду [peer lifecycle chaincode commit](commands/peerlifecycle.html#peer-lifecycle-chaincode-commit). Команда записи определения чейнкода также должна быть выполнена администратором организации.
```
peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name fabcar --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
```

В транзакции выше используется флаг `--peerAddresses` с указанием узла `peer0.org1.example.com` организации Org1 и узла `peer0.org2.example.com` организации Org2. Транзакция записи `commit` отправляется одноранговым узлам в канале для запроса определения чейнкода, которое было одобрено соответствующими организациями-владельцами этих узлов. В команде должно быть указано достаточное количество организаций, чтобы выполнить требования правил для развертывания чейнкода. Поскольку одобрение автоматически распространяется среди узлов каждой организации, можно указать любой одноранговый узел, который принадлежит члену канала.

Одобрения определения чейнкода отправляются членами канала в службу упорядочения. Далее определения добавляются в блоки и распространяются в канале. Затем одноранговые узлы в канале проверяют успешность одобрения определения чейнкода достаточным количеством организаций. Команда `peer lifecycle chaincode commit` ждет завершения проверки со стороны одноранговых узлов перед возвратом ответа.

Для проверки записи определение чейнкода в канале используйте команду [peer lifecycle chaincode querycommitted](commands/peerlifecycle.html#peer-lifecycle-chaincode-querycommitted).
```
peer lifecycle chaincode querycommitted --channelID mychannel --name fabcar --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```
Если определение чейнкода успешно записано в канале, команда `queryCommated` вернет порядковый номер и версию определения чейнкода:
```
Committed chaincode definition for chaincode 'fabcar' on channel 'mychannel':
Version: 1, Sequence: 1, Endorsement Plugin: escc, Validation Plugin: vscc, Approvals: [Org1MSP: true, Org2MSP: true]
```

## Вызов чейнкода

После записи определения чейнкода в канал, чейнкод запускается на всех одноранговых узлах канала с установленным чейнкодом. Чейнкод Fabcar теперь готов для обработки вызовов от клиентских приложений. Используйте следующую команду для создания начального набора автомобилей в реестре. Обратите внимание, что в команде `invoke` следует указать достаточное количество одноранговых узлов для выполнения требований правил одобрения чейнкода.
```
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n fabcar --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"function":"initLedger","Args":[]}'
```
Если команда выполнена успешна, будет отображен следующий результат:
```
2020-02-12 18:22:20.576 EST [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Chaincode invoke successful. result: status:200
```

Мы можем использовать функцию запроса `query` для считывания набора автомобилей, созданных чейнкодом:
```
peer chaincode query -C mychannel -n fabcar -c '{"Args":["queryAllCars"]}'
```

Ответ на запрос должен содержать следующий список автомобилей:
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
```

## Обновление смарт-контракта

Тот же процесс жизненного цикла чейнкода Fabric можно использовать для обновления уже развернутого в канале чейнкода. Участники канала могут обновить чейнкод, установив новый пакет чейнкода, а затем утвердив определение чейнкода с новым идентификатором пакета, версией чейнкода и порядковым номером. Новый чейнкод можно использовать после записи его определения в канал. Этот процесс предоставляет членам канала средство для утверждения момента обновления чейнкода, а также подтверждения, что достаточное количество членов канала готово к использованию нового чейнкода, прежде чем развернуть его в канале.

Участники канала также могут использовать процесс обновления для изменения правил одобрения чейнкода. Члены канала могут изменить правила одобрения чейнкода, не устанавливая новый пакет чейнкода, путем утверждения определения чейнкода с новым правилами одобрения и записи определения чейнкода в канал.

Чтобы привести пример обновления чейнкода Fabcar, который мы только развернули, давайте предположим, что организации Org1 и Org2 хотят установить версию чейнкода, который написан на другом языке. Они могут воспользоваться жизненным циклом чейнкода Fabric для обновления версии чейнкода и подтверждения, что обе организации установили новую версию чейнкода, прежде чем чейнкод может быть использован в канале.

Предположим, что организации Org1 и Org2 изначально установили версию чейнкода Fabcar на языке Go, однако, более комфортно было бы работать с чейнкодом, написанным на JavaScript. Первый шаг включает упаковку JavaScript-версии чейнкода Fabcar. Если вы использовали инструкции для упаковки JavaScript-версии чейнкода при изучении учебного примера, новые двоичные файлы чейнкода можно установить согласно инструкциям для упаковки версии чейнкода на языках [Go](#go) или [Java](#java).

Используйте следующие команды из каталога `test-network` для установки зависимостей чейнкода:
```
cd ../chaincode/fabcar/javascript
npm install
cd ../../../test-network
```
Используйте следующие команды из каталога `test-network` для упаковки JavaScript-версии чейнкода: Повторно установим переменные среды, необходимые для использования интерфейса командной строки одноранговых узлов на случай, если вы закрыли терминал.
```
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
peer lifecycle chaincode package fabcar_2.tar.gz --path ../chaincode/fabcar/javascript/ --lang node --label fabcar_2
```
Используйте следующие команды для работы с интерфейсом командной строки одноранговых узлов от имени администратора организации Org1:
```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```
Теперь можно воспользоваться следующей командой для установки пакета чейнкода на одноранговом узле организации Org1:
```
peer lifecycle chaincode install fabcar_2.tar.gz
```

Новый пакет чейнкода создаст новый идентификатор пакета. Новый идентификатор пакета можно узнать, отправив запрос одноранговому узлу.
```
peer lifecycle chaincode queryinstalled
```
Команда `queryinstalled` вернет список чейнкодов, установленных на одноранговом узле.
```
Installed chaincodes on peer:
Package ID: fabcar_1:69de748301770f6ef64b42aa6bb6cb291df20aa39542c3ef94008615704007f3, Label: fabcar_1
Package ID: fabcar_2:1d559f9fb3dd879601ee17047658c7e0c84eab732dca7c841102f20e42a9e7d4, Label: fabcar_2
```

Используйте метку пакета, чтобы найти идентификатор пакета нового чейнкода и указать его качестве новой переменной среды.
```
export NEW_CC_PACKAGE_ID=fabcar_2:1d559f9fb3dd879601ee17047658c7e0c84eab732dca7c841102f20e42a9e7d4
```

Теперь организация Org1 может одобрить новое определение чейнкода:
```
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name fabcar --version 2.0 --package-id $NEW_CC_PACKAGE_ID --sequence 2 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```
Используя идентификатор JavaScript-версии пакета чейнкода новое определение чейнкода обновит версию чейнкода. Поскольку порядковый номер используется жизненным циклом чейнкода Fabric для отслеживания обновлений чейнкода, организация Org1 также должна увеличить порядковый номер с 1 до 2. Для определения порядкового номера определения последнего записанного в канале чейнкода используйте команду [peer lifecycle chaincode querycommitted](commands/peerlifecycle.html#peer-lifecycle-chaincode-querycommitted).

Теперь, для обновления чейнкода нужно установить пакет чейнкода и одобрить определение чейнкода от лица организации Org2. Используйте следующие команды для работы с интерфейсом командной строки одноранговых узлов от имени администратора организации Org2:
```
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
```
Теперь можно воспользоваться следующей командой для установки пакета чейнкода на одноранговом узле организации Org2.
```
peer lifecycle chaincode install fabcar_2.tar.gz
```
После этого можно утвердить определение чейнкода от лица организации Org2.
```
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name fabcar --version 2.0 --package-id $NEW_CC_PACKAGE_ID --sequence 2 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```
Для проверки возможности записи определения чейнкода с порядковым номером 2 в канале используйте команду [peer lifecycle chaincode querycommitted](commands/peerlifecycle.html#peer-lifecycle-chaincode-querycommitted).
```
peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name fabcar --version 2.0 --sequence 2 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json
```

Чейнкод готов к обновлению, если команда возвращает следующую информацию в формате JSON:
```json
    {
            "Approvals": {
                    "Org1MSP": true,
                    "Org2MSP": true
            }
    }
```

Чейнкод будет обновлен после записи его определения в канал. До тех пор на одноранговых узлах обеих организаций будет продолжать действовать предыдущая версия чейнкода. Организация Org2 может выполнить следующую команду для обновления чейнкода:
```
peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name fabcar --version 2.0 --sequence 2 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
```
При успешном выполнении транзакции записи новый чейнкода сразу же начнет работать. Если определение чейнкода изменяет правила одобрения, они немедленно станут действительными.

Используйте команду `docker ps` для проверки, что новый чейнкод запущен на одноранговых узлах:
```
$docker ps
CONTAINER ID        IMAGE                                                                                                                                                                   COMMAND                  CREATED             STATUS              PORTS                              NAMES
197a4b70a392        dev-peer0.org1.example.com-fabcar_2-1d559f9fb3dd879601ee17047658c7e0c84eab732dca7c841102f20e42a9e7d4-d305a4e8b4f7c0bc9aedc84c4a3439daed03caedfbce6483058250915d64dd23   "docker-entrypoint.s…"   2 minutes ago       Up 2 minutes                                           dev-peer0.org1.example.com-fabcar_2-1d559f9fb3dd879601ee17047658c7e0c84eab732dca7c841102f20e42a9e7d4
b7e4dbfd4ea0        dev-peer0.org2.example.com-fabcar_2-1d559f9fb3dd879601ee17047658c7e0c84eab732dca7c841102f20e42a9e7d4-9de9cd456213232033c0cf8317cbf2d5abef5aee2529be9176fc0e980f0f7190   "docker-entrypoint.s…"   2 minutes ago       Up 2 minutes                                           dev-peer0.org2.example.com-fabcar_2-1d559f9fb3dd879601ee17047658c7e0c84eab732dca7c841102f20e42a9e7d4
8b6e9abaef8d        hyperledger/fabric-peer:latest                                                                                                                                          "peer node start"        About an hour ago   Up About an hour    0.0.0.0:7051->7051/tcp             peer0.org1.example.com
429dae4757ba        hyperledger/fabric-peer:latest                                                                                                                                          "peer node start"        About an hour ago   Up About an hour    7051/tcp, 0.0.0.0:9051->9051/tcp   peer0.org2.example.com
7de5d19400e6        hyperledger/fabric-orderer:latest                                                                                                                                       "orderer"                About an hour ago   Up About an hour    0.0.0.0:7050->7050/tcp             orderer.example.com
```
При использовании флага `--init` следует вызвать функцию Init для возможности использования обновленной версии чейнкода. Поскольку в рамках примера функция Init не запрашивалась, новую JavaScript-версию чейнкода можно проверить, создав новый автомобиль:
```
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n fabcar --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"function":"createCar","Args":["CAR11","Honda","Accord","Black","Tom"]}'
```
Можно запросить все автомобили в реестре, чтобы увидеть новый автомобиль:
```
peer chaincode query -C mychannel -n fabcar -c '{"Args":["queryAllCars"]}'
```

Должен быть отображен следующий результат, возвращенный JavaScript-версией чейнкода:
```
[{"Key":"CAR0","Record":{"make":"Toyota","model":"Prius","colour":"blue","owner":"Tomoko"}},
{"Key":"CAR1","Record":{"make":"Ford","model":"Mustang","colour":"red","owner":"Brad"}},
{"Key":"CAR11","Record":{"color":"Black","docType":"car","make":"Honda","model":"Accord","owner":"Tom"}},
{"Key":"CAR2","Record":{"make":"Hyundai","model":"Tucson","colour":"green","owner":"Jin Soo"}},
{"Key":"CAR3","Record":{"make":"Volkswagen","model":"Passat","colour":"yellow","owner":"Max"}},
{"Key":"CAR4","Record":{"make":"Tesla","model":"S","colour":"black","owner":"Adriana"}},
{"Key":"CAR5","Record":{"make":"Peugeot","model":"205","colour":"purple","owner":"Michel"}},
{"Key":"CAR6","Record":{"make":"Chery","model":"S22L","colour":"white","owner":"Aarav"}},
{"Key":"CAR7","Record":{"make":"Fiat","model":"Punto","colour":"violet","owner":"Pari"}},
{"Key":"CAR8","Record":{"make":"Tata","model":"Nano","colour":"indigo","owner":"Valeria"}},
{"Key":"CAR9","Record":{"make":"Holden","model":"Barina","colour":"brown","owner":"Shotaro"}}]
```

## Очистка

По завершению ознакомления с работой чейнкода используйте следующие команды для удаления инструмента Logspout:
```
docker stop logspout
docker rm logspout
```
После этого можно удалить сеть, выполнив следующую команду из каталога `test-network`.
```
./network.sh down
```

## Следующие шаги

После создания собственного смарт-контракта и развертывание его в канале, вы можете использовать API-интерфейс комплекта разработчика Fabric для вызова смарт-контракта из клиентского приложения. Это позволяет конечным пользователям взаимодействовать с активами реестра блокчейн. Для начала работы с комплектом разработчика Fabric ознакомьтесь с разделом [Ваше первое приложение](write_first_app.html).

## Устранение ошибок

### Чейнкод не утвержден определенной организацией

**Проблема:** при попытке записи нового определения чейнкода в канале, команда `peer lifecycle chaincode commit` завершается со следующей ошибкой:
```
Error: failed to create signed transaction: proposal response was not successful, error code 500, msg failed to invoke backing implementation of 'CommitChaincodeDefinition': chaincode definition not agreed to by this org (Org1MSP)
```

**Решение:** для решения этой проблемы следует проверить успешность одобрения определения чейнкода участниками канала с помощью команды `peer lifecycle chaincode checkcommitreadiness`. Если одна из организаций использовала другое значение для любого параметра определения чейнкода, транзакция записи будет неуспешной. Команда `peer lifecycle chaincode checkcommitreadiness` покажет, какие организации не одобрили определение чейнкода, которое необходимо записать в канал:
```
{
	"approvals": {
		"Org1MSP": false,
		"Org2MSP": true
	}
}
```

### Сбой вызова

**Проблем:** транзакция записи `peer lifecycle chaincode commit` выполняется успешно, но при попытке вызвать чейнкоде в первый раз появляется следующая ошибка:
```
Error: endorsement failure during invoke. response: status:500 message:"make sure the chaincode fabcar has been successfully defined on channel mychannel and try again: chaincode definition for 'fabcar' exists, but chaincode is not installed"
```

**Решение:** возможно указан неправильный `--package-id` при одобрении определения чейнкода. В результате записанное в канале определение чейнкода не связано с указанным пакетом чейнкода, и чейнкод не запущен на одноранговых узлаха. При использовании сети на основе Docker можно использовать команду `docker ps`, чтобы проверить, работает ли чейнкод:
```
docker ps
CONTAINER ID        IMAGE                               COMMAND             CREATED             STATUS              PORTS                              NAMES
7fe1ae0a69fa        hyperledger/fabric-orderer:latest   "orderer"           5 minutes ago       Up 4 minutes        0.0.0.0:7050->7050/tcp             orderer.example.com
2b9c684bd07e        hyperledger/fabric-peer:latest      "peer node start"   5 minutes ago       Up 4 minutes        0.0.0.0:7051->7051/tcp             peer0.org1.example.com
39a3e41b2573        hyperledger/fabric-peer:latest      "peer node start"   5 minutes ago       Up 4 minutes        7051/tcp, 0.0.0.0:9051->9051/tcp   peer0.org2.example.com
```

При отстутствии контейнеров чейнкода, используйте команду `peer lifecycle chaincode approveformyorg` для одобрения определения чейнкода с правильным идентификатором пакета.


## Сбой правил одобрения

**Проблема:** при попытке записать определения чейнкода в канале транзакция выполняется со следующей ошибкой:
```
2020-04-07 20:08:23.306 EDT [chaincodeCmd] ClientWait -> INFO 001 txid [5f569e50ae58efa6261c4ad93180d49ac85ec29a07b58f576405b826a8213aeb] committed with status (ENDORSEMENT_POLICY_FAILURE) at localhost:7051
Error: transaction invalidated with status (ENDORSEMENT_POLICY_FAILURE)
```

**Решение:** эта ошибка возникает из-за того, что транзакция записи не собирает достаточное количество одобрения для выполнения требований правил одобрения жизненного цикла чейнкода. Эта проблема может возникнуть в случае, когда в транзакции не указано достаточное количество одноранговых узлов для выполнения требований правил. Это также может быть связано с тем, что некоторые организации не добавили в файл `configtx.yaml` правила подписи `Endorsement:`, указанные по умолчанию в правилах `/Channel/Application/Endorsement`:
```
Readers:
		Type: Signature
		Rule: "OR('Org2MSP.admin', 'Org2MSP.peer', 'Org2MSP.client')"
Writers:
		Type: Signature
		Rule: "OR('Org2MSP.admin', 'Org2MSP.client')"
Admins:
		Type: Signature
		Rule: "OR('Org2MSP.admin')"
Endorsement:
		Type: Signature
		Rule: "OR('Org2MSP.peer')"
```

В случае [включения нового жизненного цикла чейнкода Fabric](enable_cc_lifecycle.html) также необходимо использовать новые правила каналов Fabric версии 2.0 в дополнение к обновлению канала к версии `V2_0`. В канал должны быть добавлены новые правила `/Channel/Application/LifecycleEndorsement` и `/Channel/Application/Endorsement`:
```
Policies:
		Readers:
				Type: ImplicitMeta
				Rule: "ANY Readers"
		Writers:
				Type: ImplicitMeta
				Rule: "ANY Writers"
		Admins:
				Type: ImplicitMeta
				Rule: "MAJORITY Admins"
		LifecycleEndorsement:
				Type: ImplicitMeta
				Rule: "MAJORITY Endorsement"
		Endorsement:
				Type: ImplicitMeta
				Rule: "MAJORITY Endorsement"
```

Если новые правила канала не указаны в конфигурации канала, может возникнуть следующая ошибка при утверждении определения чейнкода организацией:
```
Error: proposal failed with status: 500 - failed to invoke backing implementation of 'ApproveChaincodeDefinitionForMyOrg': could not set defaults for chaincode definition in channel mychannel: policy '/Channel/Application/Endorsement' must be defined for channel 'mychannel' before chaincode operations can be attempted
```



<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/) -->
