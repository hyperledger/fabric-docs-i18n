# Обновление конфигурации канала

*Целевая аудитория: сетевые администраторы, администраторы узлов*

## Что такое конфигурация канала

Как и многие сложные системы, работа сетей Hyperledger Fabric основана на определенной **структуре** и связанных с этой структурой **процессах**.

* **Структура** включает пользователей (например, администраторов), организации, одноранговые узлы,
  узлы службы упорядочения, удостоверяющие центры, смарт-контракты и приложения.
* **Процессы** представляют собой взаимодействие компонентов структуры. Самыми важными их них являются
  [политики](./policies/policies.html) — правила, регулирующие возможности и полномочия пользователей.

Информация, определяющая структуру блокчейн-сетей и процессы, регулирующие взаимодействие компонентов структуры, 
содержится в **конфигурации каналов**. Конфигурация утверждается членами каналов и содержится в блоках, которые
записываются в реестр канала. Конфигурация каналов может быть создана с помощью инструмента `configtxgen`, который
принимает исходную информацию в формате файла `configtx.yaml`. 
По [этой ссылке](http://github.com/hyperledger/fabric/blob/release-2.0/sampleconfig/configtx.yaml) можно посмотреть пример файла `configtx.yaml`.

Поскольку конфигурация содержится в блоках (самый первый из них — первичный — содержит начальную конфигурацию, а последний — 
текущую конфигурацию канала), процесс обновления конфигурации канала (изменения структуры при добавлении членов или
процессов при изменении правил канала) известен как **транзакция обновления конфигурации**.

В промышленных сетях операции обновления конфигурации обычно инициируются одним из администраторов сети после
обсуждения изменений вне сети, точно так же, как определяется изначальная конфигурация канала исходными членами канала.

В этом разделе рассматриваются:

* Пример полноценной конфигурации канала приложения.
* Редактируемые параметры канала.
* Процесс обновления конфигурации канала, включая команды, необходимые для чтения, конвертации и преобразования конфигурации в легко-читаемый формат.
* Методы редактирования конфигурации канала.
* Процесс переформатирования конфигурации и получения подписей, необходимых для ее утрверждения.

## Изменяемые параметры канала

В каналах предусмотрены широкие возможности для настройки, однако существуют некоторые ограничения. Некоторые изначально 
заданные параметры канала (например, название канала) нельзя изменить впоследствии. Причем для изменения параметров,
обсуждаемых в этом разделе, требуется удовлетворение соответствующих правил, указанных в конфигурации канала.

В этом разделе рассматривается пример конфигурации канала и изменяемые параметры конфигурации.

### Пример конфигурации канала

Ниже приведен пример файла конфигурации канала (содержание файла скрыто за надписью **Нажмите, чтобы увидеть конфигурацию**).
Для удобства чтения рекомендуется открыть файл конфигурации в редакторе, который поддерживает свертывание JSON, например, Atom или Visual Studio.

Примечание. Для простоты здесь показана только конфигурация канала приложений. Конфигурация системного канала службы
упорядочения очень похожа, но имеет некоторые отличия от конфигурации канала приложений. Тем не менее она имеет ту же
структуру и основные правила, а также позволяет использовать одни и те же команды для считывания и редактирования информации,
как показано в разделе [Обновление уровня функциональных возможностей канала](./updating_capabilities.html).

<details>
  <summary>
    **Нажмите, чтобы увидеть конфигурацию**. Обратите внимание, что это конфигурация канала приложений, а не конфигурация системного канала службы упорядочения.
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

В таком виде конфигурация может выглядеть громоздко, но, изучив ее, вы увидите, что она имеет логическую структуру.

Например, давайте посмотрим на конфигурацию с несколькими закрытыми вкладками.

Обратите внимание, что это конфигурация канала приложений, а не конфигурация системного канала службы упорядочения.

![Упрощенный пример конфигурации](./images/sample_config.png)

В таком виде структура конфигурации должна быть более понятной. В ней присутствуют группы `Channel`, `Application`, и `Orderer`,
параметры конфигурации, связанные с каждой из этих групп (подробнее это рассматривается в следующем разделе), а также где 
находятся провайдеры служб членства, представляющие организации. Обратите внимание, что группа `Channel` конфигурации
находится ниже данных группы `Orderer`.

### Подробнее об этих параметрах

В этом разделе более подробно рассматривается расположение этих изменяемых параметров в конфигурации.

Некоторые параметры повторяются в нескольких местах конфигурации:

* **Policies**. Политики — это не просто значения конфигурации (которые могут быть изменены, как определено в `mod_policy`), они определяют обстоятельства, при которых все параметры могут быть изменены. Для получения дополнительной информации ознакомьтесь с разделом [Политики](./policies/policies.html).

* **Capabilities**. Функциональные возможности гарантируют, что сети и каналы обрабатывают данные одинаково, создавая детерминированные результаты при обновлении конфигураций каналов и вызове чейнкода. Без детерминированности один одноранговый узел может посчитать транзакцию недействительной, а другой — подтвердить ее. Для получения дополнительной информации смотрите раздел [Функциональные возможности](./capabilities_concept.html).

#### `Channel/Application`

В этой группе определяются параметры конфигурации, уникальные для каналов приложений (например, касающиеся добавления или удаления членов канала). 
По умолчанию изменение этих параметров требует подписи большинства администраторов организаций в канале.

* **Добавление организаций в канал**. Чтобы добавить организацию в канал, провайдер службы членства и другие параметры организации должны быть сгенерированы и добавлены в разделе `Channel/Application/groups`.

* **Параметры, связанные с организацией**. Любые параметры, связанные с конкретной организацией (например, идентификация якорного узла или сертификатов администраторов организации), являются изменяемыми. Обратите внимание, что изменение этих значений по умолчанию не требует одобрения большинства администраторов организаций приложения, а только администраторов организации, параметры которой изменяются.

#### `Channel/Orderer`

Здесь указываются параметры конфигурации, касающиеся службы упорядочения или системного канала службы упорядочения. 
Изменение этих параметров требует согласие большинства администраторов организаций службы упорядочения (по умолчанию используется 
только одна организация службы упорядочения, однако дополнительные организации могут быть добавлены, например, 
когда несколько организаций переводят свои узлы под нужды службы упорядочения).

* **BatchSize**. Этот параметр регулирует количество и размер транзакций в блоке. Блоки не могут иметь размер более `absolute_max_bytes`, а также не могут содержать больше транзакций, чем значение `max_message_count`. Если есть возможность сформировать блок размером меньше, чем `preferred_max_bytes`, он будет закрыт, а транзакции, не умещающиеся в этот размер, будут добавлены в отдельном блоке.

* **BatchTimeout**. Количество времени ожидания дополнительных транзакций после получения первой транзакции, прежде чем блок будет закрыт. Уменьшение этого значения снижает задержку, однако слишком малое значение может снизить пропускную способность, не позволяя блокам заполняться до максимального размера.

* **BlockValidation**. Эти правила определяют требования подписи для подтверждения блока. По умолчанию требуется подпись одного из членов службы упорядочения.

* **ConsensusType**. Чтобы обеспечить миграцию службы упорядочения с технологии Kafka на Raft, можно изменить тип консенсуса канала. Для получения дополнительной информации смотрите раздел [Миграция с Kafka на Raft](./kafka_raft_migration.html).

* **Параметры службы упорядочения Raft**. Параметры, используемые для обеспечения корректной работы службы упорядочения Raft, описываются в разделе [Конфигурация Raft](./raft_configuration.html).

* **Брокеры Kafka** (где применимо). Если в типе консенсуса `ConsensusType` указано `kafka`, в списке `brokers` указываются некоторые (или, предпочтительно, все) брокеры Kafka, к которым может подключиться узел службы упорядочения при запуске.

#### `Channel`

Определяет параметры конфигурации, которые должны быть согласованы как с организациями с одноранговыми узлами, так и с организациями службы упорядочения. Для изменения этих параметров необходимо согласние большинства администраторов организаций приложений и организаций службы упорядочения.

* **OrdererAddresses**. Список адресов, по которым клиенты могут вызывать функции узлов службы упорядочения `Broadcast` и `Deliver`. Одноранговые узлы случайно выбирают один из этих адресов и обращаются к ним для получения блоков.

* **HashingStructure**. Данные блока представляют собой массив байтовых массивов. Хеш данных блока рассчитывается в виде дерева Меркла. Это значение обозначает ширину дерева Меркла. На данный момент это значение фиксировано и равно `4294967295`, что соответствует простому плоскому хешу конкатенации байтов данных блока.

* **HashingAlgorithm**. Алгоритм, используемый для вычисления хеш-значений, закодированных в блоках блокчейна. В частности, это влияет на хеш данных и поле хэша предыдущего блока. Обратите внимание, что это поле в настоящее время может принимать только одно допустимое значение (`SHA256`), которое не следует менять.

### Параметры конфигурации системного канала

Некоторые значения конфигурации являются уникальными для системного канала службы упорядочения.

* **ChannelCreationPolicy.** Определяет политику, используемую в качестве mod_policy для группы Application новых каналов консорциума, в котором она определена. Набор подписей, прикрепленный к запросу на создание канала, будет сверен с требованиями этой политики, чтобы убедиться, что создание канала разрешено. Обратите внимание, что это значение конфигурации устанавливается только в системном канале службы упорядочения.

* **ChannelRestrictions.** Это значение может быть изменено только в системном канале службы упорядочения. Общее количество каналов, которые могут обслуживаться службой упорядочения, указывается в параметре `max_count`. В первую очередь это полезно в предпроизводственных средах со слабой политикой `ChannelCreation` консорциума.

## Обновление конфигурации

Обновление конфигурации канала состоит из трех простых этапов:

1. Получение текущей конфигурации канала.
2. Создание измененной конфигурации канала.
3. Создание транзакции обновления конфигурации.

Однако, как станет понятно далее, эта концептуальная простота обернута в несколько более сложный процесс. 
В результате некоторые пользователи могут выбрать сценарий для процесса считывания, преобразования и отображения обновления конфигурации.
У пользователей есть возможность изменять саму конфигурацию канала вручную или с помощью такого инструмента, как `jq`.

Мы подготовили два руководства, в которых описывается процесс изменения конфигурации канала для достижения определенного результата:

* [Добавление организации в канал](./channel_update_tutorial.html): описывает процесс добавления новой организации в существующий канал.
* [Изменение функциональных возможностей канала](./updating_capabilities.html): описывает процесс изменения функциональных возможностей канала.

В этом разделе рассматривается процесс редактирования конфигурации канала независимо от конечной цели обновления конфигурации.

### Задание переменных среды для обновления конфигурации

Прежде чем использовать команды из примера, установите следующие переменные среды окружения, которые будут зависеть от того,
каким образом вы построили развертывание. Обратите внимание, что имя канала `CH_NAME` следует указывать для каждого обновляемого канала,
поскольку обновления конфигурации канала применимы только к конфигурации обновляемого канала (за исключением системного канала службы
упорядочения, конфигурация которой по умолчанию копируется в конфигурации каналов приложений).

* `CH_NAME`: имя обновляемого канала.
* `TLS_ROOT_CA`: путь к корневому сертификату удостоверяющего центра TLS организации, предлагающей обновление.
* `CORE_PEER_LOCALMSPID`: имя провайдера службы членства.
* `CORE_PEER_MSPCONFIGPATH`: полный путь к провайдеру службы членства организации.
* `ORDERER_CONTAINER`: название контейнера узла службы упорядочения. Обратите внимание, что при указании службы упорядочения, можно указывать любой активный узел службы упорядочения. Запросы автоматически передаются узлу-лидеру.

Примечание. В этом разделе используются имена по умолчанию для считываемых и изменяемых файлов в формате JSON и protobuf
(`config_block.pb`, `config_block.json`, и т.д.). Можно использовать любые имена по желанию. Тем не менее следует понимать,
что если по окончанию обновления конфигурации вы не удалите эти файлы, придется выбирать другие при дополнительном обновлении.

### Шаг первый: считайте и произведите конвертацию конфигурации

Первым шагом в обновлении конфигурации канала является получение блока текущей конфигурации. Эта операция состоит из трех
дополнительных шагов. Сперва конфигурация канала считывается в формате protobuf и создается файл под названием `config_block.pb`.

Убедитесь, что находитесь в контейнере однорангового узла.

Выполните команду:

```
peer channel fetch config config_block.pb -o $ORDERER_CONTAINER -c $CH_NAME --tls --cafile $TLS_ROOT_CA
```

Далее конвертируем конфигурацию канала из формата protobuf в файл JSON под названием `config_block.json` (формат JSON удобнее для чтения и понимания):

```
configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
```

А теперь, уберем ненужные метаданные из конфигурации для облегчения чтения. Результирующий файл можно назвать как угодно. В этом примере назовем его `config.json`.

```
jq .data.data[0].payload.data.config config_block.json > config.json
```

Теперь создадим копию файла `config.json` под названием `modified_config.json`. **Не изменяйте непосредственно сам файл ``config.json``**,
так как он далее понадобится для вычисления разницы между ``config.json`` и ``modified_config.json``.

```
cp config.json modified_config.json
```

### Шаг второй: Изменение конфигурации

На этом этапе существует два варианта изменения конфигурации.

1. Открыть файл ``modified_config.json`` в любом текстовом редакторе и внести нужные изменения. Сейчас существует много онлайн-руководств, в которых описывается, как скопировать файл из контейнера, отредактировать его и добавить его обратно в контейнер.
2. Использовать инструмент ``jq`` для внесения изменений в конфигурацию.

Можно выбрать любой из вариантов. Поскольку инструмент `jq` является компактным и доступным для написания скриптов 
(что является преимуществом для случаев, когда одно обновление конфигурации необходимо распространить на несколько каналов),
этот метод является рекомендуемым для выполнения обновления канала. Пример использования инструмента `jq` показан в разделе 
[Изменение функциональных возможностей канала](./updating_a_channel.html#Create-a-capabilities-config-file), 
в котором рассказывается о командах `jq` для изменения файла конфигурации функциональных возможностей `capabilities.json`. 
При обновлении других параметров понадобится соответствующим образом изменить команду `jq` и файл JSON.

Для получения дополнительной информации о содержании и структуре конфигурации канала смотрите предыдущий раздел [Пример конфигурации канала](#Sample-channel-configuration).

### Шаг третий: повторная конвертация и отправка транзакции обновлнеия конфигурации

После внесения изменений в конфигурацию вручную или с помощью инструмента `jq`, необходимо выполнить процесс считывания
и преобразования конфигурации в обратном порядке, а также рассчитать разницу между старой и новой конфигурациями.
После этого обновление конфигурации можно отправить другим администраторам в канале для согласования.

Сперва вернем файл `config.json` обратно в формат protobuf, создав файл `config.pb`. То же самое сделаем с файлом `modified_config.json`.
После этого рассчитаем разницу между двумя файлами, и создадим файл под названием `config_update.pb`.

```
configtxlator proto_encode --input config.json --type common.Config --output config.pb

configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb

configtxlator compute_update --channel_id $CH_NAME --original config.pb --updated modified_config.pb --output config_update.pb
```

Рассчитав разницу между старой и новой конфигурацией можно применить изменения конфигурации.

```
configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json

echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CH_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json

configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb
```

Отправка транзакции обновления конфигурации:

```
peer channel update -f config_update_in_envelope.pb -c $CH_NAME -o $ORDERER_CONTAINER --tls --cafile $TLS_ROOT_CA
```

Транзакция обновления конфигурации представляет разницу между исходной и измененной конфигурациями. 
Служба упорядочения использует эти данные для создания новой полноценной конфигурации канала.

## Получение нужных подписей

После успешного создания нового файла конфигурации в формате protobuf, он должен удовлетворять требованиям
политики, соответствующей той части конфигурации, которую вы пытаетесь изменить, обычно (хотя и не всегда) требуя подписи других организаций.

*Примечание. Для сбора подписей можно создать скрипт, соответствующий особенностям приложения. Вцелом, можно всегда собрать больше подписей, чем требуется.*

Фактический процесс получения подписей будет зависеть от особенности настройки системы, однако есть два основных варианта.
В настоящее время командная строка Fabric по умолчанию работает по принципу «передай дальше». То есть администратор организации,
предлагающей обновление конфигурации, отправляет обновление другому пользователю (например, другому администратору),
который должен подписать ее. Этот администратор подписывает обновление (или не подписывает) и отправляет следующему администратору. 
И так далее, пока не будет получено достаточное количество подписей для записи конфигурации.

Это простой процесс — при получении достаточного количества подписей последний администратор, получивший конфигурацию,
может записать транзакцию в реестр (команда `peer channel update` включает в себя подпись по умолчанию). Тем не менее
он практичен только в каналах с небольшим количеством членов, поскольку при большом количестве членов передача
транзакции по принципу «передай дальше» может занимать много времени.

Другой вариант — отправить обновление всем администраторам в канале и дождаться достаточного количества подписей.
Затем эти подписи можно собрать вместе и отправить транзакцию на запись. Этот процесс более сложный для администратора, 
создавшего обновление конфигурации (так как на каждого подписавшего создается отдельный файл), однако является рекомендуемым
рабочим процессом для пользователей, которые разрабатывают приложения управления сетями Fabric.

После добавления обновленной конфигурации в реестр рекомендуется считать ее и преобразовать в формат JSON, чтобы убедиться,
что все было правильно добавлено. Также это может служить копией последней конфигурации.
