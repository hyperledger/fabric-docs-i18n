Adding an Org to a Channel
==========================

.. note:: :doc:`prereqs` と :doc:`prereqs` で要約されているように、このドキュメントのバージョンに適合する適切なイメージとバイナリをダウンロードしていることを確認してください(左側の目次の一番下にあります)。

このチュートリアルは、新しい組織 -- Org3 -- をアプリケーションチャネルに加えることによってFabricテストネットワークを拡大しています。

ここではチャネルに新しい組織を追加することに焦点を当てますが、他のチャネル設定の更新(変更ポリシーの更新やバッチサイズの変更など)を行うために、同様のプロセスを使用することもできます。プロセスと一般のチャネル設定更新の可能性については、 :doc:`config_update` を参照してください。
また、ここで示したようなチャネル設定の更新は、通常、組織管理者(チェーンコードやアプリケーション開発者ではない)の責任であることも注目すべき点です。

Setup the Environment
~~~~~~~~~~~~~~~~~~~~~

``fabric-samples`` ローカルクローン内の ``test-network`` サブディレクトリのルートから操作します。下記のディレクトリに移動してください。

.. code:: bash

   cd fabric-samples/test-network

まず、 ``network.sh`` スクリプトを使って整理します。次のコマンドは、アクティブまたは古いDockerコンテナを削除し、以前に生成されたアーティファクトを削除します。チャネル設定の更新タスクを実行するためにFabricネットワークを停止することは、 **必要** ではありません。しかし、このチュートリアルでは、既知の初期状態から操作します。したがって、次のコマンドを実行して、以前の環境をクリーンアップしましょう:

.. code:: bash

  ./network.sh down

このスクリプトを使用して、 ``channel1`` という名前の1つのチャネルを持つテストネットワークを立ち上げることができます:

.. code:: bash

  ./network.sh up createChannel -c channel1

コマンドが成功した場合、コンソールログに以下のようなメッセージが表示されます:

.. code:: bash

  Channel 'channel1' joined

マシン上で実行されているテストネットワークのクリーンなバージョンができたので、作成したチャネルに新しい組織を追加するプロセスを開始できます。まず、チャネルにOrg3を追加するためのスクリプトを使用し、プロセスが機能していることを確認します。そして、チャネル設定の更新によるOrg3を追加するプロセスをステップごとに実行します。

Bring Org3 into the Channel with the Script
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``test-network`` ディレクトリにいるとします。スクリプトを使用するには、次のコマンドを実行するだけです:

.. code:: bash

  cd addOrg3
  ./addOrg3.sh up -c channel1

ここでの出力は読んでおくといいでしょう。Org3の暗号マテリアルが生成され、Org3の組織定義が作成され、そして、チャネル設定が更新・署名され、チャネルに送信されていることがわかります。

すべてがうまくいけば、次のメッセージが表示されます:

.. code:: bash

  Org3 peer successfully added to network

チャネルにOrg3を追加できることが確認できたので、スクリプトが裏で完了させたチャネル設定を更新する手順を実行することができます。

Bring Org3 into the Channel Manually
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``addOrg3.sh`` スクリプトを使用しただけの場合は、ネットワークをダウンさせる必要があります。次のコマンドは、実行中のすべてのコンポーネントを停止し、すべての組織の暗号マテリアルを削除します:

.. code:: bash

  cd ..
  ./network.sh down

ネットワークがダウンしたら、再度アップします:

.. code:: bash

  ./network.sh up createChannel -c channel1

これにより、ネットワークは、 ``addOrg3.sh`` スクリプトを実行する前と同じ状態に戻ります。

これで、Org3を手動でチャネルに追加する準備ができました。最初のステップとして、Org3の暗号マテリアルを生成する必要があります。

Generate the Org3 Crypto Material
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

別のターミナルで、 ``test-network`` から ``addOrg3`` サブディレクトリに移動します。

.. code:: bash

  cd addOrg3

まず、アプリケーションと管理者ユーザーと同時に、Org3ピアの証明書と鍵を作成します。実施例としてのチャネルを更新するため、認証局ではなくcryptogenツールを使用します。次のコマンドはcryptogenを使用して ``org3-crypto.yaml`` ファイルを読み込み、新しい ``Org3.example.com`` フォルダにOrg3暗号マテリアルを生成します:

.. code:: bash

  ../../bin/cryptogen generate --config=org3-crypto.yaml --output="../organizations"

生成されたOrg3暗号マテリアルは、Org1およびOrg2の証明書および鍵とともに ``test-network/organizations/peerOrganizations`` ディレクトリにあります。

Org3の暗号マテリアルを作成したら、configtxgenツールを使用してOrg3組織定義を印刷できます。ここでは、取り込む必要がある ``configtx.yaml`` ファイルをカレントディレクトリで検索するようにツールへ指示することによって、コマンドを開始します。

.. code:: bash

    export FABRIC_CFG_PATH=$PWD
    ../../bin/configtxgen -printOrg Org3MSP > ../organizations/peerOrganizations/org3.example.com/org3.json

上記のコマンドは、JSONファイル -- ``org3.json`` -- を作成し、それを ``test-network&slash;organizations&slash;peerOrganizations&slash;org3.example.com`` フォルダーに書き込みます。組織定義には、Org3のポリシー定義と、Org3のNodeOU定義、base64形式でエンコードされた2つの重要な証明書が含まれています:

  * CAルート証明書：組織のルートの信頼を確立するために使われます
  * TLSルート証明書：ブロック配布およびサービスディスカバリのためのOrg3を識別するゴシッププロトコルによって使用されます。

このチャネル設定を組織定義に追加することで、チャネルにOrg3を追加します。

Bring up Org3 components
~~~~~~~~~~~~~~~~~~~~~~~~

Org3証明書を作成した後、Org3ピアについて進めます。 ``addOrg3`` ディレクトリから、次のコマンドを発行します:

.. code:: bash

  docker-compose -f docker/docker-compose-org3.yaml up -d

If the command is successful, you will see the creation of the Org3 peer:
コマンドが成功すると、Org3ピアが作成されたことが表示されます:

.. code:: bash

  Creating peer0.org3.example.com ... done

このDocker Composeファイルは、最初のネットワークをブリッジするように設定されているので、Org3ピアは、テストネットワークの既存のピアおよびオーダリングノードを解決します。

.. note:: /addOrg3.sh upコマンドはFabricツールのCLIコンテナを使用して、次に示すチャネル設定の更新プロセスを実行します。これは、初めてのユーザに対するjq依存関係要件を回避するためです。しかし、不要なCLIコンテナを使用するのではなく、直接あなたのローカルマシンで次のプロセスを続けることをおすすめします。

Fetch the Configuration
~~~~~~~~~~~~~~~~~~~~~~~

チャネルの最新の構成ブロックである ``channel1`` を取得しましょう。

構成の最新バージョンをプルしなければならない理由は、チャネル構成要素がバージョニングされているからです。バージョン管理が重要な理由はいくつかあります。設定変更が繰り返されたり、再実行されたりするのを防ぐことができます(例えば、古いCRLを持つチャネル設定に戻すことはセキュリティ上のリスクになります)。また、同時実行を保証するのにも役立ちます(例えば、新しいOrgが追加された後にチャネルから別のOrgを削除したい場合、バージョン管理は削除したいOrgだけではなく、両方のOrgを削除できないようにするのに役立ちます)。

``test-network`` ディレクトリに戻ります。

.. code:: bash
  cd ..

Org3はまだチャネルのメンバーではないため、チャネル設定を取得するには、別の組織の管理者として操作する必要があります。Org1はチャネルのメンバーであるため、Org1の管理者はオーダリングサービスからチャネル設定を取得する権限を持っています。次のコマンドを実行して、Org1管理者として操作します。

.. code:: bash

  # you can issue all of these commands at once

  export PATH=${PWD}/../bin:$PATH
  export FABRIC_CFG_PATH=${PWD}/../config/
  export CORE_PEER_TLS_ENABLED=true
  export CORE_PEER_LOCALMSPID="Org1MSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
  export CORE_PEER_ADDRESS=localhost:7051

これで、最新の構成ブロックを取得するためのコマンドを発行することができます:

.. code:: bash

  peer channel fetch config channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem


このコマンドはバイナリプロトコルバッファチャネル設定ブロックを ``config_block.pb`` に保存します。名前とファイル拡張子の選択は任意であることに注意してください。ただし、表現されるオブジェクトとエンコーディング(プロトコルバッファまたはJSON)の両方のタイプを識別する次のコーディング規約に従うことが推奨されます。

``peer channel fetch`` コマンドを発行すると、次の出力がログに表示されます:

.. code:: bash

  2021-01-07 18:46:33.687 UTC [cli.common] readBlock -> INFO 004 Received block: 2

これは、 ``channel1`` の最新のコンフィギュレーションブロックは実際にはブロック2であり、 **ジェネシスブロックでない** ことを示しています。デフォルトでは、 ``peer channel fetch config`` コマンドが対象チャネルの **最新** のコンフィギュレーションブロックを返します。この場合は3番目のブロックです。これは、 ``network.sh`` のテストネットワークスクリプトが、 ``Org1`` と ``Org2`` という2つの組織のアンカーピアを、2つの別々のチャネル更新トランザクションで定義したからです。その結果、以下の設定シーケンスとなります:

  * block 0: genesis block
  * block 1: Org1 anchor peer update
  * block 2: Org2 anchor peer update

Convert the Configuration to JSON and Trim It Down
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

チャネル設定ブロックは、更新するプロセスを他のアーティファクトと区別するために、 ``channel-artifacts`` フォルダーに保存されました。 ``channel-artifacts`` フォルダに移動して、次の手順を完了します:

.. code:: bash
   cd channel-artifacts

では、 ``configtxlator`` ツールを使用して、このチャネル設定ブロックをJSONフォーマット(このフォーマットは、人が読み込みと変更をすることができるもの)にデコードします。また、変更に関係のないヘッダー、メタデータ、作成者の署名などもすべて削除する必要があります。これを行うには、 ``jq`` ツールを使用します(ローカルマシンに `jq tool <https://stedolan.github.io/jq/>`_ をインストールする必要があります。):

.. code:: bash

  configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
  jq .data.data[0].payload.data.config config_block.json > config.json

このコマンドはトリミングされたJSONオブジェクト -- ``config.json`` -- を残します。それは設定を更新するベースラインとしての役割を果たします。

お好みのテキストエディタ(またはブラウザ)でこのファイルを開きます。このチュートリアルを終えた後でも、基礎となる設定構造と、その他の種類のチャネルの更新を明らかにするので、学ぶ価値があります。それらについては :doc:`config_update` でより詳細に説明しています。

Add the Org3 Crypto Material
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. note:: これまでに実行した手順は、どのような種類の更新をしようとしても、ほとんど同じです。このチュートリアルで組織を追加すること追加することを選択したのは、みなさんが試すことができる中で最も複雑なチャネル設定の更新の1つだからです。

``jq`` ツールをもう一度使用して、Org3設定定義 -- ``org3.json`` -- をチャネルのアプリケーショングループフィールドに追加し、出力に ``modified_config.json`` という名前を付けます。

.. code:: bash

  jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"Org3MSP":.[1]}}}}}' config.json ../organizations/peerOrganizations/org3.example.com/org3.json > modified_config.json

ここでJSONファイルが2つできます- ``config.json`` と ``modified_config.json`` です。初期ファイルにはOrg1とOrg2のマテリアルのみが含まれていますが、「修正された」ファイルには3つのOrgがすべて含まれています。この時点では、単にこれら2つのJSONファイルを再エンコードして差分を計算します。

まず、 ``config.json`` を ``config.pb`` というプロトコルバッファに戻します:

.. code:: bash

  configtxlator proto_encode --input config.json --type common.Config --output config.pb

次に、 ``modified_config.json`` から ``modified_config.pb`` へエンコードします:

.. code:: bash

  configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb

そして、 ``configtxlator`` を使用して、これら2つの構成プロトコルバッファ間の差分を計算します。このコマンドは、 ``org3_update.pb`` という名前の新しいプロトコルバッファバイナリを出力します:

.. code:: bash

  configtxlator compute_update --channel_id channel1 --original config.pb --updated modified_config.pb --output org3_update.pb

この新しいプロトタイプ -- ``org3_update.pb`` -- には、Org3の定義と、Org1およびOrg2マテリアルに対する高レベルポインタが含まれています。Org1およびOrg2の広範なMSPマテリアルおよび変更ポリシー情報は、このデータがすでにチャネルのジェネシスブロックに存在しているため、省略することができます。したがって、必要なのは2つの構成間の差分だけです。

チャネル更新を提出する前に、いくつかの最終ステップを実行する必要があります。まず、このオブジェクトを編集可能なJSONフォーマットにデコードし、それを ``org3_update.json`` としましょう:

.. code:: bash

  configtxlator proto_decode --input org3_update.pb --type common.ConfigUpdate --output org3_update.json

そうして、デコードされた更新ファイル -- ``org3_update.json`` -- ができます。これをエンベロープメッセージでラップする必要があります。このステップでは、前に除去したヘッダーフィールドが戻されます。このファイルに ``org3_update_in_envelope.json`` という名前を付けます:

.. code:: bash

  echo '{"payload":{"header":{"channel_header":{"channel_id":"'channel1'", "type":2}},"data":{"config_update":'$(cat org3_update.json)'}}}' | jq . > org3_update_in_envelope.json

適切に形成されたJSON -- ``org3_update_in_envelope.json`` -- を使用して、最後に ``configtxlator`` ツールを活用し、Fabricが必要とする本格的なプロトコルバッファフォーマットに変換します。最後の更新オブジェクトに ``org3_update_in_envelope.pb`` という名前を付けます:

.. code:: bash

  configtxlator proto_encode --input org3_update_in_envelope.json --type common.Envelope --output org3_update_in_envelope.pb

Sign and Submit the Config Update
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

もうすぐ完了です!

プロトコルバッファバイナリ -- ``org3_update_in_envelope.pb`` -- ができました。ただし、構成を台帳へ書き込む前に、必須であるAdminユーザーからの署名が必要です。チャネルアプリケーショングループの変更ポリシー(mod_policy)は、「過半数」がデフォルトに設定されています。つまり、それを署名するためには、既存の組織管理者の過半数が必要です。今はOrg 1とOrg2という2つの組織しかなく、2つの過半数は2であるため、両方の組織が署名する必要があります。双方の署名がなければ、オーダリングサービスはポリシーを果たさなかったトランザクションを却下することになります。

まず、この更新プロトタイプをOrg1として署名しましょう。 ``test-network`` ディレクトリに戻ります:

.. code:: bash
   cd ..

ここでは、Org1の管理者として動作するために必要な環境変数をエクスポートしました。その結果、次の ``peer channel signconfigtx`` コマンドは、Org1として更新の署名をすることになります。

.. code:: bash

  peer channel signconfigtx -f channel-artifacts/org3_update_in_envelope.pb

最後のステップは、Org2管理者ユーザーを反映して、コンテナのアイデンティティを切り替えることです。これを行うには、Org2 MSPに固有の4つの環境変数をエクスポートします。

.. note:: コンフィギュレーショントランザクションに署名する(または他のことをする)ために組織間を切り替えることは、現実世界のFabric操作を反映したものではありません。1つのコンテナに全体のネットワーク暗号マテリアルがマウントされることはありません。むしろ、構成の更新は、検査と承認をするOrg2 Adminに対して帯域外で安全に渡される必要があります。

Org2環境変数をエクスポートします:

.. code:: bash

  # you can issue all of these commands at once

  export CORE_PEER_TLS_ENABLED=true
  export CORE_PEER_LOCALMSPID="Org2MSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
  export CORE_PEER_ADDRESS=localhost:9051

最後に ``peer channel update`` コマンドの発行を行います。Org2 Admin署名はこのコールに添付されるため、2回目のプロトコルバッファを手動で署名する必要はありません:

.. note:: 今後のオーダリングサービスへの更新は、一連の体系的な署名とポリシーのチェックを受けます。そのため、オーダリングノードのログをストリーミングして検査することが便利な場合があります。 ``docker logs -f orderer.example.com`` コマンドを発行して、それらを表示することができます。

更新コールを送信します:

.. code:: bash

  peer channel update -f channel-artifacts/org3_update_in_envelope.pb -c channel1 -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

更新が正常に送信された場合は、次のようなメッセージが表示されます:

.. code:: bash

  2021-01-07 18:51:48.015 UTC [channelCmd] update -> INFO 002 Successfully submitted channel update

チャネル更新するコールが成功すると、新しいブロック(ブロック3)がチャネルのすべてのピアに返されます。ブロック0～2は、最初のチャネル設定です。ブロック3は、チャネルに現在定義されているOrg3とともに、最新のチャネル設定として機能します。

次のコマンドによって、 ``peer0.org1.example.com`` のログを検査することができます:

.. code:: bash

      docker logs -f peer0.org1.example.com


Join Org3 to the Channel
~~~~~~~~~~~~~~~~~~~~~~~~

この時点で、チャネル設定は更新され、新しい組織であるOrg3が含まれるようになりました。これは、そこに所属するピアが ``channel1`` に参加できることを意味します。

Org3 Adminとして動作するように次の環境変数をエクスポートします:

.. code:: bash

  # you can issue all of these commands at once

  export CORE_PEER_TLS_ENABLED=true
  export CORE_PEER_LOCALMSPID="Org3MSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
  export CORE_PEER_ADDRESS=localhost:11051

チャネル更新するが成功した結果、オーダリングサービスは、Org3がジェネシスブロックをプルし、チャネルに参加することができることを検証します。もしOrg3がチャネル構成に正常に追加されなかった場合、オーダリングサービスはこの要求を却下します。

.. note:: ここでも、オーダリングノードのログを流して、署名/検証ロジックとポリシーチェックを明らかにすることが有用であると考えられます。

このブロックを取り戻すために、 ``peer channel fetch`` コマンドを使用します:

.. code:: bash

  peer channel fetch 0 channel-artifacts/channel1.block -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

``0`` を渡すことに注意してください。これは、チャネルの台帳にある最初のブロックであるジェネシスブロックが必要であることを示しています。単純に ``peer channel fetch config`` コマンドを渡していれば、ブロック3(Org3が定義されている更新された設定)を受け取ることになります。しかし、台帳を下流のブロックで始めることはできません。つまり、ブロック0から始めなければなりません。

成功した場合、コマンドはジェネシスブロックを ``channel1.block`` というファイルに戻しました。Org3ピアをチャネルに参加させるため、 ``peer channel join`` コマンドを発行し、ジェネシスブロックにへ渡します:

.. code:: bash

  peer channel join -b channel-artifacts/channel1.block

Configuring Leader Election
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. note:: このセクションは、最初のチャネル設定が完了した後に組織をネットワークに追加するときのリーダー選択設定を理解するための一般的なリファレンスとして含まれています。

新たに加入したピアは、ジェネシスブロックとともに起動されます。これには、チャネル設定の更新で追加される組織に関する情報は含まれません。よって、組織を追加したコンフィギュレーショントランザクションを取得するまで、自分の組織から他のピアによって転送されたブロックを確認できないため、新しいピアはゴシップを利用できません。新しく追加されたピアは、オーダリングサービスからブロックを受信できるように、次のいずれかの設定を行う必要があります:

1. ピアが直接オーダリングサービスからいつもブロックを受信することを確保するため、ピアを組織リーダーに設定します:

::

    CORE_PEER_GOSSIP_USELEADERELECTION=false
    CORE_PEER_GOSSIP_ORGLEADER=true


.. note:: この設定は、Fabric v2.2から始まったデフォルトであり、チャネルに追加されるすべての新しいピアで同じである必要があります。

2. 2組織内における最終的に動的リーダー選挙を利用するため、リーダー選挙を利用するようにピアを設定します:

::

    CORE_PEER_GOSSIP_USELEADERELECTION=true
    CORE_PEER_GOSSIP_ORGLEADER=false


.. note:: 新たに追加された組織のピアは、最初はメンバーシップビューを形成することができないため、この選択肢は静的設定と同様であり、それぞれのピアが自らをリーダーであると宣言し始めることになります。ただし、組織をチャネルに追加するコンフィギュレーショントランザクションで更新すると、組織のアクティブリーダーは1つだけになります。したがって、最終的に組織のピアにリーダー選定を利用させたい場合には、この選択肢を活用することが推奨されます。


.. _upgrade-and-invoke:

Install, define, and invoke chaincode
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

チャネルにチェーンコードをインストールして呼び出すことによって、Org3が ``channel1`` のメンバーであることを確認できます。既存のチャネルメンバーがすでにチャネルへのチェーンコード定義をコミットしている場合、新しい組織はチェーンコード定義を承認することによってチェーンコードの使用を開始することができます。

.. note:: この手順では、v2.0リリースで導入されたFabricチェーンコードライフサイクルを使用します。以前のライフサイクルを使用してチェーンコードをインストールおよびインスタンス化する場合は、 `Adding an org to a channel tutorial <https://hyperledger-fabric.readthedocs.io/en/release-1.4/channel_update_tutorial.html>`__ を参照してください。

チェーンコードをOrg3としてインストールするする前に、 ``./network.sh`` スクリプトを使用してチャネルのFabcarチェーンコードをデプロイすることができます。新しい端末を開き、 ``test-network`` ディレクトリに移動します。そこで ``test-network`` スクリプトを使用してBasicチェーンコードをデプロイすることができます:

.. code:: bash

  cd fabric-samples/test-network
  ./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-go/ -ccl go -c channel1

このスクリプトは、Org1およびOrg2のピアのBasicチェーンコードをインストールし、Org1およびOrg2のチェーンコード定義を承認し、チャネルにチェーンコード定義をコミットします。チェーンコード定義がチャネルにコミットされると、Basicチェーンコードは初期化され、台帳に初期データを置くために起動されます。次のコマンドは、まだチャネル ``channel1`` を使用していることを前提としています。

チェーンコードがデプロイされたら、BasicチェーンコードをOrg3として使用するために次の手順を利用します。ネットワークをOrg3 adminとしてやりとりするために、次の環境変数を端末にコピーして貼り付けます:

.. code:: bash

    export PATH=${PWD}/../bin:$PATH
    export FABRIC_CFG_PATH=$PWD/../config/
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="Org3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
    export CORE_PEER_ADDRESS=localhost:11051

最初のステップは、Basicチェーンコードのパッケージ化です。:

.. code:: bash

    peer lifecycle chaincode package basic.tar.gz --path ../asset-transfer-basic/chaincode-go/ --lang golang --label basic_1

このコマンドは ``basic.tar.gz`` という名前のチェーンコードパッケージを作り、それをOrg3ピアにインストールすることができます。JavaまたはNode.jsで書かれたチャネルを実行している場合は、それに応じてコマンドを変更します。チェーンコードパッケージ ``peer0.org3.example.com`` をインストールするために次のコマンドを発行します:

.. code:: bash

    peer lifecycle chaincode install basic.tar.gz


次のステップは、Basicチェーンコード定義をOrg3として承認することです。Org3は、Og1とOg2が承認しチャネルにコミットしたのと同じ定義を承認する必要があります。チェーンコード呼び出すために、Org3はチェーンコード定義にパッケージIDを含める必要があります。ピアをクエリすることによって、パッケージIDを検索することができます:

.. code:: bash

    peer lifecycle chaincode queryinstalled

次のような出力が表示されます:

.. code:: bash

      Get installed chaincodes on peer:
      Package ID: basic_1:5443b5b557efd3faece8723883d28d6f7026c0bf12245de109b89c5c4fe64887, Label: basic_1

パッケージIDは将来のコマンドで必要になるため、先行して環境変数として保存します。 ``peer lifecycle chaincode queryinstalled`` コマンドから返されたパッケージIDを、次のコマンドに貼り付けます。パッケージIDはすべてのユーザーで同じではない可能性があるため、あなたのコマンドウィンドウから返されたパッケージIDを使用してこのステップを完了する必要があります。

.. code:: bash

   export CC_PACKAGE_ID=basic_1:5443b5b557efd3faece8723883d28d6f7026c0bf12245de109b89c5c4fe64887

次のコマンドを使用して、Org3のBasicチェーンコードの定義を承認します:

.. code:: bash

    # use the --package-id flag to provide the package identifier
    # use the --init-required flag to request the ``Init`` function be invoked to initialize the chaincode
    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --channelID channel1 --name basic --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1


``peer lifecycle chaincode querycommitted`` コマンドを使用して、承認したチェーンコード定義がすでにチャネルにコミットされているかどうかを確認できます。

.. code:: bash

    # use the --name flag to select the chaincode whose definition you want to query
    peer lifecycle chaincode querycommitted --channelID channel1 --name basic --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

コマンドが成功すれば、コミットされた定義に関する情報が返されます:

.. code:: bash

    Committed chaincode definition for chaincode 'basic' on channel 'channel1':
    Version: 1.0, Sequence: 1, Endorsement Plugin: escc, Validation Plugin: vscc, Approvals: [Org1MSP: true, Org2MSP: true, Org3MSP: true]

Org3は、チャネルにコミットされたチェーンコード定義を承認した後、Fabcarチェーンコードを使用できます。チェーンコード定義はデフォルトエンドースメントポリシーを使用しており、チャネルがエンドースするトランザクションで組織の過半数であることが必要です。つまり、組織がチャネルに追加されたり、チャネルから削除されたりすると、エンドースメントポリシーが自動的に更新されることになります。以前は、Org1とOrg2(2つのうち2つ)からのエンドースメントが必要でした。今はOrg1、Org2、およびOrg3(3つのうち2つ)の2つの組織からのエンドースメントが必要です。

台帳にサンプル資産を入力します。Org2ピアと新しいOrg3ピアからエンドースメントを得て、エンドースメントポリシーを満足するようにします。

.. code:: bash

    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C channel1 -n basic --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt --peerAddresses localhost:11051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt -c '{"function":"InitLedger","Args":[]}'

チェーンコードをクエリして、Org3ピアがデータをコミットしたことを確認できます。

.. code:: bash

    peer chaincode query -C channel1 -n basic -c '{"Args":["GetAllAssets"]}'

応答として台帳に追加された資産の最初のリストが表示されます。


Conclusion
~~~~~~~~~~

チャネル設定を更新するプロセスは非常に複雑ですが、様々な段階で論理的な方法があります。エンドゲームは、プロトコルバッファバイナリフォーマットで表現される差分トランザクションオブジェクトを形成し、チャネル設定更新トランザクションがチャネルの変更ポリシーを満たすのに必要な数の管理者署名を獲得します。

``configtxlator`` ツールと ``jq`` ツールは、 ``peer channel`` コマンドとともに、このタスクを実現する機能を提供します。

Updating the Channel Config to include an Org3 Anchor Peer (Optional)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Org1およびOrg2にはチャネル設定で定義されたアンカーピアがあったため、Org3ピアはOrg1およびOrg2ピアとのゴシップ接続を確立することができました。同様に、Org3のような新しく追加された組織も、他の組織からの新しいピアがOrg3ピアを直接発見できるように、チャネル設定のアンカーピアを定義するべきです。このセクションでは、チャネル設定の更新を作成してOrg3アンカーピアを定義します。プロセスは以前の設定更新と同じようなものになるので、今回はもっと早く進みます。

前と同じように、最新のチャネル設定を取得してスタートします。 ``peer channel fetch`` コマンドを使用して、チャネルの最新の設定ブロックを取得します。

.. code:: bash

  peer channel fetch config channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

設定ブロックを取得したら、それをJSONフォーマットに変換します。これを行うには、前にチャネルにOrg3を追加したときと同じように、configtxlatorツールを使用します。まず、 ``channel-artifacts`` フォルダに移動します:

.. code:: bash
   cd channel-artifacts

変換するときは、必須でないすべてのヘッダー、メタデータ、および署名を削除し、 ``jq`` ツールを使用してアンカーピアに含める必要があります。この情報は、チャネル設定の更新に進む前に、後で再び取り入れます。

.. code:: bash

  configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
  jq .data.data[0].payload.data.config config_block.json > config.json

``config.json`` は、現在トリミングされているJSONであり、更新する最新のチャネル設定を表しています。

再度 ``jq`` ツールを使用して、追加したいOrg3アンカーピアで設定JSONを更新します。

.. code:: bash

    jq '.channel_group.groups.Application.groups.Org3MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.org3.example.com","port": 11051}]},"version": "0"}}' config.json > modified_anchor_config.json

これで2つのJSONファイルが作成されました。1つは現在のチャネル設定 ``config.json`` で、もう1つは目的のチャネル設定 ``modified_anchor_config.json`` です。次に、これらのそれぞれをプロトコルバッファ形式に戻し、2つの間の差分を計算します。

``config.json`` をプロトコルバッファ形式に戻して ``config.pb`` とします。

.. code:: bash

    configtxlator proto_encode --input config.json --type common.Config --output config.pb

``modified_anchor_config.json`` を ``modified_anchor_config.pb`` としてプロトコルバッファ形式に変換します。

.. code:: bash

    configtxlator proto_encode --input modified_anchor_config.json --type common.Config --output modified_anchor_config.pb

2つのプロトコルバッファ形式の構成の差分を計算します。

.. code:: bash

    configtxlator compute_update --channel_id channel1 --original config.pb --updated modified_anchor_config.pb --output anchor_update.pb

チャネルに対して期待する更新するが得られたので、それが適切に読み込みできるように、それをエンベロープメッセージで包む必要があります。そのためには、まずプロトコルバッファをラップ可能なJSONに変換し直す必要があります。

再び ``configtxlator`` コマンドを使用して ``anchor_update.pb`` を ``anchor_update.json`` に変換します。

.. code:: bash

    configtxlator proto_decode --input anchor_update.pb --type common.ConfigUpdate --output anchor_update.json

次に、更新をエンベロープメッセージでラップして、以前に削除したヘッダーを復元し、 ``anchor_update_in_envelope.json`` に出力します。

.. code:: bash

    echo '{"payload":{"header":{"channel_header":{"channel_id":"channel1", "type":2}},"data":{"config_update":'$(cat anchor_update.json)'}}}' | jq . > anchor_update_in_envelope.json

エンベロープを再構成したので、それをプロトコルバッファに変換し、更新のために適切な署名をしてordererに提出できるようにする必要があります。

.. code:: bash

    configtxlator proto_encode --input anchor_update_in_envelope.json --type common.Envelope --output anchor_update_in_envelope.pb

更新が適切にフォーマットされたので、署名と送信をしましょう。

``test-network`` ディレクトリに戻ります:

.. code:: bash
   cd ..


これはOrg3の更新だけなので、Org3に更新の署名をもらうだけでいいです。次のコマンドを実行して、Org3 adminとして動作していることを確認します:

.. code:: bash

  # you can issue all of these commands at once

  export CORE_PEER_LOCALMSPID="Org3MSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
  export CORE_PEER_ADDRESS=localhost:11051

これで、ordererに送信する前に、Org3管理者として更新の署名のために、 ``peer channel update`` コマンドを使用することができます。

.. code:: bash

    peer channel update -f channel-artifacts/anchor_update_in_envelope.pb -c channel1 -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

ordererは構成の更新要求を受信し、更新された設定でブロックを切断します。ピアがブロックを受信すると、ピアは設定アップデートを処理します。

いずれかのピアのログを調べます。新しいブロックからのコンフィギュレーショントランザクションを処理している間に、ゴシップがOrg3の新しいアンカーピアを使用して接続を再確立していることがわかります。これは、設定更新がうまく適用された証拠です!

.. code:: bash

    docker logs -f peer0.org1.example.com

.. code:: bash

    2021-01-07 19:07:01.244 UTC [gossip.gossip] learnAnchorPeers -> INFO 05a Learning about the configured anchor peers of Org1MSP for channel channel1: [{peer0.org1.example.com 7051}]
    2021-01-07 19:07:01.243 UTC [gossip.gossip] learnAnchorPeers -> INFO 05b Learning about the configured anchor peers of Org2MSP for channel channel1: [{peer0.org2.example.com 9051}]
    2021-01-07 19:07:01.244 UTC [gossip.gossip] learnAnchorPeers -> INFO 05c Learning about the configured anchor peers of Org3MSP for channel channel1: [{peer0.org3.example.com 11051}]

おめでとうございます。これで2つの設定の更新が行われました。1つはOrg3をチャネルに追加するためのもので、もう1つはOrg3のアンカーピアを定義するためのものです。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
