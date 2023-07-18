# Updating the capability level of a channel

*対象読者: ネットワーク管理者、ノード管理者*

ケーパビリティに慣れていない場合は、先に進む前に [Capabilities](./capabilities_concept.html) をチェックしてください。特に **ケーパビリティを有効にする前に、チャネルに属するピアとordererをアップグレードする必要がある** ことに注意してください。

Fabricの最新リリースの新しいケーパビリティレベルについては、 [Upgrading your components](./upgrade_to_newest_version.html#Capabilities) をご覧ください。

注意: Hyperledger Fabricで「アップグレード」という用語を使用する場合、コンポーネントのバージョンを変更することを指します(例えば、バイナリのとあるバージョンからその次のバージョンに移動すること)。一方、「アップデート」という用語は、バージョンではなく、チャネル設定やデプロイスクリプトの更新のような設定変更を意味します。Fabricでは、技術的にはデータ移行が行われていないため、ここでは「マイグレーション」または「マイグレート」という用語は使用しません。

## Prerequisites and considerations

まだ行っていない場合は、 [Prerequisites](./prereqs.html) で説明されているように、マシンのすべての依存関係を確認してください。これにより、チャネル設定をアップデートをする必要があるツールの最新バージョンがあるこことを確認できます。

Fabricバイナリはローリング方式でアップグレードでき、アップグレードする必要がありますが、 **ケーパビリティを有効にする前にバイナリのアップグレードを完了する** ことが重要です。少なくとも関連するケーパビリティのレベルにアップグレードされていないバイナリは、クラッシュして設定ミスを示し、台帳のフォークが発生する可能性があります。

ケーパビリティを有効にすると、そのチャネルの恒久的な記録の一部となります。つまり、ケーパビリティを無効にした後でも、古いバイナリはチャネルに参加できないことを意味します。なぜなら、それらはケーパビリティが有効になっているブロックを超えて処理し、無効にするブロックに到達することができないからです。その結果、一度ケーパビリティが有効になると、それを無効にすることは推奨もサポートもされていません。

このため、チャネルケイパビリティを有効にすることは、後戻りできないポイントだと考えてください。新しいケーパビリティをテスト設定で試してみて、本番で有効にする前に自信を持つようにしてください。

## Overview

このチュートリアルでは、オーダリングシステムチャネルと任意のアプリケーションチャネルの両方の設定のすべての部分でケーパビリティを更新するためのプロセスを示します。

すべてのチャネルについて、設定のすべての部分を更新する必要があるかどうかは、最新のリリース内容と自身のユースケースによって異なります。詳細については、 [Upgrading to the latest version of Fabric](./upgrade_to_newest_version.html) を参照してください。最新のリリースの機能を使用する前に、最新のケーパビリティレベルへ更新する必要がある場合があることに注意してください。ベストプラクティスは常に最新のバイナリバージョンとケーパビリティレベルであることが考えられます。

チャネルのケーパビリティレベルの更新には設定更新トランザクションプロセスが含まれるため、多くのコマンドについては [Updating a channel configuration](./config_update.html) トピックに依存します。

他のチャネル設定の更新と同様に、ケーパビリティの更新は、高いレベルでは、次のような3段階のプロセス(チャネルごと)になっています。

1. 最新のチャネル設定を取得する
2. 修正されたチャネル設定を作成する
3. コンフィグレーション更新トランザクションを作成する

次の順序でこれらのケーパビリティを有効にします。

1. [Orderer system channel](#orderer-system-channel-capabilities)

  * Orderer group
  * Channel group

2. [Application channels](#enable-capabilities-on-existing-channels)

  * Orderer group
  * Channel group
  * Application group

チャネルの設定の複数の部分を同時に編集することは可能ですが、このチュートリアルでは、このプロセスがどのように段階的に行われるかを説明します。つまり、システムチャネルの `Orderer` グループと `Channel` グループへの変更を1つの設定変更にまとめることはありません。これは、すべてのリリースが新しい `Orderer` グループケーパビリティと `Channel` グループケーパビリティの両方を持つわけではないためです。

本番ネットワークでは、1つのユーザーがこれらのチャネル(および構成の一部)のすべてを一方的に更新することは不可能であり、望ましいことではないことに注意してください。例えば、ordererシステムチャネルは、オーダリング組織管理者によって排他的に管理されています(ピア組織をオーダリングサービス組織として追加することは可能ですが)。同様に、チャネル設定の `Orderer` または `Channel` グループのいずれかを更新するには、ピア組織に加えてオーダリングサービス組織の署名が必要です。分散型システムは共同管理を必要とします。

#### Create a capabilities config file

このチュートリアルは、 `capabilities.json` というファイルが作成されていることを前提としており、さまざまな設定のセクションに対して行うケーパビリティの更新が含まれています。また、 `jq` を使用して、変更された設定ファイルに編集を適用します。

`capabilities.json` のようなファイルを作成したり、 `jq` のようなツールを使用したりすることは義務ではありません。変更された設定は、(プル、変換、スコープした後に)手動で編集することもできます。参考として、こちらの [sample channel configuration](./config_update.html#sample-channel-configuration) をご覧ください。

しかし、ここで説明するプロセス(JSONファイルと `jq` のようなツールの使用)は、スクリプト化できるという利点があり、多数のチャネルに設定更新を提案するのに適しています。 **そのため、チャンネル更新の方法として推奨されています。**

この例では、 `capabilities.json` ファイルは次のようになります(注:チャネルを [Upgrading to the latest version of Fabric](./upgrade_to_newest_version.html) の一部として更新する場合は、そのリリースに適したレベルにケーパビリティを設定する必要があります)。

```
   {
     "channel": {
         "mod_policy": "Admins",
             "value": {
                 "capabilities": {
                     "V2_0": {}
                 }
             },
         "version": "0"
     },
     "orderer": {
         "mod_policy": "Admins",
             "value": {
                 "capabilities": {
                     "V2_0": {}
                 }
             },
         "version": "0"
     },
     "application": {
         "mod_policy": "Admins",
             "value": {
                 "capabilities": {
                     "V2_0": {}
                 }
             },
         "version": "0"
     }
   }
```

デフォルトのピア組織はordererシステムチャネルの管理者ではないため、設定の更新を提案することはできないことに注意してください。オーダリング組織管理者は、システムのチャネル設定の更新を提案するために、次のようなファイルを作成する必要があります(システムチャネルに存在しない `application` グループケーパビリティを除く)。アプリケーションチャネルはシステムチャネル設定をデフォルトでコピーするため、ケーパビリティレベルを指定する別のチャネルプロファイルが作成されない限り、アプリケーションチャネルの `Channel` および `Orderer` グループケーパビリティは、ネットワークのシステムチャネルのものと同じになることに注意してください。

## Orderer system channel capabilities

アプリケーションチャネルはordererシステムチャネルの設定をデフォルトでコピーするため、アプリケーションチャネルよりも先にシステムチャネルのケーパビリティを更新することはベストプラクティスと見なされています。これは、 [Upgrading your components](./upgrading_your_components.html) で説明されているように、ピアよりも先にオーダリングノードを最新バージョンに更新するプロセスを反映しています。

ordererシステムチャネルは、オーダリングサービス組織によって管理されていることに注意してください。デフォルトでは、これは単一の組織(オーダリングサービスに最初のノードを作成した組織)になりますが、ここではより多くの組織を追加できます(たとえば、複数の組織がオーダリングサービスにノードを提供している場合)。

`Orderer` と `Channel` ケイパビリティを更新する前に、オーダリングサービス内のすべてのオーダリングノードが要求されたバイナリレベルにアップグレードされていることを確認してください。オーダリングノードが要求レベルにない場合、ケーパビリティで構成ブロックを処理することができず、クラッシュします。同様に、このオーダリングサービスに新しいチャネルが作成された場合、それに参加するすべてのピアは、少なくとも `Channel` と `Application` のケーパビリティに対応するノードレベルである必要があります。そうしないと、コンフィギュレーションブロックを処理しようとした場合にもクラッシュします。詳細については、 [Capabilities](./capabilities_concept.html) を参照してください。

### Set environment variables

次の変数をエクスポートする必要があります。

* `CH_NAME`: 更新されるシステムチャネルの名前。
* `CORE_PEER_LOCALMSPID`: チャネル更新を提案する組織のMSP ID。これは、orderer組織の1つのMSPになります。
* `TLS_ROOT_CA`: オーダリングノードのTLS証明書への絶対パス。
* `CORE_PEER_MSPCONFIGPATH`: 組織を表すMSPへの絶対パス。
* `ORDERER_CONTAINER`: オーダリングノードコンテナの名前。オーダリングサービスをターゲットにする場合、オーダリングサービス内の特定のノードをターゲットにできます。リクエストは自動的にリーダーに転送されます。

### `Orderer` group

チャネル設定をプル、変換、スコープするコマンドについては、 [Step 1: Pull and translate the config](./config_update.html#step-1-pull-and-translate-the-config) に移動します。 `modified_config.json` を取得したら、次のコマンドを使用して、設定の `Orderer` グループ( `capabilities.json` にリストされている)にケーパビリティを追加します。

```
jq -s '.[0] * {"channel_group":{"groups":{"Orderer": {"values": {"Capabilities": .[1].orderer}}}}}' config.json ./capabilities.json > modified_config.json
```

その後、 [Step 3: Re-encode and submit the config](./config_update.html#step-3-re-encode-and-submit-the-config) での手順に従ってください。

システムチャネルを更新するため、システムチャネルの `mod_policy` は、オーダリングサービス組織の管理者の署名のみを必要とすることに注意してください。

### `Channel` group

もう一度、 [Step 1: Pull and translate the config](./config_update.html#step-1-pull-and-translate-the-config) に移動します。 `modified_config.json` を取得したら、次のコマンドを使用して、設定の `Channel` グループ( `capabilities.json` にリストされている)にケーパビリティを追加します。

```
jq -s '.[0] * {"channel_group":{"values": {"Capabilities": .[1].channel}}}' config.json ./capabilities.json > modified_config.json
```

その後、 [Step 3: Re-encode and submit the config](./config_update.html#step-3-re-encode-and-submit-the-config) の手順に従ってください。

システムチャネルを更新するため、システムチャネルの `mod_policy` は、オーダリングサービス組織の管理者の署名のみを必要とすることに注意してください。アプリケーションチャネルでは、これから説明するように、通常、デフォルト値を変更していないと仮定すると、`Application`グループ（ピア組織のMSPで構成）と`Orderer`グループ（オーダリングサービス組織で構成）の両方の `MAJORITY` `Admins` ポリシーを満たす必要があるでしょう。

## Enable capabilities on existing channels

ordererシステムチャネルでケーパビリティを更新したので、更新したい既存のアプリケーションチャネルの設定を更新する必要があります。

お分かりのように、アプリケーションチャネルの設定はシステムチャネルのそれと非常によく似ています。これにより、 `capabilities.json` と、システムチャネルの更新に使用したのと同じコマンドを再利用することができます(異なる環境変数を使用しますが、これについては後で説明します)。

**ケーパビリティを更新する前に、オーダリングサービス内のすべてのオーダリングノードとチャネル上のピアが、要求されたバイナリレベルにアップグレードされていることを確認してください。ピアまたはオーダリングノードが要求レベルにない場合、コンフィグレーションブロックをケーパビリティで処理することができず、クラッシュします。** 詳細については、 [Capabilities](./capabilities_concept.html) を参照してください。

### Set environment variables

次の変数をエクスポートする必要があります。

* `CH_NAME`: 更新されるアプリケーションチャネルの名前。チャネルを更新する毎に、この変数をリセットする必要があります。
* `CORE_PEER_LOCALMSPID`: チャネル更新を提案する組織のMSP ID。これはあなたのピア組織のMSPになります。
* `TLS_ROOT_CA`: ピア組織のTLS証明書への絶対パス。
* `CORE_PEER_MSPCONFIGPATH`: MSPを表す組織への絶対パス。
* `ORDERER_CONTAINER`: オーダリングノードコンテナの名前。オーダリングサービスをターゲットにする場合、オーダリングサービス内の特定のノードをターゲットにできます。リクエストは自動的にリーダーに転送されます。

### `Orderer` group

[Step 1: Pull and translate the config](./config_update.html#step-1-pull-and-translate-the-config) に移動します。 `modified_config.json` を取得したら、次のコマンドを使用して、設定の `Orderer` グループにケーパビリティを追加します( `capabilities.json` に記載されています)。

```
jq -s '.[0] * {"channel_group":{"groups":{"Orderer": {"values": {"Capabilities": .[1].orderer}}}}}' config.json ./capabilities.json > modified_config.json
```

その後、 [Step 3: Re-encode and submit the config](./config_update.html#step-3-re-encode-and-submit-the-config) の手順に従ってください。

このケーパビリティの `mod_policy` は、デフォルトで `Orderer` グループの` Admins` の `MAJORITY` (つまり、オーダリングサービスのadminsの過半数)になります。ピア組織はこのケーパビリティに更新を提案することができますが、この場合、それらの署名は関連するポリシーを満たしません。

### `Channel` group

[Step 1: Pull and translate the config](./config_update.html#step-1-pull-and-translate-the-config) に移動します。 `modified_config.json` を取得したら、次のコマンドを使用して、設定の `Channel` グループにケーパビリティを追加します( `capabilities.json` に記載されています)。

```
jq -s '.[0] * {"channel_group":{"values": {"Capabilities": .[1].channel}}}' config.json ./capabilities.json > modified_config.json
```

その後、 [Step 3: Re-encode and submit the config](./config_update.html#step-3-re-encode-and-submit-the-config) の手順に従ってください。

このケーパビリティの `mod_policy` は、デフォルトでは、 `Application` グループと `Orderer` グループの `Admins` の `MAJORITY` の両方からの署名を必要とすることに注意してください。つまり、ピア組織管理者の過半数とオーダリングサービス組織管理者の両方が、この要求に署名しなければならないということです。

### `Application` group

[Step 1: Pull and translate the config](./config_update.html#step-1-pull-and-translate-the-config) に移動します。 `modified_config.json` を取得したら、次のコマンドを使用して、設定の `Application` グループにケーパビリティを追加します( `capabilities.json` に記載されています)。

```
jq -s '.[0] * {"channel_group":{"groups":{"Application": {"values": {"Capabilities": .[1].application}}}}}' config.json ./capabilities.json > modified_config.json
```

その後、 [Step 3: Re-encode and submit the config](./config_update.html#step-3-re-encode-and-submit-the-config) での手順に従ってください。

このケーパビリティの `mod_policy` は、デフォルトでは` Application` グループの `Admins` の `MAJORITY` からの署名を必要とすることに注意してください。つまり、ピア組織の過半数が承認する必要があります。オーダリングサービスの管理者は、このケーパビリティでは発言権がありません。

**その結果、このケーパビリティを存在しないレベルに変更しないように十分注意してください。** オーダリングノードは `Application` ケーパビリティを理解も検証するもしないため、設定を任意のレベルに承認し、新しいコンフィギュレーションブロックをピアに送信して台帳にコミットします。しかし、ピアはケーパビリティを処理することができず、クラッシュします。また、修正された設定変更を正当なケーパビリティレベルにすることが可能であったとしても、不完全なケーパビリティを持つ以前のコンフィギュレーションブロックが台帳に存在し、処理しようとするとピアがクラッシュします。

これが、 `capabilities.json` のようなファイルが便利な理由の1つです。これにより、チャネルが使用できなくなり、回復できなくなるような単純なユーザーエラー(例えば、 `Application` ケーパビリティを `V2_0` に設定しようとしていたときに `V20` に設定するなど)が防止されます。

## Verify a transaction after capabilities have been enabled

これは、すべてのチャネルでチェーンコード呼び出しにより、ケーパビリティが正常に有効になっていることを保証するためのベストプラクティスです。新しいケーパビリティを理解していないノードが十分なバイナリレベルにアップグレードされていない場合、それらはクラッシュします。正常に再起動するには、バイナリレベルをアップグレードする必要があります。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
