Building Hyperledger Fabric
---------------------------

以下の手順は、 :doc:`開発環境 <devenv>` がすでにセットアップされていることを前提としています。

Hyperledger Fabric をビルドするには以下を実行します:

::

    make dist-clean all

Building the documentation
~~~~~~~~~~~~~~~~~~~~~~~~~~

もしあなたがドキュメントに貢献している場合は、
ローカルマシン上で Fabric ドキュメントをビルドできます。
これにより、プルリクエストを開く前に、Web ブラウザを使用してあなたの変更のフォーマットを確認できます。

ドキュメントをビルドする前に、次の前提条件をダウンロードする必要があります:

- `Python 3.7 <https://wiki.python.org/moin/BeginnersGuide/Download>`__
- `Pipenv <https://pipenv.readthedocs.io/en/latest/#install-pipenv-today>`__

ドキュメントソースファイルを更新した後、次のコマンドを実行して、あなたの変更を含むビルドを生成できます:

::

    cd fabric/docs
    pipenv install
    pipenv shell
    make html

これにより、 ``docs/build/html`` フォルダにすべてのhtmlファイルが生成されます。
あなたは、任意のファイルを開いて、ブラウザを使用して更新されたドキュメントの閲覧を開始できます。
ドキュメントにさらに追加の編集を加えたい場合は、 ``make html`` を再実行して変更を組み込むことができます。

Running the unit tests
~~~~~~~~~~~~~~~~~~~~~~

次のコマンドを使用して、すべての単体テストを実行します:

::

    make unit-test

テストのサブセットを実行するには、 TEST_PKGS 環境変数を設定します。
パッケージのリスト（スペース区切り）を指定します。たとえば、以下の通りです:

::

    export TEST_PKGS="github.com/hyperledger/fabric/core/ledger/..."
    make unit-test

特定のテストを実行するには、 ``-run RE`` フラグを使用します。
RE は、テストケース名にマッチする正規表現です。
詳細出力でテストを実行するには、 ``-v`` フラグを使用します。
たとえば、 ``TestGetFoo`` テストケースを実行するには、 ``foo_test.go`` を含むディレクトリに移動し、
以下を呼び出し/実行します:

::

    go test -v -run=TestGetFoo


Running Node.js Client SDK Unit Tests
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

また、Node.js 単体テストを実行して、 Node.js クライアント SDK があなたの変更によって壊れていないことを確認する必要があります。
Node.js 単体テストを実行するには、 `こちら <https://github.com/hyperledger/fabric-sdk-node/blob/master/README.md>`__ の手順に従ってください。

Configuration
-------------

設定では、 `viper ライブラリ <https://github.com/spf13/viper>`__
と `cobra ライブラリ <https://github.com/spf13/cobra>`__ を利用します。

ピアプロセスの設定を含む **core.yaml** ファイルがあります。
設定の多くは、設定名と一致する環境変数を設定することにより、
コマンドライン上で上書きできますが、その際に接頭辞として *'CORE\_'* を付ける必要があります。
たとえば、 peer.networkId の設定は次のように行えます:

::

    CORE_PEER_NETWORKID=custom-network-id peer

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
