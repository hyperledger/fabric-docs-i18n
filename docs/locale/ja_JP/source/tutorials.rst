Tutorials
=========

アプリケーションの開発者は、Fabricのチュートリアルを使用して、独自のソリューションの構築を始めることができます。 `test network <./test_network.html>`_ をローカルマシンにデプロイして、Fabricとの作業を開始します。その後、 :doc:`deploy_chaincode` チュートリアルで提供されている手順を使用して、スマートコントラクトをデプロイしてテストすることができます。 :doc:`write_first_app` チュートリアルは、Fabric SDKが提供するAPIを使用してクライアントアプリケーションからスマートコントラクトを呼び出す方法について情報を提供しています。Fabricアプリケーションとスマートコントラクトがどのように連携するかの詳細については、 :doc:`developapps/developing_applications` トピックをご覧ください。

ネットワーク運用者は、 :doc:`deploy_chaincode` チュートリアルおよび :doc:`create_channel/create_channel_overview` チュートリアルのシリーズで、実行中のネットワークを管理するための重要な側面を学習できます。ネットワーク運用者とアプリケーション開発者の両者が、 `Private data <./private_data_tutorial.html>`_ と `CouchDB <./couchdb_tutorial.html>`_ のチュートリアルを使用して、Fabricの重要な機能を調べることができます。本番にデプロイするHyperledger Fabricの準備ができたら、 :doc:`deployment_guide_overview` のガイドを参照してください。

:doc:`config_update` と :doc:`updating_capabilities` のチャネルを更新するための2つのチュートリアルがあります。 :doc:`upgrading_your_components` では、ピア、オーダリングノード、SDKなどのコンポーネントをアップグレードする方法について説明しています。

最後に、基本的なスマートコントラクトを書く方法 :doc:`chaincode4ade` を紹介します。

.. note:: このドキュメントで説明されていない質問がある場合、またはいずれかのチュートリアルで問題が発生した場合は、 :doc:`questions` ページにアクセスして、追加のヘルプを見つけるためのヒントを見つけてください。

.. toctree::
   :maxdepth: 1
   :caption: Tutorials

   test_network
   deploy_chaincode.md
   write_first_app
   tutorial/commercial_paper
   private_data_tutorial
   secured_asset_transfer/secured_private_asset_transfer_tutorial.md
   couchdb_tutorial
   create_channel/create_channel_overview.md
   channel_update_tutorial
   config_update.md
   chaincode4ade
   videos

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
