# 更新通道配置

## 什么是通道配置？

通道配置包含关于通道管理的所有信息。最重要的是，通道配置指定了哪些组织是通道的成员，但它也
包含其他的全通道的配置信息，例如，通道访问策略和区块的批处理大小。

这个配置被存储在账本上的一个**区块**里，因此被称为配置（config）区块。每个配置区块包含一个
配置。这些区块中的第一个被称为“创世区块”，包含启动通道所需要的初始配置。对通道的每次配置修
改都是通过新配置区块完成的，最新的配置区块表示当前的通道配置。排序节点和对等节点在内存中保
持当前通道配置以便于所有通道操作，例如分割新区块、验证区块交易。

因为配置保存在区块中，更新配置是通过一个称为“配置交易”的过程进行的（尽管这个过程和普通交易
有点不同）。更新配置是一个拉取配置、转换为人可读的格式、修改并提交审核的过程，

要更深入地了解拉取配置并转换为 JSON 的过程，请查看[向通道添加组织](./channel_update_tutorial.html)。
在本文中，我们将重点关注编辑配置的不同方法，及对它进行签名的过程。

## 编辑配置

通道是高度可配置的，但并非无限制。不同的配置元素有不同的修改策略（指定了签名配置更新所需要的
身份组）.

要了解可以修改的范围，查看 JSON 格式的配置很重要。[向通道添加组织](./channel_update_tutorial.html)
教程生成了一个配置，如果你已经阅读了该文档，你只需要参考它。如果没有，我们将在这里提供一个
（为易于阅读，可将此配置放在支持 JSON 折叠的查看器中，比如 atom 或 Visual Studio）。


<details>
  <summary>
    **点击这里查看配置**
  </summary>
  ```
  {
  "channel_group": {
    "groups": {
      "Application": {
        "groups": {
          "Org1MSP": {
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
              "Readers": {
                "mod_policy": "Admins",
                "policy": {
                  "type": 1,
                  "value": {
                    "identities": [
                      {
                        "principal": {
                          "msp_identifier": "Org1MSP",
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
                          "msp_identifier": "Org1MSP",
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
                    "admins": [
                      "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNHRENDQWIrZ0F3SUJBZ0lRSWlyVmg3NVcwWmh0UjEzdmltdmliakFLQmdncWhrak9QUVFEQWpCek1Rc3cKQ1FZRFZRUUdFd0pWVXpFVE1CRUdBMVVFQ0JNS1EyRnNhV1p2Y201cFlURVdNQlFHQTFVRUJ4TU5VMkZ1SUVaeQpZVzVqYVhOamJ6RVpNQmNHQTFVRUNoTVFiM0puTVM1bGVHRnRjR3hsTG1OdmJURWNNQm9HQTFVRUF4TVRZMkV1CmIzSm5NUzVsZUdGdGNHeGxMbU52YlRBZUZ3MHhOekV4TWpreE9USTBNRFphRncweU56RXhNamN4T1RJME1EWmEKTUZzeEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRFZRUUlFd3BEWVd4cFptOXlibWxoTVJZd0ZBWURWUVFIRXcxVApZVzRnUm5KaGJtTnBjMk52TVI4d0hRWURWUVFEREJaQlpHMXBia0J2Y21jeExtVjRZVzF3YkdVdVkyOXRNRmt3CkV3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFNkdVeDlpczZ0aG1ZRE9tMmVHSlA5eW1yaXJYWE1Cd0oKQmVWb1Vpak5haUdsWE03N2NsSE5aZjArMGFjK2djRU5lMzQweGExZVFnb2Q0YjVFcmQrNmtxTk5NRXN3RGdZRApWUjBQQVFIL0JBUURBZ2VBTUF3R0ExVWRFd0VCL3dRQ01BQXdLd1lEVlIwakJDUXdJb0FnWWdoR2xCMjBGWmZCCllQemdYT280czdkU1k1V3NKSkRZbGszTDJvOXZzQ013Q2dZSUtvWkl6ajBFQXdJRFJ3QXdSQUlnYmlEWDVTMlIKRTBNWGRobDZFbmpVNm1lTEJ0eXNMR2ZpZXZWTlNmWW1UQVVDSUdVbnROangrVXZEYkZPRHZFcFRVTm5MUHp0Qwp5ZlBnOEhMdWpMaXVpaWFaCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
                    ],
                    "crypto_config": {
                      "identity_identifier_hash_function": "SHA256",
                      "signature_hash_family": "SHA2"
                    },
                    "name": "Org1MSP",
                    "root_certs": [
                      "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNRekNDQWVxZ0F3SUJBZ0lSQU03ZVdTaVM4V3VVM2haMU9tR255eXd3Q2dZSUtvWkl6ajBFQXdJd2N6RUwKTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnVENrTmhiR2xtYjNKdWFXRXhGakFVQmdOVkJBY1REVk5oYmlCRwpjbUZ1WTJselkyOHhHVEFYQmdOVkJBb1RFRzl5WnpFdVpYaGhiWEJzWlM1amIyMHhIREFhQmdOVkJBTVRFMk5oCkxtOXlaekV1WlhoaGJYQnNaUzVqYjIwd0hoY05NVGN4TVRJNU1Ua3lOREEyV2hjTk1qY3hNVEkzTVRreU5EQTIKV2pCek1Rc3dDUVlEVlFRR0V3SlZVekVUTUJFR0ExVUVDQk1LUTJGc2FXWnZjbTVwWVRFV01CUUdBMVVFQnhNTgpVMkZ1SUVaeVlXNWphWE5qYnpFWk1CY0dBMVVFQ2hNUWIzSm5NUzVsZUdGdGNHeGxMbU52YlRFY01Cb0dBMVVFCkF4TVRZMkV1YjNKbk1TNWxlR0Z0Y0d4bExtTnZiVEJaTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEEwSUEKQkJiTTVZS3B6UmlEbDdLWWFpSDVsVnBIeEl1TDEyaUcyWGhkMHRpbEg3MEljMGFpRUh1dG9rTkZsUXAzTWI0Zgpvb0M2bFVXWnRnRDJwMzZFNThMYkdqK2pYekJkTUE0R0ExVWREd0VCL3dRRUF3SUJwakFQQmdOVkhTVUVDREFHCkJnUlZIU1VBTUE4R0ExVWRFd0VCL3dRRk1BTUJBZjh3S1FZRFZSME9CQ0lFSUdJSVJwUWR0QldYd1dEODRGenEKT0xPM1VtT1ZyQ1NRMkpaTnk5cVBiN0FqTUFvR0NDcUdTTTQ5QkFNQ0EwY0FNRVFDSUdlS2VZL1BsdGlWQTRPSgpRTWdwcDRvaGRMcGxKUFpzNERYS0NuOE9BZG9YQWlCK2g5TFdsR3ZsSDdtNkVpMXVRcDFld2ZESmxsZi9MZXczClgxaDNRY0VMZ3c9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
                    ],
                    "tls_root_certs": [
                      "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNTVENDQWZDZ0F3SUJBZ0lSQUtsNEFQWmV6dWt0Nk8wYjRyYjY5Y0F3Q2dZSUtvWkl6ajBFQXdJd2RqRUwKTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnVENrTmhiR2xtYjNKdWFXRXhGakFVQmdOVkJBY1REVk5oYmlCRwpjbUZ1WTJselkyOHhHVEFYQmdOVkJBb1RFRzl5WnpFdVpYaGhiWEJzWlM1amIyMHhIekFkQmdOVkJBTVRGblJzCmMyTmhMbTl5WnpFdVpYaGhiWEJzWlM1amIyMHdIaGNOTVRjeE1USTVNVGt5TkRBMldoY05NamN4TVRJM01Ua3kKTkRBMldqQjJNUXN3Q1FZRFZRUUdFd0pWVXpFVE1CRUdBMVVFQ0JNS1EyRnNhV1p2Y201cFlURVdNQlFHQTFVRQpCeE1OVTJGdUlFWnlZVzVqYVhOamJ6RVpNQmNHQTFVRUNoTVFiM0puTVM1bGVHRnRjR3hsTG1OdmJURWZNQjBHCkExVUVBeE1XZEd4elkyRXViM0puTVM1bGVHRnRjR3hsTG1OdmJUQlpNQk1HQnlxR1NNNDlBZ0VHQ0NxR1NNNDkKQXdFSEEwSUFCSnNpQXVjYlcrM0lqQ2VaaXZPakRiUmFyVlRjTW9TRS9mSnQyU0thR1d5bWQ0am5xM25MWC9vVApCVmpZb21wUG1QbGZ4R0VSWHl0UTNvOVZBL2hwNHBlalh6QmRNQTRHQTFVZER3RUIvd1FFQXdJQnBqQVBCZ05WCkhTVUVDREFHQmdSVkhTVUFNQThHQTFVZEV3RUIvd1FGTUFNQkFmOHdLUVlEVlIwT0JDSUVJSnlqZnFoa0FvY3oKdkRpNnNGSGFZL1Bvd2tPWkxPMHZ0VGdFRnVDbUpFalZNQW9HQ0NxR1NNNDlCQU1DQTBjQU1FUUNJRjVOVVdCVgpmSjgrM0lxU3J1NlFFbjlIa0lsQ0xDMnlvWTlaNHBWMnpBeFNBaUE5NWQzeDhBRXZIcUFNZnIxcXBOWHZ1TW5BCmQzUXBFa1gyWkh3ODZlQlVQZz09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
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
              "Readers": {
                "mod_policy": "Admins",
                "policy": {
                  "type": 1,
                  "value": {
                    "identities": [
                      {
                        "principal": {
                          "msp_identifier": "Org2MSP",
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
                          "msp_identifier": "Org2MSP",
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
                    "admins": [
                      "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNHVENDQWNDZ0F3SUJBZ0lSQU5Pb1lIbk9seU94dTJxZFBteStyV293Q2dZSUtvWkl6ajBFQXdJd2N6RUwKTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnVENrTmhiR2xtYjNKdWFXRXhGakFVQmdOVkJBY1REVk5oYmlCRwpjbUZ1WTJselkyOHhHVEFYQmdOVkJBb1RFRzl5WnpJdVpYaGhiWEJzWlM1amIyMHhIREFhQmdOVkJBTVRFMk5oCkxtOXlaekl1WlhoaGJYQnNaUzVqYjIwd0hoY05NVGN4TVRJNU1Ua3lOREEyV2hjTk1qY3hNVEkzTVRreU5EQTIKV2pCYk1Rc3dDUVlEVlFRR0V3SlZVekVUTUJFR0ExVUVDQk1LUTJGc2FXWnZjbTVwWVRFV01CUUdBMVVFQnhNTgpVMkZ1SUVaeVlXNWphWE5qYnpFZk1CMEdBMVVFQXd3V1FXUnRhVzVBYjNKbk1pNWxlR0Z0Y0d4bExtTnZiVEJaCk1CTUdCeXFHU000OUFnRUdDQ3FHU000OUF3RUhBMElBQkh1M0ZWMGlqdFFzckpsbnBCblgyRy9ickFjTHFJSzgKVDFiSWFyZlpvSkhtQm5IVW11RTBhc1dyKzM4VUs0N3hyczNZMGMycGhFVjIvRnhHbHhXMUZubWpUVEJMTUE0RwpBMVVkRHdFQi93UUVBd0lIZ0RBTUJnTlZIUk1CQWY4RUFqQUFNQ3NHQTFVZEl3UWtNQ0tBSU1pSzdteFpnQVVmCmdrN0RPTklXd2F4YktHVGdLSnVSNjZqVmordHZEV3RUTUFvR0NDcUdTTTQ5QkFNQ0EwY0FNRVFDSUQxaEtRdk8KVWxyWmVZMmZZY1N2YWExQmJPM3BVb3NxL2tZVElyaVdVM1J3QWlBR29mWmVPUFByWXVlTlk0Z2JCV2tjc3lpZgpNMkJmeXQwWG9NUThyT2VidUE9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
                    ],
                    "crypto_config": {
                      "identity_identifier_hash_function": "SHA256",
                      "signature_hash_family": "SHA2"
                    },
                    "name": "Org2MSP",
                    "root_certs": [
                      "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNSRENDQWVxZ0F3SUJBZ0lSQU1pVXk5SGRSbXB5MDdsSjhRMlZNWXN3Q2dZSUtvWkl6ajBFQXdJd2N6RUwKTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnVENrTmhiR2xtYjNKdWFXRXhGakFVQmdOVkJBY1REVk5oYmlCRwpjbUZ1WTJselkyOHhHVEFYQmdOVkJBb1RFRzl5WnpJdVpYaGhiWEJzWlM1amIyMHhIREFhQmdOVkJBTVRFMk5oCkxtOXlaekl1WlhoaGJYQnNaUzVqYjIwd0hoY05NVGN4TVRJNU1Ua3lOREEyV2hjTk1qY3hNVEkzTVRreU5EQTIKV2pCek1Rc3dDUVlEVlFRR0V3SlZVekVUTUJFR0ExVUVDQk1LUTJGc2FXWnZjbTVwWVRFV01CUUdBMVVFQnhNTgpVMkZ1SUVaeVlXNWphWE5qYnpFWk1CY0dBMVVFQ2hNUWIzSm5NaTVsZUdGdGNHeGxMbU52YlRFY01Cb0dBMVVFCkF4TVRZMkV1YjNKbk1pNWxlR0Z0Y0d4bExtTnZiVEJaTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEEwSUEKQk50YW1PY1hyaGwrQ2hzYXNSeklNWjV3OHpPWVhGcXhQbGV0a3d5UHJrbHpKWE01Qjl4QkRRVWlWNldJS2tGSwo0Vmd5RlNVWGZqaGdtd25kMUNBVkJXaWpYekJkTUE0R0ExVWREd0VCL3dRRUF3SUJwakFQQmdOVkhTVUVDREFHCkJnUlZIU1VBTUE4R0ExVWRFd0VCL3dRRk1BTUJBZjh3S1FZRFZSME9CQ0lFSU1pSzdteFpnQVVmZ2s3RE9OSVcKd2F4YktHVGdLSnVSNjZqVmordHZEV3RUTUFvR0NDcUdTTTQ5QkFNQ0EwZ0FNRVVDSVFEQ3FFRmFqeU5IQmVaRworOUdWVkNFNWI1YTF5ZlhvS3lkemdLMVgyOTl4ZmdJZ05BSUUvM3JINHFsUE9HbjdSS3Yram9WaUNHS2t6L0F1Cm9FNzI4RWR6WmdRPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
                    ],
                    "tls_root_certs": [
                      "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNTakNDQWZDZ0F3SUJBZ0lSQU9JNmRWUWMraHBZdkdMSlFQM1YwQU13Q2dZSUtvWkl6ajBFQXdJd2RqRUwKTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnVENrTmhiR2xtYjNKdWFXRXhGakFVQmdOVkJBY1REVk5oYmlCRwpjbUZ1WTJselkyOHhHVEFYQmdOVkJBb1RFRzl5WnpJdVpYaGhiWEJzWlM1amIyMHhIekFkQmdOVkJBTVRGblJzCmMyTmhMbTl5WnpJdVpYaGhiWEJzWlM1amIyMHdIaGNOTVRjeE1USTVNVGt5TkRBMldoY05NamN4TVRJM01Ua3kKTkRBMldqQjJNUXN3Q1FZRFZRUUdFd0pWVXpFVE1CRUdBMVVFQ0JNS1EyRnNhV1p2Y201cFlURVdNQlFHQTFVRQpCeE1OVTJGdUlFWnlZVzVqYVhOamJ6RVpNQmNHQTFVRUNoTVFiM0puTWk1bGVHRnRjR3hsTG1OdmJURWZNQjBHCkExVUVBeE1XZEd4elkyRXViM0puTWk1bGVHRnRjR3hsTG1OdmJUQlpNQk1HQnlxR1NNNDlBZ0VHQ0NxR1NNNDkKQXdFSEEwSUFCTWZ1QTMwQVVBT1ZKRG1qVlBZd1lNbTlweW92MFN6OHY4SUQ5N0twSHhXOHVOOUdSOU84aVdFMgo5bllWWVpiZFB2V1h1RCszblpweUFNcGZja3YvYUV5alh6QmRNQTRHQTFVZER3RUIvd1FFQXdJQnBqQVBCZ05WCkhTVUVDREFHQmdSVkhTVUFNQThHQTFVZEV3RUIvd1FGTUFNQkFmOHdLUVlEVlIwT0JDSUVJRnk5VHBHcStQL08KUGRXbkZXdWRPTnFqVDRxOEVKcDJmbERnVCtFV2RnRnFNQW9HQ0NxR1NNNDlCQU1DQTBnQU1FVUNJUUNZYlhSeApXWDZoUitPU0xBNSs4bFRwcXRMWnNhOHVuS3J3ek1UYXlQUXNVd0lnVSs5YXdaaE0xRzg3bGE0V0h4cmt5eVZ2CkU4S1ZsR09IVHVPWm9TMU5PT0U9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
                    ]
                  },
                  "type": 0
                },
                "version": "0"
              }
            },
            "version": "1"
          },
          "Org3MSP": {
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
                          "msp_identifier": "Org3MSP",
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
                          "msp_identifier": "Org3MSP",
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
                          "msp_identifier": "Org3MSP",
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
                    "admins": [
                      "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNHRENDQWIrZ0F3SUJBZ0lRQUlSNWN4U0hpVm1kSm9uY3FJVUxXekFLQmdncWhrak9QUVFEQWpCek1Rc3cKQ1FZRFZRUUdFd0pWVXpFVE1CRUdBMVVFQ0JNS1EyRnNhV1p2Y201cFlURVdNQlFHQTFVRUJ4TU5VMkZ1SUVaeQpZVzVqYVhOamJ6RVpNQmNHQTFVRUNoTVFiM0puTXk1bGVHRnRjR3hsTG1OdmJURWNNQm9HQTFVRUF4TVRZMkV1CmIzSm5NeTVsZUdGdGNHeGxMbU52YlRBZUZ3MHhOekV4TWpreE9UTTRNekJhRncweU56RXhNamN4T1RNNE16QmEKTUZzeEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRFZRUUlFd3BEWVd4cFptOXlibWxoTVJZd0ZBWURWUVFIRXcxVApZVzRnUm5KaGJtTnBjMk52TVI4d0hRWURWUVFEREJaQlpHMXBia0J2Y21jekxtVjRZVzF3YkdVdVkyOXRNRmt3CkV3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFSFlkVFY2ZC80cmR4WFd2cm1qZ0hIQlhXc2lxUWxrcnQKZ0p1NzMxcG0yZDRrWU82aEd2b2tFRFBwbkZFdFBwdkw3K1F1UjhYdkFQM0tqTkt0NHdMRG5hTk5NRXN3RGdZRApWUjBQQVFIL0JBUURBZ2VBTUF3R0ExVWRFd0VCL3dRQ01BQXdLd1lEVlIwakJDUXdJb0FnSWNxUFVhM1VQNmN0Ck9LZmYvKzVpMWJZVUZFeVFlMVAyU0hBRldWSWUxYzB3Q2dZSUtvWkl6ajBFQXdJRFJ3QXdSQUlnUm5LRnhsTlYKSmppVGpkZmVoczRwNy9qMkt3bFVuUWVuNFkyUnV6QjFrbm9DSUd3dEZ1TEdpRFY2THZSL2pHVXR3UkNyeGw5ZApVNENCeDhGbjBMdXNMTkJYCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
                    ],
                    "crypto_config": {
                      "identity_identifier_hash_function": "SHA256",
                      "signature_hash_family": "SHA2"
                    },
                    "name": "Org3MSP",
                    "root_certs": [
                      "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNRakNDQWVtZ0F3SUJBZ0lRUkN1U2Y0RVJNaDdHQW1ydTFIQ2FZREFLQmdncWhrak9QUVFEQWpCek1Rc3cKQ1FZRFZRUUdFd0pWVXpFVE1CRUdBMVVFQ0JNS1EyRnNhV1p2Y201cFlURVdNQlFHQTFVRUJ4TU5VMkZ1SUVaeQpZVzVqYVhOamJ6RVpNQmNHQTFVRUNoTVFiM0puTXk1bGVHRnRjR3hsTG1OdmJURWNNQm9HQTFVRUF4TVRZMkV1CmIzSm5NeTVsZUdGdGNHeGxMbU52YlRBZUZ3MHhOekV4TWpreE9UTTRNekJhRncweU56RXhNamN4T1RNNE16QmEKTUhNeEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRFZRUUlFd3BEWVd4cFptOXlibWxoTVJZd0ZBWURWUVFIRXcxVApZVzRnUm5KaGJtTnBjMk52TVJrd0Z3WURWUVFLRXhCdmNtY3pMbVY0WVcxd2JHVXVZMjl0TVJ3d0dnWURWUVFECkV4TmpZUzV2Y21jekxtVjRZVzF3YkdVdVkyOXRNRmt3RXdZSEtvWkl6ajBDQVFZSUtvWkl6ajBEQVFjRFFnQUUKZXFxOFFQMnllM08vM1J3UzI0SWdtRVdST3RnK3Zyc2pRY1BvTU42NEZiUGJKbmExMklNaVdDUTF6ZEZiTU9hSAorMUlrb21yY0RDL1ZpejkvY0M0NW9xTmZNRjB3RGdZRFZSMFBBUUgvQkFRREFnR21NQThHQTFVZEpRUUlNQVlHCkJGVWRKUUF3RHdZRFZSMFRBUUgvQkFVd0F3RUIvekFwQmdOVkhRNEVJZ1FnSWNxUFVhM1VQNmN0T0tmZi8rNWkKMWJZVUZFeVFlMVAyU0hBRldWSWUxYzB3Q2dZSUtvWkl6ajBFQXdJRFJ3QXdSQUlnTEgxL2xSZElWTVA4Z2FWeQpKRW01QWQ0SjhwZ256N1BVV2JIMzZvdVg4K1lDSUNPK20vUG9DbDRIbTlFbXhFN3ZnUHlOY2trVWd0SlRiTFhqCk5SWjBxNTdWCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
                    ],
                    "tls_root_certs": [
                      "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNTVENDQWZDZ0F3SUJBZ0lSQU9xc2JQQzFOVHJzclEvUUNpalh6K0F3Q2dZSUtvWkl6ajBFQXdJd2RqRUwKTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnVENrTmhiR2xtYjNKdWFXRXhGakFVQmdOVkJBY1REVk5oYmlCRwpjbUZ1WTJselkyOHhHVEFYQmdOVkJBb1RFRzl5WnpNdVpYaGhiWEJzWlM1amIyMHhIekFkQmdOVkJBTVRGblJzCmMyTmhMbTl5WnpNdVpYaGhiWEJzWlM1amIyMHdIaGNOTVRjeE1USTVNVGt6T0RNd1doY05NamN4TVRJM01Ua3oKT0RNd1dqQjJNUXN3Q1FZRFZRUUdFd0pWVXpFVE1CRUdBMVVFQ0JNS1EyRnNhV1p2Y201cFlURVdNQlFHQTFVRQpCeE1OVTJGdUlFWnlZVzVqYVhOamJ6RVpNQmNHQTFVRUNoTVFiM0puTXk1bGVHRnRjR3hsTG1OdmJURWZNQjBHCkExVUVBeE1XZEd4elkyRXViM0puTXk1bGVHRnRjR3hsTG1OdmJUQlpNQk1HQnlxR1NNNDlBZ0VHQ0NxR1NNNDkKQXdFSEEwSUFCSVJTTHdDejdyWENiY0VLMmhxSnhBVm9DaDhkejNqcnA5RHMyYW9TQjBVNTZkSUZhVmZoR2FsKwovdGp6YXlndXpFalFhNlJ1MmhQVnRGM2NvQnJ2Ulpxalh6QmRNQTRHQTFVZER3RUIvd1FFQXdJQnBqQVBCZ05WCkhTVUVDREFHQmdSVkhTVUFNQThHQTFVZEV3RUIvd1FGTUFNQkFmOHdLUVlEVlIwT0JDSUVJQ2FkVERGa0JPTGkKblcrN2xCbDExL3pPbXk4a1BlYXc0MVNZWEF6cVhnZEVNQW9HQ0NxR1NNNDlCQU1DQTBjQU1FUUNJQlgyMWR3UwpGaG5NdDhHWXUweEgrUGd5aXQreFdQUjBuTE1Jc1p2dVlRaktBaUFLUlE5N2VrLzRDTzZPWUtSakR0VFM4UFRmCm9nTmJ6dTBxcThjbVhseW5jZz09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
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
        "version": "1"
      },
      "Orderer": {
        "groups": {
          "OrdererOrg": {
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
                    "admins": [
                      "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNDakNDQWJDZ0F3SUJBZ0lRSFNTTnIyMWRLTTB6THZ0dEdoQnpMVEFLQmdncWhrak9QUVFEQWpCcE1Rc3cKQ1FZRFZRUUdFd0pWVXpFVE1CRUdBMVVFQ0JNS1EyRnNhV1p2Y201cFlURVdNQlFHQTFVRUJ4TU5VMkZ1SUVaeQpZVzVqYVhOamJ6RVVNQklHQTFVRUNoTUxaWGhoYlhCc1pTNWpiMjB4RnpBVkJnTlZCQU1URG1OaExtVjRZVzF3CmJHVXVZMjl0TUI0WERURTNNVEV5T1RFNU1qUXdObG9YRFRJM01URXlOekU1TWpRd05sb3dWakVMTUFrR0ExVUUKQmhNQ1ZWTXhFekFSQmdOVkJBZ1RDa05oYkdsbWIzSnVhV0V4RmpBVUJnTlZCQWNURFZOaGJpQkdjbUZ1WTJsegpZMjh4R2pBWUJnTlZCQU1NRVVGa2JXbHVRR1Y0WVcxd2JHVXVZMjl0TUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJCnpqMERBUWNEUWdBRTZCTVcvY0RGUkUvakFSenV5N1BjeFQ5a3pnZitudXdwKzhzK2xia0hZd0ZpaForMWRhR3gKKzhpS1hDY0YrZ0tpcVBEQXBpZ2REOXNSeTBoTEMwQnRacU5OTUVzd0RnWURWUjBQQVFIL0JBUURBZ2VBTUF3RwpBMVVkRXdFQi93UUNNQUF3S3dZRFZSMGpCQ1F3SW9BZ3o3bDQ2ZXRrODU0NFJEanZENVB6YjV3TzI5N0lIMnNUCngwTjAzOHZibkpzd0NnWUlLb1pJemowRUF3SURTQUF3UlFJaEFNRTJPWXljSnVyYzhVY2hkeTA5RU50RTNFUDIKcVoxSnFTOWVCK0gxSG5FSkFpQUtXa2h5TmI0akRPS2MramJIVmgwV0YrZ3J4UlJYT1hGaEl4ei85elI3UUE9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
                    ],
                    "crypto_config": {
                      "identity_identifier_hash_function": "SHA256",
                      "signature_hash_family": "SHA2"
                    },
                    "name": "OrdererMSP",
                    "root_certs": [
                      "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNMakNDQWRXZ0F3SUJBZ0lRY2cxUVZkVmU2Skd6YVU1cmxjcW4vakFLQmdncWhrak9QUVFEQWpCcE1Rc3cKQ1FZRFZRUUdFd0pWVXpFVE1CRUdBMVVFQ0JNS1EyRnNhV1p2Y201cFlURVdNQlFHQTFVRUJ4TU5VMkZ1SUVaeQpZVzVqYVhOamJ6RVVNQklHQTFVRUNoTUxaWGhoYlhCc1pTNWpiMjB4RnpBVkJnTlZCQU1URG1OaExtVjRZVzF3CmJHVXVZMjl0TUI0WERURTNNVEV5T1RFNU1qUXdObG9YRFRJM01URXlOekU1TWpRd05sb3dhVEVMTUFrR0ExVUUKQmhNQ1ZWTXhFekFSQmdOVkJBZ1RDa05oYkdsbWIzSnVhV0V4RmpBVUJnTlZCQWNURFZOaGJpQkdjbUZ1WTJsegpZMjh4RkRBU0JnTlZCQW9UQzJWNFlXMXdiR1V1WTI5dE1SY3dGUVlEVlFRREV3NWpZUzVsZUdGdGNHeGxMbU52CmJUQlpNQk1HQnlxR1NNNDlBZ0VHQ0NxR1NNNDlBd0VIQTBJQUJQTVI2MGdCcVJham9hS0U1TExRYjRIb28wN3QKYTRuM21Ncy9NRGloQVQ5YUN4UGZBcDM5SS8wMmwvZ2xiMTdCcEtxZGpGd0JKZHNuMVN6ZnQ3NlZkTitqWHpCZApNQTRHQTFVZER3RUIvd1FFQXdJQnBqQVBCZ05WSFNVRUNEQUdCZ1JWSFNVQU1BOEdBMVVkRXdFQi93UUZNQU1CCkFmOHdLUVlEVlIwT0JDSUVJTSs1ZU9uclpQT2VPRVE0N3crVDgyK2NEdHZleUI5ckU4ZERkTi9MMjV5Yk1Bb0cKQ0NxR1NNNDlCQU1DQTBjQU1FUUNJQVB6SGNOUmQ2a3QxSEdpWEFDclFTM0grL3R5NmcvVFpJa1pTeXIybmdLNQpBaUJnb1BVTTEwTHNsMVFtb2dlbFBjblZGZjJoODBXR2I3NGRIS2tzVFJKUkx3PT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo="
                    ],
                    "tls_root_certs": [
                      "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNORENDQWR1Z0F3SUJBZ0lRYWJ5SUl6cldtUFNzSjJacisvRVpXVEFLQmdncWhrak9QUVFEQWpCc01Rc3cKQ1FZRFZRUUdFd0pWVXpFVE1CRUdBMVVFQ0JNS1EyRnNhV1p2Y201cFlURVdNQlFHQTFVRUJ4TU5VMkZ1SUVaeQpZVzVqYVhOamJ6RVVNQklHQTFVRUNoTUxaWGhoYlhCc1pTNWpiMjB4R2pBWUJnTlZCQU1URVhSc2MyTmhMbVY0CllXMXdiR1V1WTI5dE1CNFhEVEUzTVRFeU9URTVNalF3TmxvWERUSTNNVEV5TnpFNU1qUXdObG93YkRFTE1Ba0cKQTFVRUJoTUNWVk14RXpBUkJnTlZCQWdUQ2tOaGJHbG1iM0p1YVdFeEZqQVVCZ05WQkFjVERWTmhiaUJHY21GdQpZMmx6WTI4eEZEQVNCZ05WQkFvVEMyVjRZVzF3YkdVdVkyOXRNUm93R0FZRFZRUURFeEYwYkhOallTNWxlR0Z0CmNHeGxMbU52YlRCWk1CTUdCeXFHU000OUFnRUdDQ3FHU000OUF3RUhBMElBQkVZVE9mdG1rTHdiSlRNeG1aVzMKZVdqRUQ2eW1UeEhYeWFQdTM2Y1NQWDlldDZyU3Y5UFpCTGxyK3hZN1dtYlhyOHM5K3E1RDMwWHl6OEh1OWthMQpSc1dqWHpCZE1BNEdBMVVkRHdFQi93UUVBd0lCcGpBUEJnTlZIU1VFQ0RBR0JnUlZIU1VBTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0tRWURWUjBPQkNJRUlJcjduNTVjTWlUdENEYmM5UGU0RFpnZ0ZYdHV2RktTdnBNYUhzbzAKSnpFd01Bb0dDQ3FHU000OUJBTUNBMGNBTUVRQ0lGM1gvMGtQRkFVQzV2N25JVVh6SmI5Z3JscWxET05UeVg2QQpvcmtFVTdWb0FpQkpMbS9IUFZ0aVRHY2NldUZPZTE4SnNwd0JTZ1hxNnY1K1BobEdsbU9pWHc9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
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
          "ChannelRestrictions": {
            "mod_policy": "Admins",
            "version": "0"
          },
          "ConsensusType": {
            "mod_policy": "Admins",
            "value": {
              "type": "solo"
            },
            "version": "0"
          }
        },
        "version": "0"
      }
    },
    "mod_policy": "",
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
  "sequence": "3",
  "type": 0
}
```
</details>

在这种格式下，一个配置看起来很吓人，但一旦你研究了它，你就会发现它是有逻辑结构的。

除了策略的定义 -- 定义谁可以在通道级别做某些事情，及谁有权限更改谁可以修改配置 -- 通道还
有其他一些特性可以使用配置更新进行修改。[向通道添加组织](./channel_update_tutorial.html)
将带你经过一个最重要的过程 -- 将一个组织加入通道。一些其他的可能通过配置更新修改的包括：

* **批处理大小.** 这些参数决定了一个区块中交易的数量和大小。没有区块会大于 `absolute_max_bytes` 
的大小或有比 `max_message_count` 更多的交易在区块中。如果有可能在 `preferred_max_bytes` 
之下构建一个区块，那么区块将被提早分割，而大于此大小的交易将出现在它们自己的区块中。

   ```
   {
     "absolute_max_bytes": 102760448,
     "max_message_count": 10,
     "preferred_max_bytes": 524288
   }
  ```

* **批处理超时.** 自一个交易到达后，在分割区块前，等待另外交易的时间量。降低这个值会
改善延迟，但降低太多将因为不允许区块填充到其最大容量而减少吞吐量。

  ```
  { "timeout": "2s" }
  ```

* **通道限制.** 排序节点愿意分配的通道总数量被定义为 max_count。这主要用于具有弱联盟
`ChannelCreation` 策略的预生产环境。

  ```
  {
   "max_count":1000
  }
  ```

* **通道创建策略.** 定义策略值，该值将被用来设置联盟中定义的新通道的 Application 组的 
mod_policy。附加到通道创建请求中的签名集将根据策略在新通道中的实例化进行检查，以确保通道
创建是经过授权的。注意这个配置值仅在排序系统通道中设置。

  ```
  {
  "type": 3,
  "value": {
    "rule": "ANY",
    "sub_policy": "Admins"
    }
  }
  ```

* **Kafka 代理.** 当 `ConsensusType` 设置为 `kafka` 时，`brokers` 列表将遍历 Kafka 
代理的某些子集（最好是全部），供排序节点在启动时进行初始连接。*注意，共识类型一旦建立 
（在创世区块的启动过程中），就不可能更改。*

  ```
  {
    "brokers": [
      "kafka0:9092",
      "kafka1:9092",
      "kafka2:9092",
      "kafka3:9092"
    ]
  }
  ```

* **锚节点定义.** 为每个组织定义锚节点位置。

  ```
  {
    "host": "peer0.org2.example.com",
      "port": 9051
  }
  ```

* **哈希结构.** 区块数据是字节数组的数组。区块数据的哈希值用默克尔树进行计算。这个值
定义了默克尔树的宽度。目前，此值固定为 `4294967295`，它对应于区块字节数据的串联的简单
直接的哈希。

  ```
  { "width": 4294967295 }
  ```

* **哈希算法.** 这个算法被用来计算将要被编码进区块链中的区块的哈希值。 尤其，这会影响
数据哈希，和区块的前一区块哈希字段。注意，这个字段当前仅有一个合法的值（`SHA256`），而
且不应被改变。

  ```
  { "name": "SHA256" }
  ```

* **区块验证.** 这个策略指定了一个区块被视为有效的签名需求。默认情况下，它需要一个来自
排序组织中的一些成员的签名。

  ```
  {
    "type": 3,
    "value": {
      "rule": "ANY",
      "sub_policy": "Writers"
    }
  }
  ```

* **排序节点地址.** 一个地址列表，客户端可以用来调用排序节点 `Broadcast` 和 `Deliver`
功能。对等节点在这些地址中随机地选择，并在它们之间应用故障转移来获取区块。

  ```
  {
    "addresses": [
      "orderer.example.com:7050"
    ]
  }
  ```

正如我们通过添加它们的 MSP 等相关信息来添加一个组织一样，你也可以通过反转这个过程来删除它们。

**注意** 一旦共识类型被定义且网络已经被启动，就不可能再通过配置更新来改变它了。

还有另一个重要的通道配置（特别是对于 v1.1）被称为**能力需求**. 它有自己的文档在[这里](./capability_requirements.html)。

假如你想编辑通道的区块批处理大小（因为这是一个单独的数值字段，它是一个最容易做的修改）。首先
为了方便引用 JSON 路径，我们把它定义为一个环境变量。

要确定这点，查看你的配置，找到你要查找的内容，然后反向跟踪路径。

如果你找到了批处理大小，比如，你会发现那是一个 `Orderer` 的 `value`。`Orderer` 在
`channel_group` 之下的 `groups` 之下。批处理大小值在 `value` 下有一个参数 
`max_message_count`。

形成路径如下：

```
 export MAXBATCHSIZEPATH=".channel_group.groups.Orderer.values.BatchSize.value.max_message_count"
```

接着，显示属性的值如下：

```
jq "$MAXBATCHSIZEPATH" config.json
```

这应该返回一个值 `10`（在我们的示例网络里如此）。

现在，让我们设置新的批处理大小并显示新的值：

```
 jq “$MAXBATCHSIZEPATH = 20” config.json > modified_config.json
 jq “$MAXBATCHSIZEPATH” modified_config.json
```

一旦你修改了 JSON，它就可以被转换并提交。[向通道添加组织](./channel_update_tutorial.html)
里的脚本和步骤会引导你完成转换 JSON 的过程，现在让我们来看看提交的过程。

## 获取必需的签名

一旦你成功地生成了原型文件，就可以签名了。为完成这个，你需要知道将要修改的东西的相关的策略。

默认情况下，编辑如下配置：
* **特定组织** （例如，改变锚节点) 仅需要该组织的管理员签名。
* **应用** （例如，谁是组织成员）需要应用组织里的多数管理员的签名。
* **排序节点** 需要排序节点组织里多数管理员的签名（默认为1）。
* **顶级 `channel` 组** 同时需要应用组织、及排序节点组织里多数管理员的同意。

如果你已经修改了通道的默认策略，你需要相应地计算签名要求。

*注意：你可能会编写收集签名的脚本，这取决于你的应用程序。一般来说，你可能总收集比需求的多的签名。*

收集签名的真实过程取决于你如何设置你的系统，但有两种主要的实现。当前，Fabric 命令行默认
使用“传递”系统。就是说，提出配置更新的组织的管理员将更新发送给需要签名的其他人（如另
一个管理员）。这个管理员对之签名（或不签名）并把它传递给下一个管理员，以此类推，直到有足
够可以提交配置的签名。

这有一个简单的优点 -- 当有了足够的签名时，最后一个管理员可以简单地提交配置交易（在 Fabric 
里，`peer channel update` 命令默认地包含签名）。但是，这个过程只适应于较小的通道，因为
“传递”方法可能会很耗时。

另一个选项是将更新提交给通道中每个管理员并等待返回足够的签名。这些签名可以被集中在一起提交。
这使得创建配置更新的管理员的工作更加困难（强制他们处理每个签名者的一个文件），但对于正在开发 
Fabric 管理应用程序的用户来说，这是推荐的工作流程。

一旦配置被加入账本，最好将之拉取并转换为 JSON 以确认所有内容添加正确。这也将作为最新配置的
有用的副本。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
