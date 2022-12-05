Pluggable transaction endorsement and validation
================================================

Motivation
----------

トランザクションがコミットする時に検証されると、ピアは様々なチェックを実行してから、トランザクション自体に伴う状態の変更を適用します。

- トランザクションに署名したアイデンティティの検証する
- トランザクションのエンドーサーの署名を確認する
- トランザクションが、対応するチェーンコードのネームスペースのエンドースメントポリシーを満たすことを保証すること。

次のような、デフォルトのFabric検証規則とは異なるカスタムトランザクション検証規則を要求するユースケースがあります。

- **UTXO (Unspent Transaction Output):** トランザクションがその入力をダブルスペンドしないかどうかを検証で考慮に入れる場合。
- **Anonymous transactions:** エンドースメントにピアのアイデンティティが含まれていないが、署名と公開鍵が共有されていて、ピアのアイデンティティにリンクできない場合。

Pluggable endorsement and validation logic
------------------------------------------

Fabricでは、カスタムエンドースメントと検証のロジックをピアに実装および展開して、チェーンコード処理に関連付けることができます。このロジックは、ピアにコンパイルするかピアとともに構築し、 `Go plugin <https://golang.org/pkg/plugin/>`_ としてデプロイすることもできます。

.. 注:: Goプラグインにはいくつかの実質的な制限があり、ピアと同じビルド環境でコンパイルしてリンクする必要があります。Goパッケージバージョン、コンパイラバージョン、タグ、さらにはGOPATH値に違いがあると、プラグインロジックをロードまたは実行するときにランタイムエラーが発生します。

デフォルトでは、Aチェーンコードは内蔵のエンドースメントと検証ロジックを使用します。管理者は、ピアのローカル設定をカスタマイズすることによって、ピアで利用できるエンドースメントまたは検証ロジックを拡張することができます。

Configuration
-------------

各ピアにはローカル設定( ``core.yaml`` )があり、エンドースメント/検証ロジック名と実行される実装との間のマッピングを宣言します。

デフォルトのロジックは ``ESCC`` (「E」はエンドースメントを表します)および ``VSCC`` (検証)と呼ばれ、 ``handlers`` セクションのピアローカル設定にあります。

.. code-block:: YAML

    handlers:
        endorsers:
          escc:
            name: DefaultEndorsement
        validators:
          vscc:
            name: DefaultValidation

エンドースメントまたは検証の実装がピアにコンパイルされると、 ``name`` プロパティは、エンドースメント/検証ロジックのインスタンスを作成するファクトリーを取得するために実行される初期化関数を表します。

この関数は、 ``core/handlers/library/library.go`` 下の ``HandlerLibrary`` 構造体のインスタンスメソッドであり、カスタムエンドースメントまたは検証ロジックを追加するために、この構造体を追加のメソッドで拡張する必要があります。

カスタムコードがGoプラグインとしてビルドされている場合は、 ``library`` プロパティを提供し、共有ライブラリの場所に設定する必要があります。

例えば、プラグインとして実装されているカスタムエンドースメントと検証ロジックがある場合、 ``core.yaml`` の設定には次のエントリがあります。

.. code-block:: YAML

    handlers:
        endorsers:
          escc:
            name: DefaultEndorsement
          custom:
            name: customEndorsement
            library: /etc/hyperledger/fabric/plugins/customEndorsement.so
        validators:
          vscc:
            name: DefaultValidation
          custom:
            name: customValidation
            library: /etc/hyperledger/fabric/plugins/customValidation.so

そして、 ``.so`` のプラグインファイルをピアのローカルファイルシステムに配置する必要があります。

カスタムプラグインの名前は、チェーンコードが使用するチェーンコード定義によって参照される必要があります。ピアCLIを利用してチェーンコード定義を承認する場合は、 ``--escc`` と ``--vscc`` フラグを使用してカスタムエンドースメントまたは検証ライブラリの名前を選択します。Node.jsのFabric SDKを使用している場合は、 `How to install and start your chaincode <https://hyperledger.github.io/fabric-sdk-node/{BRANCH}/tutorial-chaincode-lifecycle.html>`_ を参照してください。詳細は :doc:`chaincode_lifecycle` をご覧ください。

.. 注:: これ以降、カスタムエンドースメントまたは検証ロジックの実装をピアにコンパイルされている場合でも、「プラグイン」と呼びます。

Endorsement plugin implementation
---------------------------------

エンドースメントプラグインを実装するには、 ``core/handlers/endorsement/api/endorsement.go`` にある ``Plugin`` インタフェースを実装する必要があります。

.. code-block:: Go

    // Plugin endorses a proposal response
    type Plugin interface {
    	// Endorse signs the given payload(ProposalResponsePayload bytes), and optionally mutates it.
    	// Returns:
    	// The Endorsement: A signature over the payload, and an identity that is used to verify the signature
    	// The payload that was given as input (could be modified within this function)
    	// Or error on failure
    	Endorse(payload []byte, sp *peer.SignedProposal) (*peer.Endorsement, []byte, error)

    	// Init injects dependencies into the instance of the Plugin
    	Init(dependencies ...Dependency) error
    }

特定のプラグインタイプのエンドースメントプラグインのインスタンス( ``HandlerLibrary`` のインスタンスメソッドとしてのメソッド名、またはプラグイン ``.so`` のファイルパスのいずれかで識別される)は、 ``PluginFactory`` インタフェース内の ``New`` メソッドにピアが呼び出しをすることによって、各チャネルに対して作成されます。これは、プラグイン開発者によって実装されることが期待されています。

.. code-block:: Go

    // PluginFactory creates a new instance of a Plugin
    type PluginFactory interface {
    	New() Plugin
    }


``Init`` メソッドは、 ``Dependency`` インタフェースを埋め込むものとして識別された、 ``core/handlers/endorsement/api/`` の下で宣言されたすべての依存関係を入力として受け取ることが期待されます。

``Plugin`` インスタンスの作成後、パラメータとして渡された ``dependencies`` とともに、ピアによって ``Init`` メソッドが呼び出されます。

現在、Fabricにはエンドースメントプラグインのために次の依存関係があります。

- ``SigningIdentityFetcher``: 特定の署名付きの提案に基づいて、 ``SigningIdentity`` のインスタンスを返します。

.. code-block:: Go

    // SigningIdentity signs messages and serializes its public identity to bytes
    type SigningIdentity interface {
    	// Serialize returns a byte representation of this identity which is used to verify
    	// messages signed by this SigningIdentity
    	Serialize() ([]byte, error)

    	// Sign signs the given payload and returns a signature
    	Sign([]byte) ([]byte, error)
    }

- ``StateFetcher``: ワールドステートと相互作用する **State** オブジェクトを取得します。

.. code-block:: Go

    // State defines interaction with the world state
    type State interface {
    	// GetPrivateDataMultipleKeys gets the values for the multiple private data items in a single call
    	GetPrivateDataMultipleKeys(namespace, collection string, keys []string) ([][]byte, error)

    	// GetStateMultipleKeys gets the values for multiple keys in a single call
    	GetStateMultipleKeys(namespace string, keys []string) ([][]byte, error)

    	// GetTransientByTXID gets the values private data associated with the given txID
    	GetTransientByTXID(txID string) ([]*rwset.TxPvtReadWriteSet, error)

    	// Done releases resources occupied by the State
    	Done()
     }

Validation plugin implementation
--------------------------------

バリデーションプラグインを実装するためには、 ``core/handlers/validation/api/validation.go`` にある ``Plugin`` インタフェースを実施する必要があります。

.. code-block:: Go

    // Plugin validates transactions
    type Plugin interface {
    	// Validate returns nil if the action at the given position inside the transaction
    	// at the given position in the given block is valid, or an error if not.
    	Validate(block *common.Block, namespace string, txPosition int, actionPosition int, contextData ...ContextDatum) error

    	// Init injects dependencies into the instance of the Plugin
    	Init(dependencies ...Dependency) error
    }

各 ``ContextDatum`` は、追加のランタイム派生メタデータであり、ピアによってバリデーションプラグインに渡されます。現在、唯一 ``ContextDatum`` が渡され、チェーンコードのエンドースメントポリシーを表します。

.. code-block:: Go

   // SerializedPolicy defines a serialized policy
  type SerializedPolicy interface {
	validation.ContextDatum

	// Bytes returns the bytes of the SerializedPolicy
	Bytes() []byte
   }

特定のプラグインタイプのバリデーションプラグインインスタンス( ``HandlerLibrary`` のインスタンスメソッドメソッドとしてのメソッド名、またはプラグイン ``.so`` ファイルパスのいずれかによって識別される)は、 ``PluginFactory`` インタフェース内の ``New`` メソッドにピアが呼び出しをすることによって、各チャネルに対して作成されます。 これは、プラグイン開発者によって実装されることが期待されています。

.. code-block:: Go

    // PluginFactory creates a new instance of a Plugin
    type PluginFactory interface {
    	New() Plugin
    }

``Init`` メソッドは、 ``Dependency`` インタフェースを埋め込むものとして識別された ``core/handlers/validation/api/`` の下で宣言されたすべての依存関係を入力として受け取ることが期待されます。

``Plugin`` インスタンスの作成後、パラメータとして渡された ``dependencies`` とともに、ピアによって ``Init`` メソッドが呼び出されます。

現在、Fabricには検証プラグインのために次の依存関係があります。

- ``IdentityDeserializer``: アイデンティティのバイト表現を ``Identity`` オブジェクトに変換します。このオブジェクトは、それらによって署名された署名を検証し、対応するMSPに対して検証され、特定の **MSP Principal** を満たすかどうかを確認するために使用できます。仕様の詳細は ``core/handlers/validation/api/identities/identities.go`` にあります。

- ``PolicyEvaluator``: 特定のポリシーが満たされているかどうかを評価します。

.. code-block:: Go

    // PolicyEvaluator evaluates policies
    type PolicyEvaluator interface {
    	validation.Dependency

    	// Evaluate takes a set of SignedData and evaluates whether this set of signatures satisfies
    	// the policy with the given bytes
    	Evaluate(policyBytes []byte, signatureSet []*common.SignedData) error
    }

- ``StateFetcher``: ワールドステートと相互作用する ``State`` オブジェクトを取得します。

.. code-block:: Go

    // State defines interaction with the world state
    type State interface {
        // GetStateMultipleKeys gets the values for multiple keys in a single call
        GetStateMultipleKeys(namespace string, keys []string) ([][]byte, error)

        // GetStateRangeScanIterator returns an iterator that contains all the key-values between given key ranges.
        // startKey is included in the results and endKey is excluded. An empty startKey refers to the first available key
        // and an empty endKey refers to the last available key. For scanning all the keys, both the startKey and the endKey
        // can be supplied as empty strings. However, a full scan should be used judiciously for performance reasons.
        // The returned ResultsIterator contains results of type *KV which is defined in fabric-protos/ledger/queryresult.
        GetStateRangeScanIterator(namespace string, startKey string, endKey string) (ResultsIterator, error)

        // GetStateMetadata returns the metadata for given namespace and key
        GetStateMetadata(namespace, key string) (map[string][]byte, error)

        // GetPrivateDataMetadata gets the metadata of a private data item identified by a tuple <namespace, collection, key>
        GetPrivateDataMetadata(namespace, collection, key string) (map[string][]byte, error)

        // Done releases resources occupied by the State
        Done()
    }

Important notes
---------------

- **Validation plugin consistency across peers:** 今後のリリースでは、Fabricチャネルのインフラは、特定のブロックチェーンの高さで、チャネル内のすべてのピアによって与えられたチェーンコードに対して同じ検証ロジックが使用されることを保証します。これは、誤って異なる実装を実行するピア間で状態の分岐を引き起こす可能性のある誤った設定の可能性を排除するためです。しかし、現時点では、システムのオペレーターと管理者は、これが起こらないようにする必要があります。

- **Validation plugin error handling:** データベースにアクセスできないなどの一時的な実行の問題のために、バリデーションプラグインが特定のトランザクションが有効かどうかを判断できない場合はいつでも、 ``core/handlers/validation/api/validation.go`` で定義されている **ExecutionFailureError** 型のエラーを返す必要があります。その他のエラーが返された場合は、エンドースメントポリシーエラーとして扱われ、検証ロジックによって無効にされたトランザクションとしてマークされます。しかし、 ``ExecutionFailureError`` が返された場合、チェーンプロセスはトランザクションを正当でないとしてマークするのではなく停止します。これは、異なるピア間の状態の分岐を防ぐためです。

- **Error handling for private metadata retrieval**: プラグインが ``StateFetcher`` インタフェースを利用してプライベートデータのメタデータを取得する場合、次のようにエラーが処理されることが重要です。 ``CollConfigNotDefinedError`` と ``InvalidCollNameError`` は、指定されたコレクションが存在しないことを通知しますが、決定的なエラーとして処理されるべきであり、プラグインを ``ExecutionFailureError`` を返すようにするべきではありません。

- **Importing Fabric code into the plugin**: プロトコルバッファ以外のFabricに属するコードをプラグインの一部としてインポートすることは全くお勧めできません。それにより、Fabricのコードがリリース間で変更される際に問題が発生したり、ピアのバージョンが混在していると動作しなくなる問題が発生する可能性があります。理想的には、プラグインコードは与えられた依存関係のみを使用し、プロトコルバッファ以外の最低限のものをインポートすべきです。

  .. Licensed under Creative Commons Attribution 4.0 International License
     https://creativecommons.org/licenses/by/4.0/
