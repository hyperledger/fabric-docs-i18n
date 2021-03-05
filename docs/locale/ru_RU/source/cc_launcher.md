# External builders and launchers

До релиза Hyperledger Fabric 2.0, процесс сборки и запуска чейнкода был частью реализации пира и не мог быть изменен простым способом.
Весь чейнкод, установленный на пире собирался через определенную логику (свою для каждого языка), встроенную в код пира.
Этот процесс сборки генерировал Docker container image, который запускался для исполнения чейнкода, который подсоединялся к пиру как как клиент.

Такой подход ограничивал языки, на которых мог быть написан чейнкод, требовал Docker как часть окружения, необходимого для развертывания,
и не предусматривал исполнение чейнкода как продолжительного серверного процесса.

В Fabric 2.0 был представлен механизм External builders and launchers, предназначенный для решения этих проблем. Он позволяет дополнить пир
программами, которые могут собирать и запускать чейнкод. Чтобы использовать его, необходимо создать свой buildpack и затем настроить новый элемент
конфигурации --- `externalBuilder` (внешний сборщик) в файле ``core.yaml``.

Заметьте, что если пакет с чейнкодом не обрабатывается никаким external builder, то пир попробует работать с пакетом так,
как будто бы он создан стандартными средствами управления пакетами Fabric, такими как CLI пира или Node.js SDK.

**Важно:** Это продвинутая опция Fabric, которая, скорее всего, потребует особой сборки peer image.
Например, последующие примеры используют `go` и `bash`, не включенные в официальный `fabric-peer` image.

## Модель External builder

Hyperledger Fabric External Builders and Launchers частично основаны на Heroku [Buildpacks](https://devcenter.heroku.com/articles/buildpack-api).
Реализация buildpack --- это просто набор программ, которая превращает артефакты (результаты сборки) приложения
в что-то, что можно исполнять. Модель buildpack была адаптирована для чейнкод-пакетов и была расширена для поддержки исполнения и discovery чейнкода.

### External builder and launcher API

Механизм external builder and launcher состоит из 4 программ:

- `bin/detect`: Определяет, должен ли этот buildpack использоваться для сборки и исполнения чейнкод-пакета.
- `bin/build`: Собрать пакет в исполняемый чейнкод.
- `bin/release` (опционально): Передать метаданные о чейнкоде пиру.
- `bin/run` (опционально): Исполнить чейнкод.

#### `bin/detect`

Пир вызывает `detect` с двумя аргументами:

```sh
bin/detect CHAINCODE_SOURCE_DIR CHAINCODE_METADATA_DIR
```

Директория `CHAINCODE_SOURCE_DIR` содержит исходники чейнкода, а директория `CHAINCODE_METADATA_DIR` содержит
файл `metadata.json` установленного на пир чейнкод-пакета. Содержимое директорий `CHAINCODE_SOURCE_DIR` и `CHAINCODE_METADATA_DIR` программа `detect` изменять не должна.
Если данный buildpack должен использоваться для чейнкод-пакета, `detect` должен вернуть код завершения `0`; любой другой код завершения будет истолкован как то, что buildpack не должен быть применен.

Пример простой реализации `detect` для чейнкода на Go:
```sh
#!/bin/bash

CHAINCODE_METADATA_DIR="$2"

# использовать jq для извлечения типа чейнкода из metadata.json и завершиться
# 0, если тип чейнкода - golang
if [ "$(jq -r .type "$CHAINCODE_METADATA_DIR/metadata.json" | tr '[:upper:]' '[:lower:]')" = "golang" ]; then
    exit 0
fi

exit 1
```

#### `bin/build`

Программа `bin/build` отвечает за сборку, компилирование или иную трансформацию исходных файлов в артефакты, которые могут быть использованы `release` и `run`. Пир вызывает `build` с тремя аргументами:

```sh
bin/build CHAINCODE_SOURCE_DIR CHAINCODE_METADATA_DIR BUILD_OUTPUT_DIR
```

Директория `CHAINCODE_SOURCE_DIR` содержит исходники чейнкода, директория `CHAINCODE_METADATA_DIR` содержит файл `metadata.json` установленного на пир чейнкод-пакета.
Директория `BUILD_OUTPUT_DIR` --- то, куда `build` должна поместить артефакты, необходимые `release` и `run`.
Содержимое директорий `CHAINCODE_SOURCE_DIR` и `CHAINCODE_METADATA_DIR` программа `detect` изменять не должна.

Когда `build` завершается кодом `0`, содержимое `BUILD_OUTPUT_DIR` будет скопировано в постоянное хранилище пира;
любой другой код завершения будет истолкован как сбой в сборке.

Пример простой реализации `build` для чейнкода на Go:

```sh
#!/bin/bash

CHAINCODE_SOURCE_DIR="$1"
CHAINCODE_METADATA_DIR="$2"
BUILD_OUTPUT_DIR="$3"

# Извлечь путь к пакету из from metadata.json
GO_PACKAGE_PATH="$(jq -r .path "$CHAINCODE_METADATA_DIR/metadata.json")"
if [ -f "$CHAINCODE_SOURCE_DIR/src/go.mod" ]; then
    cd "$CHAINCODE_SOURCE_DIR/src"
    go build -v -mod=readonly -o "$BUILD_OUTPUT_DIR/chaincode" "$GO_PACKAGE_PATH"
else
    GO111MODULE=off go build -v  -o "$BUILD_OUTPUT_DIR/chaincode" "$GO_PACKAGE_PATH"
fi

# сохранить statedb index metadata для release
if [ -d "$CHAINCODE_SOURCE_DIR/META-INF" ]; then
    cp -a "$CHAINCODE_SOURCE_DIR/META-INF" "$BUILD_OUTPUT_DIR/"
fi
```

#### `bin/release`

Программа `bin/release` передает метаданные чейнкода пиру. `bin/release` опциональна. Если она отсутствует, то этот шаг пропускается. Пир вызывает `release` с двумя аргументами:

```sh
bin/release BUILD_OUTPUT_DIR RELEASE_OUTPUT_DIR
```

Директория `BUILD_OUTPUT_DIR` содержит артефакты, созданные `build` и не должна быть изменена `release`.
Директория `RELEASE_OUTPUT_DIR` --- то, куда `release` должен поместить информацию для пира.

По завершению `release`, пир использует два типа метаданных из `RELEASE_OUTPUT_DIR`:

- определения индексов state database от CouchDB
- информация о соединении с чейнкод-сервером (`chaincode/server/connection.json`)

Если чейнкоду необходимы определения индексов CouchDB, `release` отвечает за то, чтобы поместить эти индексы в директорию `statedb/couchdb/indexes` (относительно `RELEASE_OUTPUT_DIR`).
Индексы должны иметь расширение `.json`.  За большей информацией обратитесь к статье [CouchDB indexes](couchdb_as_state_database.html#couchdb-indexes).

В случаях, когда используется чейнкод-сервер, `release` отвечает за то, чтобы добавить в `chaincode/server/connection.json` адрес
чейнкод-сервера и связанных с TLS артефактов, необходимых для соединения с чейнкодом.
Когда пиру предоставлена информация о соединении с чейнкод-сервером, `run` не будет вызван.
За большей информацией обратитесь к документации [Chaincode Server](https://jira.hyperledger.org/browse/FAB-14086).

Пример простой реализации `release` для чейнкода на Go:

```sh
#!/bin/bash

BUILD_OUTPUT_DIR="$1"
RELEASE_OUTPUT_DIR="$2"

# копировать индексы из META-INF/* в выходную директорию
if [ -d "$BUILD_OUTPUT_DIR/META-INF" ] ; then
   cp -a "$BUILD_OUTPUT_DIR/META-INF/"* "$RELEASE_OUTPUT_DIR/"
fi
```

#### `bin/run`

Программа `bin/run` отвечает за запуск чейнкода. Пир вызывает `run` с двумя аргументами:

```sh
bin/run BUILD_OUTPUT_DIR RUN_METADATA_DIR
```

Директория `BUILD_OUTPUT_DIR` содержит артефакты, созданные `build` .
Директория `RUN_METADATA_DIR` содержит файл `chaincode.json` с информацией, нужной чейнкоду для соединения и регистрации с пиром.
Директории `BUILD_OUTPUT_DIR` и `RUN_METADATA_DIR` и не должны быть изменены `run`.
Поля `chaincode.json`:

- `chaincode_id`: Уникальный ID чейнкод-пакета.
- `peer_address`: Адрес в формате `host:port`. Адрес указывает на `ChaincodeSupport` endpoint gRPC-сервера, размещающегося на пире.
- `client_cert`: TLS-сертификат клиента в формате PEM, сгенерированный пиром, который чейнкод должен использовать для установки соединения с пиром.
- `client_key`: TLS-ключ клиента в формате PEM, сгенерированный пиром, который чейнкод должен использовать для установки соединения с пиром.
- `root_cert`: Корневой TLS-сертификат в формате PEM для `ChaincodeSupport` endpoint gRPC-сервера, размещающегося на пире.
- `mspid`: Локальный mspid пира.

Когда `run` останавливается, пир считает чейнкод остановленным. Если приходит еще один запрос для чейнкода, пир попытается запустить еще один экземпляр чейнкода через `run`.
Содержимое `chaincode.json` не должно кешироваться между вызовами.

Пример простой реализации `run` для чейнкода на Go:
```sh
#!/bin/bash

BUILD_OUTPUT_DIR="$1"
RUN_METADATA_DIR="$2"

# установить переменные окружения для go chaincode shim
export CORE_CHAINCODE_ID_NAME="$(jq -r .chaincode_id "$RUN_METADATA_DIR/chaincode.json")"
export CORE_PEER_TLS_ENABLED="true"
export CORE_TLS_CLIENT_CERT_FILE="$RUN_METADATA_DIR/client.crt"
export CORE_TLS_CLIENT_KEY_FILE="$RUN_METADATA_DIR/client.key"
export CORE_PEER_TLS_ROOTCERT_FILE="$RUN_METADATA_DIR/root.crt"
export CORE_PEER_LOCALMSPID="$(jq -r .mspid "$RUN_METADATA_DIR/chaincode.json")"

# установить ключ и сертификаты для go chaincode shim
jq -r .client_cert "$RUN_METADATA_DIR/chaincode.json" > "$CORE_TLS_CLIENT_CERT_FILE"
jq -r .client_key  "$RUN_METADATA_DIR/chaincode.json" > "$CORE_TLS_CLIENT_KEY_FILE"
jq -r .root_cert   "$RUN_METADATA_DIR/chaincode.json" > "$CORE_PEER_TLS_ROOTCERT_FILE"
if [ -z "$(jq -r .client_cert "$RUN_METADATA_DIR/chaincode.json")" ]; then
    export CORE_PEER_TLS_ENABLED="false"
fi

# выполнить чейнкод
exec "$BUILD_OUTPUT_DIR/chaincode" -peer.address="$(jq -r .peer_address "$ARTIFACTS/chaincode.json")"
```

## Настройка external builders and launchers

Настройка пира на использование механизма external builders включает в себя добавление элемента `externalBuilder` в секцию конфигурации чейнкода
в файл `core.yaml`. Этот элемент определяет external builders. Каждое определение external builder должно включать имя (для логирования)
и путь к родительскому директории директории `bin`.

Также можно указать список переменных окружения, которые должны быть переданы от пира программам external builder.

Следующий пример определяет два external builders:

```yaml
chaincode:
  externalBuilders:
  - name: my-golang-builder
    path: /builders/golang
    propagateEnvironment:
    - GOPROXY
    - GONOPROXY
    - GOSUMDB
    - GONOSUMDB
  - name: noop-builder
    path: /builders/binary
```

В этом примере, реализация "my-golang-builder" содержится в директории `/builders/golang`, а программы сборки и исполнения чейнкода - в `/builders/golang/bin`.
Когда пир вызывает программу из `bin` "my-golang-builder", он передаст ей только указанные в `propagateEnvironment` переменные окружения.

Следующие переменные окружения всегда передаются external builders:

- LD_LIBRARY_PATH
- LIBPATH
- PATH
- TMPDIR

Когда указана конфигурация `externalBuilder`, пир начнет проход по их списку, пока `bin/detect` одного builder'а не вернет `0`.
Если ни один `detect` не завершается успешно, то пир использует устаревший процесс сборки с Docker, реализованный в пире.
Это означает, что использование external builders опционально.

В примере выше, пир попробует использовать "my-golang-builder", потом "noop-builder", а потом встроенный процесс сборки.

## Чейнкод-пакеты

Как часть нового жизненного цикла, представленного в релизе Fabric 2.0, формат пакетов изменился с сериализованных protocol buffer messages на
сжатый с помощью gzip POSIX tape archive. Чейнкод-пакеты, созданные с `peer lifecycle chaincode package`, используют этот формат.

### Содержимое пакетов lifecycle chaincode package

Пакеты вида lifecycle chaincode package содержат два файла. Первый файл, `code.tar.gz`, это gzip-сжатый POSIX tape archive.
Этот файл содержит исходные файлы чейнкода. Пакеты, созданные CLI пира поместят в директорию `src` код, а в `META-INF` - метаданные чейнкода (например, индексы CouchDB).

Второй файл, `metadata.json`, содержит три поля:
- `type`: тип чейнкода (например GOLANG, JAVA, NODE)
- `path`: Для чейнкода на Go, это путь к чейнкод-пакету относительно GOPATH или GOMOD; undefined для других типов
- `label`: Используется для генерации package-id, с помощью которого пакет идентифицируется в новом жизненном цикле чейнкода.

Заметьте, что поля `type` и `path` используются только сборкой с Docker.

### Чейнкод-пакеты и external builders

Когда чейнкод-пакет устанавливается на пир, содержимое `code.tar.gz` и `metadata.json` не обрабатывается до вызова external builders,
за исключением поля `label` для вычисления id пакета. Это обеспечивает большую гибкость в том, как именно исходники и метаданные пакета
будут обработаны external builders and launchers.

Например, пользовательский чейнкод-пакет может содержать заранее скомпилированный чейнкод в `code.tar.gz` с `metadata.json`,
позволяющей _бинарному buildpack_ определить пакет, сверить хеш бинарных файлоов и исполнить программу как чейнкод.

Другой пример - чейнкод-пакет, содержащий только определения индексов state database и данные, необходимые для external launcher,
чтобы подсоединиться к работающему чейнкод-серверу. В этом случае, `build` только извлечет метаданные, а `release` передаст их пиру.

Единственное требование заключается в том, что `code.tar.gz` должен содержать только обычные файлы и директории и не может содержать пути к файлам,
распаковка которых приведет к записи файлов не корневой директории чейнкода.

<!---
Licensed under Creative Commons Attribution 4.0 International License https://creativecommons.org/licenses/by/4.0/
-->
