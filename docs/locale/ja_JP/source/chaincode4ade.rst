Writing Your First Chaincode
============================

What is Chaincode?
------------------

チェーンコードは、 `Go <https://golang.org>`_ 、`Node.js <https://nodejs.org>`_ 、または `Java <https://java.com/en/>`_ で書かれたプログラムで、所定のインタフェースを実装したものです。
チェーンコードはピアとは別のプロセスで動作し、アプリケーションから送信されたトランザクションによって台帳ステートを初期化し、管理します。

チェーンコードは通常、ネットワークのメンバーが合意したビジネスロジックを処理するため、「スマートコントラクト」と見なします。チェーンコードは、提案トランザクションで台帳を更新またはクエリするために呼び出すことができます。適切な許可が与えられれば、チェーンコードは同じチャネルまたは別のチャネルにある別のチェーンコードを呼び出し、そのステートにアクセスすることができます。ただし、もし呼ばれたチェーンコードが呼び出しをしているチェーンコードとは別のチャネルにある場合、読み込みクエリのみが許可されます。つまり、別のチャネルの呼ばれたチェーンコードは ``Query`` だけで、その後のコミット段階でステート検証チェックには参加しません。

以下のセクションでは、アプリケーション開発者の視点でチェーンコードを解説します。asset-transferチェーンコードサンプルを提示し、Fabric Contract APIにおける各メソッドの目的について確認していきます。もし、ネットワーク運用者の方で、実行中のネットワークへチェーンコードをデプロイしている場合は、 :doc:`deploy_chaincode` チュートリアルおよび :doc:`chaincode_lifecycle` コンセプトトピックを参照してください。

このチュートリアルでは、Fabric Contract APIが提供する高レベルAPIの概要を説明します。Fabric Contract APIを使ったスマートコントラクト開発の詳細については、 :doc:`developapps/smartcontract` トピックを参照してください。

Fabric Contract API
-------------------

``fabric-contract-api`` は、アプリケーションの開発者がスマートコントラクトを実装するための高レベルAPIであるコントラクトインタフェースを提供します。Hyperledger Fabricでは、スマートコントラクトはチェーンコードとしても知られています。このAPIを操作すると、ビジネスロジックを書くための高レベルのエントリポイントが提供されます。さまざまな言語のFabric Contract APIのドキュメントについては、次のリンクを参照してください。

  - `Go <https://godoc.org/github.com/hyperledger/fabric-contract-api-go/contractapi>`__
  - `Node.js <https://hyperledger.github.io/fabric-chaincode-node/{BRANCH}/api/>`__
  - `Java <https://hyperledger.github.io/fabric-chaincode-java/{BRANCH}/api/org/hyperledger/fabric/contract/package-summary.html>`__

コントラクトAPIを使用する場合、呼び出される各チェーンコード関数にはトランザクションコンテキスト"ctx"が渡され、そこからチェーンコードスタブ (GetStub()) を取得できることに注意してください。これには、台帳(GetState()など)にアクセスするための関数があり、台帳(PutState()など)への更新を要求します。詳細については、以下の言語それぞれのリンクを参照してください。

  - `Go <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#Chaincode>`__
  - `Node.js <https://hyperledger.github.io/fabric-chaincode-node/{BRANCH}/api/fabric-shim.ChaincodeInterface.html>`__
  - `Java <https://hyperledger.github.io/fabric-chaincode-java/{BRANCH}/api/org/hyperledger/fabric/shim/Chaincode.html>`__

Goチェーンコードを使用したこのチュートリアルでは、単純な "アセット" を管理するasset-transferチェーンコードアプリケーションを実装することによって、これらのAPIの使用を実証します。

.. _Asset Transfer Chaincode:

Asset Transfer Chaincode
------------------------
アプリケーションは、基本的なサンプルチェーンコードです。このアプリケーションは、基本的なサンプルチェーンコードです。アセットを使用して台帳を初期化し、アセットを作成、読み込み、更新、および削除し、アセットが存在するかどうかを確認し、ある所有者から別の所有者にアセットを転送します。

Choosing a Location for the Code
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Goでプログラミングを行っていない場合は、 `Go <https://golang.org>`_ がインストールされ、システムが正しく設定されていることを確認してください。モジュールに対応したバージョンを使用することを前提としています。

次に、チェーンコードアプリケーション用のディレクトリを作成します。

簡単にするために、次のコマンドを使いましょう:

.. code:: bash

  // atcc is shorthand for asset transfer chaincode
     mkdir atcc && cd atcc

次に、コードを入力するモジュールとソースファイルを作成しましょう:

.. code:: bash

  go mod init atcc
  touch atcc.go

Housekeeping
^^^^^^^^^^^^

まずはハウスキーピングから始めましょう。すべてのチェーンコードと同様に、これは `fabric-contract-api interface <https://godoc.org/github.com/hyperledger/fabric-contract-api-go/contractapi>`_ を実装しますので、チェーンコードに必要な依存関係のためにGo importステートメントを追加しましょう。Fabric Contract APIパッケージをインポートして、SmartContractを定義します。

.. code:: go

  package main

  import (
    "fmt"
    "log"
    "github.com/hyperledger/fabric-contract-api-go/contractapi"
  )

  // SmartContract provides functions for managing an Asset
     type SmartContract struct {
     contractapi.Contract
     }

次に、台帳上の単純なアセットを表すために、struct ``Asset`` を追加しましょう。JSONアノテーションは、アセットをJSONに変換して台帳に保存するために使用されます。

.. code:: go

  // Asset describes basic details of what makes up a simple asset
     type Asset struct {
      ID             string `json:"ID"`
      Color          string `json:"color"`
      Size           int    `json:"size"`
      Owner          string `json:"owner"`
      AppraisedValue int    `json:"appraisedValue"`
     }

Initializing the Chaincode
^^^^^^^^^^^^^^^^^^^^^^^^^^

次に、台帳へ初期データを入力するための ``InitLedger`` 関数を実装します。

.. code:: go

  // InitLedger adds a base set of assets to the ledger
     func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
        assets := []Asset{
          {ID: "asset1", Color: "blue", Size: 5, Owner: "Tomoko", AppraisedValue: 300},
          {ID: "asset2", Color: "red", Size: 5, Owner: "Brad", AppraisedValue: 400},
          {ID: "asset3", Color: "green", Size: 10, Owner: "Jin Soo", AppraisedValue: 500},
          {ID: "asset4", Color: "yellow", Size: 10, Owner: "Max", AppraisedValue: 600},
          {ID: "asset5", Color: "black", Size: 15, Owner: "Adriana", AppraisedValue: 700},
          {ID: "asset6", Color: "white", Size: 15, Owner: "Michel", AppraisedValue: 800},
        }

     for _, asset := range assets {
        assetJSON, err := json.Marshal(asset)
        if err != nil {
          return err
        }

        err = ctx.GetStub().PutState(asset.ID, assetJSON)
        if err != nil {
          return fmt.Errorf("failed to put to world state. %v", err)
        }
      }

      return nil
    }

次に、まだ存在していない台帳にアセットを作成するため、関数を書き込みます。チェーンコードを作成する場合は、次の ``CreateAsset`` 関数で示すように、アクションを実行する前台帳に何かが存在するかどうかを確認することをお勧めします。

.. code:: go

    // CreateAsset issues a new asset to the world state with given details.
       func (s *SmartContract) CreateAsset(ctx contractapi.TransactionContextInterface, id string, color string, size int, owner string, appraisedValue int) error {
        exists, err := s.AssetExists(ctx, id)
        if err != nil {
          return err
        }
        if exists {
          return fmt.Errorf("the asset %s already exists", id)
        }

        asset := Asset{
          ID:             id,
          Color:          color,
          Size:           size,
          Owner:          owner,
          AppraisedValue: appraisedValue,
        }
        assetJSON, err := json.Marshal(asset)
        if err != nil {
          return err
        }

        return ctx.GetStub().PutState(id, assetJSON)
      }

台帳に初期アセットを台帳に入力してアセットを作成したので、台帳からアセットを読み込みするための ``ReadAsset`` 関数を書き込みしましょう。

.. code:: go

  // ReadAsset returns the asset stored in the world state with given id.
     func (s *SmartContract) ReadAsset(ctx contractapi.TransactionContextInterface, id string) (*Asset, error) {
      assetJSON, err := ctx.GetStub().GetState(id)
      if err != nil {
        return nil, fmt.Errorf("failed to read from world state: %v", err)
      }
      if assetJSON == nil {
        return nil, fmt.Errorf("the asset %s does not exist", id)
      }

      var asset Asset
      err = json.Unmarshal(assetJSON, &asset)
      if err != nil {
        return nil, err
      }

      return &asset, nil
    }

台帳にやりとりすることができるアセットができたので、変更が許可されているアセットの属性を更新するためのチェーンコード関数の ``UpdateAsset`` を書きましょう。

.. code:: go

  // UpdateAsset updates an existing asset in the world state with provided parameters.
     func (s *SmartContract) UpdateAsset(ctx contractapi.TransactionContextInterface, id string, color string, size int, owner string, appraisedValue int) error {
        exists, err := s.AssetExists(ctx, id)
        if err != nil {
          return err
        }
        if !exists {
          return fmt.Errorf("the asset %s does not exist", id)
        }

        // overwriting original asset with new asset
        asset := Asset{
          ID:             id,
          Color:          color,
          Size:           size,
          Owner:          owner,
          AppraisedValue: appraisedValue,
        }
        assetJSON, err := json.Marshal(asset)
        if err != nil {
          return err
        }

        return ctx.GetStub().PutState(id, assetJSON)
    }

台帳からアセットを削除する機能が必要な場合があるため、その要件を処理するためにの ``DeleteAsset`` 関数を書きましょう。

.. code:: go

  // DeleteAsset deletes an given asset from the world state.
     func (s *SmartContract) DeleteAsset(ctx contractapi.TransactionContextInterface, id string) error {
        exists, err := s.AssetExists(ctx, id)
        if err != nil {
          return err
        }
        if !exists {
          return fmt.Errorf("the asset %s does not exist", id)
        }

        return ctx.GetStub().DelState(id)
     }

先ほど説明したように、アセットが存在するかどうかを確認してからアクションを実行することをお勧めしますので、その要件を実装するための ``AssetExists`` という関数を書きましょう。

.. code:: go

  // AssetExists returns true when asset with given ID exists in world state
     func (s *SmartContract) AssetExists(ctx contractapi.TransactionContextInterface, id string) (bool, error) {
        assetJSON, err := ctx.GetStub().GetState(id)
        if err != nil {
          return false, fmt.Errorf("failed to read from world state: %v", err)
        }

        return assetJSON != nil, nil
      }

次に、ある所有者から別の所有者へのアセットの譲渡を可能にする、 ``TransferAsset`` と呼ばれる関数を書きます。

.. code:: go

  // TransferAsset updates the owner field of asset with given id in world state.
     func (s *SmartContract) TransferAsset(ctx contractapi.TransactionContextInterface, id string, newOwner string) error {
        asset, err := s.ReadAsset(ctx, id)
        if err != nil {
          return err
        }

        asset.Owner = newOwner
        assetJSON, err := json.Marshal(asset)
        if err != nil {
          return err
        }

        return ctx.GetStub().PutState(id, assetJSON)
      }

台帳上のすべてのアセットを返す台帳のクエリを可能にする、 ``GetAllAssets`` と呼ばれている関数を書きましょう。

.. code:: go

  // GetAllAssets returns all assets found in world state
     func (s *SmartContract) GetAllAssets(ctx contractapi.TransactionContextInterface) ([]*Asset, error) {
  // range query with empty string for startKey and endKey does an
  // open-ended query of all assets in the chaincode namespace.
      resultsIterator, err := ctx.GetStub().GetStateByRange("", "")
      if err != nil {
        return nil, err
      }
      defer resultsIterator.Close()

      var assets []*Asset
      for resultsIterator.HasNext() {
        queryResponse, err := resultsIterator.Next()
        if err != nil {
          return nil, err
        }

        var asset Asset
        err = json.Unmarshal(queryResponse.Value, &asset)
        if err != nil {
          return nil, err
        }
        assets = append(assets, &asset)
      }

      return assets, nil
    }

.. _Chaincode Sample:

.. Note:: 以下の完全なチェーンコードサンプルは、このチュートリアルを可能な限り明確かつ直接的に保つ方法として提示されています。実際の実装では、簡単なユニットテストを可能にするために、 ``main`` パッケージがチェーンコードパッケージをインポートするようにパッケージをセグメント化されることが考えられます。これがどのようなものかを確認するには、fabric-samplesの `Go chaincode <https://github.com/hyperledger/fabric-samples/tree/master/asset-transfer-basic/chaincode-go>`__ を参照してください。 ``assetTransfer.go`` を見ると、それには ``package main`` が含まれており、 ``smartcontract.go`` で定義され、 ``fabric-samples/asset-transfer-basic/chaincode-go/chaincode/`` に配置された ``package chaincode`` をインポートしていることがわかります。


Pulling it All Together
^^^^^^^^^^^^^^^^^^^^^^^

最後に、 ``main`` 関数を追加します。つまり、 `ContractChaincode.Start <https://godoc.org/github.com/hyperledger/fabric-contract-api-go/contractapi#ContractChaincode.Start>`_ 関数を呼び出します。これがチェーンコードプログラムのソース全体です。

.. code:: go

  package main

  import (
    "encoding/json"
    "fmt"
    "log"

    "github.com/hyperledger/fabric-contract-api-go/contractapi"
  )

  // SmartContract provides functions for managing an Asset
     type SmartContract struct {
        contractapi.Contract
      }

  // Asset describes basic details of what makes up a simple asset
     type Asset struct {
        ID             string `json:"ID"`
        Color          string `json:"color"`
        Size           int    `json:"size"`
        Owner          string `json:"owner"`
        AppraisedValue int    `json:"appraisedValue"`
      }

  // InitLedger adds a base set of assets to the ledger
     func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
      assets := []Asset{
        {ID: "asset1", Color: "blue", Size: 5, Owner: "Tomoko", AppraisedValue: 300},
        {ID: "asset2", Color: "red", Size: 5, Owner: "Brad", AppraisedValue: 400},
        {ID: "asset3", Color: "green", Size: 10, Owner: "Jin Soo", AppraisedValue: 500},
        {ID: "asset4", Color: "yellow", Size: 10, Owner: "Max", AppraisedValue: 600},
        {ID: "asset5", Color: "black", Size: 15, Owner: "Adriana", AppraisedValue: 700},
        {ID: "asset6", Color: "white", Size: 15, Owner: "Michel", AppraisedValue: 800},
      }

      for _, asset := range assets {
        assetJSON, err := json.Marshal(asset)
        if err != nil {
          return err
        }

        err = ctx.GetStub().PutState(asset.ID, assetJSON)
        if err != nil {
          return fmt.Errorf("failed to put to world state. %v", err)
        }
      }

      return nil
    }

  // CreateAsset issues a new asset to the world state with given details.
     func (s *SmartContract) CreateAsset(ctx contractapi.TransactionContextInterface, id string, color string, size int, owner string, appraisedValue int) error {
      exists, err := s.AssetExists(ctx, id)
      if err != nil {
        return err
      }
      if exists {
        return fmt.Errorf("the asset %s already exists", id)
      }

      asset := Asset{
        ID:             id,
        Color:          color,
        Size:           size,
        Owner:          owner,
        AppraisedValue: appraisedValue,
      }
      assetJSON, err := json.Marshal(asset)
      if err != nil {
        return err
      }

      return ctx.GetStub().PutState(id, assetJSON)
    }

  // ReadAsset returns the asset stored in the world state with given id.
     func (s *SmartContract) ReadAsset(ctx contractapi.TransactionContextInterface, id string) (*Asset, error) {
      assetJSON, err := ctx.GetStub().GetState(id)
      if err != nil {
        return nil, fmt.Errorf("failed to read from world state: %v", err)
      }
      if assetJSON == nil {
        return nil, fmt.Errorf("the asset %s does not exist", id)
      }

      var asset Asset
      err = json.Unmarshal(assetJSON, &asset)
      if err != nil {
        return nil, err
      }

      return &asset, nil
    }

  // UpdateAsset updates an existing asset in the world state with provided parameters.
     func (s *SmartContract) UpdateAsset(ctx contractapi.TransactionContextInterface, id string, color string, size int, owner string, appraisedValue int) error {
      exists, err := s.AssetExists(ctx, id)
      if err != nil {
        return err
      }
      if !exists {
        return fmt.Errorf("the asset %s does not exist", id)
      }

      // overwriting original asset with new asset
      asset := Asset{
        ID:             id,
        Color:          color,
        Size:           size,
        Owner:          owner,
        AppraisedValue: appraisedValue,
      }
      assetJSON, err := json.Marshal(asset)
      if err != nil {
        return err
      }

      return ctx.GetStub().PutState(id, assetJSON)
    }

    // DeleteAsset deletes an given asset from the world state.
    func (s *SmartContract) DeleteAsset(ctx contractapi.TransactionContextInterface, id string) error {
      exists, err := s.AssetExists(ctx, id)
      if err != nil {
        return err
      }
      if !exists {
        return fmt.Errorf("the asset %s does not exist", id)
      }

      return ctx.GetStub().DelState(id)
    }

  // AssetExists returns true when asset with given ID exists in world state
     func (s *SmartContract) AssetExists(ctx contractapi.TransactionContextInterface, id string) (bool, error) {
      assetJSON, err := ctx.GetStub().GetState(id)
      if err != nil {
        return false, fmt.Errorf("failed to read from world state: %v", err)
      }

      return assetJSON != nil, nil
    }

  // TransferAsset updates the owner field of asset with given id in world state.
     func (s *SmartContract) TransferAsset(ctx contractapi.TransactionContextInterface, id string, newOwner string) error {
      asset, err := s.ReadAsset(ctx, id)
      if err != nil {
        return err
      }

      asset.Owner = newOwner
      assetJSON, err := json.Marshal(asset)
      if err != nil {
        return err
      }

      return ctx.GetStub().PutState(id, assetJSON)
    }

  // GetAllAssets returns all assets found in world state
     func (s *SmartContract) GetAllAssets(ctx contractapi.TransactionContextInterface) ([]*Asset, error) {
  // range query with empty string for startKey and endKey does an
  // open-ended query of all assets in the chaincode namespace.
      resultsIterator, err := ctx.GetStub().GetStateByRange("", "")
      if err != nil {
        return nil, err
      }
      defer resultsIterator.Close()

      var assets []*Asset
      for resultsIterator.HasNext() {
        queryResponse, err := resultsIterator.Next()
        if err != nil {
          return nil, err
        }

        var asset Asset
        err = json.Unmarshal(queryResponse.Value, &asset)
        if err != nil {
          return nil, err
        }
        assets = append(assets, &asset)
      }

      return assets, nil
    }

    func main() {
      assetChaincode, err := contractapi.NewChaincode(&SmartContract{})
      if err != nil {
        log.Panicf("Error creating asset-transfer-basic chaincode: %v", err)
      }

      if err := assetChaincode.Start(); err != nil {
        log.Panicf("Error starting asset-transfer-basic chaincode: %v", err)
      }
    }

Chaincode access control
------------------------

チェーンコードは、 ``ctx.GetStub().GetCreator()`` によって、アクセス制御の決定にクライアント(サブミッタ)証明書を利用することができます。さらに、Fabric Contract APIは、サブミッタの証明書からクライアントアイデンティティを抽出する拡張APIを提供しており、アクセス制御の決定に使用することができます。これは、クライアントアイデンティティ自体や組織アイデンティティ、またはクライアントアイデンティティ属性のいずれに基づくものであってもかまいません。

例えば、キー/値として表されるアセットは、クライアントのアイデンティティを値の一部(例えば、アセットの所有者を示すJSON属性)として含むことができ、このクライアントだけが将来的にキー/値を更新する権限を持つことができます。クライアントアイデンティティライブラリ拡張APIは、チェーンコード内でこのサブミッタ情報を取得して、このようなアクセス制御決定を行うために使用できます。

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
