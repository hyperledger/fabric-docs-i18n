Channel Configuration (configtx)
================================

Hyperledger Fabric ブロックチェーンネットワークの共有設定は、チャンネルごとに1つずつ、
コンフィグレーショントランザクションのコレクションに保存されます。
各コンフィグレーショントランザクションは通常 *configtx* という短い名前で参照されます。

チャネル設定には、次の重要な特性があります:

1. **Versioned**: 設定のすべての要素には関連付けられたバージョンがあり、変更するたびに更新されます。
   さらに、コミットされた設定はすべてシーケンス番号を受け取ります。
2. **Permissioned**: 設定の各要素には、その要素への変更が許可されるかどうかを管理する関連付けられたポリシーがあります。
   前回のconfigtxのコピーがあれば(追加情報なしに)、誰でもこれらのポリシーに基づいて新しい設定の有効性を検証することができます。
3. **Hierarchical**: ルート設定グループはサブグループを含み、階層の各グループは関連付けられた複数の値とポリシーを持ちます。
   これらのポリシーは、階層を利用して、下位レベルの複数ポリシーからひとつ上位レベルのポリシーを導き出すことができます。

Anatomy of a configuration
--------------------------

設定は ``HeaderType_CONFIG`` 型のトランザクションとして、他のトランザクションが存在しないブロックに格納されます。
これらのブロックは *コンフィグレーションブロック* と呼ばれ、その最初のブロックは *ジェネシスブロック* と呼ばれます。

設定のプロトコルバッファのデータ構造は ``fabric-protos/common/configtx.proto`` に記述されています。
``HeaderType_CONFIG`` 型のエンベロープは ``ConfigEnvelope`` メッセージを ``Payload`` ``data`` フィールドにエンコードします。
``ConfigEnvelope`` のプロトコルバッファのデータ構造は以下のように定義されます:

::

    message ConfigEnvelope {
        Config config = 1;
        Envelope last_update = 2;
    }

``last_update`` フィールドは後述の **Configuration updates (設定更新)** セクションで説明されますが、
設定を読み込むのではなく設定を検証する際にのみ必要となります。
代わりに、現在コミットされた設定は、 ``Config`` メッセージを含む ``config`` フィールド内に格納されます。

::

    message Config {
        uint64 sequence = 1;
        ConfigGroup channel_group = 2;
    }

``sequence`` 番号は、コミットされた設定ごとに1つずつインクリメントされます。
``channel_group`` フィールドは、設定を格納するルートグループです。
``ConfigGroup`` 構造は再帰的に定義され、グループのツリーを構築し、各グループには複数の値とポリシーが含まれます。
これは以下のように定義されています:

::

    message ConfigGroup {
        uint64 version = 1;
        map<string,ConfigGroup> groups = 2;
        map<string,ConfigValue> values = 3;
        map<string,ConfigPolicy> policies = 4;
        string mod_policy = 5;
    }

``ConfigGroup`` は再帰的な構造のため、階層的な配置になっています。
以下の例はGoの構文でわかりやすく表現したものです。

::

    // 以下のグループが定義されているとする
    var root, child1, child2, grandChild1, grandChild2, grandChild3 *ConfigGroup

    // 以下の値を設定する
    root.Groups["child1"] = child1
    root.Groups["child2"] = child2
    child1.Groups["grandChild1"] = grandChild1
    child2.Groups["grandChild2"] = grandChild2
    child2.Groups["grandChild3"] = grandChild3

    // その結果、グループの設定構造は以下のようになる:
    // root:
    //     child1:
    //         grandChild1
    //     child2:
    //         grandChild2
    //         grandChild3

各グループは、設定階層のひとつのレベルを定義し、各グループは関連付けられた複数の値 (文字列キーでインデックス化) と
複数のポリシー (同じく文字列キーでインデックス化) のセットを持ちます。

値は以下のように定義されます:

::

    message ConfigValue {
        uint64 version = 1;
        bytes value = 2;
        string mod_policy = 3;
    }

ポリシーは以下のように定義されます:

::

    message ConfigPolicy {
        uint64 version = 1;
        Policy policy = 2;
        string mod_policy = 3;
    }

値、ポリシー、グループのデータ構造はすべて ``version`` と ``mod_policy`` を持つことに注意してください。
ある要素の ``version`` はその要素が修正されるたびにインクリメントされます。
``mod_policy`` (修正ポリシー) はその要素を修正するために必要となる署名を管理するために使われます。
Groups の場合、修正とは Values、Policies、 Groups マップへの要素を追加または削除 (あるいは ``mod_policy`` を変更) することです。
Values と Policies の場合、修正とは Value と Policy フィールドをそれぞれ変更 (あるいは ``mod_policy`` を変更)  することです。
各要素の ``mod_policy`` は設定の現在のレベルのコンテキストで評価されます。
次の例で、 ``Channel.Groups["Application"]`` に定義されている修正ポリシーを考えてみましょう (ここでは、我々はGoのマップ参照構文を使います。
``Channel.Groups["Application"].Policies["policy1"]`` は ``Channel`` グループの ``Application`` グループの ``Policies`` マップ
``policy1`` ポリシーを参照します)。

* ``policy1`` は ``Channel.Groups["Application"].Policies["policy1"]`` にマッピングされます。
* ``Org1/policy2`` は
  ``Channel.Groups["Application"].Groups["Org1"].Policies["policy2"]`` にマッピングされます。
* ``/Channel/policy3`` は ``Channel.Policies["policy3"]`` にマッピングされます。

``mod_policy`` が存在しないポリシーを参照している場合、その項目は修正できないことに注意してください。

Configuration updates
---------------------

設定更新は ``HeaderType_CONFIG_UPDATE`` 型の ``Envelope`` メッセージとして送信されます。
トランザクションの ``Payload`` ``data`` はマーシャリングされた ``ConfigUpdateEnvelope`` です。
``ConfigUpdateEnvelope`` の定義は以下の通りです:

::

    message ConfigUpdateEnvelope {
        bytes config_update = 1;
        repeated ConfigSignature signatures = 2;
    }

``signatures`` フィールドは、この設定更新を許可する署名のセットを含みます。
そのメッセージの定義は以下の通りです:

::

    message ConfigSignature {
        bytes signature_header = 1;
        bytes signature = 2;
    }

``signature_header`` は標準的なトランザクションで定義されるもので、署名は ``ConfigUpdateEnvelope`` メッセージの
``signature_header`` のバイトと ``config_update`` のバイトを結合したものに対するものです。
``ConfigUpdateEnvelope`` の ``config_update`` バイトは 以下のように定義される ``ConfigUpdate`` メッセージをマーシャリングしたものです:

::

    message ConfigUpdate {
        string channel_id = 1;
        ConfigGroup read_set = 2;
        ConfigGroup write_set = 3;
    }

``channel_id`` は更新対象となるチャネルIDであり、この再設定をサポートする署名のスコープを設定するために必要です。
``read_set`` (読み込みセット) は既存の設定のセットを指定するもので、
``version`` フィールドのみが設定され、他のフィールドに入力する必要がない場合は疎に指定されます。
特定の ``ConfigValue`` の ``value`` あるいは ``ConfigPolicy`` の ``policy`` フィールドを ``read_set`` に設定しないでください。
``ConfigGroup`` には設定ツリーのより深い要素を参照するために、マップフィールドのサブセットが入力されている場合があります。
たとえば、 ``Application`` グループを ``read_set`` に含めるには、その親 ( ``Channel`` グループ) も読み込みセットに含める必要があります。
しかし、 ``Channel`` グループは ``Orderer`` ``group`` キー、 ``values`` または ``policies`` のいずれかなど、すべてのキーを設定する必要はありません。 

``write_set`` (書き込みセット) は変更される設定の部分を指定するものです。
設定の階層的な性質のため、階層の深い要素への書き込みには、その ``write_set`` にも上位レベルの要素が含まれている必要があります。
ただし、同じバージョンの ``read_set`` でも指定されている ``write_set`` の要素については、 ``read_set`` の場合と同様に、要素を疎に指定する必要があります。

例えば、このような設定があるとします:

::

    Channel: (version 0)
        Orderer (version 0)
        Application (version 3)
           Org1 (version 2)

``Org1`` を修正する設定更新を送信するとき、 ``read_set`` は以下のようになります:

::

    Channel: (version 0)
        Application: (version 3)

そして ``write_set`` は以下のようになります:

::

    Channel: (version 0)
        Application: (version 3)
            Org1 (version 3)

``CONFIG_UPDATE`` を受信すると、Ordererは次のようにして 結果の ``CONFIG`` を計算します:

1. ``channel_id`` と ``read_set`` を検証します。 ``read_set`` に含まれるすべての要素が、与えられたバージョンで存在する必要があります。
2. ``write_set`` に含まれる要素のうち、 ``read_set`` と同じバージョンで現れないものをすべて集め、更新セットを計算します。
3. 更新セット内の各要素が、要素の更新のバージョン番号を正確に1だけインクリメントさせていることを確認します。
4. ``ConfigUpdateEnvelope`` に付けられた署名セットが、更新セットの各要素に対して ``mod_policy`` を満たすかどうかを確認します。
5. 現在の設定に更新セットを適用して、新しい完全なバージョンの設定を計算します。
6. 新しい設定を ``ConfigEnvelope`` に書き込みます。 ``ConfigEnvelope`` には、 ``CONFIG_UPDATE`` が ``last_update`` フィールドとして、
   新しい設定が ``config`` フィールドにエンコードされ、さらに ``sequence`` 値もインクリメントされた形で含まれます。
7. 新しい ``ConfigEnvelope`` を ``CONFIG`` 型の ``Envelope`` に書き込み、最終的にこれを新しいコンフィギュレーションブロックの
   唯一のトランザクションとして書き込みます。

ピア (または ``Deliver`` の他の受信者) がこのコンフィギュレーションブロックを受信すると、
``last_update`` メッセージを現在の設定に適用し、Ordererが計算した ``config`` フィールドに正しい新しい設定が含まれているかどうかを確認し、
その設定が適切に検証されたことを確認する必要があります。

Permitted configuration groups and values
-----------------------------------------

有効な設定は、以下の設定のサブセットとなります。
ここでは、 ``peer.<MSG>`` という表記を用いて、 ``value`` フィールドが ``fabric-protos/peer/configuration.proto`` で定義された ``<MSG>``
という名前のマーシャリングされたバッファメッセージである ``ConfigValue`` を定義しています。
``common.<MSG>``, ``msp.<MSG>``, ``orderer.<MSG>`` という表記も同様にそれぞれ
``fabric-protos/common/configuration.proto``, ``fabric-protos/msp/mspconfig.proto``, ``fabric-protos/orderer/configuration.proto``
に定義されているメッセージに対応します。

``{{org_name}}`` と ``{{consortium_name}}`` は任意の名前を表すキーであり、
異なる名前で繰り返される可能性がある要素を示していることに注意してください。

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

Orderer system channel configuration
------------------------------------

オーダリングシステムチャネルは、オーダリングパラメータと、チャネルを作成するためのコンソーシアム (Consortiums) を定義する必要があります。
オーダリングシステムチャネルは、1つのオーダリングサービスに対して1つだけ存在しなければならず、最初に作成される（正確には起動される）チャネルです。
オーダリングシステムチャネルのジェネシス設定には、Application セクションを定義しないことが推奨されますが、
テストのために定義することは可能です。
オーダリングシステムチャネルへの読み込みアクセス権を持つメンバーは、
チャネルのすべての作成内容を見ることができるため、このチャネルへのアクセスは制限されるべきです。

オーダリングパラメータは以下の設定のサブセットで定義されます:

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

オーダリングに参加する各組織は ``Orderer`` グループ下に1つのグループ要素を持ちます。
このグループには1つのパラメータ ``MSP`` が定義されており、
このパラメータにはその組織の暗号化されたアイデンティティ情報が含まれています。
``Orderer`` グループの ``Values`` は、オーダリングノードの機能を決定します。
それらはチャネルごとに存在し、例えば ``orderer.BatchTimeout`` にはあるチャネルと別のチャネルで異なる値を指定することができます。

起動時、Ordererは多くのチャネルの情報を含むファイルシステムに直面します。
Ordererは、Consortiums グループが定義されているチャネルを識別することで、システムチャネルを特定します。
Consortiums グループは以下のようなデータ構造を持っています。

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

各コンソーシアムは、オーダリング組織の組織メンバーと同じように、メンバーのセットを定義することに注意してください。
各コンソーシアムは、 ``ChannelCreationPolicy`` も定義しています。
これは、チャネル作成要求を承認するために適用されるポリシーです。
通常、この値は、チャンネルの新しいメンバーがチャンネル作成を承認するために署名する必要がある ``ImplicitMetaPolicy`` に設定されます。
チャネル作成の詳細については、このドキュメントの後半を参照してください。

Application channel configuration
---------------------------------

アプリケーション設定は、アプリケーションタイプのトランザクションのために設計されたチャネルのためのものです。
以下のように定義されます:

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

``Orderer`` セクションと同じように、各組織は1つのグループとしてエンコードされます。
しかし、 ``MSP`` のアイデンティティ情報だけでなく、各組織はさらに ``AnchorPeers`` のリストもエンコードします。
このリストによって、異なる組織のピアはピアゴシップネットワーキングのために互いにコンタクトすることができます。

アプリケーションチャンネルは、オーダリング組織とコンセンサスオプションのコピーをエンコードして、
これらのパラメータを決定論的に更新できるようにします。
したがって、オーダリングシステムチャンネルの設定と同じ ``Orderer`` セクションが含まれることになります。
しかし、アプリケーションの観点からは、これはほとんど無視されるかもしれません。

Channel creation
----------------

Ordererが存在しないチャネルの ``CONFIG_UPDATE`` を受け取った場合、
Ordererはチャネル作成要求に違いないと判断し、以下の処理を行います。

1. Ordererは、チャンネル作成要求を行うコンソーシアムを特定します。これは、トップレベルグループの ``Consortium`` 値を見ることによって行われます。
2. Ordererは、 ``Application`` グループに含まれる組織が、対応するコンソーシアムに含まれる組織のサブセットであること、
   および ``ApplicationGroup`` が ``version`` ``1`` に設定されていることを確認します。
3. Ordererは、コンソーシアムにメンバーがいる場合、新しいチャネルにもアプリケーションメンバーがいることを確認します
   (メンバーがいないコンソーシアムやチャネルの作成は、テストにのみ有効)。
4. Ordererは、オーダリングシステムチャンネルから ``Orderer`` グループを取り出し、新たに指定したメンバーを含む ``Application`` グループを作成し、
   その ``mod_policy`` をコンソーシアムの設定で指定した ``ChannelCreationPolicy`` に指定して、テンプレート設定を作成します。
   そのポリシーは新しい設定のコンテキストで評価されるので、 ``ALL`` のメンバーを要求するポリシーは、コンソーシアムのすべてのメンバーではなく、
   新しいチャンネルのすべてのメンバーからの署名を要求することになることに注意してください。
5. そして、Ordererはテンプレート設定の更新として ``CONFIG_UPDATE`` を適用します。
   ``CONFIG_UPDATE`` は ``Application`` グループ (その ``version`` は ``1``) に変更を加えるので、
   設定コードはこれらの更新を ``ChannelCreationPolicy`` に対して検証します。もしチャンネルの作成が、
   個々の組織のアンカーピアのような他の修正を含んでいる場合、その要素に対応する修正ポリシーが呼び出されます。
6. 新しいチャネル設定を持つ新しい ``CONFIG`` トランザクションはラップされ、オーダリングシステムチャネル上でオーダリングするために送信されます。
   オーダリング後、そのチャンネルが作成されます。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/

