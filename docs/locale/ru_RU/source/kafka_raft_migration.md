# Миграция с Kafka на Raft

**Важно: этот документ подразумевает хорошее владение конфигурационными транзакциями.
Не совершайте миграцию, если вы еще не ознакомились с туториалом [Добавление организации в канал](channel_update_tutorial.html).**

Для проведения миграции версия узлов должна быть 1.4.2 или выше.

До проведения миграции, учтите следущее:

1. Этот процесс работает только при миграции с Kafka на Raft, другие типы консенсуса пока не поддерживаются.

2. Миграция односторонняя. Как только Raft-узлы начнут сохранять транзакции, обратно к Kafka не вернуться.

3. Ордеринг-узлы придется перезапустить.

4. Восстановление после неудачной миграции возможно, только если был сделан бекап (как его сделать, описано ниже).

5. Должны быть обновлены все каналы сети. Миграция только подмножества каналов не возможна.

6. В конце миграции, каждый канал (включая системный) будет иметь одинаковый набор consenter'ов Raft-узлов. Это один из признаков успешной миграции.

7. Миграция использует существующие реестры и узлы. Исключние или добавление ордерер-узлов должно быть проведено после миграции.

## Краткое описание процесса миграции

Миграция проводится в 5 шагов:

1. Система начинает работу в режиме тех. обслуживания, все транзакции приложений отклоняются и только администраторы
   ордеринг-службы могут делать изменения конфигурации.
2. Система останавливается и создается бекап.
3. Система запускается, тип консенсуса и метаданные всех каналов были изменены.
4. Система перезапускается и теперь работает с Raft-консенсусом. Каждый канал проверяется на достижение консенсуса.
5. Система начинает работу в нормальном режиме.

## Подготовка к миграции

До начала миграции, сделайте следующее:

* Составьте план развертывания Raft. Выберите, какие узлы продолжат работу после миграции как Raft consenters.
  Вы должны развернуть зотя бы три узла в кластере, но лучше разверните 5 или больше; так, кластер не потеряет работоспособность при остановке узла.
* Соберите материал для создания конфигурации Raft `Metadata`. **Важно: все каналы должны получить одну и ту же конфигурацию `Metadata`**.
  Обратитесь к [Инструкции по настройке Raft](raft_configuration.html) за подробной информацией. Возможно, вам будет проще сначала запустить сеть с протоколом Raft,
  а потом изменить и скопировать секцию consensus metadata конфигурации сети. В любом случае, для каждого узла вам потребуются:
  - `hostname`
  - `port`
  - `server certificate`
  - `client certificate`
* Составьте список всех каналов сети. Проверьте, что вы имеете право подписывать конфигурационные транзакции.
* Убедитесь, что все ордеринг-узлы имеют одну и ту же версию Fabric, и что она 1.4.2 или выше.
* Убедитесь, что все пиры имеют версию 1.4.2 и выше. Проверьте, что все каналы имеют
  подходящую channel capability:
  - Orderer capability `V1_4_2` (или выше).
  - Channel capability `V1_4_2` (или выше).

### Вхождение в режим тех. обслуживания

До того, как вы ввели сеть в решим тех. обслуживания, рекомендуется выключить всех пиров и клиентов.
В принципе можно и не выключать, так как ордеринг-служба отклонит всех их запросы, но
их логи засорятся сообщениями об ошибках.

Следуйте туториалу [Добавление организации в канал](channel_update_tutorial.html),
чтобы изменить конфигурацию **каждого канала, начиная с системного**.
Единственное поле, которое потребуется изменить на этом шаге, это
`/Channel/Orderer/ConsensusType`.
В JSON-представлении конфигурации канала, это
`.channel_group.groups.Orderer.values.ConsensusType`.

`ConsensusType` состоит из трех значений: `Type`, `Metadata`, and
`State`, where:

  * `Type` - либо `kafka`, либо `etcdraft` (Raft). Это значение может быть изменено только в режиме тех. обслуживания.
  * `Metadata` пустое, если `Type` это kafka, но должно быть заполнено корректными метаданными Raft,
     если `ConsensusType` это `etcdraft`. Про них речь пойдет позже.
  * `State` - либо `STATE_NORMAL`, когда канал обрабатывает транзакции, или
    `STATE_MAINTENANCE` (во время миграции).

Первый шаг - изменить `State` с `STATE_NORMAL` на `STATE_MAINTENANCE`. Пока что не изменяйте `Type` или `Metadata`.
На этом шаге `Type` должен быть `kafka`.

В режиме тех. обслуживания обычные транзакции, конфигурационные обновления, не связанные с миграцией,
`Deliver`-запросы от пиров для получения блоков - все отклоняются (за исключением того, что администраторы
могут создавать `Deliver`-запросы, это необходимо в процессе миграции).
Это сделано для того, чтобы не нужно было создавать бекап (и при необходимости восстанавливать с него) пиров,
так как они начнут получать обновления только после миграции.

**Проверьте**, что каждый ордеринг-узел вошел в режим тех.обслуживания на каждом канале, для
этого извлеките последний конфигурационный блок и проверьте, что `Type`, `State` каждого канала - это `kafka` `STATE_MAINTENANCE`, а
поле `Metadata` пустое.

#### Создание бекапа и остановка серверов

**Сначала** остановите все ордеринг-узлы, Kafka- и Zookeeper-серверы.
Затем, после того, как вы разрешите Kafka-службе сохранить ее логи на диск (это обычно занимает порядка 30 секунд),
Kafka-серверы должны выключится. Если вы сейчас остановите еще и Kafka-брокеров, это может привести
к тому, что ордереры имеют состояние в файловой системе новее, чем Kafka-брокеры, что может не дать потом
запустить сеть.

Создайте бекапы файловой системы этих серверов. Перезагрузите Kafka-службу и потом ордеринг-узлы.

### Переход к Raft

Следущий шаг - еще одно обновление конфигурации каждого канала. В этом обновлении,
поменяйте `Type` на `etcdraft`, но сохраните `State` как `STATE_MAINTENANCE` и заполните поле
`Metadata`. Крайне рекомендуется иметь одинаковую `Metadata` во всех каналах. Если вы хотите
иметь разные consenter sets с разными узлами, вы сможете перенастроить `Metadata` после запуска сети в режиме
`etcdraft`. Одинаковая `Metadata` означает, что если системный канал пришел к консенсусу и может выйти из режима тех.обслуживания,
все остальные каналы смогут тоже.

Проверьте, что каждый ордеринг-узел сохранил новый `ConsensusType`, проверив конфигурацию каждого канала.

Обратите внимание: Для каждого канала, транзакция, изменяющая `ConsensusType` должна быть последней конфигурационной транзакцией
перед тем, как вы перезагрузите узлы на следующем шагу. В противном случае, скорее всего, узлы упадут при перезагрузке.

#### Перезагрузка и проверка лидера

Обратите внимание: выходить из режима тех.обслуживания **необходимо после перезагрузки**.

Остановите все ордеринг-узлы, Kafka-брокеры и Zookeepers, а потом запустите только ордеринг-узлы.
Они должны запустится как Raft-узлы, сформировать кластер на каждый канал и выбрать лидера в каждом канале.

**Внимание**: Так как Raft использует TLS, необходмима **дополнительняа настройка** перед тем, как возможно будет запустить узлы -
[подробная информация](./raft_configuration.md#локальная-конфигурация).

После этого, **проверьте** в логах, что на каждом канале был выбран лидер. Это подтвердит, что процесс был завершен успешно.

Когда лидер выбран, логи покажут:

```
"Raft leader changed: 0 -> node-number channel=channel-name
node=node-number "
```

Пример:

```
2019-05-26 10:07:44.075 UTC [orderer.consensus.etcdraft] serveRequest ->
INFO 047 Raft leader changed: 0 -> 1 channel=testchannel1 node=2
```

В этом примере `node 2` сообщает, что был выбран лидер (лидер -
`node 1`) кластером канал `testchannel1`.

### Выход из режима тех.обслуживания

Выполните еще одно обновление конфигурации на каждом канале (посылайте обновления
тому же узлу, которому посылали раньше), изменяющее `State` с `STATE_MAINTENANCE` на `STATE_NORMAL`.
Как обычно, начните с системного канала. Если обновление прошло успешно на нем, на всех остальных
должно тоже. Проверьте на каждом узле, что в последнем конфигурационном блоке
`State` теперь `STATE_NORMAL`.

Теперь ордеринг-служба готова принимать транзакции на всех каналах. Если вы остановили пиры
и приложения (как рекомендовалось), вы можете сейчас запустить их.

## Откат

Если во время миграции **до выхода из режима тех.обслуживания** возникает проблема,
просто выполните процедуру отката:

1. Остановите ордеринг-узлы и Kafka-службу (ансамбль серверов и Zookeeper).
2. Откатите файловую систему этих серверов с помощью бекапа, сделанного в режиме тех.обслуживания до обновления `ConsensusType`.
3. Перезапустите эти серверы, ордеринг-службы запустятся с Kafka в режиме тех.обслуживания.
4. Обновите конфигурацию, чтобы выйти из режима тех.обслуживания и продолжить использовать Kafka в качестве механизма консенсуса, или
   продолжите выполнять инструкцию и решите проблемы.

Тревожные звоночки:

1. Некоторые узлы падают или самопроизвольно останавливаются.
2. В логах канала нет записи о выборе лидера.
3. Не получается вернуться к `STATE_NORMAL`.

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/) -->
