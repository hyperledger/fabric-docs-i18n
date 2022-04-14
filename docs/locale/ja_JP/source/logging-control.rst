Logging Control
===============

Overview
--------

``ピア`` と ``Orderer`` のロギングには ``common/flogging`` を使用します。
このパッケージは以下をサポートします。

- メッセージの重要度に応じたロギング制御
- メッセージを生成するソフトウェア *ロガー (logger)* に基づくロギング制御
- メッセージの重要度によって異なるプリティプリント (整形表示) オプション

現在、すべてのログは ``標準エラー`` に送られます。
グローバルおよびロガーレベルでの重要度によるロギングの制御はユーザーと開発者の両方に提供されます。
現在のところ、各重要度レベルで提供される情報の種類に関する正式なルールはありません。
バグレポートを送信するとき、開発者は DEBUG レベルまでの完全なログを見たいと思うかもしれません。

整形表示されたログでは、ロギングレベルは色と4文字のコード (例: ERRORは「ERRO」、DEBUGは「DEBU」など) で示されます。
ロギングの文脈では、 *logger* は開発者が関連するメッセージのグループに与える任意の名前 (文字列) である。
以下の例では、複数の logger ``ledgermgmt``, ``kvledger``, ``peer`` がログを生成しています。

::

   2018-11-01 15:32:38.268 UTC [ledgermgmt] initialize -> INFO 002 Initializing ledger mgmt
   2018-11-01 15:32:38.268 UTC [kvledger] NewProvider -> INFO 003 Initializing ledger provider
   2018-11-01 15:32:38.342 UTC [kvledger] NewProvider -> INFO 004 ledger provider Initialized
   2018-11-01 15:32:38.357 UTC [ledgermgmt] initialize -> INFO 005 ledger mgmt initialized
   2018-11-01 15:32:38.357 UTC [peer] func1 -> INFO 006 Auto-detected peer address: 172.24.0.3:7051
   2018-11-01 15:32:38.357 UTC [peer] func1 -> INFO 007 Returning peer0.org1.example.com:7051

ランタイムに任意の数の logger を作成することができるため、logger の「マスターリスト」は存在せず、
ロギング制御構造はロギングする logger が実際に存在するかを確認できません。

Logging specification
---------------------

``peer`` と ``orderer`` コマンドのログレベルは、環境変数 ``FABRIC_LOGGING_SPEC`` で設定されるロギング仕様で制御されます。

完全なロギングレベルの指定は次のような形式です。

::

    [<logger>[,<logger>...]=]<level>[:[<logger>[,<logger>...]=]<level>...]

ロギングの重要度レベルは、以下に示す大文字と小文字を区別しない文字列を使用して指定します。

::

   FATAL | PANIC | ERROR | WARNING | INFO | DEBUG

ロギングレベルはそれ自体が全体的なデフォルトとして扱われます。
あるいは、以下の構文を使用して、logger の個々またはグループに対する上書き指定ができます。

::

    <logger>[,<logger>...]=<level>

この仕様の一例は以下の通りです:

::

    info                                        - デフォルトをINFOに設定
    warning:msp,gossip=warning:chaincode=info   - デフォルトはWARNING、msp, gossip, chaincodeは上書き
    chaincode=info:msp,gossip=warning:warning   - 同上

.. note:: ロギング仕様の項目はコロンで区切られます。もし、ある項目が特定の logger を含んでいない場合 (例えば `info:`)、その項目はコンポーネント上のすべての logger のデフォルトのログレベルとして適用されます。
   文字列 `info:dockercontroller,endorser,chaincode,chaincode.platform=debug` は、すべての logger のデフォルトのログレベルを `INFO` に設定し、
   さらに logger `dockercontroller`, `endorser`, `chaincode` と `chaincode.platform` を `DEBUG` に設定します。
   項目の順序は関係ありません。上の例では、2番目と3番目のオプションは順序が逆でも同じ結果になります。

Logging format
--------------

``peer`` および ``orderer`` コマンドのロギングフォーマットは、 ``FABRIC_LOGGING_FORMAT`` 環境変数を介して制御されます。
これはフォーマット文字列を設定することができます。例えばデフォルトは以下の通りで、人間が読みやすい形式でコンソールにログを出力します。

::

   "%{color}%{time:2006-01-02 15:04:05.000 MST} [%{module}] %{shortfunc} -> %{level:.4s} %{id:03x}%{color:reset} %{message}"

環境変数に ``json`` を設定することでJSON形式でログを出力することが可能です。


Chaincode
---------

**チェーンコードのロギングはチェーンコード開発者の責任です。**

独立して実行されるプログラムとして、ユーザー提供のチェーンコードは
技術的には 標準出力/標準エラーに出力を生成することができます。
これらの出力は「devmode」では当然有用なのですが、
一方、通常、本番ネットワークでは壊れたあるいは悪意のあるコードによる不正利用を防ぐために無効になっています。
ただし、CORE_VM_DOCKER_ATTACHSTDOUT=true 設定オプションを使用することで、
ピア管理コンテナ (「netmode」など) でもピアごとにこの出力を有効にすることができます。

有効にすると、各チェーンコードは、そのコンテナID (container-id) によってキーが設定された自身のロギングチャネルを受け取ります。
標準出力または標準エラーに書き込まれたすべての出力は、行単位でピアのログに統合されます。
本番環境でこの機能を有効にすることは推奨されません。

ピアコンテナに転送されない標準出力と標準エラーは、
お使いのコンテナプラットフォームの標準コマンドを使用して、チェーンコードコンテナから表示することができます。

::

    docker logs <chaincode_container_id>
    kubectl logs -n <namespace> <pod_name>
    oc logs -n <namespace> <pod_name>



.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
