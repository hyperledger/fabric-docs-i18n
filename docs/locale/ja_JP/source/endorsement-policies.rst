Endorsement policies
====================

すべてのチェーンコードはエンドースメントポリシーを持っています。
エンドースメントポリシーは、トランザクションが有効かどうかを判断するために、チェーンコードの実行と実行結果のエンドースを行う必要があるチャネル上のピアのセットを指定します。
エンドースポリシーは、ピアを経由して提案の実行を "エンドース" (つまり、承認)しなければならない組織群を定義します。

.. note :: キーバリューペアで表現される **ステート** は、ブロックチェーンのデータとは別物であることを思い出してください。
           この点については、 :doc:`ledger/ledger` を確認してください。

ピアによって実行されるトランザクション検証ステップの一部として、
各検証ピアは、トランザクションが適切な **数** のエンドースメントを含み、
それらが期待されるソースからのものであることを確認します(これらは両方ともエンドースメントポリシーで指定されます)。
また、エンドースメントが有効であること(つまり、有効な証明書からの有効な署名であること)も確認されます。

Multiple ways to require endorsement
------------------------------------

デフォルトでは、エンドースメントポリシーはチェーンコード定義で指定され、
チャネルメンバーによって同意されてからチャネルにコミットされます
(つまり、1つのエンドースメントポリシーが1つのチェーンコード内の全てのステートをカバーします)。

プライベートデータコレクションの場合は、プライベートデータコレクションのレベルでエンドースメントポリシーを指定することもできます。
これにより、プライベートデータコレクション内の任意のキーに対するチェーンコードレベルのエンドースメントポリシーが上書きされ、
プライベートデータコレクションに書き込みができる組織が制限されます。

最後に、パブリックチャネルの特定のステート、または、プライベートデータコレクションの特定のステート(つまり、特定のキーバリューペア)に対して、独自のエンドースメントポリシーが必要な場合があります。
**state-based endorsement** は、指定されたキーに対する独自のポリシーで、チェーンコードレベルまたはコレクションレベルのエンドースメントポリシーを上書きします。

さまざまな種類のエンドースメントポリシーが使われる状況を説明するために、車が取引されるチャネルを考えてみましょう。
車を取引可能な資産として"発行"(つまり、車を表すキーバリューペアをワールドステートに格納)するには、
チェーンコードレベルのエンドースメントポリシーを満たす必要があります。
チェーンコードレベルのエンドースメントポリシーの設定方法については、以下のセクションを参照してください。

車を表すキーに特定のエンドースメントポリシーが必要な場合は、車の作成時または作成後に定義できます。
特定のキーに対するエンドースメントポリシーの設定が必要または望ましい理由はいくつかあります。
ある車が歴史的な重要性や価値を持つ場合、ライセンスを持っている鑑定人のエンドースメントが必要です。
また、車の所有者(チャネルのメンバーである場合)が、自分のピアがトランザクションに署名したことを確認したい場合があります。
どちらの場合も、 **特定の資産に対して、チェーンコードの他の資産に対するデフォルトのエンドースメントポリシーとは異なるエンドースメントポリシーが必要です。**

state-basedエンドースメントポリシーを定義する方法については、次のセクションで説明します。
最初に、チェーンコードレベルのエンドースメントポリシーを設定する方法を見てみましょう。

Setting chaincode-level endorsement policies
--------------------------------------------

チェーンコードレベルのエンドースメントポリシーは、チャネルメンバーが組織のチェーンコード定義を承認するときに、チャネルメンバーによって合意されます。
チェーンコード定義をチャネルにコミットするには、 ``Channel/Application/LifecycleEndorsement`` ポリシーを満たす十分な数のチャネルメンバーが定義を承認する必要があります。
デフォルト設定では、過半数のチャネルメンバーの承認が必要です。
定義がコミットされると、そのチェーンコードは使用できる状態になります。
データを台帳に書き込むチェーンコードの呼び出しは、エンドースメントポリシーを満たす十分な数のチャネルメンバーによって検証される必要があります。

CLIでエンドースメントポリシーを作成できます。
Fabricピアバイナリでチェーンコード定義を承認およびコミットするとき、
``--signature-policy`` フラグを使用します。

.. note:: 現時点で、ポリシーの構文 (``'Org1.member'`` など) は気にしないでください。
          構文については、次のセクションで詳しく説明します。

次に例を示します。

::

    peer lifecycle chaincode approveformyorg --channelID mychannel --signature-policy "AND('Org1.member', 'Org2.member')" --name mycc --version 1.0 --package-id mycc_1:3a8c52d70c36313cfebbaf09d8616e7a6318ababa01c7cbe40603c373bcfe173 --sequence 1 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --waitForEvent

上記のコマンドは、 ``mycc`` のチェーンコード定義に対して、
Org1とOrg2の両方のメンバがトランザクションに署名することを要求する ``AND('Org1.member', 'Org2.member')`` というポリシーを設定します。
十分な数のチャネルメンバが ``mycc`` のチェーンコード定義を承認後、次のコマンドを使用して、その定義とエンドースメントポリシーをチャネルにコミットできます。

::

    peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID mychannel --signature-policy "AND('Org1.member', 'Org2.member')" --name mycc --version 1.0 --sequence 1 --init-required --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --waitForEvent --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

アイデンティティ分類が有効になっている場合( :doc:`msp` を参照)、
``PEER`` ロールを使用して、エンドースメントをピアだけに制限できます。

次に例を示します。


::

    peer lifecycle chaincode approveformyorg --channelID mychannel --signature-policy "AND('Org1.peer', 'Org2.peer')" --name mycc --version 1.0 --package-id mycc_1:3a8c52d70c36313cfebbaf09d8616e7a6318ababa01c7cbe40603c373bcfe173 --sequence 1 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --waitForEvent

CLIまたはSDKからエンドースメントポリシーを指定する方法に加えて、チャネル設定のポリシーをチェーンコードのエンドースメントポリシーとして使用することもできます。
``--channel-config-policy`` フラグを使用すると、チャネル設定およびACLで使用されるフォーマットでチャネルポリシーを選択できます。

次に例を示します。

::

    peer lifecycle chaincode approveformyorg --channelID mychannel --channel-config-policy Channel/Application/Admins --name mycc --version 1.0 --package-id mycc_1:3a8c52d70c36313cfebbaf09d8616e7a6318ababa01c7cbe40603c373bcfe173 --sequence 1 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --waitForEvent

ポリシーを指定しない場合、チェーンコード定義はデフォルトで ``Channel/Application/Endorsement`` ポリシーを使用します。
これは、トランザクションが過半数のチャネルメンバによって検証されることを要求します。
このポリシーはチャネルのメンバーシップに依存するため、組織がチャネルに追加または削除されると、ポリシーが自動的に更新されます。
チャネルポリシーを使用する利点の1つは、ポリシーがチャネルメンバーシップに合わせて自動更新されるように記述できることです。

``--signature-policy`` フラグを使用してエンドースメントポリシーを指定した場合、組織がチャネルに参加または脱退するときにポリシーを更新する必要があります。
チェーンコードが定義された後にチャネルに追加された新しい組織は、チェーンコードをクエリできます(そのクエリが、チャネルポリシーによって定義された適切な認証と、チェーンコードに定義されたアプリケーションレベルのチェックを通っている場合)。
しかし、その新しい組織は、チェーンコードを実行またはエンドースすることはできません。
エンドースメントポリシー構文に記載された組織のみが、トランザクションに署名できます。

Endorsement policy syntax
~~~~~~~~~~~~~~~~~~~~~~~~~

前述のように、ポリシーはプリンシパル("プリンシパル"はロールに一致するID)で表されます。
プリンシパルは ``'MSP.ROLE'`` と記述されます。
ここで、 ``MSP`` は必須のMSP IDを表し、 ``ROLE`` は ``member`` 、 ``admin`` 、 ``client`` 、 ``peer`` の4つのロールのいずれかを表します。

有効なプリンシパルの例を次に示します。

   -  ``'Org0.admin'``: ``Org0`` MSPの全ての管理者
   -  ``'Org1.member'``: ``Org1`` MSPのすべてのメンバー
   -  ``'Org1.client'``: ``Org1`` MSPの全てのクライアント
   -  ``'Org1.peer'``: ``Org1`` MSPの全てのピア

言語の構文は次のとおりです。

``EXPR(E[, E...])``

ここで、 ``EXPR`` は ``AND`` 、 ``OR`` または ``OutOf`` のいずれかであり、
``E`` はプリンシパル(上記の構文を使用)または別のネストされた ``EXPR`` への参照です。

次に例を示します。
  - ``AND('Org1.member', 'Org2.member', 'Org3.member')``
    3つのプリンシパルそれぞれから1つの署名が必要。
  - ``OR('Org1.member', 'Org2.member')``
    2つのプリンシパルのいずれか1つから1つの署名が必要。
  - ``OR('Org1.member', AND('Org2.member', 'Org3.member'))``
    ``Org1`` MSP のメンバーから1つの署名、または、
    ``Org2`` MSP のメンバーからの1つの署名と ``Org3`` MSPのメンバーからの1つの署名が必要。
  - ``OutOf(1, 'Org1.member', 'Org2.member')``
    ``OR('Org1.member', 'Org2.member')`` と同じことを意味します。
  - 同様に、 ``OutOf(2, 'Org1.member', 'Org2.member')`` は
    ``AND('Org1.member', 'Org2.member')`` と同じで、 ``OutOf(2, 'Org1.member',
    'Org2.member', 'Org3.member')`` は ``OR(AND('Org1.member',
    'Org2.member'), AND('Org1.member', 'Org3.member'), AND('Org2.member',
    'Org3.member'))`` と同じ。

Setting collection-level endorsement policies
---------------------------------------------
チェーンコードレベルのエンドースメントポリシーと同様に、チェーンコード定義を承認してコミットするときに、
チェーンコードのプライベートデータコレクションとそれに対応するコレクションレベルのエンドースメントポリシーを指定できます。
コレクションレベルのエンドースメントポリシーが設定されている場合、
プライベートデータコレクションのキーに書き込みをするトランザクションは、指定された組織のピアからのエンドースが必要です。

コレクションレベルのエンドースメントポリシーを使用すると、どの組織のピアがプライベートデータコレクションのネームスペースに書き込むことができるかを制限できます。
たとえば、許可されていない組織がコレクションに書き込めないようにしたり、
プライベートデータコレクション内の任意のステートがそのコレクションに必要な組織によってエンドースされていることを確認したりできます。

コレクションレベルのエンドースメントポリシーは、チェーンコードレベルのエンドースメントポリシー、
および、そのコレクションのプライベートデータ配布ポリシーに比べて、制限が少ない場合と制限が多い場合があります。
たとえば、チェーンコードトランザクションをエンドースするには過半数の組織が必要ですが、
特定のコレクション内のキーを含むトランザクションをエンドースするには特定の組織が必要かもしれません。

コレクションレベルのエンドースメントポリシーの構文は、チェーンコードレベルのエンドースメントポリシーの構文と全て同じです。
コレクション設定では、 ``signaturePolicy`` または ``channelConfigPolicy`` のいずれかで ``endorsementPolicy`` を指定できます。
詳細については、:doc:`private-data-arch` を参照してください。

.. _key-level-endorsement:

Setting key-level endorsement policies
--------------------------------------

通常のチェーンコードレベルまたはコレクションレベルのエンドースメントポリシーの設定は、
対応するチェーンコードのライフサイクルに関連付けられます。
これらは、チャネル上でチェーンコードを定義する場合にのみ設定または変更できます。

一方で、キーレベルのエンドースメントポリシーは、チェーンコード内から、より細かい粒度で設定および変更できます。
変更は、通常のトランザクションの読み書きセットの一部です。

shim API は、キーに対するエンドースメントポリシーの設定と取得を行う以下の関数を提供します。

.. note:: これ以降、 ``ep`` は "エンドースメントポリシー" を意味します。
          エンドースメントポリシーは、これまでの説明と同じ構文、
          または、以下で説明する簡易関数のいずれかで表現できます。
          どちらの方法もshim APIが利用するバイナリ形式のエンドースメントポリシーを生成します。

.. code-block:: Go

    SetStateValidationParameter(key string, ep []byte) error
    GetStateValidationParameter(key string) ([]byte, error)

キーがコレクション内の :doc:`private-data/private-data` の一部である場合、以下の関数が適用されます。

.. code-block:: Go

    SetPrivateDataValidationParameter(collection, key string, ep []byte) error
    GetPrivateDataValidationParameter(collection, key string) ([]byte, error)

エンドースメントポリシーを設定し、検証パラメータのbyte配列にマーシャリングすることを支援するため、
チェーンコード開発者が各組織のMSP IDでエンドースメントポリシーを扱えるようにする簡易関数を備えた拡張機能をGo shimが提供します。
詳しくは、 `KeyEndorsementPolicy <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/pkg/statebased#KeyEndorsementPolicy>`_ を参照。

.. code-block:: Go

    type KeyEndorsementPolicy interface {
        // Policy returns the endorsement policy as bytes
        Policy() ([]byte, error)

        // AddOrgs adds the specified orgs to the list of orgs that are required
        // to endorse
        AddOrgs(roleType RoleType, organizations ...string) error

        // DelOrgs delete the specified channel orgs from the existing key-level endorsement
        // policy for this KVS key. If any org is not present, an error will be returned.
        DelOrgs(organizations ...string) error

        // ListOrgs returns an array of channel orgs that are required to endorse changes
        ListOrgs() ([]string)
    }

たとえば、特定の2つの組織からのエンドースが必要なキーに対してエンドースメントポリシーを設定する場合、
両方の組織の ``MSPIDs`` を ``AddOrgs()`` に渡し、
``Policy()`` を呼んでエンドースメントポリシーのbyte配列を生成し、
そのbyte配列を ``SetStateValidationParameter()`` に渡します。

shim拡張をチェーンコードの依存性に追加する方法については、 :ref:`vendoring` を参照してください。

Validation
----------

コミット時にキーの値を設定することは、キーのエンドースメントポリシーを設定することと何の違いもありません。
どちらもキーの状態を更新し、同じルールに基づいて検証されます。

+----------------------+------------------------------------------------+-------------------------+
| 検証                 | 検証パラメータなし                             | 検証パラメータあり      |
+======================+================================================+=========================+
| 値を更新             | チェーンコードまたはコレクションのepをチェック | キーレベルepをチェック  |
+----------------------+------------------------------------------------+-------------------------+
| キーレベルのepを更新 | チェーンコードまたはコレクションのepをチェック | キーレベルepをチェック  |
+----------------------+------------------------------------------------+-------------------------+

上で説明したように、キーが変更され、キーレベルのエンドースメントポリシーが存在しない場合、
チェーンコードレベルまたはコレクションレベルのエンドースメントポリシーがデフォルトで適用されます。
これは、キーレベルのエンドースメントポリシーがキーに初めて設定された場合にも当てはまります。
新しいキーレベルのエンドースメントポリシーは、既存のチェーンコードレベルまたはコレクションレベルのエンドースメントポリシーに従って最初にエンドースされる必要があります。

キーが変更され、キーレベルのエンドースメントポリシーが存在する場合、
キーレベルのエンドースメントポリシーは、チェーンコードレベルまたはコレクションレベルのエンドースメントポリシーよりも優先されます。
実際には、これは、キーレベルのエンドースメントポリシーが、チェーンコードレベルまたはコレクションレベルのエンドースメントポリシーよりも制限が緩和されたり、制限が強化されたりすることを意味します。
キーレベルのエンドースメントポリシーを初めて設定するには、チェーンコードレベルまたはコレクションレベルのエンドースメントポリシーを満たす必要があるため、信頼の前提条件に違反していません。

キーのエンドースメントポリシーが削除されると(nilに設定されると)、チェーンコードレベルまたはコレクションレベルのエンドースメントポリシーが再びデフォルトになります。

1つのトランザクションが、異なるキーレベルエンドースメントポリシーを持つ複数のキーを変更する場合、トランザクションが有効であるためには、これらのポリシーのすべてが満たされる必要があります。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
