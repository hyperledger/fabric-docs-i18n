# Updating a channel configuration

*対象者：ネットワーク管理者、ノード管理者*

## What is a channel configuration?

多くの複雑なシステムと同様に、Hyperledger Fabricネットワークは、 **構造 (Structure)** といくつかの **プロセス (Processes)** の両方で構成されています。

* **構造 (Structure)**：ユーザー (管理者など)、組織、ピア、オーダリングノード、CA、スマートコントラクト、およびアプリケーションを含みます。
* **プロセス (Process)**：これらの構造がやりとりする方法です。これらの中で最も重要なのは、[ポリシー (Policies)](./policies/policies.html)です。これは、どのユーザーが何を、どのような条件下で実行できるかを管理するルールです。

ブロックチェーンネットワークの構造と、構造同士がどのようにやりとりするかを管理するプロセスを識別する情報は、 **チャネル設定 (Channel Configuration)** に含まれています。
これらの設定は、チャネルのメンバーによってまとめて決定され、チャネルの台帳にコミットされるブロックに含まれます。チャネル設定は、入力として `configtx.yaml` ファイルを使用する `configtxgen` と呼ばれるツールを使用して構築できます。
[サンプルの`configtx.yaml`ファイルはこちら](http://github.com/hyperledger/fabric/blob/release-2.2/sampleconfig/configtx.yaml)をご覧ください。

チャネル設定はブロックに含まれているため (これらのうち、最初のものは「ジェネシスブロック」と呼ばれ、最新のものはそのチャネルの現在の設定を表す)、
チャネル設定を更新するプロセス (たとえば、メンバー追加による構造の変更やチャネルポリシーの変更) は、 **設定更新トランザクション (Configuration Update Transaction)** と呼ばれます。

本番ネットワークでは、チャネルの初期設定がチャネルの初期メンバーによってネットワーク外で決定されるのと同様に、これらの設定更新トランザクションは通常、ネットワーク外での議論の後に単一のチャネル管理者によって提案されます。

このトピックでは、以下のことを説明します:

* アプリケーションチャネルの完全なサンプル設定を示します。
* 編集可能な多くのチャネルパラメータについて説明します。
* 設定を人間が読み取れるように取得、変換、スコープするために必要なコマンドを含む、チャネル設定を更新するプロセスを示します。
* チャネル設定の編集に使用できる方法について説明します。
* 設定を再フォーマットし、承認されるために必要な署名を取得するために使用されるプロセスを示します。

## Channel parameters that can be updated

チャネルは高度な設定が可能ですが、無限にできるわけではありません。
一旦、チャネルに関する特定の項目 (たとえば、チャネルの名前) が指定されると、それを変更することはできません。
また、このトピックで説明するパラメータを変更するには、チャネル設定で指定された関連するポリシーを満たす必要があります。

このセクションでは、チャネル設定のサンプルを見て、更新可能な設定パラメータを示します。

### Sample channel configuration

アプリケーションチャネルの設定ファイルが取得・スコープされた後にどのようになるかを確認するには、以下の **ここをクリックして設定を確認してください** をクリックしてください。
読みやすくするために、この設定をatomやVisual StudioのようなJSON形式のコード折り畳みをサポートするビューアに張り付けると便利です。

注: わかりやすくするために、ここではアプリケーションチャネルの設定のみを示しています。Ordererシステムチャネルの設定は、アプリケーションチャネルの設定と非常に似ていますが、同一ではありません。
しかし、同じ基本的なルールと構造が適用され、[チャネルのケーパビリティレベルの更新](./updating_capabilities.html) のトピックで見ることができるように、設定を取得して編集するコマンドも同じです。

<details>
  <summary>
    **ここをクリックして設定を確認してください**。なお、これはアプリケーションチャネルの設定であり、Ordererシステムチャネルの設定ではないことに注意してください。
  </summary>
  ```
  {
    "channel_group": {
      "groups": {
        "Application": {
          "groups": {
            "Org1MSP": {
              "groups": {},
              "mod_policy": "Admins",
              "policies": {
                "Admins": {
                  "mod_policy": "Admins",
                  "policy": {
                    "type": 1,
                    "value": {
                      "identities": [
                        {
                          "principal": {
                            "msp_identifier": "Org1MSP",
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
                "Endorsement": {
                  "mod_policy": "Admins",
                  "policy": {
                    "type": 1,
                    "value": {
                      "identities": [
                        {
                          "principal": {
                            "msp_identifier": "Org1MSP",
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
                },
                "Readers": {
                  "mod_policy": "Admins",
                  "policy": {
                    "type": 1,
                    "value": {
                      "identities": [
                        {
                          "principal": {
                            "msp_identifier": "Org1MSP",
                            "role": "ADMIN"
                          },
                          "principal_classification": "ROLE"
                        },
                        {
                          "principal": {
                            "msp_identifier": "Org1MSP",
                            "role": "PEER"
                          },
                          "principal_classification": "ROLE"
                        },
                        {
                          "principal": {
                            "msp_identifier": "Org1MSP",
                            "role": "CLIENT"
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
                            },
                            {
                              "signed_by": 1
                            },
                            {
                              "signed_by": 2
                            }
                          ]
                        }
                      },
                      "version": 0
                    }
                  },
                  "version": "0"
                },
                "Writers": {
                  "mod_policy": "Admins",
                  "policy": {
                    "type": 1,
                    "value": {
                      "identities": [
                        {
                          "principal": {
                            "msp_identifier": "Org1MSP",
                            "role": "ADMIN"
                          },
                          "principal_classification": "ROLE"
                        },
                        {
                          "principal": {
                            "msp_identifier": "Org1MSP",
                            "role": "CLIENT"
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
                            },
                            {
                              "signed_by": 1
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
              "values": {
                "AnchorPeers": {
                  "mod_policy": "Admins",
                  "value": {
                    "anchor_peers": [
                      {
                        "host": "peer0.org1.example.com",
                        "port": 7051
                      }
                    ]
                  },
                  "version": "0"
                },
                "MSP": {
                  "mod_policy": "Admins",
                  "value": {
                    "config": {
                      "admins": [],
                      "crypto_config": {
                        "identity_identifier_hash_function": "SHA256",
                        "signature_hash_family": "SHA2"
                      },
                      "fabric_node_ous": {
                        "admin_ou_identifier": {
                          "certificate": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNKekNDQWMyZ0F3SUJBZ0lVYWVSeWNkQytlR1lUTUNyWTg2UFVXUEdzQUw0d0NnWUlLb1pJemowRUF3SXcKY0RFTE1Ba0dBMVVFQmhNQ1ZWTXhGekFWQmdOVkJBZ1REazV2Y25Sb0lFTmhjbTlzYVc1aE1ROHdEUVlEVlFRSApFd1pFZFhKb1lXMHhHVEFYQmdOVkJBb1RFRzl5WnpFdVpYaGhiWEJzWlM1amIyMHhIREFhQmdOVkJBTVRFMk5oCkxtOXlaekV1WlhoaGJYQnNaUzVqYjIwd0hoY05NakF3TXpJME1qQXhPREF3V2hjTk16VXdNekl4TWpBeE9EQXcKV2pCd01Rc3dDUVlEVlFRR0V3SlZVekVYTUJVR0ExVUVDQk1PVG05eWRHZ2dRMkZ5YjJ4cGJtRXhEekFOQmdOVgpCQWNUQmtSMWNtaGhiVEVaTUJjR0ExVUVDaE1RYjNKbk1TNWxlR0Z0Y0d4bExtTnZiVEVjTUJvR0ExVUVBeE1UClkyRXViM0puTVM1bGVHRnRjR3hsTG1OdmJUQlpNQk1HQnlxR1NNNDlBZ0VHQ0NxR1NNNDlBd0VIQTBJQUJLWXIKSmtqcEhjRkcxMVZlU200emxwSmNCZEtZVjc3SEgvdzI0V09sZnphYWZWK3VaaEZ2YTFhQm9aaGx5RloyMGRWeApwMkRxb09BblZ4MzZ1V3o2SXl1alJUQkRNQTRHQTFVZER3RUIvd1FFQXdJQkJqQVNCZ05WSFJNQkFmOEVDREFHCkFRSC9BZ0VCTUIwR0ExVWREZ1FXQkJTcHpDQWdPaGRuSkE3VVpxUWlFSVFXSFpnYXZEQUtCZ2dxaGtqT1BRUUQKQWdOSUFEQkZBaUVBbEZtYWdIQkJoblFUd3dDOXBQRTRGbFY2SlhIbTdnQ1JyWUxUbVgvc0VySUNJRUhLZG51KwpIWDgrVTh1ZkFKbTdrL1laZEtVVnlWS2E3bGREUjlWajNveTIKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=",
                          "organizational_unit_identifier": "admin"
                        },
                        "client_ou_identifier": {
                          "certificate": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNKekNDQWMyZ0F3SUJBZ0lVYWVSeWNkQytlR1lUTUNyWTg2UFVXUEdzQUw0d0NnWUlLb1pJemowRUF3SXcKY0RFTE1Ba0dBMVVFQmhNQ1ZWTXhGekFWQmdOVkJBZ1REazV2Y25Sb0lFTmhjbTlzYVc1aE1ROHdEUVlEVlFRSApFd1pFZFhKb1lXMHhHVEFYQmdOVkJBb1RFRzl5WnpFdVpYaGhiWEJzWlM1amIyMHhIREFhQmdOVkJBTVRFMk5oCkxtOXlaekV1WlhoaGJYQnNaUzVqYjIwd0hoY05NakF3TXpJME1qQXhPREF3V2hjTk16VXdNekl4TWpBeE9EQXcKV2pCd01Rc3dDUVlEVlFRR0V3SlZVekVYTUJVR0ExVUVDQk1PVG05eWRHZ2dRMkZ5YjJ4cGJtRXhEekFOQmdOVgpCQWNUQmtSMWNtaGhiVEVaTUJjR0ExVUVDaE1RYjNKbk1TNWxlR0Z0Y0d4bExtTnZiVEVjTUJvR0ExVUVBeE1UClkyRXViM0puTVM1bGVHRnRjR3hsTG1OdmJUQlpNQk1HQnlxR1NNNDlBZ0VHQ0NxR1NNNDlBd0VIQTBJQUJLWXIKSmtqcEhjRkcxMVZlU200emxwSmNCZEtZVjc3SEgvdzI0V09sZnphYWZWK3VaaEZ2YTFhQm9aaGx5RloyMGRWeApwMkRxb09BblZ4MzZ1V3o2SXl1alJUQkRNQTRHQTFVZER3RUIvd1FFQXdJQkJqQVNCZ05WSFJNQkFmOEVDREFHCkFRSC9BZ0VCTUIwR0ExVWREZ1FXQkJTcHpDQWdPaGRuSkE3VVpxUWlFSVFXSFpnYXZEQUtCZ2dxaGtqT1BRUUQKQWdOSUFEQkZBaUVBbEZtYWdIQkJoblFUd3dDOXBQRTRGbFY2SlhIbTdnQ1JyWUxUbVgvc0VySUNJRUhLZG51KwpIWDgrVTh1ZkFKbTdrL1laZEtVVnlWS2E3bGREUjlWajNveTIKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=",
                          "organizational_unit_identifier": "client"
                        },
                        "enable": true,
                        "orderer_ou_identifier": {
                          "certificate": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNKekNDQWMyZ0F3SUJBZ0lVYWVSeWNkQytlR1lUTUNyWTg2UFVXUEdzQUw0d0NnWUlLb1pJemowRUF3SXcKY0RFTE1Ba0dBMVVFQmhNQ1ZWTXhGekFWQmdOVkJBZ1REazV2Y25Sb0lFTmhjbTlzYVc1aE1ROHdEUVlEVlFRSApFd1pFZFhKb1lXMHhHVEFYQmdOVkJBb1RFRzl5WnpFdVpYaGhiWEJzWlM1amIyMHhIREFhQmdOVkJBTVRFMk5oCkxtOXlaekV1WlhoaGJYQnNaUzVqYjIwd0hoY05NakF3TXpJME1qQXhPREF3V2hjTk16VXdNekl4TWpBeE9EQXcKV2pCd01Rc3dDUVlEVlFRR0V3SlZVekVYTUJVR0ExVUVDQk1PVG05eWRHZ2dRMkZ5YjJ4cGJtRXhEekFOQmdOVgpCQWNUQmtSMWNtaGhiVEVaTUJjR0ExVUVDaE1RYjNKbk1TNWxlR0Z0Y0d4bExtTnZiVEVjTUJvR0ExVUVBeE1UClkyRXViM0puTVM1bGVHRnRjR3hsTG1OdmJUQlpNQk1HQnlxR1NNNDlBZ0VHQ0NxR1NNNDlBd0VIQTBJQUJLWXIKSmtqcEhjRkcxMVZlU200emxwSmNCZEtZVjc3SEgvdzI0V09sZnphYWZWK3VaaEZ2YTFhQm9aaGx5RloyMGRWeApwMkRxb09BblZ4MzZ1V3o2SXl1alJUQkRNQTRHQTFVZER3RUIvd1FFQXdJQkJqQVNCZ05WSFJNQkFmOEVDREFHCkFRSC9BZ0VCTUIwR0ExVWREZ1FXQkJTcHpDQWdPaGRuSkE3VVpxUWlFSVFXSFpnYXZEQUtCZ2dxaGtqT1BRUUQKQWdOSUFEQkZBaUVBbEZtYWdIQkJoblFUd3dDOXBQRTRGbFY2SlhIbTdnQ1JyWUxUbVgvc0VySUNJRUhLZG51KwpIWDgrVTh1ZkFKbTdrL1laZEtVVnlWS2E3bGREUjlWajNveTIKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=",
                          "organizational_unit_identifier": "orderer"
                        },
                        "peer_ou_identifier": {
                          "certificate": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNKekNDQWMyZ0F3SUJBZ0lVYWVSeWNkQytlR1lUTUNyWTg2UFVXUEdzQUw0d0NnWUlLb1pJemowRUF3SXcKY0RFTE1Ba0dBMVVFQmhNQ1ZWTXhGekFWQmdOVkJBZ1REazV2Y25Sb0lFTmhjbTlzYVc1aE1ROHdEUVlEVlFRSApFd1pFZFhKb1lXMHhHVEFYQmdOVkJBb1RFRzl5WnpFdVpYaGhiWEJzWlM1amIyMHhIREFhQmdOVkJBTVRFMk5oCkxtOXlaekV1WlhoaGJYQnNaUzVqYjIwd0hoY05NakF3TXpJME1qQXhPREF3V2hjTk16VXdNekl4TWpBeE9EQXcKV2pCd01Rc3dDUVlEVlFRR0V3SlZVekVYTUJVR0ExVUVDQk1PVG05eWRHZ2dRMkZ5YjJ4cGJtRXhEekFOQmdOVgpCQWNUQmtSMWNtaGhiVEVaTUJjR0ExVUVDaE1RYjNKbk1TNWxlR0Z0Y0d4bExtTnZiVEVjTUJvR0ExVUVBeE1UClkyRXViM0puTVM1bGVHRnRjR3hsTG1OdmJUQlpNQk1HQnlxR1NNNDlBZ0VHQ0NxR1NNNDlBd0VIQTBJQUJLWXIKSmtqcEhjRkcxMVZlU200emxwSmNCZEtZVjc3SEgvdzI0V09sZnphYWZWK3VaaEZ2YTFhQm9aaGx5RloyMGRWeApwMkRxb09BblZ4MzZ1V3o2SXl1alJUQkRNQTRHQTFVZER3RUIvd1FFQXdJQkJqQVNCZ05WSFJNQkFmOEVDREFHCkFRSC9BZ0VCTUIwR0ExVWREZ1FXQkJTcHpDQWdPaGRuSkE3VVpxUWlFSVFXSFpnYXZEQUtCZ2dxaGtqT1BRUUQKQWdOSUFEQkZBaUVBbEZtYWdIQkJoblFUd3dDOXBQRTRGbFY2SlhIbTdnQ1JyWUxUbVgvc0VySUNJRUhLZG51KwpIWDgrVTh1ZkFKbTdrL1laZEtVVnlWS2E3bGREUjlWajNveTIKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=",
                          "organizational_unit_identifier": "peer"
                        }
                      },
                      "intermediate_certs": [],
                      "name": "Org1MSP",
                      "organizational_unit_identifiers": [],
                      "revocation_list": [],
                      "root_certs": [
                        "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNKekNDQWMyZ0F3SUJBZ0lVYWVSeWNkQytlR1lUTUNyWTg2UFVXUEdzQUw0d0NnWUlLb1pJemowRUF3SXcKY0RFTE1Ba0dBMVVFQmhNQ1ZWTXhGekFWQmdOVkJBZ1REazV2Y25Sb0lFTmhjbTlzYVc1aE1ROHdEUVlEVlFRSApFd1pFZFhKb1lXMHhHVEFYQmdOVkJBb1RFRzl5WnpFdVpYaGhiWEJzWlM1amIyMHhIREFhQmdOVkJBTVRFMk5oCkxtOXlaekV1WlhoaGJYQnNaUzVqYjIwd0hoY05NakF3TXpJME1qQXhPREF3V2hjTk16VXdNekl4TWpBeE9EQXcKV2pCd01Rc3dDUVlEVlFRR0V3SlZVekVYTUJVR0ExVUVDQk1PVG05eWRHZ2dRMkZ5YjJ4cGJtRXhEekFOQmdOVgpCQWNUQmtSMWNtaGhiVEVaTUJjR0ExVUVDaE1RYjNKbk1TNWxlR0Z0Y0d4bExtTnZiVEVjTUJvR0ExVUVBeE1UClkyRXViM0puTVM1bGVHRnRjR3hsTG1OdmJUQlpNQk1HQnlxR1NNNDlBZ0VHQ0NxR1NNNDlBd0VIQTBJQUJLWXIKSmtqcEhjRkcxMVZlU200emxwSmNCZEtZVjc3SEgvdzI0V09sZnphYWZWK3VaaEZ2YTFhQm9aaGx5RloyMGRWeApwMkRxb09BblZ4MzZ1V3o2SXl1alJUQkRNQTRHQTFVZER3RUIvd1FFQXdJQkJqQVNCZ05WSFJNQkFmOEVDREFHCkFRSC9BZ0VCTUIwR0ExVWREZ1FXQkJTcHpDQWdPaGRuSkE3VVpxUWlFSVFXSFpnYXZEQUtCZ2dxaGtqT1BRUUQKQWdOSUFEQkZBaUVBbEZtYWdIQkJoblFUd3dDOXBQRTRGbFY2SlhIbTdnQ1JyWUxUbVgvc0VySUNJRUhLZG51KwpIWDgrVTh1ZkFKbTdrL1laZEtVVnlWS2E3bGREUjlWajNveTIKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo="
                      ],
                      "signing_identity": null,
                      "tls_intermediate_certs": [],
                      "tls_root_certs": [
                        "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNKekNDQWMyZ0F3SUJBZ0lVYWVSeWNkQytlR1lUTUNyWTg2UFVXUEdzQUw0d0NnWUlLb1pJemowRUF3SXcKY0RFTE1Ba0dBMVVFQmhNQ1ZWTXhGekFWQmdOVkJBZ1REazV2Y25Sb0lFTmhjbTlzYVc1aE1ROHdEUVlEVlFRSApFd1pFZFhKb1lXMHhHVEFYQmdOVkJBb1RFRzl5WnpFdVpYaGhiWEJzWlM1amIyMHhIREFhQmdOVkJBTVRFMk5oCkxtOXlaekV1WlhoaGJYQnNaUzVqYjIwd0hoY05NakF3TXpJME1qQXhPREF3V2hjTk16VXdNekl4TWpBeE9EQXcKV2pCd01Rc3dDUVlEVlFRR0V3SlZVekVYTUJVR0ExVUVDQk1PVG05eWRHZ2dRMkZ5YjJ4cGJtRXhEekFOQmdOVgpCQWNUQmtSMWNtaGhiVEVaTUJjR0ExVUVDaE1RYjNKbk1TNWxlR0Z0Y0d4bExtTnZiVEVjTUJvR0ExVUVBeE1UClkyRXViM0puTVM1bGVHRnRjR3hsTG1OdmJUQlpNQk1HQnlxR1NNNDlBZ0VHQ0NxR1NNNDlBd0VIQTBJQUJLWXIKSmtqcEhjRkcxMVZlU200emxwSmNCZEtZVjc3SEgvdzI0V09sZnphYWZWK3VaaEZ2YTFhQm9aaGx5RloyMGRWeApwMkRxb09BblZ4MzZ1V3o2SXl1alJUQkRNQTRHQTFVZER3RUIvd1FFQXdJQkJqQVNCZ05WSFJNQkFmOEVDREFHCkFRSC9BZ0VCTUIwR0ExVWREZ1FXQkJTcHpDQWdPaGRuSkE3VVpxUWlFSVFXSFpnYXZEQUtCZ2dxaGtqT1BRUUQKQWdOSUFEQkZBaUVBbEZtYWdIQkJoblFUd3dDOXBQRTRGbFY2SlhIbTdnQ1JyWUxUbVgvc0VySUNJRUhLZG51KwpIWDgrVTh1ZkFKbTdrL1laZEtVVnlWS2E3bGREUjlWajNveTIKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo="
                      ]
                    },
                    "type": 0
                  },
                  "version": "0"
                }
              },
              "version": "1"
            },
            "Org2MSP": {
              "groups": {},
              "mod_policy": "Admins",
              "policies": {
                "Admins": {
                  "mod_policy": "Admins",
                  "policy": {
                    "type": 1,
                    "value": {
                      "identities": [
                        {
                          "principal": {
                            "msp_identifier": "Org2MSP",
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
                "Endorsement": {
                  "mod_policy": "Admins",
                  "policy": {
                    "type": 1,
                    "value": {
                      "identities": [
                        {
                          "principal": {
                            "msp_identifier": "Org2MSP",
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
                },
                "Readers": {
                  "mod_policy": "Admins",
                  "policy": {
                    "type": 1,
                    "value": {
                      "identities": [
                        {
                          "principal": {
                            "msp_identifier": "Org2MSP",
                            "role": "ADMIN"
                          },
                          "principal_classification": "ROLE"
                        },
                        {
                          "principal": {
                            "msp_identifier": "Org2MSP",
                            "role": "PEER"
                          },
                          "principal_classification": "ROLE"
                        },
                        {
                          "principal": {
                            "msp_identifier": "Org2MSP",
                            "role": "CLIENT"
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
                            },
                            {
                              "signed_by": 1
                            },
                            {
                              "signed_by": 2
                            }
                          ]
                        }
                      },
                      "version": 0
                    }
                  },
                  "version": "0"
                },
                "Writers": {
                  "mod_policy": "Admins",
                  "policy": {
                    "type": 1,
                    "value": {
                      "identities": [
                        {
                          "principal": {
                            "msp_identifier": "Org2MSP",
                            "role": "ADMIN"
                          },
                          "principal_classification": "ROLE"
                        },
                        {
                          "principal": {
                            "msp_identifier": "Org2MSP",
                            "role": "CLIENT"
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
                            },
                            {
                              "signed_by": 1
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
              "values": {
                "AnchorPeers": {
                  "mod_policy": "Admins",
                  "value": {
                    "anchor_peers": [
                      {
                        "host": "peer0.org2.example.com",
                        "port": 9051
                      }
                    ]
                  },
                  "version": "0"
                },
                "MSP": {
                  "mod_policy": "Admins",
                  "value": {
                    "config": {
                      "admins": [],
                      "crypto_config": {
                        "identity_identifier_hash_function": "SHA256",
                        "signature_hash_family": "SHA2"
                      },
                      "fabric_node_ous": {
                        "admin_ou_identifier": {
                          "certificate": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNIakNDQWNXZ0F3SUJBZ0lVQVFkb1B0S0E0bEk2a0RrMituYzk5NzNhSC9Vd0NnWUlLb1pJemowRUF3SXcKYkRFTE1Ba0dBMVVFQmhNQ1ZVc3hFakFRQmdOVkJBZ1RDVWhoYlhCemFHbHlaVEVRTUE0R0ExVUVCeE1IU0hWeQpjMnhsZVRFWk1CY0dBMVVFQ2hNUWIzSm5NaTVsZUdGdGNHeGxMbU52YlRFY01Cb0dBMVVFQXhNVFkyRXViM0puCk1pNWxlR0Z0Y0d4bExtTnZiVEFlRncweU1EQXpNalF5TURFNE1EQmFGdzB6TlRBek1qRXlNREU0TURCYU1Hd3gKQ3pBSkJnTlZCQVlUQWxWTE1SSXdFQVlEVlFRSUV3bElZVzF3YzJocGNtVXhFREFPQmdOVkJBY1RCMGgxY25OcwpaWGt4R1RBWEJnTlZCQW9URUc5eVp6SXVaWGhoYlhCc1pTNWpiMjB4SERBYUJnTlZCQU1URTJOaExtOXlaekl1ClpYaGhiWEJzWlM1amIyMHdXVEFUQmdjcWhrak9QUUlCQmdncWhrak9QUU1CQndOQ0FBVFk3VGJqQzdYSHNheC8Kem1yVk1nWnpmODBlb3JFbTNIdis2ZnRqMFgzd2cxdGZVM3hyWWxXZVJwR0JGeFQzNnJmVkdLLzhUQWJ2cnRuZgpUQ1hKak93a28wVXdRekFPQmdOVkhROEJBZjhFQkFNQ0FRWXdFZ1lEVlIwVEFRSC9CQWd3QmdFQi93SUJBVEFkCkJnTlZIUTRFRmdRVWJJNkV4dVRZSEpjczRvNEl5dXZWOVFRa1lGZ3dDZ1lJS29aSXpqMEVBd0lEUndBd1JBSWcKWndjdElBNmdoSlFCZmpDRXdRK1NmYi9iemdsQlV4b0g3ZHVtOUJrUjFkd0NJQlRqcEZkWlcyS2UzSVBMS1h2aApERmQvVmMrcloyMksyeVdKL1BIYXZWWmkKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=",
                          "organizational_unit_identifier": "admin"
                        },
                        "client_ou_identifier": {
                          "certificate": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNIakNDQWNXZ0F3SUJBZ0lVQVFkb1B0S0E0bEk2a0RrMituYzk5NzNhSC9Vd0NnWUlLb1pJemowRUF3SXcKYkRFTE1Ba0dBMVVFQmhNQ1ZVc3hFakFRQmdOVkJBZ1RDVWhoYlhCemFHbHlaVEVRTUE0R0ExVUVCeE1IU0hWeQpjMnhsZVRFWk1CY0dBMVVFQ2hNUWIzSm5NaTVsZUdGdGNHeGxMbU52YlRFY01Cb0dBMVVFQXhNVFkyRXViM0puCk1pNWxlR0Z0Y0d4bExtTnZiVEFlRncweU1EQXpNalF5TURFNE1EQmFGdzB6TlRBek1qRXlNREU0TURCYU1Hd3gKQ3pBSkJnTlZCQVlUQWxWTE1SSXdFQVlEVlFRSUV3bElZVzF3YzJocGNtVXhFREFPQmdOVkJBY1RCMGgxY25OcwpaWGt4R1RBWEJnTlZCQW9URUc5eVp6SXVaWGhoYlhCc1pTNWpiMjB4SERBYUJnTlZCQU1URTJOaExtOXlaekl1ClpYaGhiWEJzWlM1amIyMHdXVEFUQmdjcWhrak9QUUlCQmdncWhrak9QUU1CQndOQ0FBVFk3VGJqQzdYSHNheC8Kem1yVk1nWnpmODBlb3JFbTNIdis2ZnRqMFgzd2cxdGZVM3hyWWxXZVJwR0JGeFQzNnJmVkdLLzhUQWJ2cnRuZgpUQ1hKak93a28wVXdRekFPQmdOVkhROEJBZjhFQkFNQ0FRWXdFZ1lEVlIwVEFRSC9CQWd3QmdFQi93SUJBVEFkCkJnTlZIUTRFRmdRVWJJNkV4dVRZSEpjczRvNEl5dXZWOVFRa1lGZ3dDZ1lJS29aSXpqMEVBd0lEUndBd1JBSWcKWndjdElBNmdoSlFCZmpDRXdRK1NmYi9iemdsQlV4b0g3ZHVtOUJrUjFkd0NJQlRqcEZkWlcyS2UzSVBMS1h2aApERmQvVmMrcloyMksyeVdKL1BIYXZWWmkKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=",
                          "organizational_unit_identifier": "client"
                        },
                        "enable": true,
                        "orderer_ou_identifier": {
                          "certificate": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNIakNDQWNXZ0F3SUJBZ0lVQVFkb1B0S0E0bEk2a0RrMituYzk5NzNhSC9Vd0NnWUlLb1pJemowRUF3SXcKYkRFTE1Ba0dBMVVFQmhNQ1ZVc3hFakFRQmdOVkJBZ1RDVWhoYlhCemFHbHlaVEVRTUE0R0ExVUVCeE1IU0hWeQpjMnhsZVRFWk1CY0dBMVVFQ2hNUWIzSm5NaTVsZUdGdGNHeGxMbU52YlRFY01Cb0dBMVVFQXhNVFkyRXViM0puCk1pNWxlR0Z0Y0d4bExtTnZiVEFlRncweU1EQXpNalF5TURFNE1EQmFGdzB6TlRBek1qRXlNREU0TURCYU1Hd3gKQ3pBSkJnTlZCQVlUQWxWTE1SSXdFQVlEVlFRSUV3bElZVzF3YzJocGNtVXhFREFPQmdOVkJBY1RCMGgxY25OcwpaWGt4R1RBWEJnTlZCQW9URUc5eVp6SXVaWGhoYlhCc1pTNWpiMjB4SERBYUJnTlZCQU1URTJOaExtOXlaekl1ClpYaGhiWEJzWlM1amIyMHdXVEFUQmdjcWhrak9QUUlCQmdncWhrak9QUU1CQndOQ0FBVFk3VGJqQzdYSHNheC8Kem1yVk1nWnpmODBlb3JFbTNIdis2ZnRqMFgzd2cxdGZVM3hyWWxXZVJwR0JGeFQzNnJmVkdLLzhUQWJ2cnRuZgpUQ1hKak93a28wVXdRekFPQmdOVkhROEJBZjhFQkFNQ0FRWXdFZ1lEVlIwVEFRSC9CQWd3QmdFQi93SUJBVEFkCkJnTlZIUTRFRmdRVWJJNkV4dVRZSEpjczRvNEl5dXZWOVFRa1lGZ3dDZ1lJS29aSXpqMEVBd0lEUndBd1JBSWcKWndjdElBNmdoSlFCZmpDRXdRK1NmYi9iemdsQlV4b0g3ZHVtOUJrUjFkd0NJQlRqcEZkWlcyS2UzSVBMS1h2aApERmQvVmMrcloyMksyeVdKL1BIYXZWWmkKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=",
                          "organizational_unit_identifier": "orderer"
                        },
                        "peer_ou_identifier": {
                          "certificate": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNIakNDQWNXZ0F3SUJBZ0lVQVFkb1B0S0E0bEk2a0RrMituYzk5NzNhSC9Vd0NnWUlLb1pJemowRUF3SXcKYkRFTE1Ba0dBMVVFQmhNQ1ZVc3hFakFRQmdOVkJBZ1RDVWhoYlhCemFHbHlaVEVRTUE0R0ExVUVCeE1IU0hWeQpjMnhsZVRFWk1CY0dBMVVFQ2hNUWIzSm5NaTVsZUdGdGNHeGxMbU52YlRFY01Cb0dBMVVFQXhNVFkyRXViM0puCk1pNWxlR0Z0Y0d4bExtTnZiVEFlRncweU1EQXpNalF5TURFNE1EQmFGdzB6TlRBek1qRXlNREU0TURCYU1Hd3gKQ3pBSkJnTlZCQVlUQWxWTE1SSXdFQVlEVlFRSUV3bElZVzF3YzJocGNtVXhFREFPQmdOVkJBY1RCMGgxY25OcwpaWGt4R1RBWEJnTlZCQW9URUc5eVp6SXVaWGhoYlhCc1pTNWpiMjB4SERBYUJnTlZCQU1URTJOaExtOXlaekl1ClpYaGhiWEJzWlM1amIyMHdXVEFUQmdjcWhrak9QUUlCQmdncWhrak9QUU1CQndOQ0FBVFk3VGJqQzdYSHNheC8Kem1yVk1nWnpmODBlb3JFbTNIdis2ZnRqMFgzd2cxdGZVM3hyWWxXZVJwR0JGeFQzNnJmVkdLLzhUQWJ2cnRuZgpUQ1hKak93a28wVXdRekFPQmdOVkhROEJBZjhFQkFNQ0FRWXdFZ1lEVlIwVEFRSC9CQWd3QmdFQi93SUJBVEFkCkJnTlZIUTRFRmdRVWJJNkV4dVRZSEpjczRvNEl5dXZWOVFRa1lGZ3dDZ1lJS29aSXpqMEVBd0lEUndBd1JBSWcKWndjdElBNmdoSlFCZmpDRXdRK1NmYi9iemdsQlV4b0g3ZHVtOUJrUjFkd0NJQlRqcEZkWlcyS2UzSVBMS1h2aApERmQvVmMrcloyMksyeVdKL1BIYXZWWmkKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=",
                          "organizational_unit_identifier": "peer"
                        }
                      },
                      "intermediate_certs": [],
                      "name": "Org2MSP",
                      "organizational_unit_identifiers": [],
                      "revocation_list": [],
                      "root_certs": [
                        "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNIakNDQWNXZ0F3SUJBZ0lVQVFkb1B0S0E0bEk2a0RrMituYzk5NzNhSC9Vd0NnWUlLb1pJemowRUF3SXcKYkRFTE1Ba0dBMVVFQmhNQ1ZVc3hFakFRQmdOVkJBZ1RDVWhoYlhCemFHbHlaVEVRTUE0R0ExVUVCeE1IU0hWeQpjMnhsZVRFWk1CY0dBMVVFQ2hNUWIzSm5NaTVsZUdGdGNHeGxMbU52YlRFY01Cb0dBMVVFQXhNVFkyRXViM0puCk1pNWxlR0Z0Y0d4bExtTnZiVEFlRncweU1EQXpNalF5TURFNE1EQmFGdzB6TlRBek1qRXlNREU0TURCYU1Hd3gKQ3pBSkJnTlZCQVlUQWxWTE1SSXdFQVlEVlFRSUV3bElZVzF3YzJocGNtVXhFREFPQmdOVkJBY1RCMGgxY25OcwpaWGt4R1RBWEJnTlZCQW9URUc5eVp6SXVaWGhoYlhCc1pTNWpiMjB4SERBYUJnTlZCQU1URTJOaExtOXlaekl1ClpYaGhiWEJzWlM1amIyMHdXVEFUQmdjcWhrak9QUUlCQmdncWhrak9QUU1CQndOQ0FBVFk3VGJqQzdYSHNheC8Kem1yVk1nWnpmODBlb3JFbTNIdis2ZnRqMFgzd2cxdGZVM3hyWWxXZVJwR0JGeFQzNnJmVkdLLzhUQWJ2cnRuZgpUQ1hKak93a28wVXdRekFPQmdOVkhROEJBZjhFQkFNQ0FRWXdFZ1lEVlIwVEFRSC9CQWd3QmdFQi93SUJBVEFkCkJnTlZIUTRFRmdRVWJJNkV4dVRZSEpjczRvNEl5dXZWOVFRa1lGZ3dDZ1lJS29aSXpqMEVBd0lEUndBd1JBSWcKWndjdElBNmdoSlFCZmpDRXdRK1NmYi9iemdsQlV4b0g3ZHVtOUJrUjFkd0NJQlRqcEZkWlcyS2UzSVBMS1h2aApERmQvVmMrcloyMksyeVdKL1BIYXZWWmkKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo="
                      ],
                      "signing_identity": null,
                      "tls_intermediate_certs": [],
                      "tls_root_certs": [
                        "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNIakNDQWNXZ0F3SUJBZ0lVQVFkb1B0S0E0bEk2a0RrMituYzk5NzNhSC9Vd0NnWUlLb1pJemowRUF3SXcKYkRFTE1Ba0dBMVVFQmhNQ1ZVc3hFakFRQmdOVkJBZ1RDVWhoYlhCemFHbHlaVEVRTUE0R0ExVUVCeE1IU0hWeQpjMnhsZVRFWk1CY0dBMVVFQ2hNUWIzSm5NaTVsZUdGdGNHeGxMbU52YlRFY01Cb0dBMVVFQXhNVFkyRXViM0puCk1pNWxlR0Z0Y0d4bExtTnZiVEFlRncweU1EQXpNalF5TURFNE1EQmFGdzB6TlRBek1qRXlNREU0TURCYU1Hd3gKQ3pBSkJnTlZCQVlUQWxWTE1SSXdFQVlEVlFRSUV3bElZVzF3YzJocGNtVXhFREFPQmdOVkJBY1RCMGgxY25OcwpaWGt4R1RBWEJnTlZCQW9URUc5eVp6SXVaWGhoYlhCc1pTNWpiMjB4SERBYUJnTlZCQU1URTJOaExtOXlaekl1ClpYaGhiWEJzWlM1amIyMHdXVEFUQmdjcWhrak9QUUlCQmdncWhrak9QUU1CQndOQ0FBVFk3VGJqQzdYSHNheC8Kem1yVk1nWnpmODBlb3JFbTNIdis2ZnRqMFgzd2cxdGZVM3hyWWxXZVJwR0JGeFQzNnJmVkdLLzhUQWJ2cnRuZgpUQ1hKak93a28wVXdRekFPQmdOVkhROEJBZjhFQkFNQ0FRWXdFZ1lEVlIwVEFRSC9CQWd3QmdFQi93SUJBVEFkCkJnTlZIUTRFRmdRVWJJNkV4dVRZSEpjczRvNEl5dXZWOVFRa1lGZ3dDZ1lJS29aSXpqMEVBd0lEUndBd1JBSWcKWndjdElBNmdoSlFCZmpDRXdRK1NmYi9iemdsQlV4b0g3ZHVtOUJrUjFkd0NJQlRqcEZkWlcyS2UzSVBMS1h2aApERmQvVmMrcloyMksyeVdKL1BIYXZWWmkKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo="
                      ]
                    },
                    "type": 0
                  },
                  "version": "0"
                }
              },
              "version": "1"
            }
          },
          "mod_policy": "Admins",
          "policies": {
            "Admins": {
              "mod_policy": "Admins",
              "policy": {
                "type": 3,
                "value": {
                  "rule": "MAJORITY",
                  "sub_policy": "Admins"
                }
              },
              "version": "0"
            },
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
            },
            "Readers": {
              "mod_policy": "Admins",
              "policy": {
                "type": 3,
                "value": {
                  "rule": "ANY",
                  "sub_policy": "Readers"
                }
              },
              "version": "0"
            },
            "Writers": {
              "mod_policy": "Admins",
              "policy": {
                "type": 3,
                "value": {
                  "rule": "ANY",
                  "sub_policy": "Writers"
                }
              },
              "version": "0"
            }
          },
          "values": {
            "Capabilities": {
              "mod_policy": "Admins",
              "value": {
                "capabilities": {
                  "V2_0": {}
                }
              },
              "version": "0"
            }
          },
          "version": "1"
        },
        "Orderer": {
          "groups": {
            "OrdererOrg": {
              "groups": {},
              "mod_policy": "Admins",
              "policies": {
                "Admins": {
                  "mod_policy": "Admins",
                  "policy": {
                    "type": 1,
                    "value": {
                      "identities": [
                        {
                          "principal": {
                            "msp_identifier": "OrdererMSP",
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
                "Readers": {
                  "mod_policy": "Admins",
                  "policy": {
                    "type": 1,
                    "value": {
                      "identities": [
                        {
                          "principal": {
                            "msp_identifier": "OrdererMSP",
                            "role": "MEMBER"
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
                "Writers": {
                  "mod_policy": "Admins",
                  "policy": {
                    "type": 1,
                    "value": {
                      "identities": [
                        {
                          "principal": {
                            "msp_identifier": "OrdererMSP",
                            "role": "MEMBER"
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
              "values": {
                "MSP": {
                  "mod_policy": "Admins",
                  "value": {
                    "config": {
                      "admins": [],
                      "crypto_config": {
                        "identity_identifier_hash_function": "SHA256",
                        "signature_hash_family": "SHA2"
                      },
                      "fabric_node_ous": {
                        "admin_ou_identifier": {
                          "certificate": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNDekNDQWJHZ0F3SUJBZ0lVUkgyT0tlV1loaStFMkFHZ3IwWUdlVTRUOWs0d0NnWUlLb1pJemowRUF3SXcKWWpFTE1Ba0dBMVVFQmhNQ1ZWTXhFVEFQQmdOVkJBZ1RDRTVsZHlCWmIzSnJNUkV3RHdZRFZRUUhFd2hPWlhjZwpXVzl5YXpFVU1CSUdBMVVFQ2hNTFpYaGhiWEJzWlM1amIyMHhGekFWQmdOVkJBTVREbU5oTG1WNFlXMXdiR1V1ClkyOXRNQjRYRFRJd01ETXlOREl3TVRnd01Gb1hEVE0xTURNeU1USXdNVGd3TUZvd1lqRUxNQWtHQTFVRUJoTUMKVlZNeEVUQVBCZ05WQkFnVENFNWxkeUJaYjNKck1SRXdEd1lEVlFRSEV3aE9aWGNnV1c5eWF6RVVNQklHQTFVRQpDaE1MWlhoaGJYQnNaUzVqYjIweEZ6QVZCZ05WQkFNVERtTmhMbVY0WVcxd2JHVXVZMjl0TUZrd0V3WUhLb1pJCnpqMENBUVlJS29aSXpqMERBUWNEUWdBRS9yb2dWY0hFcEVQMDhTUTl3VTVpdkNxaUFDKzU5WUx1dkRDNkx6UlIKWXdyZkFxdncvT0FodVlQRkhnRFZ1SFExOVdXMGxSV2FKWmpVcDFxNmRCWEhlYU5GTUVNd0RnWURWUjBQQVFILwpCQVFEQWdFR01CSUdBMVVkRXdFQi93UUlNQVlCQWY4Q0FRRXdIUVlEVlIwT0JCWUVGTG9kWFpjaTVNNlFxYkNUCm1YZ3lTbU1aYlZHWE1Bb0dDQ3FHU000OUJBTUNBMGdBTUVVQ0lRQ0hFTElvajJUNG15ODI0SENQRFc2bEZFRTEKSDc1c2FyN1V4TVJSNmFWckZnSWdMZUxYT0ZoSDNjZ0pGeDhJckVyTjlhZmdjVVIyd0ZYUkQ0V0V0MVp1bmxBPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==",
                          "organizational_unit_identifier": "admin"
                        },
                        "client_ou_identifier": {
                          "certificate": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNDekNDQWJHZ0F3SUJBZ0lVUkgyT0tlV1loaStFMkFHZ3IwWUdlVTRUOWs0d0NnWUlLb1pJemowRUF3SXcKWWpFTE1Ba0dBMVVFQmhNQ1ZWTXhFVEFQQmdOVkJBZ1RDRTVsZHlCWmIzSnJNUkV3RHdZRFZRUUhFd2hPWlhjZwpXVzl5YXpFVU1CSUdBMVVFQ2hNTFpYaGhiWEJzWlM1amIyMHhGekFWQmdOVkJBTVREbU5oTG1WNFlXMXdiR1V1ClkyOXRNQjRYRFRJd01ETXlOREl3TVRnd01Gb1hEVE0xTURNeU1USXdNVGd3TUZvd1lqRUxNQWtHQTFVRUJoTUMKVlZNeEVUQVBCZ05WQkFnVENFNWxkeUJaYjNKck1SRXdEd1lEVlFRSEV3aE9aWGNnV1c5eWF6RVVNQklHQTFVRQpDaE1MWlhoaGJYQnNaUzVqYjIweEZ6QVZCZ05WQkFNVERtTmhMbVY0WVcxd2JHVXVZMjl0TUZrd0V3WUhLb1pJCnpqMENBUVlJS29aSXpqMERBUWNEUWdBRS9yb2dWY0hFcEVQMDhTUTl3VTVpdkNxaUFDKzU5WUx1dkRDNkx6UlIKWXdyZkFxdncvT0FodVlQRkhnRFZ1SFExOVdXMGxSV2FKWmpVcDFxNmRCWEhlYU5GTUVNd0RnWURWUjBQQVFILwpCQVFEQWdFR01CSUdBMVVkRXdFQi93UUlNQVlCQWY4Q0FRRXdIUVlEVlIwT0JCWUVGTG9kWFpjaTVNNlFxYkNUCm1YZ3lTbU1aYlZHWE1Bb0dDQ3FHU000OUJBTUNBMGdBTUVVQ0lRQ0hFTElvajJUNG15ODI0SENQRFc2bEZFRTEKSDc1c2FyN1V4TVJSNmFWckZnSWdMZUxYT0ZoSDNjZ0pGeDhJckVyTjlhZmdjVVIyd0ZYUkQ0V0V0MVp1bmxBPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==",
                          "organizational_unit_identifier": "client"
                        },
                        "enable": true,
                        "orderer_ou_identifier": {
                          "certificate": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNDekNDQWJHZ0F3SUJBZ0lVUkgyT0tlV1loaStFMkFHZ3IwWUdlVTRUOWs0d0NnWUlLb1pJemowRUF3SXcKWWpFTE1Ba0dBMVVFQmhNQ1ZWTXhFVEFQQmdOVkJBZ1RDRTVsZHlCWmIzSnJNUkV3RHdZRFZRUUhFd2hPWlhjZwpXVzl5YXpFVU1CSUdBMVVFQ2hNTFpYaGhiWEJzWlM1amIyMHhGekFWQmdOVkJBTVREbU5oTG1WNFlXMXdiR1V1ClkyOXRNQjRYRFRJd01ETXlOREl3TVRnd01Gb1hEVE0xTURNeU1USXdNVGd3TUZvd1lqRUxNQWtHQTFVRUJoTUMKVlZNeEVUQVBCZ05WQkFnVENFNWxkeUJaYjNKck1SRXdEd1lEVlFRSEV3aE9aWGNnV1c5eWF6RVVNQklHQTFVRQpDaE1MWlhoaGJYQnNaUzVqYjIweEZ6QVZCZ05WQkFNVERtTmhMbVY0WVcxd2JHVXVZMjl0TUZrd0V3WUhLb1pJCnpqMENBUVlJS29aSXpqMERBUWNEUWdBRS9yb2dWY0hFcEVQMDhTUTl3VTVpdkNxaUFDKzU5WUx1dkRDNkx6UlIKWXdyZkFxdncvT0FodVlQRkhnRFZ1SFExOVdXMGxSV2FKWmpVcDFxNmRCWEhlYU5GTUVNd0RnWURWUjBQQVFILwpCQVFEQWdFR01CSUdBMVVkRXdFQi93UUlNQVlCQWY4Q0FRRXdIUVlEVlIwT0JCWUVGTG9kWFpjaTVNNlFxYkNUCm1YZ3lTbU1aYlZHWE1Bb0dDQ3FHU000OUJBTUNBMGdBTUVVQ0lRQ0hFTElvajJUNG15ODI0SENQRFc2bEZFRTEKSDc1c2FyN1V4TVJSNmFWckZnSWdMZUxYT0ZoSDNjZ0pGeDhJckVyTjlhZmdjVVIyd0ZYUkQ0V0V0MVp1bmxBPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==",
                          "organizational_unit_identifier": "orderer"
                        },
                        "peer_ou_identifier": {
                          "certificate": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNDekNDQWJHZ0F3SUJBZ0lVUkgyT0tlV1loaStFMkFHZ3IwWUdlVTRUOWs0d0NnWUlLb1pJemowRUF3SXcKWWpFTE1Ba0dBMVVFQmhNQ1ZWTXhFVEFQQmdOVkJBZ1RDRTVsZHlCWmIzSnJNUkV3RHdZRFZRUUhFd2hPWlhjZwpXVzl5YXpFVU1CSUdBMVVFQ2hNTFpYaGhiWEJzWlM1amIyMHhGekFWQmdOVkJBTVREbU5oTG1WNFlXMXdiR1V1ClkyOXRNQjRYRFRJd01ETXlOREl3TVRnd01Gb1hEVE0xTURNeU1USXdNVGd3TUZvd1lqRUxNQWtHQTFVRUJoTUMKVlZNeEVUQVBCZ05WQkFnVENFNWxkeUJaYjNKck1SRXdEd1lEVlFRSEV3aE9aWGNnV1c5eWF6RVVNQklHQTFVRQpDaE1MWlhoaGJYQnNaUzVqYjIweEZ6QVZCZ05WQkFNVERtTmhMbVY0WVcxd2JHVXVZMjl0TUZrd0V3WUhLb1pJCnpqMENBUVlJS29aSXpqMERBUWNEUWdBRS9yb2dWY0hFcEVQMDhTUTl3VTVpdkNxaUFDKzU5WUx1dkRDNkx6UlIKWXdyZkFxdncvT0FodVlQRkhnRFZ1SFExOVdXMGxSV2FKWmpVcDFxNmRCWEhlYU5GTUVNd0RnWURWUjBQQVFILwpCQVFEQWdFR01CSUdBMVVkRXdFQi93UUlNQVlCQWY4Q0FRRXdIUVlEVlIwT0JCWUVGTG9kWFpjaTVNNlFxYkNUCm1YZ3lTbU1aYlZHWE1Bb0dDQ3FHU000OUJBTUNBMGdBTUVVQ0lRQ0hFTElvajJUNG15ODI0SENQRFc2bEZFRTEKSDc1c2FyN1V4TVJSNmFWckZnSWdMZUxYT0ZoSDNjZ0pGeDhJckVyTjlhZmdjVVIyd0ZYUkQ0V0V0MVp1bmxBPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==",
                          "organizational_unit_identifier": "peer"
                        }
                      },
                      "intermediate_certs": [],
                      "name": "OrdererMSP",
                      "organizational_unit_identifiers": [],
                      "revocation_list": [],
                      "root_certs": [
                        "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNDekNDQWJHZ0F3SUJBZ0lVUkgyT0tlV1loaStFMkFHZ3IwWUdlVTRUOWs0d0NnWUlLb1pJemowRUF3SXcKWWpFTE1Ba0dBMVVFQmhNQ1ZWTXhFVEFQQmdOVkJBZ1RDRTVsZHlCWmIzSnJNUkV3RHdZRFZRUUhFd2hPWlhjZwpXVzl5YXpFVU1CSUdBMVVFQ2hNTFpYaGhiWEJzWlM1amIyMHhGekFWQmdOVkJBTVREbU5oTG1WNFlXMXdiR1V1ClkyOXRNQjRYRFRJd01ETXlOREl3TVRnd01Gb1hEVE0xTURNeU1USXdNVGd3TUZvd1lqRUxNQWtHQTFVRUJoTUMKVlZNeEVUQVBCZ05WQkFnVENFNWxkeUJaYjNKck1SRXdEd1lEVlFRSEV3aE9aWGNnV1c5eWF6RVVNQklHQTFVRQpDaE1MWlhoaGJYQnNaUzVqYjIweEZ6QVZCZ05WQkFNVERtTmhMbVY0WVcxd2JHVXVZMjl0TUZrd0V3WUhLb1pJCnpqMENBUVlJS29aSXpqMERBUWNEUWdBRS9yb2dWY0hFcEVQMDhTUTl3VTVpdkNxaUFDKzU5WUx1dkRDNkx6UlIKWXdyZkFxdncvT0FodVlQRkhnRFZ1SFExOVdXMGxSV2FKWmpVcDFxNmRCWEhlYU5GTUVNd0RnWURWUjBQQVFILwpCQVFEQWdFR01CSUdBMVVkRXdFQi93UUlNQVlCQWY4Q0FRRXdIUVlEVlIwT0JCWUVGTG9kWFpjaTVNNlFxYkNUCm1YZ3lTbU1aYlZHWE1Bb0dDQ3FHU000OUJBTUNBMGdBTUVVQ0lRQ0hFTElvajJUNG15ODI0SENQRFc2bEZFRTEKSDc1c2FyN1V4TVJSNmFWckZnSWdMZUxYT0ZoSDNjZ0pGeDhJckVyTjlhZmdjVVIyd0ZYUkQ0V0V0MVp1bmxBPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
                      ],
                      "signing_identity": null,
                      "tls_intermediate_certs": [],
                      "tls_root_certs": [
                        "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNDekNDQWJHZ0F3SUJBZ0lVUkgyT0tlV1loaStFMkFHZ3IwWUdlVTRUOWs0d0NnWUlLb1pJemowRUF3SXcKWWpFTE1Ba0dBMVVFQmhNQ1ZWTXhFVEFQQmdOVkJBZ1RDRTVsZHlCWmIzSnJNUkV3RHdZRFZRUUhFd2hPWlhjZwpXVzl5YXpFVU1CSUdBMVVFQ2hNTFpYaGhiWEJzWlM1amIyMHhGekFWQmdOVkJBTVREbU5oTG1WNFlXMXdiR1V1ClkyOXRNQjRYRFRJd01ETXlOREl3TVRnd01Gb1hEVE0xTURNeU1USXdNVGd3TUZvd1lqRUxNQWtHQTFVRUJoTUMKVlZNeEVUQVBCZ05WQkFnVENFNWxkeUJaYjNKck1SRXdEd1lEVlFRSEV3aE9aWGNnV1c5eWF6RVVNQklHQTFVRQpDaE1MWlhoaGJYQnNaUzVqYjIweEZ6QVZCZ05WQkFNVERtTmhMbVY0WVcxd2JHVXVZMjl0TUZrd0V3WUhLb1pJCnpqMENBUVlJS29aSXpqMERBUWNEUWdBRS9yb2dWY0hFcEVQMDhTUTl3VTVpdkNxaUFDKzU5WUx1dkRDNkx6UlIKWXdyZkFxdncvT0FodVlQRkhnRFZ1SFExOVdXMGxSV2FKWmpVcDFxNmRCWEhlYU5GTUVNd0RnWURWUjBQQVFILwpCQVFEQWdFR01CSUdBMVVkRXdFQi93UUlNQVlCQWY4Q0FRRXdIUVlEVlIwT0JCWUVGTG9kWFpjaTVNNlFxYkNUCm1YZ3lTbU1aYlZHWE1Bb0dDQ3FHU000OUJBTUNBMGdBTUVVQ0lRQ0hFTElvajJUNG15ODI0SENQRFc2bEZFRTEKSDc1c2FyN1V4TVJSNmFWckZnSWdMZUxYT0ZoSDNjZ0pGeDhJckVyTjlhZmdjVVIyd0ZYUkQ0V0V0MVp1bmxBPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
                      ]
                    },
                    "type": 0
                  },
                  "version": "0"
                }
              },
              "version": "0"
            }
          },
          "mod_policy": "Admins",
          "policies": {
            "Admins": {
              "mod_policy": "Admins",
              "policy": {
                "type": 3,
                "value": {
                  "rule": "MAJORITY",
                  "sub_policy": "Admins"
                }
              },
              "version": "0"
            },
            "BlockValidation": {
              "mod_policy": "Admins",
              "policy": {
                "type": 3,
                "value": {
                  "rule": "ANY",
                  "sub_policy": "Writers"
                }
              },
              "version": "0"
            },
            "Readers": {
              "mod_policy": "Admins",
              "policy": {
                "type": 3,
                "value": {
                  "rule": "ANY",
                  "sub_policy": "Readers"
                }
              },
              "version": "0"
            },
            "Writers": {
              "mod_policy": "Admins",
              "policy": {
                "type": 3,
                "value": {
                  "rule": "ANY",
                  "sub_policy": "Writers"
                }
              },
              "version": "0"
            }
          },
          "values": {
            "BatchSize": {
              "mod_policy": "Admins",
              "value": {
                "absolute_max_bytes": 103809024,
                "max_message_count": 10,
                "preferred_max_bytes": 524288
              },
              "version": "0"
            },
            "BatchTimeout": {
              "mod_policy": "Admins",
              "value": {
                "timeout": "2s"
              },
              "version": "0"
            },
            "Capabilities": {
              "mod_policy": "Admins",
              "value": {
                "capabilities": {
                  "V2_0": {}
                }
              },
              "version": "0"
            },
            "ChannelRestrictions": {
              "mod_policy": "Admins",
              "value": null,
              "version": "0"
            },
            "ConsensusType": {
              "mod_policy": "Admins",
              "value": {
                "metadata": {
                  "consenters": [
                    {
                      "client_tls_cert": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN3akNDQW1pZ0F3SUJBZ0lVZG9JbmpzaW5vVnZua0llbE5WUU8wbDRMbEdrd0NnWUlLb1pJemowRUF3SXcKWWpFTE1Ba0dBMVVFQmhNQ1ZWTXhFVEFQQmdOVkJBZ1RDRTVsZHlCWmIzSnJNUkV3RHdZRFZRUUhFd2hPWlhjZwpXVzl5YXpFVU1CSUdBMVVFQ2hNTFpYaGhiWEJzWlM1amIyMHhGekFWQmdOVkJBTVREbU5oTG1WNFlXMXdiR1V1ClkyOXRNQjRYRFRJd01ETXlOREl3TVRnd01Gb1hEVEl4TURNeU5ESXdNak13TUZvd1lERUxNQWtHQTFVRUJoTUMKVlZNeEZ6QVZCZ05WQkFnVERrNXZjblJvSUVOaGNtOXNhVzVoTVJRd0VnWURWUVFLRXd0SWVYQmxjbXhsWkdkbApjakVRTUE0R0ExVUVDeE1IYjNKa1pYSmxjakVRTUE0R0ExVUVBeE1IYjNKa1pYSmxjakJaTUJNR0J5cUdTTTQ5CkFnRUdDQ3FHU000OUF3RUhBMElBQkdGaFd3SllGbHR3clBVellIQ3loNTMvU3VpVU1ZYnVJakdGTWRQMW9FRzMKSkcrUlRSOFR4NUNYTXdpV05sZ285dU00a1NGTzBINURZUWZPQU5MU0o5NmpnZjB3Z2Zvd0RnWURWUjBQQVFILwpCQVFEQWdPb01CMEdBMVVkSlFRV01CUUdDQ3NHQVFVRkJ3TUJCZ2dyQmdFRkJRY0RBakFNQmdOVkhSTUJBZjhFCkFqQUFNQjBHQTFVZERnUVdCQlJ2M3lNUmh5cHc0Qi9Cc1NHTlVJL0VpU1lNN2pBZkJnTlZIU01FR0RBV2dCUzYKSFYyWEl1VE9rS213azVsNE1rcGpHVzFSbHpBZUJnTlZIUkVFRnpBVmdoTnZjbVJsY21WeUxtVjRZVzF3YkdVdQpZMjl0TUZzR0NDb0RCQVVHQndnQkJFOTdJbUYwZEhKeklqcDdJbWhtTGtGbVptbHNhV0YwYVc5dUlqb2lJaXdpCmFHWXVSVzV5YjJ4c2JXVnVkRWxFSWpvaWIzSmtaWEpsY2lJc0ltaG1MbFI1Y0dVaU9pSnZjbVJsY21WeUluMTkKTUFvR0NDcUdTTTQ5QkFNQ0EwZ0FNRVVDSVFESHNrWUR5clNqeWpkTVVVWDNaT05McXJUNkdCcVNUdmZXN0dXMwpqVTg2cEFJZ0VIZkloVWxVV0VpN1hTb2Y4K2toaW9PYW5PWG80TWxQbGhlT0xjTGlqUzA9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K",
                      "host": "orderer.example.com",
                      "port": 7050,
                      "server_tls_cert": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN3akNDQW1pZ0F3SUJBZ0lVZG9JbmpzaW5vVnZua0llbE5WUU8wbDRMbEdrd0NnWUlLb1pJemowRUF3SXcKWWpFTE1Ba0dBMVVFQmhNQ1ZWTXhFVEFQQmdOVkJBZ1RDRTVsZHlCWmIzSnJNUkV3RHdZRFZRUUhFd2hPWlhjZwpXVzl5YXpFVU1CSUdBMVVFQ2hNTFpYaGhiWEJzWlM1amIyMHhGekFWQmdOVkJBTVREbU5oTG1WNFlXMXdiR1V1ClkyOXRNQjRYRFRJd01ETXlOREl3TVRnd01Gb1hEVEl4TURNeU5ESXdNak13TUZvd1lERUxNQWtHQTFVRUJoTUMKVlZNeEZ6QVZCZ05WQkFnVERrNXZjblJvSUVOaGNtOXNhVzVoTVJRd0VnWURWUVFLRXd0SWVYQmxjbXhsWkdkbApjakVRTUE0R0ExVUVDeE1IYjNKa1pYSmxjakVRTUE0R0ExVUVBeE1IYjNKa1pYSmxjakJaTUJNR0J5cUdTTTQ5CkFnRUdDQ3FHU000OUF3RUhBMElBQkdGaFd3SllGbHR3clBVellIQ3loNTMvU3VpVU1ZYnVJakdGTWRQMW9FRzMKSkcrUlRSOFR4NUNYTXdpV05sZ285dU00a1NGTzBINURZUWZPQU5MU0o5NmpnZjB3Z2Zvd0RnWURWUjBQQVFILwpCQVFEQWdPb01CMEdBMVVkSlFRV01CUUdDQ3NHQVFVRkJ3TUJCZ2dyQmdFRkJRY0RBakFNQmdOVkhSTUJBZjhFCkFqQUFNQjBHQTFVZERnUVdCQlJ2M3lNUmh5cHc0Qi9Cc1NHTlVJL0VpU1lNN2pBZkJnTlZIU01FR0RBV2dCUzYKSFYyWEl1VE9rS213azVsNE1rcGpHVzFSbHpBZUJnTlZIUkVFRnpBVmdoTnZjbVJsY21WeUxtVjRZVzF3YkdVdQpZMjl0TUZzR0NDb0RCQVVHQndnQkJFOTdJbUYwZEhKeklqcDdJbWhtTGtGbVptbHNhV0YwYVc5dUlqb2lJaXdpCmFHWXVSVzV5YjJ4c2JXVnVkRWxFSWpvaWIzSmtaWEpsY2lJc0ltaG1MbFI1Y0dVaU9pSnZjbVJsY21WeUluMTkKTUFvR0NDcUdTTTQ5QkFNQ0EwZ0FNRVVDSVFESHNrWUR5clNqeWpkTVVVWDNaT05McXJUNkdCcVNUdmZXN0dXMwpqVTg2cEFJZ0VIZkloVWxVV0VpN1hTb2Y4K2toaW9PYW5PWG80TWxQbGhlT0xjTGlqUzA9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
                    }
                  ],
                  "options": {
                    "election_tick": 10,
                    "heartbeat_tick": 1,
                    "max_inflight_blocks": 5,
                    "snapshot_interval_size": 16777216,
                    "tick_interval": "500ms"
                  }
                },
                "state": "STATE_NORMAL",
                "type": "etcdraft"
              },
              "version": "0"
            }
          },
          "version": "0"
        }
      },
      "mod_policy": "Admins",
      "policies": {
        "Admins": {
          "mod_policy": "Admins",
          "policy": {
            "type": 3,
            "value": {
              "rule": "MAJORITY",
              "sub_policy": "Admins"
            }
          },
          "version": "0"
        },
        "Readers": {
          "mod_policy": "Admins",
          "policy": {
            "type": 3,
            "value": {
              "rule": "ANY",
              "sub_policy": "Readers"
            }
          },
          "version": "0"
        },
        "Writers": {
          "mod_policy": "Admins",
          "policy": {
            "type": 3,
            "value": {
              "rule": "ANY",
              "sub_policy": "Writers"
            }
          },
          "version": "0"
        }
      },
      "values": {
        "BlockDataHashingStructure": {
          "mod_policy": "Admins",
          "value": {
            "width": 4294967295
          },
          "version": "0"
        },
        "Capabilities": {
          "mod_policy": "Admins",
          "value": {
            "capabilities": {
              "V2_0": {}
            }
          },
          "version": "0"
        },
        "Consortium": {
          "mod_policy": "Admins",
          "value": {
            "name": "SampleConsortium"
          },
          "version": "0"
        },
        "HashingAlgorithm": {
          "mod_policy": "Admins",
          "value": {
            "name": "SHA256"
          },
          "version": "0"
        },
        "OrdererAddresses": {
          "mod_policy": "/Channel/Orderer/Admins",
          "value": {
            "addresses": [
              "orderer.example.com:7050"
            ]
          },
          "version": "0"
        }
      },
      "version": "0"
    },
    "sequence": "3"
  }
```
</details>

設定は、このような形では、一見すると敷居が高いように見えますが、一度学ぶと、論理的な構造になっていることがわかります。

例えば、タブをいくつか閉じた状態の設定を見てみましょう。

なお、これはアプリケーションチャネルの設定であり、Ordererのシステムチャネルの設定ではないことに注意してください。

![単純化した設定サンプル](./images/sample_config.png)

これで、設定の構造がより明確になったはずです。設定グループ (`Channel`、`Application`、`Orderer`) と各設定グループに関連する設定パラメータ (これらについては次のセクションで詳しく説明します) だけでなく、
組織を表すMSPも確認できます。なお、`Channel` の設定グループは、`Orderer` グループの設定値の下にあります。

### More about these parameters

このセクションでは、設定可能な値が設定内のどこにあるかというコンテキストで、より深く見ていきます。

まず、設定の複数の部分で出てくる設定パラメータがあります:

* **ポリシー (Policies)** ポリシーは、単なる設定値 (`mod_policy`で定義された通りに更新できる) ではなく、すべてのパラメータを変更できる状況を定義するものです。詳しくは[ポリシー (Policies)](./policies/policies.html)をご覧ください。

* **ケーパビリティ (Capabilities)** ネットワークとチャネルが同じ方法で物事を処理することを保証し、チャネル設定の更新やチェーンコードの呼び出しなどで決定性のある結果を生み出します。
決定的な結果が得られないと、チャネル上のあるピアがトランザクションを無効にしても、別のピアがトランザクションを有効にすることがあります。詳細については、[ケーパビリティ (Capabilities)](./capabilities_concept.html)をご覧ください。

#### `Channel/Application`

アプリケーションチャネルに固有の設定パラメータ (チャネルメンバーの追加や削除など) を管理します。デフォルトでは、これらのパラメータを変更するには、アプリケーション組織の管理者の過半数の署名が必要です。

* **チャネルへの組織追加 (Add orgs to a channel)** 組織をチャネルに追加するには、そのMSPおよびその他の組織に関するパラメータを生成してここ (`Channel/Application/groups` 以下) に追加する必要があります。

* **組織に関するパラメータ (Organization-related parameters)** 組織に固有のパラメータ (アンカーピアの識別、組織の管理者の証明書など) は、すべて変更可能です。
これらの値を変更するには、デフォルトでは、アプリケーション組織の管理者の過半数は必要なく、その組織自体の管理者のみが必要となることに注意してください。

#### `Channel/Orderer`

オーダリングサービスまたはOrdererシステムチャネルに固有の設定パラメータを管理し、
オーダリング組織の管理者の過半数が必要となります（デフォルトではオーダリング組織は1つだけですが、複数の組織がオーダリングサービスにノードを提供する場合などさらに追加できます）。

* **バッチサイズ (Batch size)** これらのパラメータは、ブロック内のトランザクションの数とサイズを決定します。ブロックのサイズが `absolute_max_bytes` より大きくなったり、ブロック内のトランザクション数が `max_message_count` より多くなったりすることはありません。もし `preferred_max_bytes` 以下のブロックを構築することが可能であれば、早々にブロックとしてカットされ、このサイズより大きいトランザクションはそれ自体がブロックになります。

* **バッチタイムアウト (Batch timeout)** 最初のトランザクションが到着してから追加のトランザクションを待ってブロックとしてカットするまでの待機時間です。この値を減少させるとレイテンシが改善しますが、減少させすぎるとブロックが最大容量まで満たされなくなり、スループットが低下する可能性があります。

* **ブロック検証 (Block validation)** このポリシーは、ブロックが正当と見なされるための署名要件を指定します。デフォルトでは、オーダリング組織のメンバーからの署名が必要です。

* **合意形成タイプ (Consensus type)** KafkaベースのオーダリングサービスからRaftベースのオーダリングサービスへの移行を可能にするために、チャネルの合意形成タイプを変更することができます。 詳細については、[KafkaからRaftへの移行](./kafka_raft_migration.html)をご覧ください。

* **Raftオーダリングサービスパラメータ (Raft ordering service parameters)** Raftオーダリングサービスに固有のパラメータについては、[Raft設定](./raft_configuration.html)をご覧ください。

* **Kafkaブローカー (Kafka brokers)** (該当する場合) `ConsensusType` が `kafka` に設定されている場合、 `brokers` リストは、Ordererが起動時に最初に接続するKafkaブローカーのサブセット（またはできればすべて）を列挙します。

#### `Channel`

ピア組織とオーダリングサービス組織の両方が同意する必要のある設定パラメータを管理し、アプリケーション組織管理者の過半数とオーダリング組織管理者の両方の同意が必要です。

* **Ordererアドレス (Orderer addresses)** クライアントがOrdererの `Broadcast` および `Deliver` 関数を呼び出すことができるアドレスのリストです。ピアはこれらのアドレスからランダムに選択し、ブロックを取得するためにそれらの間でフェイルオーバーします。

* **ハッシュ構造 (Hashing structure)** ブロックデータはバイト列の配列です。ブロックデータのハッシュは、マークルツリーとして計算されます。この値は、そのマークルツリーの幅を指定します。当面、この値は `4294967295` に固定されます。これは、ブロックデータバイトを連結した単純なフラットハッシュに対応します。

* **ハッシュアルゴリズム (Hashing algorithm)** ブロックチェーンのブロックにエンコードされたハッシュ値を計算するために使用されるアルゴリズムです。 特に、これはブロックのデータハッシュと前ブロックハッシュのフィールドに影響します。現在、このフィールドには有効な値 (`SHA256`) が1つしかないため、変更しないでください。

#### System channel configuration parameters

特定の設定値は、オーダリングシステムチャネルに固有のものです。

* **チャネル作成ポリシー (Channel creation policy)** 定義されているコンソーシアムの新しいチャネルのアプリケーショングループの mod_policy として設定されるポリシー値を定義します。チャネル作成要求に添付された署名セットは、新しいチャネルでのこのポリシーのインスタンス化と照合され、チャネル作成が許可されていることを確認します。この設定値は、Ordererシステムチャネルでのみ設定されることに注意してください。

* **チャネル制限 (Channel restrictions)** Ordererシステムチャネルでのみ編集可能です。Ordererが割り当てても構わないと思っているチャネルの総数を `max_count` として指定できます。これは主に、コンソーシアムの `ChannelCreation` ポリシーが弱い実稼働前の環境で役立ちます。

## Editing a config

チャネル設定の更新は、概念的にはシンプルな3つのステップで行われます:

1. 最新のチャネル設定を取得
2. 修正されたチャネル設定を作成
3. チャネル更新トランザクションを作成

しかし、後述するように、この概念的な単純さは、やや複雑なプロセスに包まれています。そのため、ユーザーによっては、設定更新を取得、変換、スコープに収めるというプロセスをスクリプト化することを選ぶかもしれません。
また、チャネル設定自体を修正するには、手動または `jq` のようなツールを使用するという選択肢もあります。

特定の目的を達成するためにチャネル設定を編集することに特化した2つのチュートリアルがあります:

* [チャネルへの組織追加](./channel_update_tutorial.html): 既存のチャネルに組織を追加する手順を示します。
* [チャネルケーパビリティの更新](./updating_capabilities.html): チャネルケーパビリティを更新する方法を示します。

このトピックでは、設定更新の最終目的とは関係なく、チャネル設定を編集するプロセスを紹介します。

### Set environment variables for your config update

サンプルコマンドを使用する前に、以下の環境変数をエクスポートしてください。これらの環境変数は、あなたのデプロイメントの構成によって異なります。
チャネル設定更新は、更新されるチャネルの設定にのみ適用されるため、チャネル名 `CH_NAME` は、更新されるすべてのチャネルに設定する必要があります (デフォルトで設定がアプリケーションチャネル設定にコピーされるオーダリングシステムチャネルを除く)。

* `CH_NAME`: 更新されるチャネルの名前。
* `TLS_ROOT_CA`: 更新を提案する組織のTLS CAのルートCA証明書へのパス。
* `CORE_PEER_LOCALMSPID`: MSPの名前。
* `CORE_PEER_MSPCONFIGPATH`: 組織のMSPの絶対パス。
* `ORDERER_CONTAINER`: オーダリングノードコンテナの名前。オーダリングサービスをターゲットにする場合、オーダリングサービス内の任意のアクティブノードをターゲットにできることに注意してください。あなたの要求は自動的にリーダーに転送されます。

注: このトピックでは、取得および修正されるさまざまなJSONファイルとprotobufファイルのデフォルト名 (`config_block.pb`、` config_block.json`など) を提供します。これらは好きな名前を自由に使用できます。
ただし、各設定更新の最後にこれらのファイルを消去しない限り、追加の更新を行うときに別のファイルを選択する必要があることに注意してください。

### Step 1: Pull and translate the config

チャネル設定を更新する最初のステップは、最新のコンフィグブロックを取得することです。これは3ステップのプロセスです。 まず、チャネル設定をprotobuf形式で取得し、 `config_block.pb` というファイルを作成します。

あなたはピアコンテナの中にいることを確認してください。

まず、以下を発行します:

```
peer channel fetch config config_block.pb -o $ORDERER_CONTAINER -c $CH_NAME --tls --cafile $TLS_ROOT_CA
```

次に、protobufバージョンのチャネル設定を、 `config_block.json` というJSONバージョンに変換します (JSONファイルは人間が読んで理解するのに適しています):

```
configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
```

最後に、設定から不要なメタデータをすべて削除して、読みやすくします。このファイルをどのように呼ぶかは自由ですが、この例では `config.json` と呼ぶことにします。

```
jq .data.data[0].payload.data.config config_block.json > config.json
```

さて、`config.json` のコピーを `modified_config.json` という名前で作りましょう。後のステップで ``config.json`` と ``modified_config.json`` の差分を計算するために使用するため、 **``config.json``は直接編集しないでください**。

```
cp config.json modified_config.json
```

### Step 2: Modify the config

この時点で、設定をどのように修正するか、2つの選択肢があります:

1. お好みのテキストエディタで ``modified_config.json`` を開き、編集します。エディタを持たないコンテナからファイルをコピーして編集し、コンテナに戻す方法を説明したオンラインチュートリアルがあります。
2. ``jq`` を使用して、設定に編集を適用します。

設定を手動で編集するか、 `jq` を使用するかは、ユースケースによって異なります。 `jq` は簡潔でスクリプト可能であるため（同じ設定更新が複数のチャネルに対して行われる場合に利点）、チャネル設定を実行するための推奨される方法です。
`jq` の使用方法の例については、[チャネルケーパビリティの更新](./updating_a_channel.html#Create-a-capabilities-config-file) を確認してください。
これは、ケーパビリティ設定ファイル `capabilities.json` を利用する複数の `jq` コマンドを示しています。チャネルケーパビリティ以外のものを更新する場合は、それに応じて `jq` コマンドとJSONファイルを修正する必要があります。

チャネル設定の内容と構造についての詳細な情報は、前述の[チャネル設定サンプル]](#Sample-channel-configuration)を確認してください。

### Step 3: Re-encode and submit the config

設定更新を手動で行っている場合でも、 `jq` のようなツールを使っている場合でも、設定更新をチャネルの他の管理者に送信して承認を得る前に、設定を取り出してスコープするために実行したプロセスを逆に実行し、
古い設定と新しい設定の差分を計算するステップを加えなければなりません。

まず、`config.json` ファイルをprotobuf形式に戻して、 `config.pb` というファイルを作成します。次に、同じことを `modified_config.json` ファイルに対して行います。その後、2つのファイルの差分を計算して、 `config_update.pb` というファイルを作成します。

```
configtxlator proto_encode --input config.json --type common.Config --output config.pb

configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb

configtxlator compute_update --channel_id $CH_NAME --original config.pb --updated modified_config.pb --output config_update.pb
```

これで、古い設定と新しい設定の差分が計算できたので、設定変更を適用することができます。

```
configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json

echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CH_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json

configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb
```

設定更新トランザクションを送信します:

```
peer channel update -f config_update_in_envelope.pb -c $CH_NAME -o $ORDERER_CONTAINER --tls --cafile $TLS_ROOT_CA
```

設定更新トランザクションは、元の設定と修正された設定の差分を表しますが、オーダリングサービスはこれを完全なチャネル設定に変換します。

## Get the Necessary Signatures

新しい設定のprotobufファイルの作成に成功したら、変更しようとしているものがなんであっても関連するポリシー (常にではありませんが、通常は他の組織からの署名を要求する) を満たす必要があります。

*注：アプリケーションによっては、署名収集のスクリプトを作成できる場合があります。一般的には、常に必要以上の署名を集めることができます。*

これらの署名を取得するための実際のプロセスは、システムをどのようにセットアップしたかによって異なりますが、主に2つの実装方法があります。
現在、Fabricのコマンドラインはデフォルトで「順番に渡していく」システムになっています。つまり、設定更新を提案する組織の管理者は、署名が必要な他の人 (通常は別の管理者) にその更新を送ります。
この管理者はそれに署名して (あるいは署名しないで)、次の管理者に渡し、というように、 設定を送信するのに十分な署名が得られるまで繰り返します。

これには単純さの利点があります --- 十分な署名がある場合、最後の管理者は単に設定トランザクションを送信できます (Fabricでは、 `peer channel update` コマンドにはデフォルトで署名が含まれています)。
ただし、「順番に渡していく」方法は時間がかかる可能性があるため、このプロセスは小さなチャネルでのみ実用的です。

もう1つのオプションは、チャネル上のすべての管理者に更新を送信し、十分な署名が返されるのを待つことです。
その後で、これらの署名をつなぎ合わせて送信できます。
これにより、設定更新を作成した管理者の作業が少し難しくなりますが (署名者ごとにファイルを処理しなければならない)、Fabric管理アプリケーションを開発しているユーザーに推奨されるワークフローです。

設定が台帳に追加されたら、それを取得してJSONに変換し、すべてが正しく追加されたことを確認することをおすすめします。 これは、最新の設定の便利なコピーとしても機能します。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
