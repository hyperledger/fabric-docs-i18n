# Enabling the new chaincode lifecycle

v1.4.x から v2.x にアップグレードした場合、新しいライフサイクルの機能を有効にするために、チャネル設定を編集する必要があります。このプロセスは [channel configuration updates](./config_update.html) に関連しているので、必要に応じて確認してください。

新しいチェーンコードライフサイクルを動作させるためには、アプリケーションチャネルの `Channel` と `Application` の [capabilities](./capabilities_concept.html) を、 `V2_0` に更新する必要があります。より詳しい情報は、 [Considerations for getting to 2.0](./upgrade_to_newest_version.html#chaincode-lifecycle) を参照してください。

チャネル設定の更新は、大まかに3ステップあります。この更新は各チャネルに対して実施してください。

1. 最新のチャネル設定の取得
2. 修正したチャネル設定の作成
3. 設定更新トランザクションの作成

`enable_lifecycle.json` を使用してチャネル設定を更新します。このファイルは、チャネル設定で変更する箇所の全てを含みます。本番環境の設定に関しては、複数のユーザがチャネル更新のリクエストを送信することになります。しかし、単純化のために、ここでは単一のファイルを使用して更新する方法を説明します。

## Create `enable_lifecycle.json`

`enable_lifecycle.json` を使用することに加えて、このチュートリアルでは `jq` を使用します。これは、修正内容をファイルに適用するために使用します。また修正するファイルは、（プルし、トランスレイトし、スコープした後に）手動で編集することも可能です。関連する情報は、 [sample channel configuration](./config_update.html#sample-channel-configuration) を参照してください。

ここで説明するJSONファイルと `jq` の様なツールを使用したプロセスは、スクリプタブルで数多くののチャネルを更新することに適しており、チャネル設定を編集するためのプロセスとして推奨されています。

また、ここで説明する `enable_lifecycle.json` は、 `org1Policies` や `Org1ExampleCom` の様なサンプル値を使用します。これらは、使用する環境に合わせて設定してください。

```
{
  "org1Policies": {
      "Endorsement": {
           "mod_policy": "Admins",
           "policy": {
               "type": 1,
               "value": {
               "identities": [
                  {
	                 "principal": {
	           	         "msp_identifier": "Org1ExampleCom",
	           	         "role": "PEER"
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
      }
   },
  "org2Policies": {
      "Endorsement": {
           "mod_policy": "Admins",
           "policy": {
               "type": 1,
               "value": {
               "identities": [
                  {
	                 "principal": {
	           	         "msp_identifier": "Org2ExampleCom",
	           	         "role": "PEER"
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
      }
   },
   "appPolicies": {
 		"Endorsement": {
			"mod_policy": "Admins",
			"policy": {
				"type": 3,
				"value": {
					"rule": "MAJORITY",
					"sub_policy": "Endorsement"
				}
			},
			"version": "0"
		},
		"LifecycleEndorsement": {
			"mod_policy": "Admins",
			"policy": {
				"type": 3,
				"value": {
					"rule": "MAJORITY",
					"sub_policy": "Endorsement"
				}
			},
			"version": "0"
		}
   },
   "acls": {
		"_lifecycle/CheckCommitReadiness": {
			"policy_ref": "/Channel/Application/Writers"
		},
		"_lifecycle/CommitChaincodeDefinition": {
			"policy_ref": "/Channel/Application/Writers"
		},
		"_lifecycle/QueryChaincodeDefinition": {
			"policy_ref": "/Channel/Application/Readers"
		},
		"_lifecycle/QueryChaincodeDefinitions": {
			"policy_ref": "/Channel/Application/Readers"
		}
   }
}
```

**注釈：新しいポリシーの"role"フィールドに関して、 [NodeOUs](./msp.html#organizational-units) が組織で有効になっている場合は `'PEER'` 、そうでない場合は `'MEMBER'` を設定する必要があります。**

## Edit the channel configurations

### System channel updates

新しいライフサイクルを有効にするシステムチャネルへの設定変更は、チャネル設定に含まれるピア組織の設定パラメータにだけ関連するので、編集された各ピア組織は関連するチャネル設定の更新に署名する必要があります。

しかしデフォルトでは、システムチャネル管理者によってのみシステムチャネルは編集されます。（典型的なシステムチャネル管理者は、ピア組織ではなくオーダリングサービス組織の管理者です。）これは、コンソーシアム内のピア組織への設定更新はシステムチャネル管理者によって提案され、署名が必要なピア組織に送信されます。

また、以下の環境変数をエクスポートする必要があります:

* `CH_NAME`: 更新するシステムチャネルの名称
* `CORE_PEER_LOCALMSPID`: チャネルの更新を提案した組織のMSP ID（オーダリングサービス組織の1つのMSP IDになります。）
* `CORE_PEER_MSPCONFIGPATH`: 対象組織のMSPへの絶対パス
* `TLS_ROOT_CA`: システムチャネルの更新を提案した組織が持つルートCA証明書への絶対パス
* `ORDERER_CONTAINER`: オーダリングノードコンテナの名称（どのオーダリングサービスのノードを対象としても良いです。自動的にリーダーに転送されます。）
* `ORGNAME`: 更新する対象組織の名称
* `CONSORTIUM_NAME`: 更新するコンソーシアムの名称

環境変数を設定した後は、 [Step 1: Pull and translate the config](./config_update.html#step-1-pull-and-translate-the-config) を参照してください。

その後に、 `enable_lifecycle.json` にある様なライフサイクル組織ポリシーを、以下のコマンドを使用して `modified_config.json` に追加してください:

```
jq -s ".[0] * {\"channel_group\":{\"groups\":{\"Consortiums\":{\"groups\": {\"$CONSORTIUM_NAME\": {\"groups\": {\"$ORGNAME\": {\"policies\": .[1].${ORGNAME}Policies}}}}}}}}" config.json ./enable_lifecycle.json > modified_config.json
```

そして、 [Step 3: Re-encode and submit the config](./config_update.html#step-3-re-encode-and-submit-the-config) を参照してください。

前述した様に、これらの更新はシステムチャネル管理者によって提案され、署名が必要なピア組織に送信されます。

### Application channel updates

#### Edit the peer organizations

全てのアプリケーションチャネル上の全組織に対して、同様のセットの編集をする必要があります。

システムチャネルとは異なり、ピア組織はアプリケーションチャネルに対して設定更新のリクエストを作成できます。自組織の設定に変更を加えたい場合、他組織の署名なしに変更することが可能です。しかし、異なる組織の設定に変更を加える場合、当該組織が変更を承認する必要があります。

また、以下の環境変数をエクスポートする必要があります:

* `CH_NAME`: 更新するアプリケーションチャネルの名称
* `ORGNAME`: 更新する対象組織の名称
* `TLS_ROOT_CA`: オーダリングノードのTLS証明書への絶対パス
* `CORE_PEER_MSPCONFIGPATH`: 対象組織のMSPへの絶対パス
* `CORE_PEER_LOCALMSPID`: チャネルの更新を提案した組織のMSP ID（ピア組織のMSP IDになります。）
* `ORDERER_CONTAINER`: オーダリングノードコンテナの名称（どのオーダリングサービスのノードを対象としても良いです。自動的にリーダーに転送されます。）

環境変数を設定した後は、 [Step 1: Pull and translate the config](./config_update.html#step-1-pull-and-translate-the-config) を参照してください。

Then, add the lifecycle organization policy (as listed in `enable_lifecycle.json`) to a file called `modified_config.json` using this command:

その後に、 `enable_lifecycle.json` にある様なライフサイクル組織ポリシーを、以下のコマンドを使用して `modified_config.json` に追加してください:

```
jq -s ".[0] * {\"channel_group\":{\"groups\":{\"Application\": {\"groups\": {\"$ORGNAME\": {\"policies\": .[1].${ORGNAME}Policies}}}}}}" config.json ./enable_lifecycle.json > modified_config.json
```

そして、 [Step 3: Re-encode and submit the config](./config_update.html#step-3-re-encode-and-submit-the-config) を参照してください。

#### Edit the application channels

[updated to include V2_0 capabilities](./upgrade_to_newest_version.html#capabilities) に沿って全てのアプリケーションチャネルのケーパビリティを更新した後、新しいチェーンコードライフサイクル向けの各アプリケーションチャネルのエンドースメントポリシーを更新してください。

ピア組織を更新する際、同じ環境変数を設定することができます。この場合、設定ファイル内の組織の設定を更新できないので、 `ORGNAME` の環境変数は使用できません。

環境変数を設定した後は、 [Step 1: Pull and translate the config](./config_update.html#step-1-pull-and-translate-the-config) を参照してください。

その後に、 `enable_lifecycle.json` にある様なライフサイクル組織ポリシーを、以下のコマンドを使用して `modified_config.json` に追加してください:

```
jq -s '.[0] * {"channel_group":{"groups":{"Application": {"policies": .[1].appPolicies}}}}' config.json ./enable_lifecycle.json > modified_config.json
```

そして、 [Step 3: Re-encode and submit the config](./config_update.html#step-3-re-encode-and-submit-the-config) を参照してください。

チャネルの更新が承認されるためには、設定に含まれる `Channel/Application`  セクションの変更のためのポリシーを満たす必要があります。デフォルトでは、チャネルのピア組織の `過半数` を得る必要があります。

#### Edit channel ACLs (optional)

`enable_lifecycle.json` に含まれる以下の [Access Control List (ACL)](./access_control.html)  は、新しいライフサイクルのためのデフォルト値です。ユースケースに応じて、それらを変更してください。

```
"acls": {
 "_lifecycle/CheckCommitReadiness": {
   "policy_ref": "/Channel/Application/Writers"
 },
 "_lifecycle/CommitChaincodeDefinition": {
   "policy_ref": "/Channel/Application/Writers"
 },
 "_lifecycle/QueryChaincodeDefinition": {
   "policy_ref": "/Channel/Application/Readers"
 },
 "_lifecycle/QueryChaincodeDefinitions": {
   "policy_ref": "/Channel/Application/Readers"
```

アプリケーションチャネルを編集したときと同様に、環境変数を設定します。

環境変数を設定した後は、 [Step 1: Pull and translate the config](./config_update.html#step-1-pull-and-translate-the-config) を参照してください。

その後、 `enable_lifecycle.json` にある様なACLを、以下のコマンドを使用して `modified_config.json` に追加してください:

```
jq -s '.[0] * {"channel_group":{"groups":{"Application": {"values": {"ACLs": {"value": {"acls": .[1].acls}}}}}}}' config.json ./enable_lifecycle.json > modified_config.json
```

そして、 [Step 3: Re-encode and submit the config](./config_update.html#step-3-re-encode-and-submit-the-config) を参照してください。

チャネルの更新が承認されるためには、設定に含まれる `Channel/Application`  セクションの変更のためのポリシーを満たす必要があります。デフォルトでは、チャネルのピア組織の `過半数` を得る必要があります。

## Enable new lifecycle in `core.yaml`

`diff` の様なツールを使用して新しいバージョンと古いバージョンの `core.yaml` を比較するような、　[the recommended process](./upgrading_your_components.html#overview) の方法に沿う場合、 `chaincode/system` 配下にある新しいバージョンの `core.yaml` に `_lifecycle: enable` が含まれるため、システムチェーンコードリストに `_lifecycle: enable` を追加する必要はありません。

しかし、古いノードのYAMLファイルを直接更新する場合、システムチェーンコードリストに `_lifecycle: enable` を、 追加する必要があります。

ノードのアップグレードに関するより詳しい情報は、 [Upgrading your components](./upgrading_your_components.html) を参照してください。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
