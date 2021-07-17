Chaincode for Developers
========================

What is Chaincode?
------------------

チェーンコードは、 `Go <https://golang.org>`_ 、`Node.js <https://nodejs.org>`_ 、または `Java <https://java.com/en/>`_ で書かれたプログラムで、所定のインタフェースを実装したものです。
チェーンコードはピアとは別のプロセスで動作し、アプリケーションから送信されたトランザクションによって台帳ステートを初期化し、管理します。

チェーンコードは通常、ネットワークのメンバーが合意したビジネスロジックを処理するため、「スマートコントラクト」と見なします。チェーンコードは、提案トランザクションで台帳を更新またはクエリするために呼び出すことができます。適切な許可が与えられれば、チェーンコードは同じチャネルまたは別のチャネルにある別のチェーンコードを呼び出し、そのステートにアクセスすることができます。ただし、もし呼ばれたチェーンコードが呼び出しをしているチェーンコードとは別のチャネルにある場合、読み込みクエリのみが許可されます。つまり、別のチャネルの呼ばれたチェーンコードは ``Query`` だけで、その後のコミット段階でステート検証チェックには参加しません。

以下のセクションでは、アプリケーション開発者の視点でチェーンコードを解説します。簡単なチェーンコードサンプルアプリケーションを提示し、Chaincode Shim APIにおける各メソッドの目的について確認していきます。もし、ネットワーク運用者の方で、実行中のネットワークへチェーンコードをデプロイしている場合は、 :doc:`deploy_chaincode` チュートリアルおよび :doc:`chaincode_lifecycle` コンセプトトピックを参照してください。

このチュートリアルでは、Fabric Chaincode Shim APIが提供する低レベルAPIの概要を説明します。また、Fabric Contract APIが提供する高レベルAPIも使用できます。Fabric Contract APIを使ったスマートコントラクト開発の詳細については、 :doc:`developapps/smartcontract` トピックを参照してください。

Chaincode API
-------------

すべてのチェーンコードプログラムは、受信したトランザクションに応じてメソッドが呼び出される ``Chaincode`` インタフェースを実装する必要があります。異なる言語のChaincode Shim APIの参考ドキュメントは以下の通りです:

  - `Go <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#Chaincode>`__
  - `Node.js <https://hyperledger.github.io/fabric-chaincode-node/{BRANCH}/api/fabric-shim.ChaincodeInterface.html>`__
  - `Java <https://hyperledger.github.io/fabric-chaincode-java/{BRANCH}/api/org/hyperledger/fabric/shim/Chaincode.html>`__

それぞれの言語で、 ``Invoke`` メソッドはトランザクション提案に送信するため、クライアントによって呼び出されます。このメソッドでは、チャネル台帳でデータの読み込みおよび書き込みのためにチェーンコードを使用することが許可されます。

また、チェーンコードには、初期化関数として機能する ``Init`` メソッドを含める必要があります。この関数はチェーンコードインターフェイスによって要求されますが、必ずしもアプリケーションで呼び出す必要はありません。 ``Invoke`` メソッド呼び出しの前に ``Init`` 関数を呼び出す必要があるかどうかを指定するために、Fabricチェーンコードライフサイクルプロセスを使用することができます。詳細は、Fabricチェーンコードライフサイクルドキュメントの `Approving a chaincode definition <chaincode_lifecycle.html#step-three-approve-a-chaincode-definition-for-your-organization>`__ の初期化パラメータを参照してください。

チェーンコードの"shim"APIのもう一つのインタフェースは ``ChaincodeStubInterface`` です。

  - `Go <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStubInterface>`__
  - `Node.js <https://hyperledger.github.io/fabric-chaincode-node/{BRANCH}/api/fabric-shim.ChaincodeStub.html>`__
  - `Java <https://hyperledger.github.io/fabric-chaincode-java/{BRANCH}/api/org/hyperledger/fabric/shim/ChaincodeStub.html>`__

台帳にアクセスして変更したり、チェーンコード間で呼び出しを行うために使用されます。

Goチェーンコードを使用したこのチュートリアルでは、単純な「アセット」を管理する簡単なチェーンコードアプリケーションを実装することによって、これらのAPIの使用を実証します。

.. _Simple Asset Chaincode:

Simple Asset Chaincode
----------------------
アプリケーションは、台帳にアセット(キーバリューペア)を作成するための基本的なサンプルチェーンコードです。

Choosing a Location for the Code
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Goでプログラミングを行っていない場合は、 `Go <https://golang.org>`_ がインストールされ、システムが正しく設定されていることを確認してください。モジュールに対応したバージョンを使用することを前提としています。

次に、チェーンコードアプリケーション用のディレクトリを作成します。

簡単にするために、次のコマンドを使いましょう:

.. code:: bash

  mkdir sacc && cd sacc

次に、コードを入力するモジュールとソースファイルを作成しましょう:

.. code:: bash

  go mod init sacc
  touch sacc.go

Housekeeping
^^^^^^^^^^^^

まずはハウスキーピングから始めましょう。すべてのチェーンコードと同様に、 `Chaincode interface <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#Chaincode>`_ 、特に ``Init`` 関数と ``Invoke`` 関数を実装します。そして、チェーンコードに必要な依存関係に対してGoインポート文を追加しましょう。Chaincode shimパッケージと `peer protobuf package <https://godoc.org/github.com/hyperledger/fabric-protos-go/peer>`_ (ピアプロトコルバッファーパッケージ)をインポートします。次に、 Chaincode shim関数のレシーバとして構造体SimpleAssetを追加しましょう。

.. code:: go

    package main

    import (
    	"fmt"

    	"github.com/hyperledger/fabric-chaincode-go/shim"
    	"github.com/hyperledger/fabric-protos-go/peer"
    )

    // SimpleAsset implements a simple chaincode to manage an asset
    type SimpleAsset struct {
    }

Initializing the Chaincode
^^^^^^^^^^^^^^^^^^^^^^^^^^

次に、 ``Init`` 関数を実装します。

.. code:: go

  // Init is called during chaincode instantiation to initialize any data.
  func (t *SimpleAsset) Init(stub shim.ChaincodeStubInterface) peer.Response {

  }

.. note:: チェーンコードアップグレードはこの関数も呼ぶことに注意してください。既存のものをアップグレードするチェーンコードを作成する場合は、 ``Init`` 関数を適切に変更してください。特に、「マイグレーション」がない場合や、アップグレードする一部として初期化されるものがない場合は、空の「Init」メソッドを提供してください。

次に、 `ChaincodeStubInterface.GetStringArgs <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStub.GetStringArgs>`_ 関数を使用して ``Init`` 呼び出しの引数を取得し、妥当性をチェックします。この例では、キーバリューペアを想定しています。

  .. code:: go

    // Init is called during chaincode instantiation to initialize any
    // data. Note that chaincode upgrade also calls this function to reset
    // or to migrate data, so be careful to avoid a scenario where you
    // inadvertently clobber your ledger's data!
    func (t *SimpleAsset) Init(stub shim.ChaincodeStubInterface) peer.Response {
      // Get the args from the transaction proposal
      args := stub.GetStringArgs()
      if len(args) != 2 {
        return shim.Error("Incorrect arguments. Expecting a key and a value")
      }
    }

次に、呼び出しが正当であることを確認したので、初期ステートを台帳に格納します。これを行うには、引数としてキーと値を伴った `ChaincodeStubInterface.PutState <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStub.PutState>`_ を呼び出します。すべてがうまくいったと仮定して、初期化が成功したことを示すpeer.Responseオブジェクトを返します。

.. code:: go

  // Init is called during chaincode instantiation to initialize any
  // data. Note that chaincode upgrade also calls this function to reset
  // or to migrate data, so be careful to avoid a scenario where you
  // inadvertently clobber your ledger's data!
  func (t *SimpleAsset) Init(stub shim.ChaincodeStubInterface) peer.Response {
    // Get the args from the transaction proposal
    args := stub.GetStringArgs()
    if len(args) != 2 {
      return shim.Error("Incorrect arguments. Expecting a key and a value")
    }

    // Set up any variables or assets here by calling stub.PutState()

    // We store the key and the value on the ledger
    err := stub.PutState(args[0], []byte(args[1]))
    if err != nil {
      return shim.Error(fmt.Sprintf("Failed to create asset: %s", args[0]))
    }
    return shim.Success(nil)
  }

Invoking the Chaincode
^^^^^^^^^^^^^^^^^^^^^^

まず、 ``Invoke`` 関数の署名を追加しましょう。

.. code:: go

    // Invoke is called per transaction on the chaincode. Each transaction is
    // either a 'get' or a 'set' on the asset created by Init function. The 'set'
    // method may create a new asset by specifying a new key-value pair.
    func (t *SimpleAsset) Invoke(stub shim.ChaincodeStubInterface) peer.Response {

    }

上記の ``Init`` 関数と同様に、 ``ChaincodeStubInterface`` からの引数を解凍するする必要があります。Invoke関数の引数は、チェーンコードアプリケーション関数を呼び出すための名前になります。この例では、アプリケーションには2つの関数があるだけです: ``set`` と ``get`` です。これらは、アセットの値を設定したり、現在のステートを取得したりすることができます。最初に、チェーンコードアプリケーション関数に対して関数名とパラメータを展開するために、 `ChaincodeStubInterface.GetFunctionAndParameters <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStub.GetFunctionAndParameters>`_ を呼び出します。

.. code:: go

    // Invoke is called per transaction on the chaincode. Each transaction is
    // either a 'get' or a 'set' on the asset created by Init function. The Set
    // method may create a new asset by specifying a new key-value pair.
    func (t *SimpleAsset) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
    	// Extract the function and args from the transaction proposal
    	fn, args := stub.GetFunctionAndParameters()

    }

次に、 関数名が ``set`` または ``get`` のいずれかであることを検証して、それらのチェーンコードアプリケーション関数を呼び出し、応答をgRPCプロトコルバッファメッセージにシリアライズする ``shim.Success`` または ``shim.Error`` 関数を介して適切な応答を戻します。

.. code:: go

    // Invoke is called per transaction on the chaincode. Each transaction is
    // either a 'get' or a 'set' on the asset created by Init function. The Set
    // method may create a new asset by specifying a new key-value pair.
    func (t *SimpleAsset) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
    	// Extract the function and args from the transaction proposal
    	fn, args := stub.GetFunctionAndParameters()

    	var result string
    	var err error
    	if fn == "set" {
    		result, err = set(stub, args)
    	} else {
    		result, err = get(stub, args)
    	}
    	if err != nil {
    		return shim.Error(err.Error())
    	}

    	// Return the result as success payload
    	return shim.Success([]byte(result))
    }

Implementing the Chaincode Application
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

すでに述べたように、私たちのチェーンコードアプリケーションは、 ``Invoke`` 関数経由で呼び出すことができる2つの機能を実装しています。ここでこれらの機能を実装しましょう。前述したように、台帳のステートにアクセスするには、Chaincode shim APIの `ChaincodeStubInterface.PutState <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStub.PutState>`_ 関数と `ChaincodeStubInterface.GetState <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStub.GetState>`_ 関数を利用します。

.. code:: go

    // Set stores the asset (both key and value) on the ledger. If the key exists,
    // it will override the value with the new one
    func set(stub shim.ChaincodeStubInterface, args []string) (string, error) {
    	if len(args) != 2 {
    		return "", fmt.Errorf("Incorrect arguments. Expecting a key and a value")
    	}

    	err := stub.PutState(args[0], []byte(args[1]))
    	if err != nil {
    		return "", fmt.Errorf("Failed to set asset: %s", args[0])
    	}
    	return args[1], nil
    }

    // Get returns the value of the specified asset key
    func get(stub shim.ChaincodeStubInterface, args []string) (string, error) {
    	if len(args) != 1 {
    		return "", fmt.Errorf("Incorrect arguments. Expecting a key")
    	}

    	value, err := stub.GetState(args[0])
    	if err != nil {
    		return "", fmt.Errorf("Failed to get asset: %s with error: %s", args[0], err)
    	}
    	if value == nil {
    		return "", fmt.Errorf("Asset not found: %s", args[0])
    	}
    	return string(value), nil
    }

.. _Chaincode Sample:

Pulling it All Together
^^^^^^^^^^^^^^^^^^^^^^^

最後に、 ``main`` 関数を追加します。つまり、 `shim.Start <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#Start>`_ 関数を呼び出します。これがチェーンコードプログラムのソース全体です。

.. code:: go

    package main

    import (
    	"fmt"

    	"github.com/hyperledger/fabric-chaincode-go/shim"
    	"github.com/hyperledger/fabric-protos-go/peer"
    )

    // SimpleAsset implements a simple chaincode to manage an asset
    type SimpleAsset struct {
    }

    // Init is called during chaincode instantiation to initialize any
    // data. Note that chaincode upgrade also calls this function to reset
    // or to migrate data.
    func (t *SimpleAsset) Init(stub shim.ChaincodeStubInterface) peer.Response {
    	// Get the args from the transaction proposal
    	args := stub.GetStringArgs()
    	if len(args) != 2 {
    		return shim.Error("Incorrect arguments. Expecting a key and a value")
    	}

    	// Set up any variables or assets here by calling stub.PutState()

    	// We store the key and the value on the ledger
    	err := stub.PutState(args[0], []byte(args[1]))
    	if err != nil {
    		return shim.Error(fmt.Sprintf("Failed to create asset: %s", args[0]))
    	}
    	return shim.Success(nil)
    }

    // Invoke is called per transaction on the chaincode. Each transaction is
    // either a 'get' or a 'set' on the asset created by Init function. The Set
    // method may create a new asset by specifying a new key-value pair.
    func (t *SimpleAsset) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
    	// Extract the function and args from the transaction proposal
    	fn, args := stub.GetFunctionAndParameters()

    	var result string
    	var err error
    	if fn == "set" {
    		result, err = set(stub, args)
    	} else { // assume 'get' even if fn is nil
    		result, err = get(stub, args)
    	}
    	if err != nil {
    		return shim.Error(err.Error())
    	}

    	// Return the result as success payload
    	return shim.Success([]byte(result))
    }

    // Set stores the asset (both key and value) on the ledger. If the key exists,
    // it will override the value with the new one
    func set(stub shim.ChaincodeStubInterface, args []string) (string, error) {
    	if len(args) != 2 {
    		return "", fmt.Errorf("Incorrect arguments. Expecting a key and a value")
    	}

    	err := stub.PutState(args[0], []byte(args[1]))
    	if err != nil {
    		return "", fmt.Errorf("Failed to set asset: %s", args[0])
    	}
    	return args[1], nil
    }

    // Get returns the value of the specified asset key
    func get(stub shim.ChaincodeStubInterface, args []string) (string, error) {
    	if len(args) != 1 {
    		return "", fmt.Errorf("Incorrect arguments. Expecting a key")
    	}

    	value, err := stub.GetState(args[0])
    	if err != nil {
    		return "", fmt.Errorf("Failed to get asset: %s with error: %s", args[0], err)
    	}
    	if value == nil {
    		return "", fmt.Errorf("Asset not found: %s", args[0])
    	}
    	return string(value), nil
    }

    // main function starts up the chaincode in the container during instantiate
    func main() {
    	if err := shim.Start(new(SimpleAsset)); err != nil {
    		fmt.Printf("Error starting SimpleAsset chaincode: %s", err)
    	}
    }

Chaincode access control
------------------------

チェーンコードは、GetCreator()関数を呼び出すことによって、アクセス制御の決定にクライアント(サブミッタ)証明書を利用することができます。さらに、Go shimは、サブミッタの証明書からクライアントアイデンティティを抽出する拡張APIを提供しており、アクセス制御の決定に使用することができます。これは、クライアントアイデンティティ自体や組織アイデンティティ、またはクライアントアイデンティティ属性のいずれに基づくものであってもかまいません。

例えば、キー/値として表されるアセットは、クライアントのアイデンティティを値の一部(例えば、アセットの所有者を示すJSON属性)として含むことができ、このクライアントだけが将来的にキー/値を更新する権限を持つことができます。クライアントアイデンティティライブラリ拡張APIは、チェーンコード内でこのサブミッタ情報を取得して、このようなアクセス制御決定を行うために使用できます。

詳細は `client identity (CID) library documentation <https://github.com/hyperledger/fabric-chaincode-go/blob/{BRANCH}/pkg/cid/README.md>`_ をご覧ください。

クライアントアイデンティティshim拡張をチェーンコードに依存関係として追加するには、 :ref:`vendoring` を参照してください。

.. _vendoring:

Managing external dependencies for chaincode written in Go
----------------------------------------------------------
Goチェーンコードは、標準ライブラリに含まれていないGoパッケージ(チェーンコードshimなど)に依存しています。これらのパッケージのソースは、ピアにインストールするときチェーンコードパッケージに含まれている必要があります。チェーンコードをモジュールとして構成した場合、最も簡単な方法は、チェーンコードをパッケージ化する前に、 ``go mod vendor`` を使って依存関係を "vendor" することです。

.. code:: bash

  go mod tidy
  go mod vendor

これにより、チェーンコードの外部依存関係がローカル ``vendor`` のディレクトリに配置されます。

チェーンコードディレクトリーで依存関係がベンダー化されると、 ``peer chaincode package`` と ``peer chaincode install`` のオペレーションは、依存関係に関連したコードをチェーンコードパッケージに組み込みます。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
