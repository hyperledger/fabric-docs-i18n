Writing Your First Application
==============================

.. note:: Fabricネットワークの基本的なアーキテクチャにまだ慣れていない場合は、先に進む前に
          :doc:`key_concepts` のセクションを参考にしてください。

          また、このチュートリアルでは、シンプルなスマートコントラクトとアプリケーションを使用してFabricのアプリケーションの概要を説明します。
          Fabricのアプリケーションとスマートコントラクトの詳細については、 :doc:`developapps/developing_applications` セクションまたは :doc:`Commercial Paper Tutorial<tutorial/commercial_paper>` を参照してください。

このチュートリアルでは、Fabricアプリケーションと、デプロイされたブロックチェーンネットワークとのやりとりについて説明します。
Fabric SDKを使用して構築されたサンプル・プログラムを使用します。サンプル・プログラムの詳細については、:doc:`Application</developapps/application>` トピックを参照してください。スマートコントラクトを実行すると、
スマートコントラクトAPIを使用して台帳の参照と更新が行われます。詳細については、 :doc:`Smart Contract Processing</developapps/smartcontract>` を参照してください。
また、サンプル・プログラムとデプロイされたCAを使用して、アプリケーションが許可型のブロックチェーンと接続するために必要なX.509証明書を生成します。

**About FabCar**

FabCarのサンプルでは、台帳に保存された ``Car`` （このサンプルでのビジネスデータ）をクエリする方法と、台帳を更新する（新しい ``Car`` を追加する）方法を示します。
これには、次の2つのコンポーネントが含まれます。

  1.サンプル・アプリケーションはスマートコントラクトに実装されたトランザクションを実行して、ブロックチェーン・ネットワークに接続します。

  2.スマートコントラクトは、台帳とのやりとりを含むトランザクションを実装します。


ここでは、3つの主要なステップを実行します。

  **1. 開発環境の設定**
  このアプリケーションと接続するためのネットワークが必要なので、スマートコントラクトとアプリケーションのための基本的なネットワークをデプロイします。

  .. image:: images/AppConceptsOverview.png

  **2. サンプルのスマートコントラクトを確認**
  サンプルのFabcarスマートコントラクトを調べて、その中のトランザクションと、アプリケーションがトランザクションを使用して台帳にクエリしたり、更新したりする方法について学習します。

  **3. サンプルアプリケーションを利用してスマートコントラクトを操作**
  このアプリケーションでは、FabCarスマートコントラクトを使用して、台帳に記録された自動車アセットへのクエリと更新を行います。
 ここでは、ある自動車のクエリ、全ての自動車のクエリ、新しい自動車の作成など、アプリケーションのコードとそのアプリケーションが作成するトランザクションについて説明します。

このチュートリアルを完了すると、ブロックチェーンネットワークの分散台帳上のデータを管理するために、Fabricアプリケーションとスマートコントラクトがどのように連携して動作するのかについて、基本的な理解が得られます。

Before you begin
----------------

このチュートリアルでは、Fabricの :doc:`標準的なソフトウェア <prereqs>` に加えて、Hyperledger Fabric SDK for Node.jsを活用します。
前提条件の最新リストについては、Node.js SDK `README <https://github.com/hyperledger/fabric-sdk-node#build-and-test>`__ を参照してください。

- もしあなたがmacOSを使用している場合は、次の手順を実行します。

  1. `Homebrew <https://brew.sh/>`__ をインストールしてください。
  2. インストールするNode SDKのバージョンを確認するには、Node SDK `prerequisites <https://github.com/hyperledger/fabric-sdk-node#build-and-test>`__ をチェックしてください。
  3. ``brew install node`` を実行して、nodeの最新バージョンをダウンロードするか、または特定のバージョンを選択します。たとえば、前提条件でサポートされている内容に応じて、``brew install node@10`` を実行します。
  4. ``npm install`` を実行してください。

- Windowsの場合は、以下のnpmコマンドで、必要なコンパイラとツールである `windows-build-tools <https://github.com/felixrieseberg/windows-build-tools#readme>`__ をインストールできます。

  .. code:: bash

    npm install --global windows-build-tools

- Linuxを使っている場合、`Python v2.7 <https://www.python.org/download/releases/2.7/>`__ 、`make <https://www.gnu.org/software/make/>`__ 、そして `GCC <https://gcc.gnu.org/>`__ のようなC/C++コンパイラツールをインストールする必要があります。

  .. code:: bash

    sudo apt install build-essentials

Set up the blockchain network
-----------------------------

既に :doc:`Using the Fabric test network<test_network>` を実行していて、ネットワークを起動して実行している場合、このチュートリアルは新しいネットワークを起動する前に、実行中のネットワークを停止します。


Launch the network
^^^^^^^^^^^^^^^^^^

.. note:: このチュートリアルでは、FabCarスマートコントラクトとアプリケーションのJavaScriptバージョンで紹介しますが、 ``fabric-samples`` リポジトリには、このサンプルのGo、Java、TypeScriptバージョンも含まれています。
Go、Java、またはTypeScriptのバージョンを試すには、下記の ``./startFabric.sh`` の ``javascript`` 引数を ``go`` 、``java`` 、または ``typescript`` に変更し、ターミナルに表示された指示に従ってください。

ローカルの ``fabric-samples`` リポジトリの ``fabcar`` サブディレクトリに移動します。

.. code:: bash

  cd fabric-samples/fabcar

``startFabric.sh`` シェルスクリプトを使ってネットワークを起動します。

.. code:: bash

  ./startFabric.sh javascript

このコマンドは、2つのピアと1つのOrdering Serviceで構成されたFabricテストネットワークをデプロイします。
cryptogen toolを使用する代わりに、CAを使用してテストネットワークを起動します。
これらのCAを使用して、今後の手順でアプリケーションで使用する証明書と暗号鍵を作成します。
``startFabric.sh`` スクリプトはチャネル ``mychannel`` 上のFabCarスマートコントラクトのJavaScriptバージョンをデプロイして初期化し、スマートコントラクトを実行して初期データを台帳に記録します。

Sample application
^^^^^^^^^^^^^^^^^^
FabCarのサンプル・アプリケーションは、次の言語で使用できます。

- `Golang <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/fabcar/go>`__
- `Java <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/fabcar/java>`__
- `JavaScript <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/fabcar/javascript>`__
- `Typescript <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/fabcar/typescript>`__

このチュートリアルでは、nodejs用に ``javascript`` で書かれたサンプルアプリケーションについて説明します。

``fabric-samples/fabcar`` ディレクトリから ``javascript`` ディレクトリに移動します。

.. code:: bash

  cd javascript

このディレクトリには、Fabric SDK for Node.jsを使用して開発されたサンプルプログラムが格納されています。
次のコマンドを実行して、アプリケーションの実行に必要なモジュールをインストールします。完了までに約1分かかります。

.. code:: bash

  npm install

このプロセスは、 ``package.json`` で定義されたアプリケーションに必要なモジュールをインストールします。
その中で最も重要なのは ``fabric-network`` クラスです。このクラスを使用すると、アプリケーションはアイデンティティ、ウォレット、ゲートウェイを使用してチャネルに接続し、トランザクションを送信し、実行結果を待ちます。
また、このチュートリアルでは、 ``fabric-ca-client`` クラスを使用してユーザをそれぞれのCAに登録し、 ``fabric-network`` クラスメソッドで使用される有効なアイデンティティを生成します。

``npm install`` が完了すると、アプリケーションを実行するためのすべての準備が整います。
このチュートリアルで使用するサンプルのJavaScriptアプリケーションのファイルを見てみましょう。

.. code:: bash

  ls

次のように表示されます。

.. code:: bash

  enrollAdmin.js  node_modules       package.json  registerUser.js
  invoke.js       package-lock.json  query.js      wallet

他のプログラム言語用のファイル同様に格納されています。例えば ``fabcar/java`` ディレクトリにあります。
JavaScriptの例を理解できれば、他の言語も原則は同じです。

Enrolling the admin user
------------------------

.. note:: 次の2つのセクションでは、CAとの通信について説明します。
          新しいターミナルを開いて ``docker logs -f ca_org1`` を実行することで、今後のプログラムを実行する際にCAログをストリームすることができて便利です。

ネットワークを作った時、管理者ユーザー（ ``admin`` と呼ばれる）が認証局（CA）の **登録管理者（Register）** として作られました。
最初のステップは、 ``enroll.js`` プログラムを使って、 ``admin`` 用の秘密鍵、公開鍵、X.509証明書を生成することです。
このプロセスでは、**Certificate Signing Request** （CSR）が使用されます。
まず、秘密鍵と公開鍵がローカルで生成され、公開鍵がCAに送信されます。CAは、アプリケーションで使用するためにエンコードされた証明書を返します。
これらの認証情報はウォレットに格納され、CAの管理者として機能できるようになります。

``admin`` ユーザーをenrollします。

.. code:: bash

  node enrollAdmin.js

このコマンドは、CAの管理者の認証情報を ``wallet`` ディレクトリに保存します。
管理者の証明書と秘密鍵は ``wallet/admin.id`` ファイルにあります。

Register and enroll an application user
---------------------------------------

``admin`` ユーザーは、CAの作業に使用します。
ウォレットに管理者の認証情報が入ったので、ブロックチェーンネットワークに接続する際に使用するアプリケーション・ユーザーを新しく作成できます。
次のコマンドを実行して、 ``appUser`` という名前の新規ユーザーを登録します。

.. code:: bash

  node registerUser.js

管理者ユーザーの登録と同様に、このプログラムはCSRを使用して ``appUser`` を登録し、その認証情報を ``admin`` の認証情報と一緒にウォレットに格納します。
これで、 ``admin`` と ``appUser`` という2つの別々のユーザーができました。これらのアイデンティティは、アプリケーションで使用できます。

Querying the ledger
-------------------

ブロックチェーンネットワーク内の各ピアは `台帳 <./ledger/ledger.html>`__ をホストします。
アプリケーション・プログラムは、クエリと呼ばれる、ピアで実行されているスマートコントラクトの読み取り専用の呼び出しによって、台帳から最新のデータを表示できます。

以下に、クエリの動作を簡略化して示します。

.. image:: tutorial/write_first_app.diagram.1.png

最も一般的なクエリは、台帳内のデータの現在の値、その `ワールドステート <./ledger/ledger.html#world-state>`__ を取得します。
ワールドステートはキーと値のペアのセットとして記録され、アプリケーションは単一のキーまたは複数のキーのデータを用いてクエリできます。
さらに、ステートデータベースとしてCouchDBを使用し、データをJSONでモデル化すると、複雑なクエリを使用して台帳のデータを読み取ることができます。
これは、特定の値を持つ特定のキーワードに一致するすべてのアセット（例えば、特定のオーナーを持つすべての車）を検索する場合に非常に便利です。

まず、 ``query.js`` プログラムを実行して、台帳にあるすべての車のリストを取得します。このプログラムは、台帳にアクセスするために二つ目のアイデンティティである ``appUser`` を使用して台帳にアクセスします。

.. code:: bash

  node query.js

結果は次のようになります。

.. code:: json

  Wallet path: ...fabric-samples/fabcar/javascript/wallet
  Transaction has been evaluated, result is:
  [{"Key":"CAR0","Record":{"color":"blue","docType":"car","make":"Toyota","model":"Prius","owner":"Tomoko"}},
  {"Key":"CAR1","Record":{"color":"red","docType":"car","make":"Ford","model":"Mustang","owner":"Brad"}},
  {"Key":"CAR2","Record":{"color":"green","docType":"car","make":"Hyundai","model":"Tucson","owner":"Jin Soo"}},
  {"Key":"CAR3","Record":{"color":"yellow","docType":"car","make":"Volkswagen","model":"Passat","owner":"Max"}},
  {"Key":"CAR4","Record":{"color":"black","docType":"car","make":"Tesla","model":"S","owner":"Adriana"}},
  {"Key":"CAR5","Record":{"color":"purple","docType":"car","make":"Peugeot","model":"205","owner":"Michel"}},
  {"Key":"CAR6","Record":{"color":"white","docType":"car","make":"Chery","model":"S22L","owner":"Aarav"}},
  {"Key":"CAR7","Record":{"color":"violet","docType":"car","make":"Fiat","model":"Punto","owner":"Pari"}},
  {"Key":"CAR8","Record":{"color":"indigo","docType":"car","make":"Tata","model":"Nano","owner":"Valeria"}},
  {"Key":"CAR9","Record":{"color":"brown","docType":"car","make":"Holden","model":"Barina","owner":"Shotaro"}}]

``query.js`` プログラムが、 `Fabric Node SDK <https://hyperledger.github.io/fabric-sdk-node/>`__ によって提供されるAPIを使用して、Fabricネットワークに接続する方法を詳しく見てみましょう。
エディタ（例えばatomやvisual studio）を使って ``query.js`` を開きます。

アプリケーションは、 ``fabric-network`` モジュールから主要なクラス、 ``Wallets`` と ``Gateway`` を読み込むところから始まります。
これらのクラスは、ウォレット内の ``appUser`` アイデンティティを見つけ、それを使用してネットワークに接続するために使用されます。

.. code:: bash

  const { Gateway, Wallets } = require('fabric-network');

まず、プログラムはWalletクラスを使用して、ファイル・システムからアプリケーション・ユーザーを取得します。

.. code:: bash

  const identity = await wallet.get('appUser');

プログラムがアイデンティティを取得すると、Gatewayクラスを使用してネットワークに接続します。

.. code:: bash

  const gateway = new Gateway();
  await gateway.connect(ccpPath, { wallet, identity: 'appUser', discovery: { enabled: true, asLocalhost: true } });

``ccpPath`` は、アプリケーションがネットワークに接続するために使用するコネクションプロファイルへのパスを記述します。
コネクションプロファイルは ``fabric-samples/test-network`` ディレクトリ内からロードされ、JSON形式で記述されています。

.. code:: bash

  const ccpPath = path.resolve(__dirname, '..', '..', 'test-network','organizations','peerOrganizations','org1.example.com', 'connection-org1.json');

コネクションプロファイルの構造や、どのようにネットワークを定義するのかをもっと知りたい場合は、 `the connection profile topic <./developapps/connectionprofile.html>`__ を見てください。

ネットワークは複数のチャネルに分割することができ、次のコードでアプリケーションをネットワーク内の特定のチャネル ``mychannel`` に接続します。 ``mychannel`` はスマートコントラクトがデプロイされています。

.. code:: bash

  const network = await gateway.getNetwork('mychannel');

このチャネルでは、FabCarスマートコントラクトにアクセスして台帳とやりとりできます。

.. code:: bash

  const contract = network.getContract('fabcar');

FabCar内には多くの **トランザクション** があります。アプリケーションは最初に台帳のワールドステートデータにアクセスするために ``queryAllCars`` トランザクションを使用します。

.. code:: bash

  const result = await contract.evaluateTransaction('queryAllCars');

``evaluateTransaction`` メソッドは、ブロックチェーンネットワークにおけるスマートコントラクトとの最もシンプルなやりとりをするメソッドの1つです。
単純に、コネクションプロファイルに定義されているピアを選択してリクエストを送信し、そこで実行されます。
スマートコントラクトは、ピアの台帳にあるすべての車を取得し、その結果をアプリケーションに返します。
この操作によって台帳が更新されることはありません。

The FabCar smart contract
-------------------------
FabCarスマートコントラクトのサンプルは、次の言語で利用できます。

- `Golang <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/fabcar/go>`__
- `Java <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/fabcar/java>`__
- `JavaScript <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/fabcar/javascript>`__
- `Typescript <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/fabcar/typescript>`__

JavaScriptで書かれたFabCarスマートコントラクトの中身を見てみましょう。
新しいターミナルを開き、 ``fabric-samples`` リポジトリ内のFabCarスマートコントラクトのJavaScriptに移動します。

.. code:: bash

  cd fabric-samples/chaincode/fabcar/javascript/lib

``fabcar.js`` ファイルをテキストエディタで開きます。

``Contract`` クラスを使用してスマートコントラクトがどのように定義されるかを見てください。

.. code:: bash

  class FabCar extends Contract {...

このクラスでは、 ``initLedger`` 、 ``queryCar`` 、 ``queryAllCars`` 、 ``createCar`` 、 ``changeCarOwner`` のトランザクションが定義されていることがわかります。
次に例を示します。

.. code:: bash

  async queryCar(ctx, carNumber) {...}
  async queryAllCars(ctx) {...}

``queryAllCars`` がどのように台帳とやりとりするかを見てみましょう。

.. code:: bash

  async queryAllCars(ctx) {

    const startKey = '';
    const endKey = '';

    const iterator = await ctx.stub.getStateByRange(startKey, endKey);


このコードは、 ``getStateByRange`` を使用して台帳からキー範囲内のすべての自動車を検索する方法を示しています。
空のstartKeyとendKeyを指定すると、最初から最後までのすべてのキーとして解釈されます。
別の例として、もしあなたが ``startKey='CAR0',endKey='CAR999'`` を使用するなら、 ``getStateByRange`` は ``CAR0`` と ``CAR999`` の間のキー（ただし ``CAR0`` を含み ``CAR999`` は含まない）を持つ車を辞書順で検索します。
コードの残りの部分はクエリの結果を繰り返し処理し、サンプル・アプリケーションが使用するJSON形式でパッケージ化します。

以下は、アプリケーションがスマートコントラクト内のトランザクションを呼び出す方法を示します。
それぞれのトランザクションは、 ``getStateByRange`` のような幅広いAPIセットを使用して台帳に接続します。
これらのAPIの詳細については、`detail <https://hyperledger.github.io/fabric-chaincode-node/>`__ を参照してください。

.. image:: images/RunningtheSample.png

``queryAllCars`` トランザクションと ``createCar`` と呼ばれるトランザクションがあります。
このチュートリアルの後半では、これを使用して台帳を更新し、新しいブロックをブロックチェーンに追加します。

しかし、まず ``query`` プログラムに戻り、 ``evaluateTransaction`` のリクエストを ``CAR4`` のクエリに変更します。
``query`` プログラムは次のようになります。

.. code:: bash

  const result = await contract.evaluateTransaction('queryCar', 'CAR4');

プログラムを保存し、 ``fabcar/javascript`` ディレクトリに戻ります。
``query`` プログラムをもう一度実行します。

.. code:: bash

  node query.js

次のような結果になります。

.. code:: json

  Wallet path: ...fabric-samples/fabcar/javascript/wallet
  Transaction has been evaluated, result is:
  {"color":"black","docType":"car","make":"Tesla","model":"S","owner":"Adriana"}

``queryAllCars`` を実行した時の結果を見てみると、 ``CAR4`` はAdrianaの黒いTeslaモデルSであり、ここに返された結果であることがわかります。
``queryCar`` トランザクションを使用すると、そのキー( ``CAR0`` など)を使用して任意の自動車をクエリし、その自動車に対応するメーカー、モデル、色、所有者を取得できます。

ここまでで、スマートコントラクトの基本的な操作といくつかのパラメーターに慣れているはずです。

今度は台帳を更新しましょう。

Updating the ledger
-------------------

これで、いくつかのクエリを実行し、少しコードを追加したので、台帳を更新する準備ができました。最初に **新しい** 自動車を作成しましょう。

アプリケーションの観点から見ると、台帳の更新は簡単です。
アプリケーションは、トランザクションをブロックチェーンネットワークに送信し、トランザクションが検証されてコミットされると、トランザクションが成功したという通知を受け取ります。
これには **合意形成** のプロセスが含まれ、ブロックチェーンネットワークのさまざまなコンポーネントが連携して、提案された台帳の更新がすべて有効で、一貫した順序で実行されるようにします。

.. image:: tutorial/write_first_app.diagram.2.png

上の図は、このプロセスを機能させる主なコンポーネントを示しています。
ネットワークはそれぞれ台帳とスマートコントラクトをホストする複数のピアと同様にOrdering Serviceも含まれています。
Ordering Serviceは、ネットワークのトランザクションを調整します。
このサービスは、ネットワークに接続されたすべての異なるアプリケーションから発信され定義されたシーケンスのトランザクションを含んだブロックを作成します。

最初に台帳を更新すると、新しい車が作成されます。
``invoke.js`` という別のプログラムがあり、これを使用して台帳を更新します。
クエリと同様に、エディタを使用してプログラムを開き、トランザクションを構築してネットワークに送信するコードブロックまで移動します。

.. code:: bash

  await contract.submitTransaction('createCar', 'CAR12', 'Honda', 'Accord', 'Black', 'Tom');

アプリケーションがスマートコントラクト・トランザクションを ``createCar`` トランザクションを実行し、Tomというオーナーの黒いHonda Accordの車を作成する様子を見てください。
ここでは、 ``CAR12`` を識別キーとして使用します。これは、連続したキーを使用する必要がないことを示すためです。

保存してプログラムを実行します。

.. code:: bash

  node invoke.js

実行が成功すると、次のように表示されます。

.. code:: bash

  Wallet path: ...fabric-samples/fabcar/javascript/wallet
  Transaction has been submitted

``invoke`` アプリケーションが ``evaluateTransaction`` ではなく ``submitTransaction`` APIを使ってブロックチェーンネットワークとどのように相互接続したかに注目してください。

.. code:: bash

  await contract.submitTransaction('createCar', 'CAR12', 'Honda', 'Accord', 'Black', 'Tom');

``submitTransaction`` は ``evaluateTransaction`` よりも洗練されています。
SDKは、単一のピアと接続するのではなく、ブロックチェーンネットワーク内のすべての必要な組織のピアに ``submitTransaction`` の提案を送信します。
これらの各ピアは、この提案を使用して要求されたスマートコントラクトを実行し、トランザクションレスポンスを生成し、それに署名してSDKに返します。
SDKは、すべての署名されたトランザクションレスポンスを1つのトランザクションに集約し、それをOrdererに送信します。
Ordererは、すべてのアプリケーションからトランザクションを収集し、トランザクションのブロックに順序付けします。
次に、これらのブロックがネットワーク内のすべてのピアに配布され、すべてのトランザクションが検証されてコミットされます。
最後に、SDKに通知され、アプリケーションに制御を戻すことができます。

.. note:: ``submitTransaction`` には、トランザクションが検証され、台帳にコミットされたことを確認するリスナーも含まれています。
アプリケーションはコミット・リスナーを使用するか、 ``submitTransaction`` のようなAPIを利用してこれを行う必要があります。
これを行わないと、取引が正常に検証および台帳へのコミットが正常に行われない場合があります。

``submitTransaction`` はアプリケーションのためにこれらすべてを行います。
アプリケーション、スマートコントラクト、ピア、およびOrdering Serviceが連携してネットワーク全体で一貫性のある台帳を維持するプロセスは、
合意形成と呼ばれ、こちらの `セクション <./peers/peers.html>`__ で詳細に説明されています。

このトランザクションが台帳に書き込まれたことを確認するには、 ``query.js`` に戻り、引数を ``CAR4`` から ``CAR12`` に変更します。

つまり、次のように変更します。

.. code:: bash

  const result = await contract.evaluateTransaction('queryCar', 'CAR4');

変更後

.. code:: bash

  const result = await contract.evaluateTransaction('queryCar', 'CAR12');

もう一度保存し、クエリを実行します。

.. code:: bash

  node query.js

次のような結果が表示されます。

.. code:: bash

  Wallet path: ...fabric-samples/fabcar/javascript/wallet
  Transaction has been evaluated, result is:
  {"color":"Black","docType":"car","make":"Honda","model":"Accord","owner":"Tom"}

おめでとうございます。車を作成し、その車が台帳に記録されていることを確認しました。

Tomが寛大な気持ちで、HondaのAccordをDaveという人にあげたいとしましょう。

これを行うには、 ``invoke.js`` に戻り、スマートコントラクトトランザクションを ``createCar`` から ``changeCarOwner`` に変更し、対応する引数を変更します。

.. code:: bash

  await contract.submitTransaction('changeCarOwner', 'CAR12', 'Dave');

最初の引数 ``CAR12`` は、所有者を変更する車を識別します。
2番目の引数は ``Dave`` は、車の新しい所有者を定義します。

プログラムを保存して再度実行します。

.. code:: bash

  node invoke.js

次に、台帳を再度クエリし、Daveが ``CAR12`` キーに関連付けられていることを確認します。

.. code:: bash

  node query.js

次の結果が返されます。

.. code:: bash

   Wallet path: ...fabric-samples/fabcar/javascript/wallet
   Transaction has been evaluated, result is:
   {"color":"Black","docType":"car","make":"Honda","model":"Accord","owner":"Dave"}

``CAR12`` のオーナーがTomからDaveに変わりました。

.. note::	実際のアプリケーションでは、スマートコントラクトは何らかのアクセス制御ロジックを持っています。
          たとえば、特定の認可されたユーザだけが新しい車を作成でき、車の所有者だけが車を他の誰かに譲渡できます。

Clean up
--------

FabCarのサンプルを使い終わったら、 ``networkDown.sh`` スクリプトを使ってテストネットワークを停止することができます。


.. code:: bash

  ./networkDown.sh

このコマンドは、作成したネットワークのCA、ピア、およびOrdererノードを停止します。
また、 ``wallet`` ディレクトリに保存されている ``admin`` と ``appUser`` の認証情報も削除されます。
台帳のすべてのデータが削除されることに注意してください。

チュートリアルを再度実行する場合は、クリーンな初期状態から開始します。

Summary
-------

これまでにいくつかのクエリと更新を行ってきました。
スマートコントラクトを使用してアプリケーションがブロックチェーンネットワークがやりとりし、台帳をクエリまたは更新する方法については、かなり理解しているはずです。
スマートコントラクト、API、そしてSDKがクエリや更新で果たす役割の基本を見てきました。そしてあなたはさまざまな種類のアプリケーションを使用して、他のビジネスタスクや操作を実行する方法を理解する必要があります。

Additional resources
--------------------

導入部で述べたように、:doc:`Developing Application <developapps/developing_applications>` のセクション全体には、スマートコントラクト、プロセス、データ設計に関する詳細な情報、
より詳細な `Commercial Paper Tutorial <./tutorial/commercial_paper.html>`__ を使ったチュートリアル、そしてアプリケーションの開発に関するその他の多くの情報が含まれています。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
