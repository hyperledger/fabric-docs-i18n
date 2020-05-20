# 使用新的链码生命周期

从1.4升级到2.0的用户将需要修改通道配置以使用新的生命周期特性。这个过程涉及到一系列相关用户必须要执行的[通道配置更新](./config_update.html)。

需要注意的是，你的应用通道的 `通道` 和 `应用` [能力](./capabilities_concept.html) 需要更新到 `V2_0` ，以确保新的链码生命周期能工作。 更多详情请参考 [升级2.0注意事项](./upgrade_to_newest_version.html#chaincode-lifecycle) 

从大的方面看，每一个通道配置升级需要执行三个步骤：

1. 获取最新的通道配置
2. 创建一个修改后的通道配置
3. 创建一个配置更新交易

我们将借助文件 `enable_lifecycle.json`来执行这些通道配置更新, 这个文件包含了我们需要做的所有通道配置更新。不得不注意的是，在生产配置中很可能多个用户都会发出这些通道更新请求。可是，为了简单起见，我们将在一个文件中表示所有用户的更新。

## 创建 `enable_lifecycle.json`

需要注意的是，除了 `enable_lifecycle.json`, 还需要使用`jq`对修改后的配置文件进行编辑。修改后的配置文件也可以被手动修改（在文件被拉取，翻译和检查后）。详情请参考 [通道配置样本](./config_update.html#sample-channel-configuration) 。

但是，这里描述的过程 (使用一个JSON文件和一个像`jq`的工具) 确实具备可被编写脚本的优势，适合于提交大批量的通道配置更新，也是编辑一个通道配置的推荐过程。

需要注意的是`enable_lifecycle.json` 使用的是样本值，比如说 `org1Policies` 和 `Org1ExampleCom`, 在你部署时需将值特殊处理):

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

**注意:  如果这个组织启用了 [NodeOUs](./msp.html#organizational-units) , 同时不属于`'MEMBER'` 的话，这些新策略中的"role"字段应该设置成 `'PEER'` 。**

## 编辑通道配置
### 系统通道更新

因为使用新生命周期的系统通道配置修改，仅会涉及到系统通道配置内的节点组织配置参数，被编辑的每个节点组织需要对相关的通道配置进行签名更新。

可是, 在默认情况下, 系统通道只能被系统管理员编辑 (通常这些人是排序服务组织的管理员，而不是节点组织的管理员), 也就是说联盟中的节点组织的配置更新只能由系统通道的管理员提议和发送到相关节点组织进行签名。

你需要导出以下变量：

* `CH_NAME`: 被更新的系统通道名称
* `CORE_PEER_LOCALMSPID`: 提交的通道更新组织的MSP ID。这是排序服务组织中一员的MSP。 
* `CORE_PEER_MSPCONFIGPATH`: 代表组织的MSP的绝对路径。
* `TLS_ROOT_CA`: 提交的系统通道更新的组织的根CA证书的绝对路径
* `ORDERER_CONTAINER`: 一个排序节点容器的名称。 当定位排序服务时，你可以在排序服务中定位任意一个特定节点。你的请求将会被自动推送至领导者。
* `ORGNAME`: 你正在更新的组织名称。
* `CONSORTIUM_NAME`: 被更新联盟的名称。
  
环境变量设置完毕后，导航至 [Step 1: Pull and translate the config](./config_update.html#step-1-pull-and-translate-the-config).

 `modified_config.json`设置完毕后, 添加生命周期组织策略 ( 像`enable_lifecycle.json`文件中所展示的) 使用以下命令:
```
jq -s ".[0] * {\"channel_group\":{\"groups\":{\"Consortiums\":{\"groups\": {\"$CONSORTIUM_NAME\": {\"groups\": {\"$ORGNAME\": {\"policies\": .[1].${ORGNAME}Policies}}}}}}}}" config.json ./enable_lifecycle.json > modified_config.json
```

紧接着, 按照步骤[Step 3: Re-encode and submit the config]进行操作(./config_update.html#step-3-re-encode-and-submit-the-config).

综上所述, 这些变更需要由系统通道管理员提议并发送到相关节点组织进行签名。

### Application channel updates
### 应用通道更新
#### Edit the peer organizations
#### 编辑节点组织

我们需要针对所有应用通道上的组织，执行一系列类似的编辑。

需要说明的是，不像系统通道，节点组织能够针对应用通道进行配置更新生成请求。如果你是针对你自己的组织进行配置变更，将不需要其他企业组织的签名确认。 但是，如果你要对其他组织进行配置变更，则那个组织将需要批准这次变更。

你需要导出以下变量:

* `CH_NAME`: 被更新的应用通道名称。
* `ORGNAME`: 你正在更新的组织名称。
* `TLS_ROOT_CA`: 排序节点TLS证书的绝对路径。
* `CORE_PEER_MSPCONFIGPATH`: 代表组织的MSP的绝对路径。
* `CORE_PEER_LOCALMSPID`: 提交的通道更新组织的MSP ID。这是节点服务组织中一员的MSP。 
* `ORDERER_CONTAINER`: 一个排序节点容器的名称。 当定位排序服务时，你可以在排序服务中定位任意一个特定节点。你的请求将会被自动推送至领导者。
  
环境变量设置完毕后，导航至 [Step 1: Pull and translate the config](./config_update.html#step-1-pull-and-translate-the-config).

 `modified_config.json`设置完毕后, 添加生命周期组织策略 ( 像`enable_lifecycle.json`文件中所展示的) 使用以下命令:

```
jq -s ".[0] * {\"channel_group\":{\"groups\":{\"Application\": {\"groups\": {\"$ORGNAME\": {\"policies\": .[1].${ORGNAME}Policies}}}}}}" config.json ./enable_lifecycle.json > modified_config.json
```
紧接着, 按照步骤[Step 3: Re-encode and submit the config]进行操作(./config_update.html#step-3-re-encode-and-submit-the-config).

#### Edit the application channels
#### 编辑应用通道

待所有应用通道更新至2.0[updated to include V2_0 capabilities](./upgrade_to_newest_version.html#capabilities),
新链码生命周期的背书策略必须被添加到每个通道。

你可以设置和你更新节点组织时设置的一样的环境变量。在这种情况下，需要注意的是你不需要更新配置中的组织配置，所以不需要使用 `ORGNAME` 变量。

环境变量设置完毕后，导航至 [Step 1: Pull and translate the config](./config_update.html#step-1-pull-and-translate-the-config).

 `modified_config.json`设置完毕后, 添加通道背书策略 ( 像`enable_lifecycle.json`文件中所展示的) 使用以下命令:

```
jq -s '.[0] * {"channel_group":{"groups":{"Application": {"policies": .[1].appPolicies}}}}' config.json ./enable_lifecycle.json > modified_config.json
```

紧接着, 按照步骤[Step 3: Re-encode and submit the config]进行操作(./config_update.html#step-3-re-encode-and-submit-the-config).

若想要通道更新被批准，修改配置中 `Channel/Application` 章节的策略需要被满足。默认情况下，这是通道中节点组织的 `MAJORITY`。

#### Edit channel ACLs (optional)
#### 编辑通道访问控制列表（可选的）

对于新生命周期，虽然下面的 [Access Control List (ACL)](./access_control.html) 在`enable_lifecycle.json` 展示的是默认值，但是你可以根据你的用例选择是否更改他们。

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

您可以保留与以前编辑应用程序通道时相同的环境。

环境变量设置完毕后，导航至 [Step 1: Pull and translate the config](./config_update.html#step-1-pull-and-translate-the-config).

 `modified_config.json`设置完毕后, 添加ACLS ( 像`enable_lifecycle.json`文件中所展示的) 使用以下命令:

```
jq -s '.[0] * {"channel_group":{"groups":{"Application": {"values": {"ACLs": {"value": {"acls": .[1].acls}}}}}}}' config.json ./scripts/policies.json > modified_config.json
```

紧接着, 按照步骤[Step 3: Re-encode and submit the config]进行操作(./config_update.html#step-3-re-encode-and-submit-the-config).

若想要通道更新被批准，修改配置中 `Channel/Application` 章节的策略需要被满足。默认情况下，这是通道中节点组织的 `MAJORITY`。

## Enable new lifecycle in `core.yaml`
## 在`core.yaml`使用新生命周期

若按照 [the recommended process](./upgrading_your_components.html#overview) 使用一个像 `diff` 的工具以二进制来对比 `core.yaml` 的新版与旧版, 你将不需要将 `_lifecycle: enable` 加入白名单因为新的 `core.yaml` 已经加入到了 `chaincode/system`。

但是，如果你直接更新你的旧节点的YAML文件，你需要将`_lifecycle: enable` 添加至系统链码白名单。

如果想了解关于节点升级的更多信息，请参考[Upgrading your components]

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
