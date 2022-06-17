# Access Control Lists (ACL)

## What is an Access Control List?

*注釈: このトピックでは、チャネル管理レベルのアクセス制御とポリシーを説明します。
チェーンコードのアクセス制御を学ぶ場合、[chaincode for developers tutorial](./chaincode4ade.html#Chaincode_API)を参照してください。*

Fabricは、[Policy](policies/policies.html)をリソースに関連付けることで、アクセス制御リスト(ACL)を使用したリソースのアクセス管理を行います。
Fabricには、デフォルトのアクセス制御リストがたくさんあります。
このドキュメントでは、アクセス制御リストのフォーマット、および、デフォルトを上書きする方法を説明します。

しかし、その前に、リソースとポリシーについて少し理解する必要があります。

### Resources

ユーザとFabricのやり取りは、[ユーザーチェーンコード](./chaincode4ade.html)、[イベントソース](./peer_event_services.html)、または、バックグラウンドで呼び出されるシステムチェーンコードで発生します。
そのため、これらのエンドポイントは、アクセス制御を実行する必要がある"リソース"と見なされます。

アプリケーション開発者は、これらのリソースとそれらに関連付けられたデフォルトポリシーを認識する必要があります。
これらのリソースの完全なリストは `configtx.yaml` にあります。
[`configtx.yaml` のサンプルファイルはこちら](http://github.com/hyperledger/fabric/blob/release-2.0/sampleconfig/configtx.yaml)を参照してください。

`configtx.yaml`で指定されたリソースは、Fabricによって現在定義されているすべての内部リソースの完全なリストです。
ここで採用されている緩い規約は `<component>/<resource>` です。
したがって、 `cscc/GetConfigBlock` は、 `CSCC` コンポーネント内の`GetConfigBlock` 呼出しのリソースです。

### Policies

ポリシーはFabricの動作において重要です。
リクエストに関連づけられたアイデンティティ(またはアイデンティティのセット)は、リクエストを処理するために必要なリソースに関連づけられたポリシーと照合されます。
エンドースメントポリシーは、トランザクションが適切にエンドースされているかどうかを判断するために使用されます。
チャネル設定で定義されたポリシーは、アクセス制御だけでなく変更ポリシーとしても参照され、チャネル設定自体で定義されます。

ポリシーは、`Signature` ポリシーと `ImplicitMeta` ポリシーのうち、いずれかの方法で記述されます。

#### `Signature` policies

このポリシーは、どのユーザからの署名が必要かを指定します。
次に例を示します。

```
Policies:
  MyPolicy:
    Type: Signature
    Rule: "OR('Org1.peer', 'Org2.peer')"

```

このポリシー構造体は次のように解釈できます。*`MyPolicy` という名前のポリシーは、"Org1のピア"または"Org2のピア"の役割を持つアイデンティティの署名によってのみ満たされます*。

Signatureポリシーは、 `AND` 、 `OR` 、 `NOutOf` の任意の組み合わせをサポートしており、"組織Aの管理者とそれ以外の2組織の管理者、もしくは、20組織のうち11組織の管理者"のように非常に強力なルールを記述することもできます。

#### `ImplicitMeta` policies

`ImplicitMeta` ポリシーは、設定階層の下層部分で定義されている `Signature` ポリシーを集約します。
例えば、"その組織の管理者の過半数"のようなデフォルトルールをサポートしています。
これらのポリシーは、 `Signature` ポリシーとは異なりますが、非常に単純な構文を使用します。
`<ALL|ANY|MAJORITY> <sub_policy>`.

次に例を示します。: `ANY` `Readers` または `MAJORITY` `Admins`.

*デフォルトのポリシー設定では、 `Admins` は運用の役割を持ちます。
Admins(またはAdminsの一部)だけがリソースにアクセスできるポリシーは、ネットワークの機密性や運用面(チャネル上のチェーンコードのインスタンス化など)に使用される傾向があります。
`Writers` はトランザクションのように台帳の更新を提案できますが、通常は管理者権限を持たない傾向があります。
`Readers` は受動的な役割です。情報にアクセスすることはできますが、台帳の更新を提案する権限も管理タスクを実行する権限もありません。
これらのデフォルトポリシーは、例えば新しい `peer` ロールや `client` ロール( `NodeOU` を利用する場合)によって、追加、編集、補足することができます。*

`ImplicitMeta` ポリシーの記述例を示します。:

```
Policies:
  AnotherPolicy:
    Type: ImplicitMeta
    Rule: "MAJORITY Admins"
```

ここで、 `AnotherPolicy` ポリシーは、 `MAJORITY` の `Admins` により満たされます。
`Admins` は、より低レイヤの `Signature` ポリシーで定義されます。

### Where is access control specified?

アクセス制御のデフォルトは `configtx.yaml` に存在します。
`configtxgen` は、このファイルを利用してチャネル設定をビルドします。

アクセス制御は、次のいずれかの方法で更新できます。
1つ目は、 `configtx.yaml` を編集し、新しいチャネル設定を生成する時に利用する方法です。
2つ目は、既存チャネルのチャネル設定内のアクセス制御を更新する方法です。

## How ACLs are formatted in `configtx.yaml`

ACLは、リソース関数名の後に文字列が続くキーバリューペアで記述されます。
これがどのように見えるかを確認するには、[configtx.yamlのサンプルファイル](https://github.com/hyperledger/fabric/blob/release-2.0/sampleconfig/configtx.yaml)を参照してください。

このサンプルからの2つの抜粋:

```
# ACL policy for invoking chaincodes on peer
peer/Propose: /Channel/Application/Writers
```

```
# ACL policy for sending block events
event/Block: /Channel/Application/Readers
```

これらのアクセス制御リストは、`peer/Propose` と `event/Block` リソースへのアクセスが、それぞれ `/Channel/Application/Writers` と `/Channel/Application/Readers` という正規化パスで定義されたポリシーを満たすアイデンティティに制限されることを示します。

### Updating ACL defaults in `configtx.yaml`

ネットワークのブートストラップ時にACLのデフォルトを上書きする必要がある場合や、チャネルがブートストラップされる前にACLを変更する必要がある場合は、 `configtx.yaml` を更新するのがベストプラクティスです。

例えば、ピアのチェーンコード呼び出しに関するポリシーを指定する `peer/Propose` のACLのデフォルトを、 `/Channel/Application/Writers` から `MyPolicy` というポリシーに変更したいとしましょう。

これを行うには、 `MyPolicy` という名前のポリシーを追加します(このポリシーは任意の名前にすることができますが、この例では `MyPolicy` と呼びます)。
ポリシーは、 `configtx.yaml` 内の `Application.Policies` セクションで定義され、ユーザーへのアクセスを許可または拒否するためにチェックされるルールを指定します。
この例では、 `SampleOrg.admin` を識別する `Signature` ポリシーを作成します。

```
Policies: &ApplicationDefaultPolicies
    Readers:
        Type: ImplicitMeta
        Rule: "ANY Readers"
    Writers:
        Type: ImplicitMeta
        Rule: "ANY Writers"
    Admins:
        Type: ImplicitMeta
        Rule: "MAJORITY Admins"
    MyPolicy:
        Type: Signature
        Rule: "OR('SampleOrg.admin')"
```

それから、 `peer/Propose` を変更するために、 `configtx.yaml` 内の `Application: ACLs` セクションを:

`peer/Propose: /Channel/Application/Writers`

下記のように編集します。:

`peer/Propose: /Channel/Application/MyPolicy`

これらのフィールドが `configtx.yaml` で変更されると、チャネル作成トランザクションを作成する時、 `configtxgen` ツールはそのポリシーとACLを使用します。
コンソーシアムメンバーの管理者の1人が適切に署名して送信すると、定義されたACLとポリシーを持つ新しいチャネルが作成されます。

`MyPolicy` がチャネル設定にブートストラップされると、他のACLのデフォルトを上書きするために参照することもできます。
次に例を示します。

```
SampleSingleMSPChannel:
    Consortium: SampleConsortium
    Application:
        <<: *ApplicationDefaults
        ACLs:
            <<: *ACLsDefault
            event/Block: /Channel/Application/MyPolicy
```

これにより、 `SampleOrg.admin` がブロックイベントをサブスクライブする機能が制限されます。

このACLを使用するチャネルがすでに作成されている場合は、次のフローを使用してチャネル設定を一度に1つずつ更新する必要があります。

### Updating ACL defaults in the channel config

`MyPolicy` を使用して `peer/Propose` へのアクセスを制限するチャネルがすでに作成されている場合、または他のチャネルに知られたくないACLを作成したい場合は、コンフィギュレーション更新トランザクションを使用してチャネル設定を一度に1つずつ更新する必要があります。

*注釈: チャネル設定トランザクションはプロセスが複雑なので、ここでは詳しく説明しません。
詳細については、[channel configuration updates](./config_update.html)、および、["Adding an Org to a Channel" tutorial](./channel_update_tutorial.html)のドキュメントを参照してください。*

設定を編集するには、メタデータのコンフィギュレーションブロックを取得し、変換し、除去した後で、`Application: policies` の下に `MyPolicy` を追加します。
ここでは、 `Admins` と `Writers` と `Readers` の各ポリシーがすでに存在しています。

```
"MyPolicy": {
  "mod_policy": "Admins",
  "policy": {
    "type": 1,
    "value": {
      "identities": [
        {
          "principal": {
            "msp_identifier": "SampleOrg",
            "role": "ADMIN"
          },
          "principal_classification": "ROLE"
        }
      ],
      "rule": {
        "n_out_of": {
          "n": 1,
          "rules": [
            {
              "signed_by": 0
            }
          ]
        }
      },
      "version": 0
    }
  },
  "version": "0"
},
```

ここで特に `msp_identifier` と `role` に注意してください。

それから、設定のACLセクション内で、`peer/Propose` のACLを:

```
"peer/Propose": {
  "policy_ref": "/Channel/Application/Writers"
```

以下のように更新します。:

```
"peer/Propose": {
  "policy_ref": "/Channel/Application/MyPolicy"
```

注釈: チャネル設定でACLが定義されていない場合は、ACLセクション全体を追加する必要があります。

設定が更新されたら、通常のチャネル更新プロセスで送信する必要があります。

### Satisfying an ACL that requires access to multiple resources

メンバーが複数のシステムチェーンコードを呼び出す要求を行った場合は、それらのシステムチェーンコードに対するすべてのACLを満たす必要があります。

例えば、 `peer/Proposal` はチャネル上の任意の提案要求を参照します。
特定の提案が、 `Writers` を満たすアイデンティティを必要とする2つのシステムチェーンコードと、 `MyPolicy` を満たすアイデンティティを必要とする1つのシステムチェーンコードへのアクセスを必要とする場合、
提案を送信するメンバーは `Writers` と `MyPolicy` の両方が"true"と評価されるアイデンティティを持っている必要があります。

デフォルト設定では、 `Writers` は `SampleOrg.member` という `rule` を持つ署名ポリシーです。
つまり、"私の組織のすべてのメンバー"ということです。
上記の `MyPolicy` には、`SampleOrg.admin` 、つまり、"私の組織のすべての管理者"というルールがあります。
これらのACLを満たすためには、メンバーは管理者であると同時に `SampleOrg` のメンバーである必要があります。
デフォルトでは、すべての管理者がメンバーになっていますが(すべての管理者がメンバーになっているわけではありません)、これらのポリシーを任意のポリシーに上書きすることができます。
その場合、これらのポリシーを追跡して、(意図的ではない限り)ピアの提案を満たすことが不可能なACLになっていないことを確認することが重要です。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
