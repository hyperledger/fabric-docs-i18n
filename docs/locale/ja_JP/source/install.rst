Install Samples, Binaries, and Docker Images
============================================

我々はHyperledger Fabricバイナリの実際のインストーラの開発に取り組んでいますが、
サンプルとバイナリをダウンロードしてあなたのシステムにインストールするスクリプトを提供します。
インストールされるサンプルアプリケーションは、Hyperledger Fabricの能力と運用の詳細を学習するのに役立つと思います。

.. note:: **Windows** で実行している場合には、以降のターミナルコマンドのために Docker Quickstart Terminalを使うことをお勧めします。
          まだインストールしていない場合には、 :doc:`prereqs` にアクセスしてください。

          Docker Toolbox または macOS を使用している場合には、
          サンプルをインストールして実行するときに、 ``/Users`` (macOS) 以下の場所を使用する必要があります。

          Docker for Mac を使用している場合には、 ``/Users`` 、 ``/Volumes`` 、 ``/private`` または ``/tmp``
          以下の場所を使用する必要があります。
          その他の場所を使用したい場合には、Dockerドキュメントの
          `file sharing <https://docs.docker.com/docker-for-mac/#file-sharing>`__ を参照してください。

          Docker for Windows を利用している場合には、Dockerドキュメントの
          `shared drives <https://docs.docker.com/docker-for-windows/#shared-drives>`__ を参照して、
          共有ドライブの1つの中の場所を使用してください。

マシン上で `fabric-samples` リポジトリを配置したい場所を決定し、ターミナルウィンドウにそのディレクトリを入力します。
以降のコマンドは、次の手順を実行します:

#. 必要に応じて `hyperledger/fabric-samples <https://github.com/hyperledger/fabric-samples>`_ リポジトリをクローン
#. 適切なバージョンタグをチェックアウト
#. 指定されたバージョンのHyperledger Fabricのプラットフォーム固有のバイナリと設定ファイルをfabric-samplesの/binおよび/configディレクトリにインストール
#. 指定されたバージョンのHyperledger FabricのDockerイメージをダウンロード

準備ができたら、Fabricのサンプルとバイナリをインストールしたいディレクトリで、以下に示すバイナリとイメージをプルダウンするコマンドを実行してください。

.. note:: 最新のプロダクションリリースが必要な場合は、すべてのバージョン識別子を省略してください。

.. code:: bash

  curl -sSL https://bit.ly/2ysbOFE | bash -s

.. note:: 特定のリリースが必要な場合は、FabricとFabric CAの各Dockerイメージのバージョン識別子を渡します。
          以下のコマンドは、最新のプロダクションリリース **Fabric v2.2.0** と **Fabric CA v1.4.7** をダウンロードする方法を示しています。

.. code:: bash

  curl -sSL https://bit.ly/2ysbOFE | bash -s -- <Fabricのバージョン> <Fabric CAのバージョン>
  curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.2.0 1.4.7

.. note:: 上記のcurlコマンドを実行してエラーが発生した場合、curlのバージョンが古すぎてリダイレクトを処理できないか、あるいはサポートされていない環境になっている可能性があります。

    curlの最新バージョンを見つけて適切な環境を取得するための情報の詳細は :doc:`prereqs` ページを参照してください。
    あるいは、短縮されていないURLを代用することもできます
    (https://raw.githubusercontent.com/hyperledger/fabric/{BRANCH}/scripts/bootstrap.sh)。

上記のコマンドは、ネットワークをセットアップするために必要なプラットフォーム固有のすべてのバイナリを
をダウンロードおよび解凍してクローンリポジトリ以下に配置するBashスクリプトをダウンロードして実行します。
スクリプトは以下のプラットフォーム固有のバイナリを取得します:

  * ``configtxgen``,
  * ``configtxlator``,
  * ``cryptogen``,
  * ``discover``,
  * ``idemixgen``
  * ``orderer``,
  * ``peer``,
  * ``fabric-ca-client``,
  * ``fabric-ca-server``

そしてこれらを現在の作業ディレクトリ以下の ``bin`` サブディレクトリに配置します。

上記のパスをPATH環境変数に追加すると、各バイナリへのパスを完全修飾せずにこれらを使用することができます。
例えば、以下の通りです。:

.. code:: bash

  export PATH=<ダウンロード場所へのパス>/bin:$PATH

最後に、スクリプトはHyperledger FabricのDockerイメージを
`Docker Hub <https://hub.docker.com/u/hyperledger/>`__ からローカルのDockerレジストリにダウンロードし、
それらに「latest」のタグを付けます。

スクリプトは、終了時にインストールされたDockerイメージの一覧を表示します。

各イメージの名前を見てください。
これらは、つまるところ、Hyperledger Fabricネットワークを構成するコンポーネントです。
また、同じイメージIDのインスタンスが2つあることに気付くでしょう。
1つは「amd64-1.x.x」のタグが付けられ、もう1つは「latest」のタグが付けられていると思います。
1.2.0より前のバージョンでは、ダウンロードされるイメージは ``uname -m`` によって決定され、「x86_64-1.x.x」と表示されていました。

.. note:: 別のアーキテクチャでは、x86_64/amd64 はアーキテクチャを識別する文字列に置き換えられます。

.. note:: このドキュメントで扱われていない質問がある場合や、チュートリアルで問題が発生した場合は、追加のヘルプを見つけるためのヒントを得るために :doc:`questions` のページをご覧ください。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
