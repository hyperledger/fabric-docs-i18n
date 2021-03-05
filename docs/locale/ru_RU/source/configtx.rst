Конфигурация канала (configtx)
==============================

Общая конфигурация блокчейн-сети HL Fabric хранится в коллекции конфигурационных
транзакций, одна на канал. Часто конфигурационную транзакцию называют *configtx*.

Необходимо отметить, что конфигурация канала:

1. **Версированная**: Все элементы конфигурации соответствуют версии, которая
   увеличивается с каждой модификацией. Также каждая сохраненная конфигурация
   получает порядковый номер.
2. **Permissioned** (то есть обладающая разным уровнем разрешений): Каждый элемент конфигурации обладает политикой,
   которая регламентирует, можно ли применить данную модификацию к элементу.
   Обладая копией предыдущей configtx, можно проверить валидность нового конфига,
   руководствуясь этими политиками.
3. **Иерархичная**: Корневая группа конфигурация содержит подгруппы, и каждая группа иерархии
   имеет соответствующие значения и политики. Политики могут использовать иерархию: чтобы
   вывести политики определенного уровня вложенности можно использовать политики уровнем ниже.

Структура конфигурации
----------------------

Конфигурация хранится как транзакция типа ``HeaderType_CONFIG`` в блоке без
других транзакций. Эти блоки называются *Конфигурационные блоки* (Configuration blocks),
а первый из них называется *Genesis-блок*.

Proto-структуры конфигурации хранятся в ``fabric-protos/common/configtx.proto``. Envelope (конверт) типа
``HeaderType_CONFIG`` кодирует message ``ConfigEnvelope`` как поле
``Payload`` ``data``. Код proto ``ConfigEnvelope`` определен так:

::

    message ConfigEnvelope {
        Config config = 1;
        Envelope last_update = 2;
    }

Поле ``last_update`` определено ниже, однако оно необходимо только для
проверки конфигурации. Конфигурация хранится в поле ``config``, которое содержит значение типа
message ``Config``.

::

    message Config {
        uint64 sequence = 1;
        ConfigGroup channel_group = 2;
    }

Число ``sequence`` (порядковый номер) увеличивается на 1 с каждой сохраненной конфигурацией.
Поле ``channel_group`` - корневая группа конфигурации
Структура данных ``ConfigGroup`` определена рекурсивно, она создает дерево групп, каждая из
которых содержит значения и политики.

::

    message ConfigGroup {
        uint64 version = 1;
        map<string,ConfigGroup> groups = 2;
        map<string,ConfigValue> values = 3;
        map<string,ConfigPolicy> policies = 4;
        string mod_policy = 5;
    }

Так ``ConfigGroup`` рекурсивна, она обладает иерархией.
Следующий пример для простоты приведен в синтаксисе Go:

::

    // Пусть определены следующие группы:
    var root, child1, child2, grandChild1, grandChild2, grandChild3 *ConfigGroup

    // Устанавливаем соответствующие значения
    root.Groups["child1"] = child1
    root.Groups["child2"] = child2
    child1.Groups["grandChild1"] = grandChild1
    child2.Groups["grandChild2"] = grandChild2
    child2.Groups["grandChild3"] = grandChild3

    // Тогда структура групп в конфигурации выглядит так:
    // root:
    //     child1:
    //         grandChild1
    //     child2:
    //         grandChild2
    //         grandChild3

Каждая группа определяет уровень иерархии конфига, а также обладает
множеством значений (values), соответствующих строковым ключам, и политик (policies), также соответствующих строковым ключам.
Другими словами, ``values`` и ``policies`` - ассоциативные массивы.

Значения имеют тип ``ConfigValue``:

::

    message ConfigValue {
        uint64 version = 1;
        bytes value = 2;
        string mod_policy = 3;
    }

Политики имеют тип ``ConfigPolicy``:

::

    message ConfigPolicy {
        uint64 version = 1;
        Policy policy = 2;
        string mod_policy = 3;
    }

Заметьте, что значения, политики и группы имеют поле ``version`` и поле
``mod_policy``. ``version`` увеличивается при каждой модификации элемента.
``mod_policy`` регламентирует, какие подписи нужно иметь для изменения элемента.

* Для групп, модификация - это добавление или удаление элементов в ассоциативном массиве
  ``values``, ``policies`` или ``groups``, или изменение ``mod_policy``.
* Для значений и политик, модификация - это изменение поля ``value`` или
  поля ``policy`` соответственно, или изменение ``mod_policy``.

``mod_policy`` интерпретируется в контексте соответствующего уровня конфига.
Рассмотрим пример политик, определенных в ``Channel.Groups["Application"]``
(здесь мы используем синтаксис Go для ассоциативных массивов, так что
``Channel.Groups["Application"].Policies["policy1"]`` указывает на политику
``policy1`` ассоциативного массива ``Policies`` группы ``Application`` корневой
группы ``Channel``).

* ``policy1`` указывает на ``Channel.Groups["Application"].Policies["policy1"]``
* ``Org1/policy2`` указывает на
  ``Channel.Groups["Application"].Groups["Org1"].Policies["policy2"]``
* ``/Channel/policy3`` указывает на ``Channel.Policies["policy3"]``

Заметьте, что если ``mod_policy`` указывает на несуществующую политику, она не может быть
изменена.

Обновления конфигурации
-----------------------

Обновления конфигурации представлены в качестве message ``Envelope`` типа
``HeaderType_CONFIG_UPDATE``. ``Payload`` ``data`` транзакции сериализована в
``ConfigUpdateEnvelope``. ``ConfigUpdateEnvelope`` определен так:

::

    message ConfigUpdateEnvelope {
        bytes config_update = 1;
        repeated ConfigSignature signatures = 2;
    }

Поле ``signatures`` содержит множество подписей, авторизующих обновление конфига.
Определение соответствующего message:

::

    message ConfigSignature {
        bytes signature_header = 1;
        bytes signature = 2;
    }

Поле ``signature_header`` определено так же, как и у стандартных транзакций, а
``signature`` - это подпись над конкатенацией байт ``signature_header`` и байт
``config_update`` из message ``ConfigUpdateEnvelope``

Байты ``config_update`` ``ConfigUpdateEnvelope`` - это сериализованное
message ``ConfigUpdate``, которое определено так:

::

    message ConfigUpdate {
        string channel_id = 1;
        ConfigGroup read_set = 2;
        ConfigGroup write_set = 3;
    }

Поле ``channel_id`` - идентификатор канала, конфигурация которого обновляется. Оно не допускает возможности
копирования подписей из обновления конфигурации другого канала.

Поле ``read_set`` - подмножество существующей конфигурации, в котором указаны только поля ``version``.
Нельзя указать значение ``value`` объекта ``ConfigValue`` или значение ``policy`` объекта ``ConfigPolicy`` в ``read_set``.
В ``ConfigGroup`` можно заполнить подмножество ассоциативных словарей, чтобы указать на элемент, находящийся глубже в конфигурационном дереве.
К примеру, чтобы включить группу ``Application`` в ``read_set`` необходимо включить в ``read_set`` ее родителя (группу ``Channel``), но в
группе ``Channel`` необязательно заполнять все поля, такие как, например, группа по ключу ``Orderer`` или любой ключ ``values`` или ``policies``.

Поле ``write_set`` указывает на обновленные части конфигурации.
Из-за иерархической структуры конфигурации, изменение элемента в глубине иерархии ведет к включению в ``write_set`` всех его вышестоящих предков.

Как пример, рассмотрим такую конфигурацию:

::

    Channel: (version 0)
        Orderer (version 0)
        Application (version 3)
           Org1 (version 2)

Для того, чтобы составить конфигурацию, обновляющую ``Org1``,
``read_set`` должен быть таким:

::

    Channel: (version 0)
        Application: (version 3)

А ``write_set`` таким:

::

    Channel: (version 0)
        Application: (version 3)
            Org1 (version 3)

При получении ``CONFIG_UPDATE``, orderer вычисляет новый
``CONFIG``, следуя такому алгоритму:

1. Проверяет ``channel_id`` и ``read_set``. Все элементы с соответствующими версиями
   из ``read_set`` должны существовать.
2. Вычисляет множество обновления (update set), собирая все элементы из
   ``write_set``, не присутствующие с такой же версией в
   ``read_set``.
3. Проверяет, что каждый элемент в этом множестве увеличивает порядковый номер (version number) на 1.
4. Проверяет, что подписи, указанные в
   ``ConfigUpdateEnvelope`` удовлетворяют ``mod_policy`` каждого
   элемента множества обновления.
5. Вычисляет новую версию конфига, применяя множество обновления к текущему конфигу.
6. Записывает новый конфиг в ``ConfigEnvelope``, содержащий
   ``CONFIG_UPDATE`` в качестве поля ``last_update`` и новый конфиг, закодированный в поле
   ``config``, вместе с увеличенным на 1 числом ``sequence`` (порядковым номером).
7. Записывает новый ``ConfigEnvelope`` в ``Envelope`` типа
   ``CONFIG`` и записывает это как единственную транзакцию в
   новом конфигурационном блоке.

Когда пир (или другой получатель для ``Deliver``) получает
конфигурационный блок, он должен проверить, что конфиг был правильно подтвержден,
применив ``last_update`` к текущему конфигу и проверив, что в поле ``config``, вычисленном orderer'ом,
содержится верная новая конфигурация.

Permitted-группы и permitted-значения
-------------------------------------

Любая корректная конфигурация - подмножество описанной ниже конфигурации.
Обозначение ``peer.<MSG>`` определяет ``ConfigValue``, чье поле
``value`` - это сериализованное proto message с именем ``<MSG>``, определенное
в ``fabric-protos/peer/configuration.proto``. Обозначения
``common.<MSG>``, ``msp.<MSG>`` и ``orderer.<MSG>`` определены аналогично,
но их message находятся в
``fabric-protos/common/configuration.proto``,
``fabric-protos/msp/mspconfig.proto`` и
``fabric-protos/orderer/configuration.proto`` соответственно.

Ключи ``{{org_name}}`` и ``{{consortium_name}}`` соответствуют
произвольным именам, и обозначают элемент, который можно повторить несколько раз
с разными именами.

::

    &ConfigGroup{
        Groups: map<string, *ConfigGroup> {
            "Application":&ConfigGroup{
                Groups:map<String, *ConfigGroup> {
                    {{org_name}}:&ConfigGroup{
                        Values:map<string, *ConfigValue>{
                            "MSP":msp.MSPConfig,
                            "AnchorPeers":peer.AnchorPeers,
                        },
                    },
                },
            },
            "Orderer":&ConfigGroup{
                Groups:map<String, *ConfigGroup> {
                    {{org_name}}:&ConfigGroup{
                        Values:map<string, *ConfigValue>{
                            "MSP":msp.MSPConfig,
                        },
                    },
                },

                Values:map<string, *ConfigValue> {
                    "ConsensusType":orderer.ConsensusType,
                    "BatchSize":orderer.BatchSize,
                    "BatchTimeout":orderer.BatchTimeout,
                    "KafkaBrokers":orderer.KafkaBrokers,
                },
            },
            "Consortiums":&ConfigGroup{
                Groups:map<String, *ConfigGroup> {
                    {{consortium_name}}:&ConfigGroup{
                        Groups:map<string, *ConfigGroup> {
                            {{org_name}}:&ConfigGroup{
                                Values:map<string, *ConfigValue>{
                                    "MSP":msp.MSPConfig,
                                },
                            },
                        },
                        Values:map<string, *ConfigValue> {
                            "ChannelCreationPolicy":common.Policy,
                        }
                    },
                },
            },
        },

        Values: map<string, *ConfigValue> {
            "HashingAlgorithm":common.HashingAlgorithm,
            "BlockHashingDataStructure":common.BlockDataHashingStructure,
            "Consortium":common.Consortium,
            "OrdererAddresses":common.OrdererAddresses,
        },
    }

Настройка системного канала в части Ordering
---------------------------------------------

Системный канал должен определить параметры ordering'а и консорциумы для
создания каналов. Может существовать ровно один системный канал для
ordering-служб, и этот канал создается первым (более аккуратно, по-английски: first channel to be bootstrapped).
Рекомендуется никогда не определять секцию Application внутри genesis-конфигурации системного канала, но
это можно сделать при тестировании. Заметьте, что любой участник с доступом к чтению системного канала
может увидеть создание всех каналов, так что доступ к системному каналу должен быть ограничен.

Параметры ordering'а определены как следующее подмножество конфига:

::

    &ConfigGroup{
        Groups: map<string, *ConfigGroup> {
            "Orderer":&ConfigGroup{
                Groups:map<String, *ConfigGroup> {
                    {{org_name}}:&ConfigGroup{
                        Values:map<string, *ConfigValue>{
                            "MSP":msp.MSPConfig,
                        },
                    },
                },

                Values:map<string, *ConfigValue> {
                    "ConsensusType":orderer.ConsensusType,
                    "BatchSize":orderer.BatchSize,
                    "BatchTimeout":orderer.BatchTimeout,
                    "KafkaBrokers":orderer.KafkaBrokers,
                },
            },
        },

Каждая организация, участвующая в ordering'e имеет подгруппу группы ``Orderer``.
Эта подгруппа определяет единственный параметр, ``MSP``, содержащий криптографическую информацию об
identity организации.  ``Values`` группы ``Orderer`` определяют функционирование ordering-узла.
Группа ``Orderer`` своя для каждого канала, так что, к примеру,
``orderer.BatchTimeout`` может различаться в зависимости от канала.

При запуске, orderer имеет файловую систему с информацией про множество различных каналов.
Orderer определяет системный канал как тот, который определяет группу консорциумов, имеющую следующую структуру:

::

    &ConfigGroup{
        Groups: map<string, *ConfigGroup> {
            "Consortiums":&ConfigGroup{
                Groups:map<String, *ConfigGroup> {
                    {{consortium_name}}:&ConfigGroup{
                        Groups:map<string, *ConfigGroup> {
                            {{org_name}}:&ConfigGroup{
                                Values:map<string, *ConfigValue>{
                                    "MSP":msp.MSPConfig,
                                },
                            },
                        },
                        Values:map<string, *ConfigValue> {
                            "ChannelCreationPolicy":common.Policy,
                        }
                    },
                },
            },
        },
    },

Заметьте, что каждый консорциум определяет набор участников, как и участников организаций для ordering-организаций.
Каждый консорциум также определяет ``ChannelCreationPolicy``. Эта политика авторизует запросы по созданию каналов.
Обычно этой политикой будет ``ImplicitMetaPolicy``, требующая подписи новых членов канала для авторизации создания канала.
Больше подробностей про создание канала последует далее в этом документе.

Настройка канала в части Application
------------------------------------

Конфигурация Application предназначена для каналов, созданных для прикладных транзакций.
Она определяется так:

::

    &ConfigGroup{
        Groups: map<string, *ConfigGroup> {
            "Application":&ConfigGroup{
                Groups:map<String, *ConfigGroup> {
                    {{org_name}}:&ConfigGroup{
                        Values:map<string, *ConfigValue>{
                            "MSP":msp.MSPConfig,
                            "AnchorPeers":peer.AnchorPeers,
                        },
                    },
                },
            },
        },
    }

Как и с секцией ``Orderer``, каждая организация кодирована как группа.
Однако вместо кодирования только информации про identity (``MSP``), каждая организация
также задает список ``AnchorPeers``. Этот список позволяет пирам из разных организаций
общаться по gossip-протоколу.

Такой канал включает копию ordering-организаций и опций консенсуса, чтобы обеспечить
детерминированное обновление этих параметров, так что в него включена секция ``Orderer``
из конфигурации системного канала. С точки зрения приложений это может быть проигнорировано.

Создание канала
---------------

Когда orderer получает ``CONFIG_UPDATE`` для несуществующего канала, orderer интерпретирует это как запрос по созданию канала и следует следующему алгоритму:

1. Orderer определяет консорциум, для которого создается канал, ориентируясь на значение ``Consortium`` корневой группы.
2. Orderer проверяет, что организации, включенные в группу ``Application`` состовляют подмножество консорциума и ``version`` группы ``ApplicationGroup`` равна ``1``.
3. Orderer проверяет, что, если консорциум имеет участников, то новый канал также имеет application-участников (прикладных участников, ?) (создание консорциумов и каналов без участников имеет смысл только при тестировании).
4. Orderer создает шаблон конфигурации: берет группу ``Orderer`` из системного канала и создает группу ``Application`` с указанными участниками, а также присваивает
   ``mod_policy`` ``ChannelCreationPolicy``, как было указано в конфигурации консорциума.
   Заметьте, что политика исполняется в контексте новой конфигурации, так что политика, требующая ``ALL`` (всех) участников потребует подписей от всех участников нового канала, а не от
   всех участников консорциума.
5. Orderer применяет ``CONFIG_UPDATE`` как обновление к шаблону конфигурации.
   Так как ``CONFIG_UPDATE`` применяет изменения к
   группе ``Application`` (с ``version``, равной ``1``), конфигурационный узел проверяет обновления через
   ``ChannelCreationPolicy``. Если создание канала имеет другие изменения, направленные, например, на anchor-пиров конкретной организации, будет применена
   соответствующая ``mod_policy``.
6. Новая ``CONFIG``-транзакция с конфигом нового канала соответственно оборачивается и посылается на ordering в системный канал. После odering'а и происходит создание канала.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/

