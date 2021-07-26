# Команда configtxlator

Команда `configtxlator` позволяет пользователям конвертировать структуры данных Fabric из формата protobuf в JSON и обратно,
а также создавать обновления конфигурации. Команда может либо запускаться как REST-сервер для предоставления своих функций
через HTTP, либо может использоваться непосредственно как инструмента командной строки.

## Синтаксис

Команда `configtxlator` включает следующие пять подкоманд:

  * start
  * proto_encode
  * proto_decode
  * compute_update
  * version

## Команда configtxlator start

```
usage: configtxlator start [<flags>]

Start the configtxlator REST server

Flags:
  --help                Show context-sensitive help (also try --help-long and
                        --help-man).
  --hostname="0.0.0.0"  The hostname or IP on which the REST server will listen
  --port=7059           The port on which the REST server will listen
  --CORS=CORS ...       Allowable CORS domains, e.g. '*' or 'www.example.com'
                        (may be repeated).
```


## Команда configtxlator proto_encode
```
usage: configtxlator proto_encode --type=TYPE [<flags>]

Converts a JSON document to protobuf.

Flags:
  --help                Show context-sensitive help (also try --help-long and
                        --help-man).
  --type=TYPE           The type of protobuf structure to encode to. For
                        example, 'common.Config'.
  --input=/dev/stdin    A file containing the JSON document.
  --output=/dev/stdout  A file to write the output to.
```


## Команда configtxlator proto_decode
```
usage: configtxlator proto_decode --type=TYPE [<flags>]

Converts a proto message to JSON.

Flags:
  --help                Show context-sensitive help (also try --help-long and
                        --help-man).
  --type=TYPE           The type of protobuf structure to decode from. For
                        example, 'common.Config'.
  --input=/dev/stdin    A file containing the proto message.
  --output=/dev/stdout  A file to write the JSON document to.
```


## Команда configtxlator compute_update
```
usage: configtxlator compute_update --channel_id=CHANNEL_ID [<flags>]

Takes two marshaled common.Config messages and computes the config update which
transitions between the two.

Flags:
  --help                   Show context-sensitive help (also try --help-long and
                           --help-man).
  --original=ORIGINAL      The original config message.
  --updated=UPDATED        The updated config message.
  --channel_id=CHANNEL_ID  The name of the channel for this update.
  --output=/dev/stdout     A file to write the JSON document to.
```


## Команда configtxlator version
```
usage: configtxlator version

Show version information

Flags:
  --help  Show context-sensitive help (also try --help-long and --help-man).
```

## Примеры использования

### Декодирование

Декодирование блока, хранящегося в файле `fabric_block.pb`, в формат JSON и его вывод в stdout.

```
configtxlator proto_decode --input fabric_block.pb --type common.Block
```

Также, после запуска REST-сервера, можно воспользоваться следующей командой curl для выполнения этой же операции через REST API.

```
curl -X POST --data-binary @fabric_block.pb "${CONFIGTXLATOR_URL}/protolator/decode/common.Block"
```

### Кодирование

Преобразование политики, полученной в формате JSON из stdin, в файл с названием `policy.pb`.

```
configtxlator proto_encode --type common.Policy --output policy.pb
```

Также, после запуска REST-сервера, можно воспользоваться следующей командой curl для выполнения этой же операции через REST API.

```
curl -X POST --data-binary /dev/stdin "${CONFIGTXLATOR_URL}/protolator/encode/common.Policy" > policy.pb
```

### Использование в процессе разработки

Вычисление разницы между файлами с конфигурацией канала `original_config.pb` и `modified_config.pb`, декодирование ее в формат JSON и вывод в stdout.

```
configtxlator compute_update --channel_id testchan --original original_config.pb --updated modified_config.pb | configtxlator proto_decode --type common.ConfigUpdate
```

Также, после запуска REST-сервера, можно воспользоваться следующей командой curl для выполнения этой же операции через REST API.

```
curl -X POST -F channel=testchan -F "original=@original_config.pb" -F "updated=@modified_config.pb" "${CONFIGTXLATOR_URL}/configtxlator/compute/update-from-configs" | curl -X POST --data-binary /dev/stdin "${CONFIGTXLATOR_URL}/protolator/decode/common.ConfigUpdate"
```

## Дополнительная информация

Название инструмента строится из двух слов — *configtx* и *translator*, и это означает, что инструмент предназначен 
для преобразования данных в различные представления. Инструмент не генерирует конфигурацию. Он не отправляет и не получает
конфигурацию. Также он не изменяет саму конфигурацию, а просто предоставляет некоторые взаимно-однозначные операции 
для различных представлений формата configtx.

REST-сервер не предусматривает ни конфигурационного файла `configtxlator`, ни каких-либо средств аутентификации и 
авторизации. Инструмент `configtxlator` не имеет доступа к данным, криптографическим ключам или другой конфиденциальной
информации, поэтому не создает риска незащищенности данных для владельца сервера перед другими клиентами. Однако,
поскольку данные, отправляемые пользователем на сервер REST, могут быть конфиденциальными, пользователь должен доверять 
администратору сервера, либо использовать сервер локально или работать через интерфейс командной строки.
