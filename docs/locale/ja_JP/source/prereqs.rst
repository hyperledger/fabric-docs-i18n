Prerequisites
=============

始める前に、Hyperledger Fabricを実行するプラットフォームに以下のすべての前提条件がインストールされていることを確認する必要があります。

.. note:: これらの前提条件は、Fabricのユーザーに推奨されます。もしあなたがFabricの開発者なら、 :doc:`dev-setup/devenv` の説明を参照するべきです。

Install Git
-----------
`git <https://git-scm.com/downloads>`_ がまだインストールされていない場合や、curlコマンドの実行に問題がある場合には、gitの最新バージョンをダウンロードしてください。

Install cURL
------------
`cURL <https://curl.haxx.se/download.html>`_ ツールがまだインストールされていない場合、またはドキュメント内のcurlコマンドの実行中にエラーが発生した場合は、
最新バージョンのcURLツールをダウンロードしてください。

.. note:: Windowsを使用している場合には、後述の `Windows extras`_ に記述している注意事項を参照してください。

Docker and Docker Compose
-------------------------

Hyperledger Fabricを運用する、Hyperledger Fabric上で開発する（またはHyperledger Fabricのために開発する）プラットフォームには以下がインストールされている必要があります:

  - MacOSX、\*nix、 またはWindows 10: `Docker <https://www.docker.com/get-docker>`__
    Dockerのバージョン「Docker 17.06.2-ce」以降が必要です。
  - 古いバージョンのWindows: `Docker
    Toolbox <https://docs.docker.com/toolbox/toolbox_install_windows/>`__ と、Dockerのバージョン「Docker 17.06.2-ce」以降が必要です。

ターミナルのプロンプトから次のコマンドを使用して、インストールしたDockerのバージョンを確認することができます:

.. code:: bash

  docker --version

.. note:: 以下は、systemdを実行しているLinuxシステムに適用されます。

dockerデーモンが実行されていることを確認してください。

.. code:: bash

  sudo systemctl start docker

オプション: システムの起動時にdockerデーモンを起動する場合は、以下を使用します:

.. code:: bash

  sudo systemctl enable docker

ユーザーをdockerグループに追加します。

.. code:: bash

  sudo usermod -a -G docker <username>

.. note:: MacまたはWindows用のDocker、またはDocker Toolboxをインストールすると、Docker Composeもインストールされます。
          すでにDockerがインストールされている場合は、Docker Composeのバージョン1.14.0以降がインストールされていることを確認してください。
          そうでない場合は、より新しいバージョンのDockerをインストールすることをお勧めします。

ターミナルのプロンプトから次のコマンドを使用して、インストールしたDocker Composeのバージョンを確認できます:

.. code:: bash

  docker-compose --version

.. _windows-extras:

Windows extras
--------------

Windows 10では、WindowsネイティブのDockerディストリビューションを使用する必要があり、
Windows PowerShellを使用できます。
ただし、 ``binaries`` コマンドを成功させるには、 ``uname`` コマンドを使用できるようにする必要があります。
それはGitの一部として入手できますが、64ビット版のみがサポートされていることに注意してください。

``git clone`` コマンドを実行する前に、次のコマンドを実行してください:

::

    git config --global core.autocrlf false
    git config --global core.longpaths true

これらのパラメータの設定値は、次のコマンドで確認できます:

::

    git config --get core.autocrlf
    git config --get core.longpaths

これらはそれぞれ ``false`` と ``true`` である必要があります。

GitとDocker Toolboxに付属している ``curl`` コマンドは古く、
:doc:`getting_started` で使用されているリダイレクトを適切に処理しません。
`cURLダウンロードページ <https://curl.haxx.se/download.html>`__ からダウンロード可能な、
より新しいバージョンを使用していることを確認してください

.. note:: このドキュメントで説明されていない質問がある場合、またはいずれかのチュートリアルで問題が発生した場合は、:doc:`questions` ページにアクセスして、追加のヘルプを見つけるためのヒントを見つけてください。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
