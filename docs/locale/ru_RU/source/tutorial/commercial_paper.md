# Руководство: коммерческие ценные бумаги

**Аудитория:** Архитекторы, разработчики приложений и смарт-контрактов, администраторы


В этом руководстве мы покажем вам, как установить и использовать образец приложения и
смарт-контракта для оборота коммерческих ценных бумаг. Этот раздел ориентирован на практику,
поэтому в первую очередь внимание уделяется процедурам, а не концепциям. Если вы захотите
более глубокого понимания концепций, обратитесь к разделу
[Разработка приложений](../developapps/developing_applications.html).

![commercialpaper.tutorial](./commercial_paper.diagram.1.png) *В этом разделе мы рассматриваем
две организации, MagnetoCorp и DigiBank, которые торгуют коммерческими ценными бумагами друг с другом, используя PaperNet,
блокчейн-сеть на основе технологии Hyperledger Fabric.*

Сразу по установке тестовой сети вы будете действовать в роли Изабеллы, сотрудницы
организации MagnetoCorp, которая будет выпускать коммерческие ценные бумаги от имени организации.
Затем вы переключитесь на роль Баладжи, сотрудника DigiBank, который будет покупать эти коммерческие бумаги,
держать их некоторое время, и затем предъявлять в MagnetoCorp для погашения, фиксируя
небольшую прибыль.

Вы будете выступать в роли разработчика, конечного пользователя и администратора
в различных организациях, выполняя описанные ниже этапы. Это поможет вам понять
суть коллаборации двух разных независимых организаций, хоть и независимых, но действующих
по обоюдно согласованным правилам в сети Hyperledger Fabric.

* [Настройка машины](#prerequisites) и [загрузка образцов](#download-samples)
* [Создать сеть](#create-the-network)
* [Исследовать смарт-контракт коммерческой бумаги](#examine-the-commercial-paper-smart-contract)
* [Развернуть смарт-контракт в канал](#deploy-the-smart-contract-to-the-channel)
  посредством одобрения чейнкода организациями MagnetoCorp и Digibank.
* Понять структуру [приложения] MagnetoCorp (#application-structure),
  включая его [зависимости](#application-dependencies)
* Сконфигурировать и использовать [кошелек и идентификаторы](#wallet)
* Запустить приложение MagnetoCorp и [выпустить коммерческие бумаги](#issue-application)
* Понять, как DigiBank использует смарт-контракт в [приложениях](#digibank-applications)
* На месте Digibank'a, запускайте приложения для
  [покупки](#buy-application) и [погашения](#redeem-application) коммерческих ценных бумаг.

Это руководство было протестировано на MacOS и Ubuntu, и должно также работать на других дистрибутивах Linux.
Версия для Windows - в процессе разработки.

## Предварительные требования

Прежде, чем начать, вам нужно установить некоторые требуемые технологии. Мы постарались свести
требования к минимуму.

Вам **необходимо** установить:

  * [**Node**](https://github.com/hyperledger/fabric-sdk-node#build-and-test)
    Файл README для Node.js SDK содержит всё требуемое на данный момент.

 **Считается полезным**, и вам будет легче, если вы также установите:

  * Текстовый редактор кода, например:
    [**Visual Studio Code**](https://code.visualstudio.com/) версия 1.28 или выше
    .VS Code облегчает разработку и тестирование приложения и смарт-контракта.
    Ссылка на установку [здесь](https://code.visualstudio.com/Download).

    Также рекомендуем и некоторые другие полезные текстовые редакторы, включая:
    [Atom](https://atom.io/), [Sublime Text](http://www.sublimetext.com/) и
    [Brackets](http://www.sublimetext.com/).

**Возможно**, будет польза и в установке нижеуказанных компонентов по мере
приобретения опыта разработки приложения и смарт-контрактов. Для того, чтобы пройти
данное руководство, эти требования не являются обязательными:

  * [**Node Version Manager**](https://github.com/creationix/nvm). NVM облегчает
    переключение между разными версиями узлов -- это может пригодиться, когда вы будете
    работать над несколькими проектами одновременно. Установить NVM
    [можно отсюда](https://github.com/creationix/nvm#installation).

## Загрузить образцы

Руководство по коммерческим ценным бумагам содержится в репозитории `fabric-samples`.
Прежде чем начать, удостоверьтесь в том, что вы исполнили инструкции по установке
Fabric [Требования и условия](../prereqs.html) и произвели
[Загрузку образцов, исполняемых файлов и образов Docker](../install.html).
После того, как закончите, у вас будет копия репозитория `fabric-samples`,
содержащая скрипты руководства и файлы приложений.

![commercialpaper.download](./commercial_paper.diagram.2.png) *Загрузите с GitHub
репозиторий `fabric-samples` на свою локальную машину.*

После загрузки можете посмотреть на структуру директории `fabric-samples`:

```
$ cd fabric-samples
$ ls

CODEOWNERS			    SECURITY.md			        first-network
CODE_OF_CONDUCT.md		chaincode			        high-throughput
CONTRIBUTING.md			chaincode-docker-devmode	interest_rate_swaps
LICENSE				    ci				            off_chain_data
MAINTAINERS.md			commercial-paper		    test-network
README.md			    fabcar
```

Обратите внимание на директорию `commercial-paper`  -- здесь лежит наш образец!

Теперь вы завершили первую стадию руководства. По мере прохождения вы будете открывать
множество командных окон для различных пользователей и компонентов. К примеру:

* Показать узлу, службе упорядочения и УЦ сообщения на выходе из вашей сети.
* Одобрить чейнкод от имени администратора MagnetoCorp и от имени администратора DigiBank.
* Запускать приложения от имени Изабеллы и Баладжи, использующих смарт-контракт для
  трейдинга коммерческих ценных бумаг друг с другом.

Мы обозначим, когда вам следует ввести команду в конкретном окне команд; например:

```
(isabella)$ ls
```

показывает, что вам следует ввести команду `ls` из окна Изабеллы.

## Создание сети

Это руководство развернет смарт-контракт в тестовой сети Fabric.
Тестовая сеть состоит из двух равноправных организаций и одной организации-упорядочивателя.
Две равноправных организации управляют по одному одноранговому узлу каждая, в то
время как организация-упорядочиватель управляет единственным узлом службы упорядочения на
протоколе Raft. Также мы создадим в тестовой сети единственный канал под названием
`mychannel`, и обе равноправные организации будут его членами.

![commercialpaper.network](./commercial_paper.diagram.testnet.png)
*Тестовая сеть Fabric состоит из двух равноправных организаций, Org1 и Org2,
и одной организации-упорядочивателя. Каждый компонент запущен как контейнер Docker.*

Каждая организация управляет собственным удостоверяющим центром. Два равноправных узла,
[базы данных состояний](../ledger/ledger.html#world-state-database-options), узел
службы упорядочения и УЦ каждой организации запущены в собственных Docker-контейнерах.
В рабочих средах организации обычно используют существующие УЦ, работающие совместно
и на другие системы - УЦ не обязательно должны быть исключительно для сети Fabric.

Две организации введены в тестовой сети для того, чтобы иметь возможность показать
взаимодействие двух организаций с отдельными принадлежащими каждой одноранговыми
узлами, с реестром блокчейна. В данном руководстве Org1 действует как DigiBank
и Org2 как MagnetoCorp.

Вы можете запустить тестовую сеть и создать канал скриптом из директории коммерческих
ценных бумаг. Перейдите в директорию `commercial-paper` в `fabric-samples`:
```
cd fabric-samples/commercial-paper
```
Затем запустите скриптом тестовую сеть:
```
./network-starter.sh
```

По мере исполнения скрипта вы будете видеть журнальные записи развертывания тестовой
сети. Когда скрипт выполнится, при помощи команды `docker ps` вы можете увидеть
узлы Fabric, запущенные на вашей локальной машине:
```
$ docker ps

CONTAINER ID        IMAGE                               COMMAND                  CREATED              STATUS              PORTS                                        NAMES
a86f50ca1907        hyperledger/fabric-peer:latest      "peer node start"        About a minute ago   Up About a minute   7051/tcp, 0.0.0.0:9051->9051/tcp             peer0.org2.example.com
77d0fcaee61b        hyperledger/fabric-peer:latest      "peer node start"        About a minute ago   Up About a minute   0.0.0.0:7051->7051/tcp                       peer0.org1.example.com
7eb5f64bfe5f        hyperledger/fabric-couchdb          "tini -- /docker-ent…"   About a minute ago   Up About a minute   4369/tcp, 9100/tcp, 0.0.0.0:5984->5984/tcp   couchdb0
2438df719f57        hyperledger/fabric-couchdb          "tini -- /docker-ent…"   About a minute ago   Up About a minute   4369/tcp, 9100/tcp, 0.0.0.0:7984->5984/tcp   couchdb1
03373d116c5a        hyperledger/fabric-orderer:latest   "orderer"                About a minute ago   Up About a minute   0.0.0.0:7050->7050/tcp                       orderer.example.com
6b4d87f65909        hyperledger/fabric-ca:latest        "sh -c 'fabric-ca-se…"   About a minute ago   Up About a minute   7054/tcp, 0.0.0.0:8054->8054/tcp             ca_org2
7b01f5454832        hyperledger/fabric-ca:latest        "sh -c 'fabric-ca-se…"   About a minute ago   Up About a minute   7054/tcp, 0.0.0.0:9054->9054/tcp             ca_orderer
87aef6062f23        hyperledger/fabric-ca:latest        "sh -c 'fabric-ca-se…"   About a minute ago   Up About a minute   0.0.0.0:7054->7054/tcp                       ca_org1
```

Посмотрите на соответствие контейнеров узлам вашей сети (может потребоваться
горизонтальная прокрутка):
* Узел Org1, `peer0.org1.example.com`, запущен в контейнере `a86f50ca1907`
* Узел Org2, `peer0.org2.example.com`, запущен в контейнере `77d0fcaee61b`
* База CouchDB для узла Org1, `couchdb0`, запущена в контейнере `7eb5f64bfe5f`
* База CouchDB для узла Org2, `couchdb1`, запущена в контейнере `2438df719f57`
* Узел упорядочения, `orderer.example.com`, запущен в контейнере `03373d116c5a`
* УЦ Org1, `ca_org1`, запущен в контейнере `87aef6062f23`
* УЦ Org2, `ca_org2`, запущен в контейнере `6b4d87f65909`
* УЦ узла упорядочения, `ca_orderer`, запущен в контейнере `7b01f5454832`

Из этих контейнеров состоит [сеть Docker](https://docs.docker.com/network/) под
названием `net_test`. Можно посмотреть на сеть при помощи команды `docker network`:

```
$ docker network inspect net_test

  [
      {
          "Name": "net_test",
          "Id": "f4c9712139311004b8f7acc14e9f90170c5dcfd8cdd06303c7b074624b44dc9f",
          "Created": "2020-04-28T22:45:38.525016Z",
          "Containers": {
              "03373d116c5abf2ca94f6f00df98bb74f89037f511d6490de4a217ed8b6fbcd0": {
                  "Name": "orderer.example.com",
                  "EndpointID": "0eed871a2aaf9a5dbcf7896aa3c0f53cc61f57b3417d36c56747033fd9f81972",
                  "MacAddress": "02:42:c0:a8:70:05",
                  "IPv4Address": "192.168.112.5/20",
                  "IPv6Address": ""
              },
              "2438df719f57a597de592cfc76db30013adfdcfa0cec5b375f6b7259f67baff8": {
                  "Name": "couchdb1",
                  "EndpointID": "52527fb450a7c80ea509cb571d18e2196a95c630d0f41913de8ed5abbd68993d",
                  "MacAddress": "02:42:c0:a8:70:06",
                  "IPv4Address": "192.168.112.6/20",
                  "IPv6Address": ""
              },
              "6b4d87f65909afd335d7acfe6d79308d6e4b27441b25a829379516e4c7335b88": {
                  "Name": "ca_org2",
                  "EndpointID": "1cc322a995880d76e1dd1f37ddf9c43f86997156124d4ecbb0eba9f833218407",
                  "MacAddress": "02:42:c0:a8:70:04",
                  "IPv4Address": "192.168.112.4/20",
                  "IPv6Address": ""
              },
              "77d0fcaee61b8fff43d33331073ab9ce36561a90370b9ef3f77c663c8434e642": {
                  "Name": "peer0.org1.example.com",
                  "EndpointID": "05d0d34569eee412e28313ba7ee06875a68408257dc47e64c0f4f5ef4a9dc491",
                  "MacAddress": "02:42:c0:a8:70:08",
                  "IPv4Address": "192.168.112.8/20",
                  "IPv6Address": ""
              },
              "7b01f5454832984fcd9650f05b4affce97319f661710705e6381dfb76cd99fdb": {
                  "Name": "ca_orderer",
                  "EndpointID": "057390288a424f49d6e9d6f788049b1e18aa28bccd56d860b2be8ceb8173ef74",
                  "MacAddress": "02:42:c0:a8:70:02",
                  "IPv4Address": "192.168.112.2/20",
                  "IPv6Address": ""
              },
              "7eb5f64bfe5f20701aae8a6660815c4e3a81c3834b71f9e59a62fb99bed1afc7": {
                  "Name": "couchdb0",
                  "EndpointID": "bfe740be15ec9dab7baf3806964e6b1f0b67032ce1b7ae26ac7844a1b422ddc4",
                  "MacAddress": "02:42:c0:a8:70:07",
                  "IPv4Address": "192.168.112.7/20",
                  "IPv6Address": ""
              },
              "87aef6062f2324889074cda80fec8fe014d844e10085827f380a91eea4ccdd74": {
                  "Name": "ca_org1",
                  "EndpointID": "a740090d33ca94dd7c6aaf14a79e1cb35109b549ee291c80195beccc901b16b7",
                  "MacAddress": "02:42:c0:a8:70:03",
                  "IPv4Address": "192.168.112.3/20",
                  "IPv6Address": ""
              },
              "a86f50ca19079f59552e8674932edd02f7f9af93ded14db3b4c404fd6b1abe9c": {
                  "Name": "peer0.org2.example.com",
                  "EndpointID": "6e56772b4783b1879a06f86901786fed1c307966b72475ce4631405ba8bca79a",
                  "MacAddress": "02:42:c0:a8:70:09",
                  "IPv4Address": "192.168.112.9/20",
                  "IPv6Address": ""
              }
          },
          "Options": {},
          "Labels": {}
      }
  ]
```

Обратите внимание, что восемь контейнеров используют разные IP-адреса, будучи
частями единой сети Docker (мы сократили экранный вывод для читаемости).

Так как мы управляем сетью как DigiBank и MagnetoCorp,
`peer0.org1.example.com` будет принадлежать организации DigiBank, а
`peer0.org2.example.com` будет управляться MagnetoCorp. Теперь, когда сеть запущена,
мы далее будем называть её PaperNet.

Повторимся: вы загрузили репозиторий образцов Hyperledger Fabric с GitHub
и получили сеть Fabric network на вашей локальной машине. Теперь давайте вступим в роль
 MagnetoCorp, которая планирует выпускать и торговать коммерческими ценными бумагами.

## Мониторинг сети от лица MagnetoCorp

Руководство по этой сети обращения коммерческих ценных бумаг позволяет вам
действовать от лица двух организаций, используя две отдельные папки для каждого из
DigiBank и MagnetoCorp. Эти две папки содержат смарт-контракты и файлы приложений
для каждой из организаций. Откройте новое окно в репозитории `fabric-samples`
перейдите в директорию MagnetoCorp следующей командой:
```
cd commercial-paper/organization/magnetocorp
```
От имени MagnetoCorp мы начнем с мониторинга компонентов PaperNet. Администратор может
просматривать агрегированный вывод данных от набора контейнеров [инструментом](https://github.com/gliderlabs/logspout#logspout)
`logspout`.Этот инструмент собирает все потоки вывода в одном месте, так удобнее посмотреть
все происходящее из одного окна. Это очень помогает администраторам при установке
смарт-контрактов или, к примеру, разработчикам, вызывающим смарт-контракты.

В директории MagnetoCorp запустите следующую команду для запуска скрипта
`monitordocker.sh`  и инструмента `logspout` для контейнеров PaperNet, запущенных на `net_test`:
```
(magnetocorp admin)$ ./configuration/cli/monitordocker.sh net_test
...
latest: Pulling from gliderlabs/logspout
4fe2ade4980c: Pull complete
decca452f519: Pull complete
(...)
Starting monitoring on all containers on the network net_test
b7f3586e5d0233de5a454df369b8eadab0613886fc9877529587345fc01a3582
```

Заметьте, что вы можете задать номер порта, если порт, заданный в `monitordocker.sh` по умолчанию,
уже используется.
```
(magnetocorp admin)$ ./monitordocker.sh net_test <port_number>
```

В этом окне будет показываться вывод ото всех контейнеров Docker вплоть до конца данного
руководства, так что теперь перейдите к открытию еще одного окна команд.
Следующим шагом мы посмотрим на смарт-контракты, при помощи которых MagnetoCorp будет
выпускать коммерческие ценные бумаги.

## Смарт-контракт коммерческих ценных бумаг

`issue` (выпуск/эмиссия), `buy` (купить) и `redeem` (погасить) представляют три основных функции смарт-контракта коммерческих
ценных бумаг. Его используют приложения для записи транзакций, которые соответственно
выпускают, покупают и погашают коммерческие ценные бумаги в реестре. Теперь наша задача -
изучить этот смарт-контракт.

Откройте новый терминал в директории `fabric-samples` и перейдите в папку
MagnetoCorp, чтобы действовать от лица разработчика MagnetoCorp.
```
cd commercial-paper/organization/magnetocorp
```
Теперь можете просмотреть смарт-контракт в директории `contract` при помощи
вашего текстового редактора (мы используем VS Code):
```
(magnetocorp developer)$ code contract
```

В директории `lib` этой папки находится файл `papercontract.js`  -- он и содержит
смарт-контракт коммерческих ценных бумаг!

![commercialpaper.vscode1](./commercial_paper.vscode.papercontract.png) *Пример отображения кода смарт-контракта из файла `papercontract.js` в текстовом редакторе*

`papercontract.js` это программа на JavaScript, предназначенная для запуска в
среде Node.js. Отметим следующие строчки кода:

* `const { Contract, Context } = require('fabric-contract-api');`

  Эта инструкция вводит два ключевых класса Hyperledger Fabric, которые широко
  будут использоваться этим смарт-контрактом  -- `Contract` и `Context`. Узнать
  о них подробнее можно в документах:
  [`fabric-shim` JSDOCS](https://hyperledger.github.io/fabric-chaincode-node/).


* `class CommercialPaperContract extends Contract {`

  Этим определяется класс `CommercialPaperContract`, основанный на встроенном
  в Fabric классе `Contract`. В этом классе определяются методы, реализующие
  ключевые транзакции с коммерческими ценными бумагами - `issue` ("выпустить"),
  `buy`("купить") и `redeem`("погасить").


* `async issue(ctx, issuer, paperNumber, issueDateTime, maturityDateTime...) {`

  Этим методом определяется транзакция `issue` для PaperNet. Параметры, передающиеся
  в этот метод, будут использоваться для создания новой коммерческой ценной бумаги.

  Предлагаем самостоятельно найти и изучить транзакции `buy` и `redeem` в смарт-контракте.


* `let paper = CommercialPaper.createInstance(issuer, paperNumber, issueDateTime...);`

  В пределах транзакции `issue` эта инструкция создает новую коммерческую ценную бумагу
  в памяти, используя класс `CommercialPaper` с заданными параметрами. Изучите
  транзакции `buy` и `redeem`, чтобы убедиться, что они используют этот класс сходным образом.


* `await ctx.paperList.addPaper(paper);`

  Эта инструкция добавляет новую коммерческую ценную бумагу в реестр, используя
  `ctx.paperList`, экземпляр класса `PaperList`, котрый был создан в момент инициализации
  контекста смарт-контракта `CommercialPaperContext`. Аналогично,
  изучите методы `buy` и `redeem` для того, чтобы увидеть, как они используют этот класс.


* `return paper;`

  Эта инструкция возвращает бинарный буфер в качестве ответа от транзакции `issue`
  на обработку тому, кто вызвал смарт-контракт.


Попробуйте посмотреть на другие файлы в директории `contract`, чтобы понять, как
работает смарт-контракт, особенно подробно почитайте в главе
[обработка смарт-контракта](../developapps/smartcontract.html), как устроен `papercontract.js`.

## Развернуть смарт-контракт в канале

Перед тем как `papercontract` может быть вызван приложениями, его нужно установить
на соответствующие узлы тестовой сети и затем определить в канале, используя
[жизненный цикл чейнкода Fabric](../chaincode_lifecycle.html#chaincode-lifecycle).
Жизненный цикл чейнкода Fabric позволяет нескольким организациям согласовывать параметры чейнкода,
прежде чем развернуть чейнкод в канале. В итоге нам нужно установить и одобрить чейнкод -
как от имени администраторов MagnetoCorp, так и DigiBank.

![commercialpaper.install](./commercial_paper.diagram.install.png)  *Администратор MagnetoCorp устанавливает копию `papercontract` на узел MagnetoCorp.*

Смарт-контракты, как центральный элемент разработки приложений, содержатся в сущности
Hyperledger Fabric, называемой [чейнкод](../chaincode.html). Одним чейнкодом могут быть
определены как один, так и несколько смарт-контрактов, и, установив этот чейнкод, ими
могут пользоваться любые организации в сети PaperNet. Это значит, что установка чейнкода -
дело администраторов, а все остальные могут обращать внимание только на смарт-контракты.

### Установить и одобрить смарт-контракт от имени MagnetoCorp

Сначала мы установим и одобрим смарт-контракт от имени администратора MagnetoCorp. Сначала
проверьте, что вы находитесь в папке `magnetocorp` и, если нет, то перейдите в нее
следующей командой:
```
cd commercial-paper/organization/magnetocorp
```

Администратор MagnetoCorp может взаимодействовать с PaperNet при помощи команд `peer`.
Но в то же время, администратор должен задать определенные переменные среды в своем
командном окне, чтобы использовать подходящие двоичные файлы `peer` binaries, отсылать
команды по адресу узла MagnetoCorp, и подписывать запросы правильными криптографическими
средствами.

Используйте скрипт, который вам предоставлен в примере, чтобы задать значения переменных среды
в своем командном окне. Запустите эту команду в директории `magnetocorp`:
```
source magnetocorp.sh
```

В вашем окне откроется полный список переменных среды. Теперь мы можем использовать это командное окно
для взаимодействия с PaperNet от имени администратора MagnetoCorp.

В первую очередь установите смарт-контракт `papercontract`. Его можно обернуть в чейнкод,
используя команду `peer lifecycle chaincode package`. Для создания пакета чейнкода в окне
команд администратора MagnetoCorp запустите следующую команду:
```
(magnetocorp admin)$ peer lifecycle chaincode package cp.tar.gz --lang node --path ./contract --label cp_0
```
После этого администратор MagnetoCorp может установить чейнкод на узле в MagnetoCorp,
используя команду `peer lifecycle chaincode install`:
```
(magnetocorp admin)$ peer lifecycle chaincode install cp.tar.gz
```
После установки чейнкода вы увидите примерно такие сообщения:
```
2020-01-30 18:32:33.762 EST [cli.lifecycle.chaincode] submitInstallProposal -> INFO 001 Installed remotely: response:<status:200 payload:"\nEcp_0:ffda93e26b183e231b7e9d5051e1ee7ca47fbf24f00a8376ec54120b1a2a335c\022\004cp_0" >
2020-01-30 18:32:33.762 EST [cli.lifecycle.chaincode] submitInstallProposal -> INFO 002 Chaincode code package identifier: cp_0:ffda93e26b183e231b7e9d5051e1ee7ca47fbf24f00a8376ec54120b1a2a335c
```
Из-за того, что администратор MagnetoCorp сделал установку, что `CORE_PEER_ADDRESS=localhost:9051`
должен направлять своим команды в `peer0.org2.example.com`, то `INFO 001 Installed remotely...`
показывает, что `papercontract` успешно установился на узел.

После установки смарт-контракта, нам от имени администратора MagnetoCorp необходимо одобрить
определение чейнкода для `papercontract`. В первую очередь найдите packageID чейнкода,
установленного на узле. Мы можем запросить packageID командой `peer lifecycle chaincode queryinstalled`:
```
peer lifecycle chaincode queryinstalled
```

Эта команда выдаст тот же пакетный идентфикатор, что и команда установки. Вы
должны увидеть примерно следующее:
```
Installed chaincodes on peer:
Package ID: cp_0:ffda93e26b183e231b7e9d5051e1ee7ca47fbf24f00a8376ec54120b1a2a335c, Label: cp_0
```

Пакетный идентификатор (package ID) нам понадобится на следующем шаге, и для этого мы запомним его как переменную
среды. Не для всех пользователей он будет одинаковым, поэтому необходимо закончить
этот этап, используя пакетный идентификатор, выданный в командном окне.
```
export PACKAGE_ID=cp_0:ffda93e26b183e231b7e9d5051e1ee7ca47fbf24f00a8376ec54120b1a2a335c
```

Администратор теперь может одобрить определение чейнкода для MagnetoCorp командой
`peer lifecycle chaincode approveformyorg`:
```
(magnetocorp admin)$ peer lifecycle chaincode approveformyorg --orderer localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name papercontract -v 0 --package-id $PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA
```

Одним из важнейших параметров чейнкода, который должен быть согласован между членами каналами
при определении чейнкода, это [установленные правила одобрения](../endorsement-policies.html) чейнкода.
Установленные правила одобрения задают список организаций, которые должны одобрить (исполнить и подписать)
транзакцию, прежде, чем определить ее как действительную. Одобрив чейнкод `papercontract`
без флага ``--policy``, администратор MagnetoCorp принимает установленные в канале по умолчанию правила одобрения (`Endorsement`),
которые в случае тестового канала `mychannel` постановляют, что для одобрения транзакции
необходимо одобрения большинства организаций канала.  
Все транзакции, как действительные, так и недействительные, будут записаны в [реестр блокчейна](../ledger/ledger.html#blockchain),
но только действительным транзакциям позволено изменить [глобальное состояние](../ledger/ledger.html#world-state).

### Установить и одобрить смарт-контракт от имени DigiBank

Основываясь на установленных в `mychannel` правилах `LifecycleEndorsement`, жизненный
цикл чейнкода Fabric требует, чтобы определение чейнкода было согласовано
большинством организаций канала, прежде, чем чейнкод будет записан в канал.
Из этого следует, что для одобрения чейнкода `papernet`, мы должны одобрить его
от имени как MagnetoCorp, так и DigiBank, что и составит необходимое большинство (2 из 2).
Откройте новое терминальное окно в `fabric-samples` и перейдите в папку, содержащую
смарт-контракт DigiBank и файлы приложений:
```
(digibank admin)$ cd commercial-paper/organization/digibank/
```
Используйте скрипт из папки DigiBank, чтобы задать переменные среды, которые дадут вам
право действовать от лица администратора DigiBank:
```
source digibank.sh
```

Теперь можно установить и одобрить `papercontract` от имени DigiBank. Запустите следующую
команду для упаковки чейнкода:
```
(digibank admin)$ peer lifecycle chaincode package cp.tar.gz --lang node --path ./contract --label cp_0
```
Теперь администратор установит чейнкод на узел DigiBank:
```
(digibank admin)$ peer lifecycle chaincode install cp.tar.gz
```
Теперь нужно запросить и сохранить пакетный идентификатор (packageID) только что установленного
чейнкода:
```
(digibank admin)$ peer lifecycle chaincode queryinstalled
```
Сохраните пакетный идентификатор как переменную среды. Используйте пакетный идентификатор из окна
вывода, чтобы завершить этот шаг.
```
export PACKAGE_ID=cp_0:ffda93e26b183e231b7e9d5051e1ee7ca47fbf24f00a8376ec54120b1a2a335c
```

Теперь администратор Digibank может одобрить определение чейнкода `papercontract`:
```
(digibank admin)$ peer lifecycle chaincode approveformyorg --orderer localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name papercontract -v 0 --package-id $PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA
```

### Записать определение чейнкода в канал

DigiBank и MagnetoCorp одобрили чейнкод `papernet`, и теперь у нас есть
необходимое большинство (2 из 2) для записи определения чейнкода в канал.
Как только чейнкод успешно определен в канале, клиентские приложения в канале могут
вызывать смарт-контракт `CommercialPaper`, содержащийся в чейнкоде `papercontract`.
Любая из двух организаций может записать чейнкод в канал, и мы сделаем это, например,
от лица администратора DigiBank:

![commercialpaper.commit](./commercial_paper.diagram.commit.png)  *Aдминистратор DigiBank записывает определение чейнкода `papercontract` в канал, после чего создается новый контейнер Docker для запуска `papercontract` на обоих узлах PaperNet*

Чтобы записать определение `papercontract` в `mychannel`, администратор DigiBank использует
команду `peer lifecycle chaincode commit`:
```
(digibank admin)$ peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --peerAddresses localhost:7051 --tlsRootCertFiles ${PEER0_ORG1_CA} --peerAddresses localhost:9051 --tlsRootCertFiles ${PEER0_ORG2_CA} --channelID mychannel --name papercontract -v 0 --sequence 1 --tls --cafile $ORDERER_CA --waitForEvent
```
После того, как определение чейнкода будет записано в канал, запустится контейнер чейнкода.
Посмотрите, как запускается контейнер `papercontract` на обоих узлах, используся команду `docker ps`.

```
(digibank admin)$ docker ps

CONTAINER ID        IMAGE                                                                                                                                                               COMMAND                  CREATED             STATUS              PORTS                                        NAMES
d4ba9dc9c55f        dev-peer0.org1.example.com-cp_0-ebef35e7f1f25eea1dcc6fcad5019477cd7f434c6a5dcaf4e81744e282903535-05cf67c20543ee1c24cf7dfe74abce99785374db15b3bc1de2da372700c25608   "docker-entrypoint.s…"   30 seconds ago      Up 28 seconds                                                    dev-peer0.org1.example.com-cp_0-ebef35e7f1f25eea1dcc6fcad5019477cd7f434c6a5dcaf4e81744e282903535
a944c0f8b6d6        dev-peer0.org2.example.com-cp_0-1487670371e56d107b5e980ce7f66172c89251ab21d484c7f988c02912ddeaec-1a147b6fd2a8bd2ae12db824fad8d08a811c30cc70bc5b6bc49a2cbebc2e71ee   "docker-entrypoint.s…"   31 seconds ago      Up 28 seconds                                                    dev-peer0.org2.example.com-cp_0-1487670371e56d107b5e980ce7f66172c89251ab21d484c7f988c02912ddeaec
```

Имена контейнеров отражают имя узла, который его запустил, и информацию о том, что в нем
запущен `papercontract` версии `0`.

После развертывания чейнкода `papercontract` в канале, приложение MagnetoCorp может выпускать
коммерческие ценные бумаги. Взглянем на структуру приложения.

## Структура приложения

Приложение `issue.js` организации MagnetoCorp обращается к смарт-контракту, содержащемуся
в `papercontract`. Изабелла использует это приложение, чтобы записать в реестр транзакцию, которая
выпускает коммерческую ценную бумагу `00001`. Кратко разберем, как работает приложение `issue`:

![commercialpaper.application](./commercial_paper.diagram.8.png) *Шлюз фокусирует приложение на создании транзакций, записи и ответе на транзакции. Он координирует создание транзакций, упорядочение и обработку уведомлений между разными компонентами сети.*

Приложение `issue` пишет транзакции от имени Изабеллы, следовательно, для начала оно
извлекает сертификат X.509, принадлежащий Изабелле из ее [кошелька](../developapps/wallet.html),
который может храниться в локальной файловой системе или в аппаратном модуле безопасности
[HSM](https://en.wikipedia.org/wiki/Hardware_security_module). Затем приложение `issue`
имеет право использовать шлюз для посылки транзакций в канал. Набор средств разработки Hyperledger Fabric (SDK)
содержит абстракцию [шлюза](../developapps/gateway.html), таким образом приложение может
заниматься только собственной логикой, положившись в сетевом взаимодействии на шлюз.
Шлюзы и кошельки радикально упрощают написание приложений Hyperledger Fabric.

Итак, посмотрим на приложение Изабеллы `issue`. Откройте отдельное терминальное окно для нее, и
найдите папку `/application` организации MagnetoCorp в `fabric-samples`:

```
(isabella)$ cd commercial-paper/organization/magnetocorp/application/
(isabella)$ ls

addToWallet.js		enrollUser.js		issue.js		package.json
```

при помощи программы `addToWallet.js` Изабелла загрузит свой идентификатор в кошелек, и,
вызвав `papercontract`, при помощи этого идентификатора `issue.js` создаст коммерческую
ценную бумагу `00001` от лица MagnetoCorp.

Перейдите в директорию, которая содержит копию приложения `issue.js`, принадлежащую
MagnetoCorp, и посмотрите ее в текстовом редакторе:

```
(isabella)$ cd commercial-paper/organization/magnetocorp/application
(isabella)$ code issue.js
```

Изучите эту директорию; в ней лежит приложение эмиссии (выпуска/issue) и все его зависимости.

![commercialpaper.vscode2](./commercial_paper.vscode.issue.png) *Взгляд из текстового редактора: содержимое директории приложения коммерческих ценных бумаг.*

Ключевыми программными строчками в `issue.js` являются:

* `const { Wallets, Gateway } = require('fabric-network');`

  Эта инструкция вводит два ключевых класса набора средств разработки Hyperledger Fabric --
  `Wallet` и `Gateway`.


* `const wallet = await Wallets.newFileSystemWallet('../identity/user/isabella/wallet');`

  В этой инструкции определяется, что приложение будет использовать кошелек `isabella` при
  соединении с каналом сети блокчейн. Так как сертификат X.509 Изабеллы находится в локальной
  файловой системе, приложение создает новый `FileSystemWallet`. Это приложение
  выберет конкретный идентификатор в кошельке `isabella`.


* `await gateway.connect(connectionProfile, connectionOptions);`

  Эта строчка соединяется с сетью через шлюз, определенный в `connectionProfile`,
  используя идентификатор, указанный в `ConnectionOptions`.

  Посмотрите как `../gateway/networkConnection.yaml` и `User1@org1.example.com`
  используются для этих значений каждый в свою очередь.


* `const network = await gateway.getNetwork('mychannel');`

  Этой строчкой приложение соединяется с каналом `mychannel` с заранее развернутым
  чейнкодом `papercontract`.


* `const contract = await network.getContract('papercontract');`

  Эта инструкция дает приложению доступ к чейнкоду `papercontract`.
  Как только приложение выпустит getContract, оно может записывать в любую транзакцию
  смарт-контракта на этом чейнкоде.

* `const issueResponse = await contract.submitTransaction('issue', 'MagnetoCorp', '00001', ...);`

  Эта строчка посылает транзакцию в сеть с помощью транзакции `issue`,
  определенной внутри смарт-контракта. `MagnetoCorp`, `00001`... это значения, которые
  должна использовать транзакция `issue` для создания новой коммерческой ценной бумаги.

* `let paper = CommercialPaper.fromBuffer(issueResponse);`

  Эта инструкция обрабатывает ответ от транзакции `issue`. Ответ должен быть десериализован из
  буфера в `paper`, объект `CommercialPaper`, для корректной интерпретации приложением.


Можете изучить и другие файлы в директории `/application` для понимания того, как работает
`issue.js`, а прочитать о подробностях реализации его в приложении можете в [главе](../developapps/application.html).

## Зависимости приложения

Приложение `issue.js` написано на JavaScript и предназначено для исполнения в среде
Node.js, являющейся клиентом для сети PaperNet.
Как обычно, приложение MagnetoCorp построено на большом числе внешних пакетов -- для
улучшения качества и ускорения разработки. Приложение `issue.js` включает `js-yaml`
[пакет](https://www.npmjs.com/package/js-yaml) чтобы обработать профиль соединения с шлюзом YAML,
или [пакет](https://www.npmjs.com/package/fabric-network) `fabric-network` для доступа
к классам `Gateway` и `Wallet`:

```JavaScript
const yaml = require('js-yaml');
const { Wallets, Gateway } = require('fabric-network');
```

Эти пакеты нужно загрузить с [npm](https://www.npmjs.com/) в локальную файловую систему,
используя команду `npm install`. По общепринятому правилу, для использования по мере
исполнения пакеты устанавливают в связанную с приложением директорию `/node_modules`.

Откройте файл `package.json`, чтобы убедиться, как `issue.js` определяет, какие пакеты
следует загружать и в какой версии, пользуясь разделом "зависимости" в файле.

Версионирование **npm** это мощный инструмент; подробнее об этом
[см.здесь](https://docs.npmjs.com/getting-started/semantic-versioning).

Давайте установим эти пакеты командой `npm install` -- это займет немного времени:

```
(isabella)$ cd commercial-paper/organization/magnetocorp/application/
(isabella)$ npm install

(           ) extract:lodash: sill extract ansi-styles@3.2.1
(...)
added 738 packages in 46.701s
```

Вот как эта команда изменила директорию:

```
(isabella)$ ls

enrollUser.js 		node_modules	      	package.json
issue.js	      	package-lock.json
```

Взгляните на директорию `node_modules`, чтобы увидеть установленные пакеты. Их довольно
много, так как `js-yaml` и `fabric-network` в свою очередь тоже построены на других
npm-пакетах! К счастью, [файл](https://docs.npmjs.com/files/package-lock.json) `package-lock.json`
распознает точные значения версий, что просто необходимо при точном воспроизведении среды -
например, для тестирования приложений, диагностирования проблем или поставки
протестированных приложений заказчику.

## Кошелек

Изабелла уже готова запустить `issue.js`, чтобы выпустить коммерческие ценные бумаги MagnetoCorp
`00001`; осталось только одно небольшое действие. Поскольку `issue.js` будет
действовать от имени Изабеллы, и, следовательно, и MagnetoCorp, оно использует
[кошелек](../developapps/wallet.html), в котором эта информация будет отражена.
Теперь мы должны исполнить разовую задачу по генерации по стандарту X.509 необходимых
идентифицирующих данных для ее кошелька.

В удостоверяющем центре MagnetoCorp, запущенном на PaperNet, `ca_org2`, есть пользователь
приложения, который был зарегистрирован при разворачивании сети.
Изабелла может использовать его имя и секрет для генерации криптографического материала
по стандарту X.509 для приложения `issue.js`. Участие УЦ в генерации криптографического
материала на стороне клиента назовем **регистрацией(enrollment)**. При исполнении действительных
производственных задач, оператор сети предоставит имя и секрет клиентского идентификатора,
зарегистрированного в УЦ, разработчику приложения. Затем, эти данные разработчик использует, чтобы
зарегистрировать свое приложение в сети и взаимодействовать с сетью.


Программа `enrollUser.js` использует класс `fabric-ca-client` для генерации пары ключей - открытого
и секретного, а затем отправляет **Запрос на подпись сертификата** в УЦ.
Если имя идентификатора и секрет, которые отправляет Изабелла в УЦ, совпадут с хранящимися там, то
УЦ выпустит и подпишет сертификат, кодирующий открытый ключ, удостоверяющий, что Изабелла
работает в MagnetoCorp. После того, как обработка запроса на подпись завершена, `enrollUser.js`
записывает и хранит секретный ключ и подписывающий сертификат в кошельке Изабеллы.
Можете посмотреть в файле `enrollUser.js`, как именно набор средств разработки Node SDK
использует класс `fabric-ca-client` для этих процессов.

В терминальном окне Изабеллы запустите программу `enrollUser.js` для внесения информации
об идентификаторе в ее кошелек:

```
(isabella)$ node enrollUser.js

Wallet path: /Users/nikhilgupta/fabric-samples/commercial-paper/organization/magnetocorp/identity/user/isabella/wallet
Successfully enrolled client user "isabella" and imported it into the wallet
```

Теперь можем обратить внимание на результат исполнения программы --- содержимое
кошелька, которое будет использовано для посылки транзакций в PaperNet:

```
(isabella)$ ls ../identity/user/isabella/wallet/

isabella.id
```

В своем кошельке Изабелла может хранить много идентификаторов, хоть и используя лишь один,
как в нашем случае. Папка `wallet` содержит файл `isabella.id`, в котором лежит информация,
необходимая Изабелле, чтобы соединяться с сетью. На каждый другой идентификатор, который
Изабелла может использовать, будет приходиться собственный отдельный файл.
Можете открыть этот файл, чтобы увидеть идентифицирующую информацию, которую `issue.js`
будет применять от имени Изабеллы внутри JSON-файла. Поток вывода отформатирован для наглядности.
```
(isabella)$  cat ../identity/user/isabella/wallet/*

{
  "credentials": {
    "certificate": "-----BEGIN CERTIFICATE-----\nMIICKTCCAdCgAwIBAgIQWKwvLG+sqeO3LwwQK6avZDAKBggqhkjOPQQDAjBzMQsw\nCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEWMBQGA1UEBxMNU2FuIEZy\nYW5jaXNjbzEZMBcGA1UEChMQb3JnMi5leGFtcGxlLmNvbTEcMBoGA1UEAxMTY2Eu\nb3JnMi5leGFtcGxlLmNvbTAeFw0yMDAyMDQxOTA5MDBaFw0zMDAyMDExOTA5MDBa\nMGwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMRYwFAYDVQQHEw1T\nYW4gRnJhbmNpc2NvMQ8wDQYDVQQLEwZjbGllbnQxHzAdBgNVBAMMFlVzZXIxQG9y\nZzIuZXhhbXBsZS5jb20wWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAT4TnTblx0k\ngfqX+NN7F76Me33VTq3K2NUWZRreoJzq6bAuvdDR+iFvVPKXbdORnVvRSATcXsYl\nt20yU7n/53dbo00wSzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADArBgNV\nHSMEJDAigCDOCdm4irsZFU3D6Hak4+84QRg1N43iwg8w1V6DRhgLyDAKBggqhkjO\nPQQDAgNHADBEAiBhzKix1KJcbUy9ey5ulWHRUMbqdVCNHe/mRtUdaJagIgIgYpbZ\nXf0CSiTXIWOJIsswN4Jp+ZxkJfFVmXndqKqz+VM=\n-----END CERTIFICATE-----\n",
    "privateKey": "-----BEGIN PRIVATE KEY-----\nMIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQggs55vQg2oXi8gNi8\nNidE8Fy5zenohArDq3FGJD8cKU2hRANCAAT4TnTblx0kgfqX+NN7F76Me33VTq3K\n2NUWZRreoJzq6bAuvdDR+iFvVPKXbdORnVvRSATcXsYlt20yU7n/53db\n-----END PRIVATE KEY-----\n"
  },
  "mspId": "Org2MSP",
  "type": "X.509",
  "version": 1
}
```

В этом файле легко отметить:

* `"privateKey":` - используется для подписи транзакций от имени Изабеллы, но
  передается вовне только с ее прямого разрешения.

* `"certificate":` содержит открытый ключ Изабеллы и прочие атрибуты протокола X.509,
  которые вносит УЦ при создании сертификата. Этот сертификат передается любым участникам
  сети, так что они в любое время могут криптографически верифицировать информацию,
  созданную при помощи секретного ключа Изабеллы.

Подробнее о сертификатах [см. здесь](../identity/identity.html#digital-certificates). На деле,
файл сертификата содержит также специфические для Fabric метаданные - например, название
организации, в которой работает Изабелла, и должность Изабеллы -- подробнее написано
в главе [кошелек](../developapps/wallet.html).

## Приложение issue

Теперь Изабелла при помощи `issue.js` может послать транзакцию, которая создает коммерческую
ценную бумагу MagnetoCorp `00001`:

```
(isabella)$ node issue.js

Connect to Fabric gateway.
Use network channel: mychannel.
Use org.papernet.commercialpaper smart contract.
Submit commercial paper issue transaction.
Process issue transaction response.{"class":"org.papernet.commercialpaper","key":"\"MagnetoCorp\":\"00001\"","currentState":1,"issuer":"MagnetoCorp","paperNumber":"00001","issueDateTime":"2020-05-31","maturityDateTime":"2020-11-30","faceValue":"5000000","owner":"MagnetoCorp"}
MagnetoCorp commercial paper : 00001 successfully issued for value 5000000
Transaction complete.
Disconnect from Fabric gateway.
Issue program complete.
```

Команда `node` инициализирует среду Node.js, и запускает `issue.js`. Из программного
вывода на экран видно, что MagnetoCorp выпустила коммерческую ценную бумагу 00001 с
номиналом 5 млн долл США.

Как видите, чтобы сделать это, приложение вызывает транзакцию `issue`, определенную
смарт-контрактом `CommercialPaper` посредством `papercontract.js`.
Чтобы представить новую коммерческую ценную бумагу как вектор состояния внутри
глобального состояния, смарт-контракт взаимодействует с реестром посредством API-интерфейсов Fabric, самыми
примечательными из которых являются `putState()` и `getState()`. Впоследствии мы
увидим, как вектор состояния изменяется транзакциями `buy` и `redeem`, которые также
определены в этом смарт-контракте.

И так постоянно: использованный набор средств разработки Fabric SDK упрощает логику разработки,
обрабатывая одобрение транзакций и процессы упорядочения и уведомления; Fabric SDK
пользуется [шлюзом](../developapps/gateway.html), чтобы абстрагировать любые подробности
конкретной сети и [варианты подключения](../developapps/connectoptions.html), чтобы
декларировать более сложные стратегии обработки, такие как перезапуск транзакции.

Продолжим отслеживание жизненного цикла бумаги MagnetoCorp 00001, переключив внимание на
сотрудника DigiBank по имени Баладжи, который будет покупать коммерческие ценные бумаги при помощи
приложения DigiBank.

## Приложения Digibank

Используя приложение DigiBank'а `buy`, Баладжи посылает в реестр транзакцию, которая
передает право собственности на коммерческую ценную бумагу `00001` от MagnetoCorp к
DigiBank. Смарт-контракт `CommercialPaper` - тот же, что использовался приложением
MagnetoCorp, только транзакция в этот раз другая -- не `issue`, а `buy`.
Посмотрим, как работает приложение DigiBank.

Откройте отдельное терминальное окно для Баладжи. Находясь в`fabric-samples`, перейдите
в директорию приложения DigiBank, в которой содержится приложение `buy.js`, и откройте
текстовым редактором:

```
(balaji)$ cd commercial-paper/organization/digibank/application/
(balaji)$ code buy.js
```

Легко можно видеть, что эта директория содержит как приложение `buy`, так и приложение `redeem` -
их и будет использовать Баладжи.  

![commercialpaper.vscode3](./commercial_paper.diagram.12.png) *Директория DigiBank, содержащая приложения `buy.js` и `redeem.js`*

Приложение `buy.js` DigiBank очень похоже по структуре на приложение MagnetoCorp
`issue.js`, но с двумя важными отличиями:


  * **Идентификатор**: пользователем в данном случае является пользователь DigiBank `Balaji`, а не сотрудник MagnetoCorp
    `Isabella`

    ```JavaScript
    const wallet = await Wallets.newFileSystemWallet('../identity/user/balaji/wallet');
    ```

    Вот так приложение использует кошелек `balaji`, когда соединяется с каналом сети
    PaperNet. `buy.js` выбирает конкретный идентификатор в кошельке
    `balaji`.


  * **Транзакция**: вызывается транзакция `buy`, а не `issue`

    ```JavaScript
    const buyResponse = await contract.submitTransaction('buy', 'MagnetoCorp', '00001', ...);
    ```

    Транзакция `buy` посылается со значениями `MagnetoCorp`, `00001`, ..., и
    эти значения используются смарт-контрактом `CommercialPaper`, чтобы
    передать права собственности на коммерческую ценную бумагу `00001` банку DigiBank.

Посмотрите, пожалуйста, и другие файлы в директории `application`, чтобы
понять, как работает приложение, и подробно изучите, как реализована `buy.js` в
приложении в [главе](../developapps/application.html).

## Исполнение на стороне DigiBank

Приложения DigiBank по покупке и погашению коммерческих ценных бумаг имею сходную структуру
с приложением MagnetoCorp по выпуску ценных бумаг. Итак, теперь произведем установку их зависимостей
и настроим кошелек Баладжи, чтобы он мог использовать эти приложения для покупки
и погашения коммерческих ценных бумаг.

Как и MagnetoCorp, Digibank должен установить необходимые пакеты приложений
при помощи команды ``npm install``, это опять займет некоторое время.

В окне администратора DigiBank, установите следующие зависимости приложения:

```
(digibank admin)$ cd commercial-paper/organization/digibank/application/
(digibank admin)$ npm install

(            ) extract:lodash: sill extract ansi-styles@3.2.1
(...)
added 738 packages in 46.701s
```

В окне команд Баладжи, запустите программу `enrollUser.js` для генерации
сертификата и секретного ключа и внесения их в его кошелек:
```
(balaji)$ node enrollUser.js

Wallet path: /Users/nikhilgupta/fabric-samples/commercial-paper/organization/digibank/identity/user/balaji/wallet
Successfully enrolled client user "balaji" and imported it into the wallet
```

Программа `addToWallet.js` внесла идентфицирующую информацию для `balaji` в его
кошелек, и эта информация будет использоваться приложениями `buy.js` и `redeem.js`
для посылки транзакций в `PaperNet`.

Как и Изабелла, Баладжи может хранить любые другие идентификаторы в своем кошельке, но
в нашем примере будет использоваться только один. Соответствующий ему идентификационный
файл `digibank/identity/user/balaji/wallet/balaji.id` очень похож на тот, что был у Изабеллы,
если посмотреть на него.

## Приложение buy

Баладжи теперь может запусить `buy.js`, чтобы послать транзакцию, которая передаст
право собственности на коммерческую ценную бумагу 00001 от MagnetoCorp в пользу DigiBank.

Запустите приложение `buy` в окне Баладжи:

```
(balaji)$ node buy.js

Connect to Fabric gateway.
Use network channel: mychannel.
Use org.papernet.commercialpaper smart contract.
Submit commercial paper buy transaction.
Process buy transaction response.
MagnetoCorp commercial paper : 00001 successfully purchased by DigiBank
Transaction complete.
Disconnect from Fabric gateway.
Buy program complete.
```

Можете убедиться, что выводные данные программы показывают, что коммерческая ценная
бумага 00001 организации MagnetoCorp была успешно приобретена Баладжи от имени DigiBank.
Приложение `buy.js` создало транзакцию`buy`, определенную в смарт-контракте `CommercialPaper`,
которая изменила статус коммерческой ценной бумаги `00001` в глобальном состоянии, используя интерфейсы Fabric `putState()` и
`getState()`. Логика приложений по покупке и выпуску коммерческих ценных бумаг очень схожая,
как и логика смарт-контракта.

## Приложение погашения

Последняя транзакция в жизненном цикле коммерческой ценной бумаги 00001 должна отражать
погашение этой ценной бумаги организацией MagnetoCorp при предъявлении организацией DigiBank.
Баладжи использует `redeem.js`, чтобы послать транзакцию, которая исполнит логику погашения,
заложенную в смарт-контракте.

Запустите транзакцию `redeem` в окне Баладжи:

```
(balaji)$ node redeem.js

Connect to Fabric gateway.
Use network channel: mychannel.
Use org.papernet.commercialpaper smart contract.
Submit commercial paper redeem transaction.
Process redeem transaction response.
MagnetoCorp commercial paper : 00001 successfully redeemed with MagnetoCorp
Transaction complete.
Disconnect from Fabric gateway.
Redeem program complete.
```

Обратите внимание, как в очередной раз коммерческая ценная бумага 00001 была успешно
погашена, когда `redeem.js` создало транзакцию `redeem`, определенную в `CommercialPaper`.
И снова, статус бумаги `00001` в глобальном состоянии был изменен, чтобы отразить
факт возврата права собственности к MagnetoCorp, эмитенту этой бумаги.

## Убрать за собой

После того, как закончите прохождение руководства "Коммерческие ценные бумаги", для
очистки среды можете использовать скрипт. В командном окне перейдите в директору с
образцами для коммерческих ценных бумаг:
```
cd fabric-samples/commercial-paper
```
Теперь можете остановить сеть следующей командой:
```
./network-clean.sh
```
Эта команда, как и инструмент logspout, остановит узлы, контейнеры CouchDB и узел упорядочения сети.
Она также удалит идентификаторы Изабеллы и Баладжи. Все данные реестра будут удалены.
Теперь, если вы захотите пройти руководство еще раз, придется снова начинать с чистого начального состояния.

## Дополнительная литература

Чтобы понять подробности устройства и работы приложений и смарт-контрактов из данногог
руководства, советуем прочитать главу [Разработка приложений](../developapps/developing_applications.html).
В этой главе содержится более полное объяснение механизма коммерческих ценных бумаг,
построения сети PaperNet, ее действующих лиц, и механизмов работы их приложений и
смарт-контрактов.

Можете также использовать этот пример для создания собственных приложений и смарт-контрактов!

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
