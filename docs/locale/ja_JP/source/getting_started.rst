Getting Started
===============

.. toctree::
   :maxdepth: 1
   :hidden:

   prereqs
   install
   test_network

最初に、ブロックチェーンアプリケーションを開発したり、Hyperledger Fabricを運用したりするプラットフォームに、すべての :doc:`prereqs' がインストールされていることを確認します。

確認が終わったら、HyperLedger Fabricをダウンロードしてインストールできます。
Hyperledger Fabricをインストールファイルには次のようなスクリプト :doc:`install` が含まれます。
スクリプトはDockerイメージもローカルレジストリにダウンロードします。

Fabric SamplesとDockerイメージをローカルマシンにダウンロードしたら、チュートリアル :doc:`test_network' を使ってFabricを使い始めることができます。

Hyperledger Fabric smart contract (chaincode) APIs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Hyperledger Fabricは、さまざまなプログラミング言語でのスマートコントラクト(チェーンコード)の開発をサポートするためのAPIを提供しています。

  * `Go contract-api <https://github.com/hyperledger/fabric-contract-api-go>`__.
  * `Node.js contract API <https://github.com/hyperledger/fabric-chaincode-node>`__ and `Node.js contract API documentation <https://hyperledger.github.io/fabric-chaincode-node/>`__.
  * `Java contract API <https://github.com/hyperledger/fabric-chaincode-java>`__ and `Java contract API documentation <https://hyperledger.github.io/fabric-chaincode-java/>`__.

Hyperledger Fabric application SDKs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Hyperledger Fabricは、さまざまなプログラミング言語でのアプリケーション開発をサポートするために、多数のSDKを提供しています。

  * `Node.js SDK <https://github.com/hyperledger/fabric-sdk-node>`__ and `Node.js SDK documentation <https://hyperledger.github.io/fabric-sdk-node/>`__.
  * `Java SDK <https://github.com/hyperledger/fabric-gateway-java>`__ and `Java SDK documentation <https://hyperledger.github.io/fabric-gateway-java/>`__.

SDKで開発するための前提条件は、Node.js SDK`README<https://github.com/hyperledger/fabric-sdk-node#build-and-test>`__とJava SDK`README<https://github.com/hyperledger/fabric-gateway-java/blob/master/README.md>`__にあります。

さらに、まだ正式にリリースされていない(PythonとGo用)2つのアプリケーションSDKがありますが、ダウンロードしてテストすることができます。

  * `Python SDK <https://github.com/hyperledger/fabric-sdk-py>`__.
  * `Go SDK <https://github.com/hyperledger/fabric-sdk-go>`__.

現在、Node.js、Java、Goは、Hyperledger Fabric v1.4で提供される新しいアプリケーションプログラミングモデルをサポートしています。

Hyperledger Fabric CA
^^^^^^^^^^^^^^^^^^^^^

Hyperledger Fabricには、オプションで「認証局サービス<http://hyperledger-fabric-ca.readthedocs.io/en/latest>」_が用意されています。このサービスを使用すると、ブロックチェーンネットワーク内のIDを設定および管理するための証明書と鍵を生成できます。
また、ECDSA証明書を作成することができるCAであれば任意のCAを使用することができます。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
