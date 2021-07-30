Setting up the development environment
--------------------------------------

Prerequisites
~~~~~~~~~~~~~

-  `Git client <https://git-scm.com/downloads>`__
-  `Go <https://golang.org/dl/>`__ version 1.15.x
-  `Docker <https://docs.docker.com/get-docker/>`__ version 18.03 以降
-  (macOS) `Xcode Command Line Tools <https://developer.apple.com/downloads/>`__
-  `SoftHSM <https://github.com/opendnssec/SoftHSMv2>`__
-  `jq <https://stedolan.github.io/jq/download/>`__


Steps
~~~~~

Install the Prerequisites
^^^^^^^^^^^^^^^^^^^^^^^^^

macOSの場合、`Homebrew <https://brew.sh>`__ を使用して開発の前提条件を管理することをお勧めします。
Xcodeコマンドラインツールは、Homebrewインストールの一部としてインストールされます。

Homebrewの準備ができたら、必要な前提条件のインストールは非常に簡単です:

::

    brew install git go jq softhsm
    brew cask install --appdir="/Applications" docker

インストールを完了するには Docker Desktop を起動する必要があるため、インストール後に必ずアプリケーションを開いてください:

::

    open /Applications/Docker.app

Developing on Windows
~~~~~~~~~~~~~~~~~~~~~

Windows 10では、Windows ネイティブの Docker ディストリビューションを使用する必要があり、
Windows PowerShellを使用できます。
ただし、``binaries`` コマンドを成功させるには、``uname`` コマンドを使用できるようにする必要があります。
それはGitの一部として入手できますが、64ビットバージョンのみがサポートされていることに注意してください。

``git clone`` コマンドを実行する前に、次のコマンドを実行します:

::

    git config --global core.autocrlf false
    git config --global core.longpaths true

これらのパラメータの設定は、次のコマンドで確認できます:

::

    git config --get core.autocrlf
    git config --get core.longpaths

これらはそれぞれ ``false`` と ``true`` が設定されている必要があります。

Git と Docker Toolbox に付属の ``curl`` コマンドは古く、:doc:`../getting_started` で使用されているリダイレクトを適切に処理しません。
`cURL ダウンロードページ <https://curl.haxx.se/download.html>`__ からダウンロードできる新しいバージョンを使用していることを確認してください。

Clone the Hyperledger Fabric source
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

まず、 https://github.com/hyperledger/fabric に移動し、
右上隅にあるForkボタンを使用してファブリックリポジトリをフォークします。
フォークした後、リポジトリをクローンします。

::

    mkdir -p github.com/<your_github_userid>
    cd github.com/<your_github_userid>
    git clone https://github.com/<your_github_userid>/fabric

.. note::
    Windows を使っている場合は、リポジトリをクローンする前に、次のコマンドを実行します:

    ::

        git config --get core.autocrlf

    ``core.autocrlf`` が ``true`` に設定されている場合は、以下を実行して ``false`` に設定する必要があります:

    ::

        git config --global core.autocrlf false


Configure SoftHSM
^^^^^^^^^^^^^^^^^

単体テストを実行するには、PKCS #11 暗号化トークンの実装が必要です。
PKCS #11 API は、Fabric の bccsp コンポーネントによって使用され、
暗号化情報を格納して暗号化計算を実行するハードウェアセキュリティモジュール (HSM) と対話します。
テスト環境では、SoftHSM を使用してこの要件を満たすことができます。

SoftHSM は通常、使用する前に追加設定が必要です。
たとえば、デフォルト設定では、特権のないユーザーが書き込めないシステムディレクトリにトークンデータを保存しようとします。

SoftHSMの設定は、通常、 ``/etc/softhsm2.conf`` を ``$HOME/.config/softhsm2/softhsm2.conf`` にコピーし、
``directories.tokendir`` を適切な場所に変更します。
詳細については、 ``softhsm2.conf`` の man ページを参照してください。

SoftHSMを設定した後、次のコマンドを使用して、単体テストに必要なトークンを初期化できます:

::

    softhsm2-util --init-token --slot 0 --label "ForFabric" --so-pin 1234 --pin 98765432

テストであなたの環境内の libsofthsm2.so ライブラリを見つけることができない場合は、
適切な環境変数でライブラリのパス、PIN、およびトークンのラベルを指定します。
たとえば、macOSの場合は以下の通りです:

::

    export PKCS11_LIB="/usr/local/Cellar/softhsm/2.6.1/lib/softhsm/libsofthsm2.so"
    export PKCS11_PIN=98765432
    export PKCS11_LABEL="ForFabric"

Install the development tools
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

リポジトリをクローンしたら、 ``make`` を使用して、
開発環境で使用されるツールの一部をインストールできます。
デフォルトでは、これらのツールは ``$HOME/go/bin`` にインストールされます。
``PATH`` にそのディレクトリが含まれていることを確認してください。

::

    make gotools

これらのツールをインストールした後、
いくつかのコマンドを実行してビルド環境を確認できます。

::

    make basic-checks integration-test-prereqs
    ginkgo -r ./integration/nwo

これらのコマンドが完全に正常に実行されたら、準備は完了です！

もし Hyperledger Fabric のアプリケーション SDK を使用する場合には、Node.js SDK の `README <https://github.com/hyperledger/fabric-sdk-node#build-and-test>`__
と Java SDK の `README <https://github.com/hyperledger/fabric-gateway-java/blob/master/README.md>`__ の前提条件を確認してください。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
