# 更新通道配置

* 受众：网络管理员、节点管理员*

## 什么是通道配置？

Like many complex systems, Hyperledger Fabric networks are comprised of both **structure** and a number related of **processes**.

* **Structure**: encompassing users (like admins), organizations, peers, ordering nodes, CAs, smart contracts, and applications.
* **Process**: the way these structures interact. Most important of these are [Policies](./policies/policies.html), the rules that govern which users can do what, and under what conditions.

Information identifying the structure of blockchain networks and the processes governing how structures interact are contained in **channel configurations**. These configurations are collectively decided upon by the members of application channels, where transactions between peer organizations happen, and the "orderer system channel" managed by ordering organizations, and are contained in blocks that are committed to the ledger of a channel.

Because configurations are contained in blocks (the first of these is known as the genesis block with the latest representing the current configuration of the channel), the process for updating a channel configuration (changing the structure by adding members, for example, or processes by modifying channel policies) is known as a **configuration update transaction**.

In production networks, these configuration update transactions will normally be proposed by a single channel admin after an out of band discussion, just as the initial configuration of the channel will be decided on out of band by the initial members of the channel.

In this topic, we'll:

* Show a full sample configuration of an application channel.
* Discuss many of the channel parameters that can be edited.
* Show the process for updating a channel configuration, including the commands necessary to pull, translate, and scope a configuration into something that humans can read.
* Discuss the methods that can be used to edit a channel configuration.
* Show the process used to reformat a configuration and get the signatures necessary for it to be approved.

## Channel parameters that can be updated

通道是高度可配置的，但并非无限制。 Once certain things about a channel (for example, the name of the channel) have been specified, they cannot be changed. And changing one of the parameters we'll talk about in this topic requires satisfying the relevant policy as specified in the channel configuration.

In this section, we'll look a sample channel configuration and show the configuration parameters that can be updated.

### 通道配置示例

To see what the configuration file of an application channel looks like after it has been pulled and scoped, click **Click here to see the config** below. For ease of readability, it might be helpful to put this config into a viewer that supports JSON folding, like atom or Visual Studio.

Note: for simplicity, we are only showing an application channel configuration here. The configuration of the orderer system channel is very similar, but not identical, to the configuration of an application channel. However, the same basic rules and structure apply, as do the commands to pull and edit a configuration, as you can see in our topic on [Updating the capability level of a channel](./updating_capabilities.html).

<details>
  <summary>
    **Click here to see the config**. Note that this is the configuration of an application channel, not the orderer system channel.
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
                        "certificate": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNVakNDQWZpZ0F3SUJBZ0lSQVBYKzVxL21nckhNR280NFB5bjhYRnd3Q2dZSUtvWkl6ajBFQXdJd2N6RUwKTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnVENrTmhiR2xtYjNKdWFXRXhGakFVQmdOVkJBY1REVk5oYmlCRwpjbUZ1WTJselkyOHhHVEFYQmdOVkJBb1RFRzl5WnpFdVpYaGhiWEJzWlM1amIyMHhIREFhQmdOVkJBTVRFMk5oCkxtOXlaekV1WlhoaGJYQnNaUzVqYjIwd0hoY05NVGt4TVRFME1UTTBPREF3V2hjTk1qa3hNVEV4TVRNME9EQXcKV2pCek1Rc3dDUVlEVlFRR0V3SlZVekVUTUJFR0ExVUVDQk1LUTJGc2FXWnZjbTVwWVRFV01CUUdBMVVFQnhNTgpVMkZ1SUVaeVlXNWphWE5qYnpFWk1CY0dBMVVFQ2hNUWIzSm5NUzVsZUdGdGNHeGxMbU52YlRFY01Cb0dBMVVFCkF4TVRZMkV1YjNKbk1TNWxlR0Z0Y0d4bExtTnZiVEJaTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEEwSUEKQkV5TWtxZndLUkJCWDNKY2xGM3c0UkJZdGFGZytPeFgzSW9RanRrZzJodGxsV3dMV3YrWExXdVl2dkpUMTdxZAp1ei9uWGlWRWhhYnQ2VmVkRnBzanJuR2piVEJyTUE0R0ExVWREd0VCL3dRRUF3SUJwakFkQmdOVkhTVUVGakFVCkJnZ3JCZ0VGQlFjREFnWUlLd1lCQlFVSEF3RXdEd1lEVlIwVEFRSC9CQVV3QXdFQi96QXBCZ05WSFE0RUlnUWcKVytUN0RIb2puYXh0TkpJTHAvREd4UmVONkpPZENSUlBIdVhPNzZXY3k5OHdDZ1lJS29aSXpqMEVBd0lEU0FBdwpSUUloQUtUaHZNaFlBR3p6aVpNR1B1TjFpTTBEcHVpaFNydHJXRHJ6NkQ4QTBXOXBBaUI0MTFrTnJzVjN4ZU05ClNnaHFNc2lzK2QxWThEWE9DOXVrZGhBcU5GZ25FUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K",
                        "organizational_unit_identifier": "admin"
                      },
                      "client_ou_identifier": {
                        "certificate": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNVakNDQWZpZ0F3SUJBZ0lSQVBYKzVxL21nckhNR280NFB5bjhYRnd3Q2dZSUtvWkl6ajBFQXdJd2N6RUwKTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnVENrTmhiR2xtYjNKdWFXRXhGakFVQmdOVkJBY1REVk5oYmlCRwpjbUZ1WTJselkyOHhHVEFYQmdOVkJBb1RFRzl5WnpFdVpYaGhiWEJzWlM1amIyMHhIREFhQmdOVkJBTVRFMk5oCkxtOXlaekV1WlhoaGJYQnNaUzVqYjIwd0hoY05NVGt4TVRFME1UTTBPREF3V2hjTk1qa3hNVEV4TVRNME9EQXcKV2pCek1Rc3dDUVlEVlFRR0V3SlZVekVUTUJFR0ExVUVDQk1LUTJGc2FXWnZjbTVwWVRFV01CUUdBMVVFQnhNTgpVMkZ1SUVaeVlXNWphWE5qYnpFWk1CY0dBMVVFQ2hNUWIzSm5NUzVsZUdGdGNHeGxMbU52YlRFY01Cb0dBMVVFCkF4TVRZMkV1YjNKbk1TNWxlR0Z0Y0d4bExtTnZiVEJaTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEEwSUEKQkV5TWtxZndLUkJCWDNKY2xGM3c0UkJZdGFGZytPeFgzSW9RanRrZzJodGxsV3dMV3YrWExXdVl2dkpUMTdxZAp1ei9uWGlWRWhhYnQ2VmVkRnBzanJuR2piVEJyTUE0R0ExVWREd0VCL3dRRUF3SUJwakFkQmdOVkhTVUVGakFVCkJnZ3JCZ0VGQlFjREFnWUlLd1lCQlFVSEF3RXdEd1lEVlIwVEFRSC9CQVV3QXdFQi96QXBCZ05WSFE0RUlnUWcKVytUN0RIb2puYXh0TkpJTHAvREd4UmVONkpPZENSUlBIdVhPNzZXY3k5OHdDZ1lJS29aSXpqMEVBd0lEU0FBdwpSUUloQUtUaHZNaFlBR3p6aVpNR1B1TjFpTTBEcHVpaFNydHJXRHJ6NkQ4QTBXOXBBaUI0MTFrTnJzVjN4ZU05ClNnaHFNc2lzK2QxWThEWE9DOXVrZGhBcU5GZ25FUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K",
                        "organizational_unit_identifier": "client"
                      },
                      "enable": true,
                      "orderer_ou_identifier": {
                        "certificate": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNVakNDQWZpZ0F3SUJBZ0lSQVBYKzVxL21nckhNR280NFB5bjhYRnd3Q2dZSUtvWkl6ajBFQXdJd2N6RUwKTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnVENrTmhiR2xtYjNKdWFXRXhGakFVQmdOVkJBY1REVk5oYmlCRwpjbUZ1WTJselkyOHhHVEFYQmdOVkJBb1RFRzl5WnpFdVpYaGhiWEJzWlM1amIyMHhIREFhQmdOVkJBTVRFMk5oCkxtOXlaekV1WlhoaGJYQnNaUzVqYjIwd0hoY05NVGt4TVRFME1UTTBPREF3V2hjTk1qa3hNVEV4TVRNME9EQXcKV2pCek1Rc3dDUVlEVlFRR0V3SlZVekVUTUJFR0ExVUVDQk1LUTJGc2FXWnZjbTVwWVRFV01CUUdBMVVFQnhNTgpVMkZ1SUVaeVlXNWphWE5qYnpFWk1CY0dBMVVFQ2hNUWIzSm5NUzVsZUdGdGNHeGxMbU52YlRFY01Cb0dBMVVFCkF4TVRZMkV1YjNKbk1TNWxlR0Z0Y0d4bExtTnZiVEJaTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEEwSUEKQkV5TWtxZndLUkJCWDNKY2xGM3c0UkJZdGFGZytPeFgzSW9RanRrZzJodGxsV3dMV3YrWExXdVl2dkpUMTdxZAp1ei9uWGlWRWhhYnQ2VmVkRnBzanJuR2piVEJyTUE0R0ExVWREd0VCL3dRRUF3SUJwakFkQmdOVkhTVUVGakFVCkJnZ3JCZ0VGQlFjREFnWUlLd1lCQlFVSEF3RXdEd1lEVlIwVEFRSC9CQVV3QXdFQi96QXBCZ05WSFE0RUlnUWcKVytUN0RIb2puYXh0TkpJTHAvREd4UmVONkpPZENSUlBIdVhPNzZXY3k5OHdDZ1lJS29aSXpqMEVBd0lEU0FBdwpSUUloQUtUaHZNaFlBR3p6aVpNR1B1TjFpTTBEcHVpaFNydHJXRHJ6NkQ4QTBXOXBBaUI0MTFrTnJzVjN4ZU05ClNnaHFNc2lzK2QxWThEWE9DOXVrZGhBcU5GZ25FUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K",
                        "organizational_unit_identifier": "orderer"
                      },
                      "peer_ou_identifier": {
                        "certificate": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNVakNDQWZpZ0F3SUJBZ0lSQVBYKzVxL21nckhNR280NFB5bjhYRnd3Q2dZSUtvWkl6ajBFQXdJd2N6RUwKTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnVENrTmhiR2xtYjNKdWFXRXhGakFVQmdOVkJBY1REVk5oYmlCRwpjbUZ1WTJselkyOHhHVEFYQmdOVkJBb1RFRzl5WnpFdVpYaGhiWEJzWlM1amIyMHhIREFhQmdOVkJBTVRFMk5oCkxtOXlaekV1WlhoaGJYQnNaUzVqYjIwd0hoY05NVGt4TVRFME1UTTBPREF3V2hjTk1qa3hNVEV4TVRNME9EQXcKV2pCek1Rc3dDUVlEVlFRR0V3SlZVekVUTUJFR0ExVUVDQk1LUTJGc2FXWnZjbTVwWVRFV01CUUdBMVVFQnhNTgpVMkZ1SUVaeVlXNWphWE5qYnpFWk1CY0dBMVVFQ2hNUWIzSm5NUzVsZUdGdGNHeGxMbU52YlRFY01Cb0dBMVVFCkF4TVRZMkV1YjNKbk1TNWxlR0Z0Y0d4bExtTnZiVEJaTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEEwSUEKQkV5TWtxZndLUkJCWDNKY2xGM3c0UkJZdGFGZytPeFgzSW9RanRrZzJodGxsV3dMV3YrWExXdVl2dkpUMTdxZAp1ei9uWGlWRWhhYnQ2VmVkRnBzanJuR2piVEJyTUE0R0ExVWREd0VCL3dRRUF3SUJwakFkQmdOVkhTVUVGakFVCkJnZ3JCZ0VGQlFjREFnWUlLd1lCQlFVSEF3RXdEd1lEVlIwVEFRSC9CQVV3QXdFQi96QXBCZ05WSFE0RUlnUWcKVytUN0RIb2puYXh0TkpJTHAvREd4UmVONkpPZENSUlBIdVhPNzZXY3k5OHdDZ1lJS29aSXpqMEVBd0lEU0FBdwpSUUloQUtUaHZNaFlBR3p6aVpNR1B1TjFpTTBEcHVpaFNydHJXRHJ6NkQ4QTBXOXBBaUI0MTFrTnJzVjN4ZU05ClNnaHFNc2lzK2QxWThEWE9DOXVrZGhBcU5GZ25FUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K",
                        "organizational_unit_identifier": "peer"
                      }
                    },
                    "intermediate_certs": [],
                    "name": "Org1MSP",
                    "organizational_unit_identifiers": [],
                    "revocation_list": [],
                    "root_certs": [
                      "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNVakNDQWZpZ0F3SUJBZ0lSQVBYKzVxL21nckhNR280NFB5bjhYRnd3Q2dZSUtvWkl6ajBFQXdJd2N6RUwKTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnVENrTmhiR2xtYjNKdWFXRXhGakFVQmdOVkJBY1REVk5oYmlCRwpjbUZ1WTJselkyOHhHVEFYQmdOVkJBb1RFRzl5WnpFdVpYaGhiWEJzWlM1amIyMHhIREFhQmdOVkJBTVRFMk5oCkxtOXlaekV1WlhoaGJYQnNaUzVqYjIwd0hoY05NVGt4TVRFME1UTTBPREF3V2hjTk1qa3hNVEV4TVRNME9EQXcKV2pCek1Rc3dDUVlEVlFRR0V3SlZVekVUTUJFR0ExVUVDQk1LUTJGc2FXWnZjbTVwWVRFV01CUUdBMVVFQnhNTgpVMkZ1SUVaeVlXNWphWE5qYnpFWk1CY0dBMVVFQ2hNUWIzSm5NUzVsZUdGdGNHeGxMbU52YlRFY01Cb0dBMVVFCkF4TVRZMkV1YjNKbk1TNWxlR0Z0Y0d4bExtTnZiVEJaTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEEwSUEKQkV5TWtxZndLUkJCWDNKY2xGM3c0UkJZdGFGZytPeFgzSW9RanRrZzJodGxsV3dMV3YrWExXdVl2dkpUMTdxZAp1ei9uWGlWRWhhYnQ2VmVkRnBzanJuR2piVEJyTUE0R0ExVWREd0VCL3dRRUF3SUJwakFkQmdOVkhTVUVGakFVCkJnZ3JCZ0VGQlFjREFnWUlLd1lCQlFVSEF3RXdEd1lEVlIwVEFRSC9CQVV3QXdFQi96QXBCZ05WSFE0RUlnUWcKVytUN0RIb2puYXh0TkpJTHAvREd4UmVONkpPZENSUlBIdVhPNzZXY3k5OHdDZ1lJS29aSXpqMEVBd0lEU0FBdwpSUUloQUtUaHZNaFlBR3p6aVpNR1B1TjFpTTBEcHVpaFNydHJXRHJ6NkQ4QTBXOXBBaUI0MTFrTnJzVjN4ZU05ClNnaHFNc2lzK2QxWThEWE9DOXVrZGhBcU5GZ25FUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
                    ],
                    "signing_identity": null,
                    "tls_intermediate_certs": [],
                    "tls_root_certs": [
                      "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNWekNDQWY2Z0F3SUJBZ0lSQUtvOGhJS0JjeldFOFQrSUZSVWVmZm93Q2dZSUtvWkl6ajBFQXdJd2RqRUwKTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnVENrTmhiR2xtYjNKdWFXRXhGakFVQmdOVkJBY1REVk5oYmlCRwpjbUZ1WTJselkyOHhHVEFYQmdOVkJBb1RFRzl5WnpFdVpYaGhiWEJzWlM1amIyMHhIekFkQmdOVkJBTVRGblJzCmMyTmhMbTl5WnpFdVpYaGhiWEJzWlM1amIyMHdIaGNOTVRreE1URTBNVE0wT0RBd1doY05Namt4TVRFeE1UTTAKT0RBd1dqQjJNUXN3Q1FZRFZRUUdFd0pWVXpFVE1CRUdBMVVFQ0JNS1EyRnNhV1p2Y201cFlURVdNQlFHQTFVRQpCeE1OVTJGdUlFWnlZVzVqYVhOamJ6RVpNQmNHQTFVRUNoTVFiM0puTVM1bGVHRnRjR3hsTG1OdmJURWZNQjBHCkExVUVBeE1XZEd4elkyRXViM0puTVM1bGVHRnRjR3hsTG1OdmJUQlpNQk1HQnlxR1NNNDlBZ0VHQ0NxR1NNNDkKQXdFSEEwSUFCRUdGY3N6UmNJWXJnUVltK1JwL0owR3NrRXk4OFlDS2xqY2lSY1BoS3FKVWI3L29aSExRSWRtNQpSV0pLcVNZeSs3R2FqWHlROFQxNG1mY2IrM0ZodkpTamJUQnJNQTRHQTFVZER3RUIvd1FFQXdJQnBqQWRCZ05WCkhTVUVGakFVQmdnckJnRUZCUWNEQWdZSUt3WUJCUVVIQXdFd0R3WURWUjBUQVFIL0JBVXdBd0VCL3pBcEJnTlYKSFE0RUlnUWdOZzd3RHhRSkMwREYvQWo5YUwvbXJQVlJNMkozb2VRelEwdnV2cWgzdm5Fd0NnWUlLb1pJemowRQpBd0lEUndBd1JBSWdkYWZXMjJ0WXZuZVd6bEp2Mlg5WC9qM2VCbTdxSG9xejZ2QmV2cENZd3Q4Q0lHYXJJTm5oCnArRnFyaUVoaDI5SDgrcEVTV1NvZXQ1UzFKQVRrd0srNTJMawotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
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
                        "certificate": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNVakNDQWZpZ0F3SUJBZ0lSQU1JaCt2V1lHTGs5bUFTT1JNb05iVkl3Q2dZSUtvWkl6ajBFQXdJd2N6RUwKTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnVENrTmhiR2xtYjNKdWFXRXhGakFVQmdOVkJBY1REVk5oYmlCRwpjbUZ1WTJselkyOHhHVEFYQmdOVkJBb1RFRzl5WnpJdVpYaGhiWEJzWlM1amIyMHhIREFhQmdOVkJBTVRFMk5oCkxtOXlaekl1WlhoaGJYQnNaUzVqYjIwd0hoY05NVGt4TVRFME1UTTBPREF3V2hjTk1qa3hNVEV4TVRNME9EQXcKV2pCek1Rc3dDUVlEVlFRR0V3SlZVekVUTUJFR0ExVUVDQk1LUTJGc2FXWnZjbTVwWVRFV01CUUdBMVVFQnhNTgpVMkZ1SUVaeVlXNWphWE5qYnpFWk1CY0dBMVVFQ2hNUWIzSm5NaTVsZUdGdGNHeGxMbU52YlRFY01Cb0dBMVVFCkF4TVRZMkV1YjNKbk1pNWxlR0Z0Y0d4bExtTnZiVEJaTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEEwSUEKQlBBc2FrbklPUmx2M0pPdnBsQld5VCt0SUlFZWo2U2ZQaTlKTS8yQmYzOWkxdFVpRCt2aVV1Tk43MGlKcXRwRQpUbm50V2htWjA5elAzaVUwcklXWGJLcWpiVEJyTUE0R0ExVWREd0VCL3dRRUF3SUJwakFkQmdOVkhTVUVGakFVCkJnZ3JCZ0VGQlFjREFnWUlLd1lCQlFVSEF3RXdEd1lEVlIwVEFRSC9CQVV3QXdFQi96QXBCZ05WSFE0RUlnUWcKQzl3Y0RKb3FKL2dyUGF3S1d4RnVjNVB3MitTdTBsQVpFcFRGaEdDQlJSTXdDZ1lJS29aSXpqMEVBd0lEU0FBdwpSUUloQU1JaFJOVDVJMHpwTlRaa1dCSkdyblJqSUhkWXYwS2lWL1JKbkd5Yi9XVFFBaUJ6eUJqYnR3L1JyWEV3Clpzb0N1MmtoOUUwOUZIdXl5dGgydUtWc3Y0ZTlnUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K",
                        "organizational_unit_identifier": "admin"
                      },
                      "client_ou_identifier": {
                        "certificate": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNVakNDQWZpZ0F3SUJBZ0lSQU1JaCt2V1lHTGs5bUFTT1JNb05iVkl3Q2dZSUtvWkl6ajBFQXdJd2N6RUwKTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnVENrTmhiR2xtYjNKdWFXRXhGakFVQmdOVkJBY1REVk5oYmlCRwpjbUZ1WTJselkyOHhHVEFYQmdOVkJBb1RFRzl5WnpJdVpYaGhiWEJzWlM1amIyMHhIREFhQmdOVkJBTVRFMk5oCkxtOXlaekl1WlhoaGJYQnNaUzVqYjIwd0hoY05NVGt4TVRFME1UTTBPREF3V2hjTk1qa3hNVEV4TVRNME9EQXcKV2pCek1Rc3dDUVlEVlFRR0V3SlZVekVUTUJFR0ExVUVDQk1LUTJGc2FXWnZjbTVwWVRFV01CUUdBMVVFQnhNTgpVMkZ1SUVaeVlXNWphWE5qYnpFWk1CY0dBMVVFQ2hNUWIzSm5NaTVsZUdGdGNHeGxMbU52YlRFY01Cb0dBMVVFCkF4TVRZMkV1YjNKbk1pNWxlR0Z0Y0d4bExtTnZiVEJaTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEEwSUEKQlBBc2FrbklPUmx2M0pPdnBsQld5VCt0SUlFZWo2U2ZQaTlKTS8yQmYzOWkxdFVpRCt2aVV1Tk43MGlKcXRwRQpUbm50V2htWjA5elAzaVUwcklXWGJLcWpiVEJyTUE0R0ExVWREd0VCL3dRRUF3SUJwakFkQmdOVkhTVUVGakFVCkJnZ3JCZ0VGQlFjREFnWUlLd1lCQlFVSEF3RXdEd1lEVlIwVEFRSC9CQVV3QXdFQi96QXBCZ05WSFE0RUlnUWcKQzl3Y0RKb3FKL2dyUGF3S1d4RnVjNVB3MitTdTBsQVpFcFRGaEdDQlJSTXdDZ1lJS29aSXpqMEVBd0lEU0FBdwpSUUloQU1JaFJOVDVJMHpwTlRaa1dCSkdyblJqSUhkWXYwS2lWL1JKbkd5Yi9XVFFBaUJ6eUJqYnR3L1JyWEV3Clpzb0N1MmtoOUUwOUZIdXl5dGgydUtWc3Y0ZTlnUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K",
                        "organizational_unit_identifier": "client"
                      },
                      "enable": true,
                      "orderer_ou_identifier": {
                        "certificate": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNVakNDQWZpZ0F3SUJBZ0lSQU1JaCt2V1lHTGs5bUFTT1JNb05iVkl3Q2dZSUtvWkl6ajBFQXdJd2N6RUwKTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnVENrTmhiR2xtYjNKdWFXRXhGakFVQmdOVkJBY1REVk5oYmlCRwpjbUZ1WTJselkyOHhHVEFYQmdOVkJBb1RFRzl5WnpJdVpYaGhiWEJzWlM1amIyMHhIREFhQmdOVkJBTVRFMk5oCkxtOXlaekl1WlhoaGJYQnNaUzVqYjIwd0hoY05NVGt4TVRFME1UTTBPREF3V2hjTk1qa3hNVEV4TVRNME9EQXcKV2pCek1Rc3dDUVlEVlFRR0V3SlZVekVUTUJFR0ExVUVDQk1LUTJGc2FXWnZjbTVwWVRFV01CUUdBMVVFQnhNTgpVMkZ1SUVaeVlXNWphWE5qYnpFWk1CY0dBMVVFQ2hNUWIzSm5NaTVsZUdGdGNHeGxMbU52YlRFY01Cb0dBMVVFCkF4TVRZMkV1YjNKbk1pNWxlR0Z0Y0d4bExtTnZiVEJaTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEEwSUEKQlBBc2FrbklPUmx2M0pPdnBsQld5VCt0SUlFZWo2U2ZQaTlKTS8yQmYzOWkxdFVpRCt2aVV1Tk43MGlKcXRwRQpUbm50V2htWjA5elAzaVUwcklXWGJLcWpiVEJyTUE0R0ExVWREd0VCL3dRRUF3SUJwakFkQmdOVkhTVUVGakFVCkJnZ3JCZ0VGQlFjREFnWUlLd1lCQlFVSEF3RXdEd1lEVlIwVEFRSC9CQVV3QXdFQi96QXBCZ05WSFE0RUlnUWcKQzl3Y0RKb3FKL2dyUGF3S1d4RnVjNVB3MitTdTBsQVpFcFRGaEdDQlJSTXdDZ1lJS29aSXpqMEVBd0lEU0FBdwpSUUloQU1JaFJOVDVJMHpwTlRaa1dCSkdyblJqSUhkWXYwS2lWL1JKbkd5Yi9XVFFBaUJ6eUJqYnR3L1JyWEV3Clpzb0N1MmtoOUUwOUZIdXl5dGgydUtWc3Y0ZTlnUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K",
                        "organizational_unit_identifier": "orderer"
                      },
                      "peer_ou_identifier": {
                        "certificate": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNVakNDQWZpZ0F3SUJBZ0lSQU1JaCt2V1lHTGs5bUFTT1JNb05iVkl3Q2dZSUtvWkl6ajBFQXdJd2N6RUwKTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnVENrTmhiR2xtYjNKdWFXRXhGakFVQmdOVkJBY1REVk5oYmlCRwpjbUZ1WTJselkyOHhHVEFYQmdOVkJBb1RFRzl5WnpJdVpYaGhiWEJzWlM1amIyMHhIREFhQmdOVkJBTVRFMk5oCkxtOXlaekl1WlhoaGJYQnNaUzVqYjIwd0hoY05NVGt4TVRFME1UTTBPREF3V2hjTk1qa3hNVEV4TVRNME9EQXcKV2pCek1Rc3dDUVlEVlFRR0V3SlZVekVUTUJFR0ExVUVDQk1LUTJGc2FXWnZjbTVwWVRFV01CUUdBMVVFQnhNTgpVMkZ1SUVaeVlXNWphWE5qYnpFWk1CY0dBMVVFQ2hNUWIzSm5NaTVsZUdGdGNHeGxMbU52YlRFY01Cb0dBMVVFCkF4TVRZMkV1YjNKbk1pNWxlR0Z0Y0d4bExtTnZiVEJaTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEEwSUEKQlBBc2FrbklPUmx2M0pPdnBsQld5VCt0SUlFZWo2U2ZQaTlKTS8yQmYzOWkxdFVpRCt2aVV1Tk43MGlKcXRwRQpUbm50V2htWjA5elAzaVUwcklXWGJLcWpiVEJyTUE0R0ExVWREd0VCL3dRRUF3SUJwakFkQmdOVkhTVUVGakFVCkJnZ3JCZ0VGQlFjREFnWUlLd1lCQlFVSEF3RXdEd1lEVlIwVEFRSC9CQVV3QXdFQi96QXBCZ05WSFE0RUlnUWcKQzl3Y0RKb3FKL2dyUGF3S1d4RnVjNVB3MitTdTBsQVpFcFRGaEdDQlJSTXdDZ1lJS29aSXpqMEVBd0lEU0FBdwpSUUloQU1JaFJOVDVJMHpwTlRaa1dCSkdyblJqSUhkWXYwS2lWL1JKbkd5Yi9XVFFBaUJ6eUJqYnR3L1JyWEV3Clpzb0N1MmtoOUUwOUZIdXl5dGgydUtWc3Y0ZTlnUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K",
                        "organizational_unit_identifier": "peer"
                      }
                    },
                    "intermediate_certs": [],
                    "name": "Org2MSP",
                    "organizational_unit_identifiers": [],
                    "revocation_list": [],
                    "root_certs": [
                      "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNVakNDQWZpZ0F3SUJBZ0lSQU1JaCt2V1lHTGs5bUFTT1JNb05iVkl3Q2dZSUtvWkl6ajBFQXdJd2N6RUwKTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnVENrTmhiR2xtYjNKdWFXRXhGakFVQmdOVkJBY1REVk5oYmlCRwpjbUZ1WTJselkyOHhHVEFYQmdOVkJBb1RFRzl5WnpJdVpYaGhiWEJzWlM1amIyMHhIREFhQmdOVkJBTVRFMk5oCkxtOXlaekl1WlhoaGJYQnNaUzVqYjIwd0hoY05NVGt4TVRFME1UTTBPREF3V2hjTk1qa3hNVEV4TVRNME9EQXcKV2pCek1Rc3dDUVlEVlFRR0V3SlZVekVUTUJFR0ExVUVDQk1LUTJGc2FXWnZjbTVwWVRFV01CUUdBMVVFQnhNTgpVMkZ1SUVaeVlXNWphWE5qYnpFWk1CY0dBMVVFQ2hNUWIzSm5NaTVsZUdGdGNHeGxMbU52YlRFY01Cb0dBMVVFCkF4TVRZMkV1YjNKbk1pNWxlR0Z0Y0d4bExtTnZiVEJaTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEEwSUEKQlBBc2FrbklPUmx2M0pPdnBsQld5VCt0SUlFZWo2U2ZQaTlKTS8yQmYzOWkxdFVpRCt2aVV1Tk43MGlKcXRwRQpUbm50V2htWjA5elAzaVUwcklXWGJLcWpiVEJyTUE0R0ExVWREd0VCL3dRRUF3SUJwakFkQmdOVkhTVUVGakFVCkJnZ3JCZ0VGQlFjREFnWUlLd1lCQlFVSEF3RXdEd1lEVlIwVEFRSC9CQVV3QXdFQi96QXBCZ05WSFE0RUlnUWcKQzl3Y0RKb3FKL2dyUGF3S1d4RnVjNVB3MitTdTBsQVpFcFRGaEdDQlJSTXdDZ1lJS29aSXpqMEVBd0lEU0FBdwpSUUloQU1JaFJOVDVJMHpwTlRaa1dCSkdyblJqSUhkWXYwS2lWL1JKbkd5Yi9XVFFBaUJ6eUJqYnR3L1JyWEV3Clpzb0N1MmtoOUUwOUZIdXl5dGgydUtWc3Y0ZTlnUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
                    ],
                    "signing_identity": null,
                    "tls_intermediate_certs": [],
                    "tls_root_certs": [
                      "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNXRENDQWY2Z0F3SUJBZ0lSQVBoOGJPUzV1aVZLK2xwdjBKZDN5ZUl3Q2dZSUtvWkl6ajBFQXdJd2RqRUwKTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnVENrTmhiR2xtYjNKdWFXRXhGakFVQmdOVkJBY1REVk5oYmlCRwpjbUZ1WTJselkyOHhHVEFYQmdOVkJBb1RFRzl5WnpJdVpYaGhiWEJzWlM1amIyMHhIekFkQmdOVkJBTVRGblJzCmMyTmhMbTl5WnpJdVpYaGhiWEJzWlM1amIyMHdIaGNOTVRreE1URTBNVE0wT0RBd1doY05Namt4TVRFeE1UTTAKT0RBd1dqQjJNUXN3Q1FZRFZRUUdFd0pWVXpFVE1CRUdBMVVFQ0JNS1EyRnNhV1p2Y201cFlURVdNQlFHQTFVRQpCeE1OVTJGdUlFWnlZVzVqYVhOamJ6RVpNQmNHQTFVRUNoTVFiM0puTWk1bGVHRnRjR3hsTG1OdmJURWZNQjBHCkExVUVBeE1XZEd4elkyRXViM0puTWk1bGVHRnRjR3hsTG1OdmJUQlpNQk1HQnlxR1NNNDlBZ0VHQ0NxR1NNNDkKQXdFSEEwSUFCRHlhdEd3R2ZLSmFLazZ5ZmVJMGpObHVyWU5rbjdOaG5uNGVYbnVTd0hCazBRMDY4bnZ1Ujg4awprQTBRWm5vR2ZRWkEwU3RRM3JqVCt4b3BnMHFMcVBhamJUQnJNQTRHQTFVZER3RUIvd1FFQXdJQnBqQWRCZ05WCkhTVUVGakFVQmdnckJnRUZCUWNEQWdZSUt3WUJCUVVIQXdFd0R3WURWUjBUQVFIL0JBVXdBd0VCL3pBcEJnTlYKSFE0RUlnUWdGVDh3UThUcWlIVUxqMU1sY21JRWoreUFPSDF1R1NDNGxFRUVadUlTVkZBd0NnWUlLb1pJemowRQpBd0lEU0FBd1JRSWhBTExXb3Z2Z2JWTnJwcC9mbzZwTStoVXNMTTFkT3NncGRKNlRNd2FFdzQrTkFpQnJ0WFArCno5MFd6ZEQvRWpFWlcyM0xmeVhNMWRscXcyVHJEL3FWUVlGYXJRPT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo="
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
                "V1_4_2": {}
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
                        "certificate": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNQVENDQWVTZ0F3SUJBZ0lSQUxCOWVtTVhObkxaWW56TitkMHNJQ2N3Q2dZSUtvWkl6ajBFQXdJd2FURUwKTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnVENrTmhiR2xtYjNKdWFXRXhGakFVQmdOVkJBY1REVk5oYmlCRwpjbUZ1WTJselkyOHhGREFTQmdOVkJBb1RDMlY0WVcxd2JHVXVZMjl0TVJjd0ZRWURWUVFERXc1allTNWxlR0Z0CmNHeGxMbU52YlRBZUZ3MHhPVEV4TVRReE16UTRNREJhRncweU9URXhNVEV4TXpRNE1EQmFNR2t4Q3pBSkJnTlYKQkFZVEFsVlRNUk13RVFZRFZRUUlFd3BEWVd4cFptOXlibWxoTVJZd0ZBWURWUVFIRXcxVFlXNGdSbkpoYm1OcApjMk52TVJRd0VnWURWUVFLRXd0bGVHRnRjR3hsTG1OdmJURVhNQlVHQTFVRUF4TU9ZMkV1WlhoaGJYQnNaUzVqCmIyMHdXVEFUQmdjcWhrak9QUUlCQmdncWhrak9QUU1CQndOQ0FBVGVXYjlZWUdMNmgwMVlFckdzVS9xZmFzUmEKbUpHcFlWZGxsVTNwNldNUTMwZjcyazBFQitPRVQ3WWM3K0w2TWxxTTdNUDJBYnQ2RWUwV2w2OGpjZGxXbzIwdwphekFPQmdOVkhROEJBZjhFQkFNQ0FhWXdIUVlEVlIwbEJCWXdGQVlJS3dZQkJRVUhBd0lHQ0NzR0FRVUZCd01CCk1BOEdBMVVkRXdFQi93UUZNQU1CQWY4d0tRWURWUjBPQkNJRUlMQ0ZrREpzNkJNNzQ1YlVMUUhPY3RscFRtbFIKTTR6ZGpDaHlicW11QVNqb01Bb0dDQ3FHU000OUJBTUNBMGNBTUVRQ0lIQllZTVplZ2V3Wk5BUU1iU3hoQUhZMApqZnNCdDJOOHVTZ3prNHRIUWMvQ0FpQklCSjVXK3AyVTRzYi9zWjhPeS9mZjBIdFBBekZCSWV4VERkUGNnNUxBCk1RPT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=",
                        "organizational_unit_identifier": "admin"
                      },
                      "client_ou_identifier": {
                        "certificate": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNQVENDQWVTZ0F3SUJBZ0lSQUxCOWVtTVhObkxaWW56TitkMHNJQ2N3Q2dZSUtvWkl6ajBFQXdJd2FURUwKTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnVENrTmhiR2xtYjNKdWFXRXhGakFVQmdOVkJBY1REVk5oYmlCRwpjbUZ1WTJselkyOHhGREFTQmdOVkJBb1RDMlY0WVcxd2JHVXVZMjl0TVJjd0ZRWURWUVFERXc1allTNWxlR0Z0CmNHeGxMbU52YlRBZUZ3MHhPVEV4TVRReE16UTRNREJhRncweU9URXhNVEV4TXpRNE1EQmFNR2t4Q3pBSkJnTlYKQkFZVEFsVlRNUk13RVFZRFZRUUlFd3BEWVd4cFptOXlibWxoTVJZd0ZBWURWUVFIRXcxVFlXNGdSbkpoYm1OcApjMk52TVJRd0VnWURWUVFLRXd0bGVHRnRjR3hsTG1OdmJURVhNQlVHQTFVRUF4TU9ZMkV1WlhoaGJYQnNaUzVqCmIyMHdXVEFUQmdjcWhrak9QUUlCQmdncWhrak9QUU1CQndOQ0FBVGVXYjlZWUdMNmgwMVlFckdzVS9xZmFzUmEKbUpHcFlWZGxsVTNwNldNUTMwZjcyazBFQitPRVQ3WWM3K0w2TWxxTTdNUDJBYnQ2RWUwV2w2OGpjZGxXbzIwdwphekFPQmdOVkhROEJBZjhFQkFNQ0FhWXdIUVlEVlIwbEJCWXdGQVlJS3dZQkJRVUhBd0lHQ0NzR0FRVUZCd01CCk1BOEdBMVVkRXdFQi93UUZNQU1CQWY4d0tRWURWUjBPQkNJRUlMQ0ZrREpzNkJNNzQ1YlVMUUhPY3RscFRtbFIKTTR6ZGpDaHlicW11QVNqb01Bb0dDQ3FHU000OUJBTUNBMGNBTUVRQ0lIQllZTVplZ2V3Wk5BUU1iU3hoQUhZMApqZnNCdDJOOHVTZ3prNHRIUWMvQ0FpQklCSjVXK3AyVTRzYi9zWjhPeS9mZjBIdFBBekZCSWV4VERkUGNnNUxBCk1RPT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=",
                        "organizational_unit_identifier": "client"
                      },
                      "enable": true,
                      "orderer_ou_identifier": {
                        "certificate": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNQVENDQWVTZ0F3SUJBZ0lSQUxCOWVtTVhObkxaWW56TitkMHNJQ2N3Q2dZSUtvWkl6ajBFQXdJd2FURUwKTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnVENrTmhiR2xtYjNKdWFXRXhGakFVQmdOVkJBY1REVk5oYmlCRwpjbUZ1WTJselkyOHhGREFTQmdOVkJBb1RDMlY0WVcxd2JHVXVZMjl0TVJjd0ZRWURWUVFERXc1allTNWxlR0Z0CmNHeGxMbU52YlRBZUZ3MHhPVEV4TVRReE16UTRNREJhRncweU9URXhNVEV4TXpRNE1EQmFNR2t4Q3pBSkJnTlYKQkFZVEFsVlRNUk13RVFZRFZRUUlFd3BEWVd4cFptOXlibWxoTVJZd0ZBWURWUVFIRXcxVFlXNGdSbkpoYm1OcApjMk52TVJRd0VnWURWUVFLRXd0bGVHRnRjR3hsTG1OdmJURVhNQlVHQTFVRUF4TU9ZMkV1WlhoaGJYQnNaUzVqCmIyMHdXVEFUQmdjcWhrak9QUUlCQmdncWhrak9QUU1CQndOQ0FBVGVXYjlZWUdMNmgwMVlFckdzVS9xZmFzUmEKbUpHcFlWZGxsVTNwNldNUTMwZjcyazBFQitPRVQ3WWM3K0w2TWxxTTdNUDJBYnQ2RWUwV2w2OGpjZGxXbzIwdwphekFPQmdOVkhROEJBZjhFQkFNQ0FhWXdIUVlEVlIwbEJCWXdGQVlJS3dZQkJRVUhBd0lHQ0NzR0FRVUZCd01CCk1BOEdBMVVkRXdFQi93UUZNQU1CQWY4d0tRWURWUjBPQkNJRUlMQ0ZrREpzNkJNNzQ1YlVMUUhPY3RscFRtbFIKTTR6ZGpDaHlicW11QVNqb01Bb0dDQ3FHU000OUJBTUNBMGNBTUVRQ0lIQllZTVplZ2V3Wk5BUU1iU3hoQUhZMApqZnNCdDJOOHVTZ3prNHRIUWMvQ0FpQklCSjVXK3AyVTRzYi9zWjhPeS9mZjBIdFBBekZCSWV4VERkUGNnNUxBCk1RPT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=",
                        "organizational_unit_identifier": "orderer"
                      },
                      "peer_ou_identifier": {
                        "certificate": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNQVENDQWVTZ0F3SUJBZ0lSQUxCOWVtTVhObkxaWW56TitkMHNJQ2N3Q2dZSUtvWkl6ajBFQXdJd2FURUwKTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnVENrTmhiR2xtYjNKdWFXRXhGakFVQmdOVkJBY1REVk5oYmlCRwpjbUZ1WTJselkyOHhGREFTQmdOVkJBb1RDMlY0WVcxd2JHVXVZMjl0TVJjd0ZRWURWUVFERXc1allTNWxlR0Z0CmNHeGxMbU52YlRBZUZ3MHhPVEV4TVRReE16UTRNREJhRncweU9URXhNVEV4TXpRNE1EQmFNR2t4Q3pBSkJnTlYKQkFZVEFsVlRNUk13RVFZRFZRUUlFd3BEWVd4cFptOXlibWxoTVJZd0ZBWURWUVFIRXcxVFlXNGdSbkpoYm1OcApjMk52TVJRd0VnWURWUVFLRXd0bGVHRnRjR3hsTG1OdmJURVhNQlVHQTFVRUF4TU9ZMkV1WlhoaGJYQnNaUzVqCmIyMHdXVEFUQmdjcWhrak9QUUlCQmdncWhrak9QUU1CQndOQ0FBVGVXYjlZWUdMNmgwMVlFckdzVS9xZmFzUmEKbUpHcFlWZGxsVTNwNldNUTMwZjcyazBFQitPRVQ3WWM3K0w2TWxxTTdNUDJBYnQ2RWUwV2w2OGpjZGxXbzIwdwphekFPQmdOVkhROEJBZjhFQkFNQ0FhWXdIUVlEVlIwbEJCWXdGQVlJS3dZQkJRVUhBd0lHQ0NzR0FRVUZCd01CCk1BOEdBMVVkRXdFQi93UUZNQU1CQWY4d0tRWURWUjBPQkNJRUlMQ0ZrREpzNkJNNzQ1YlVMUUhPY3RscFRtbFIKTTR6ZGpDaHlicW11QVNqb01Bb0dDQ3FHU000OUJBTUNBMGNBTUVRQ0lIQllZTVplZ2V3Wk5BUU1iU3hoQUhZMApqZnNCdDJOOHVTZ3prNHRIUWMvQ0FpQklCSjVXK3AyVTRzYi9zWjhPeS9mZjBIdFBBekZCSWV4VERkUGNnNUxBCk1RPT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=",
                        "organizational_unit_identifier": "peer"
                      }
                    },
                    "intermediate_certs": [],
                    "name": "OrdererMSP",
                    "organizational_unit_identifiers": [],
                    "revocation_list": [],
                    "root_certs": [
                      "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNQVENDQWVTZ0F3SUJBZ0lSQUxCOWVtTVhObkxaWW56TitkMHNJQ2N3Q2dZSUtvWkl6ajBFQXdJd2FURUwKTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnVENrTmhiR2xtYjNKdWFXRXhGakFVQmdOVkJBY1REVk5oYmlCRwpjbUZ1WTJselkyOHhGREFTQmdOVkJBb1RDMlY0WVcxd2JHVXVZMjl0TVJjd0ZRWURWUVFERXc1allTNWxlR0Z0CmNHeGxMbU52YlRBZUZ3MHhPVEV4TVRReE16UTRNREJhRncweU9URXhNVEV4TXpRNE1EQmFNR2t4Q3pBSkJnTlYKQkFZVEFsVlRNUk13RVFZRFZRUUlFd3BEWVd4cFptOXlibWxoTVJZd0ZBWURWUVFIRXcxVFlXNGdSbkpoYm1OcApjMk52TVJRd0VnWURWUVFLRXd0bGVHRnRjR3hsTG1OdmJURVhNQlVHQTFVRUF4TU9ZMkV1WlhoaGJYQnNaUzVqCmIyMHdXVEFUQmdjcWhrak9QUUlCQmdncWhrak9QUU1CQndOQ0FBVGVXYjlZWUdMNmgwMVlFckdzVS9xZmFzUmEKbUpHcFlWZGxsVTNwNldNUTMwZjcyazBFQitPRVQ3WWM3K0w2TWxxTTdNUDJBYnQ2RWUwV2w2OGpjZGxXbzIwdwphekFPQmdOVkhROEJBZjhFQkFNQ0FhWXdIUVlEVlIwbEJCWXdGQVlJS3dZQkJRVUhBd0lHQ0NzR0FRVUZCd01CCk1BOEdBMVVkRXdFQi93UUZNQU1CQWY4d0tRWURWUjBPQkNJRUlMQ0ZrREpzNkJNNzQ1YlVMUUhPY3RscFRtbFIKTTR6ZGpDaHlicW11QVNqb01Bb0dDQ3FHU000OUJBTUNBMGNBTUVRQ0lIQllZTVplZ2V3Wk5BUU1iU3hoQUhZMApqZnNCdDJOOHVTZ3prNHRIUWMvQ0FpQklCSjVXK3AyVTRzYi9zWjhPeS9mZjBIdFBBekZCSWV4VERkUGNnNUxBCk1RPT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo="
                    ],
                    "signing_identity": null,
                    "tls_intermediate_certs": [],
                    "tls_root_certs": [
                      "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNRekNDQWVtZ0F3SUJBZ0lRYmVteDhRa200VTNMT1EwWWJibzNmVEFLQmdncWhrak9QUVFEQWpCc01Rc3cKQ1FZRFZRUUdFd0pWVXpFVE1CRUdBMVVFQ0JNS1EyRnNhV1p2Y201cFlURVdNQlFHQTFVRUJ4TU5VMkZ1SUVaeQpZVzVqYVhOamJ6RVVNQklHQTFVRUNoTUxaWGhoYlhCc1pTNWpiMjB4R2pBWUJnTlZCQU1URVhSc2MyTmhMbVY0CllXMXdiR1V1WTI5dE1CNFhEVEU1TVRFeE5ERXpORGd3TUZvWERUSTVNVEV4TVRFek5EZ3dNRm93YkRFTE1Ba0cKQTFVRUJoTUNWVk14RXpBUkJnTlZCQWdUQ2tOaGJHbG1iM0p1YVdFeEZqQVVCZ05WQkFjVERWTmhiaUJHY21GdQpZMmx6WTI4eEZEQVNCZ05WQkFvVEMyVjRZVzF3YkdVdVkyOXRNUm93R0FZRFZRUURFeEYwYkhOallTNWxlR0Z0CmNHeGxMbU52YlRCWk1CTUdCeXFHU000OUFnRUdDQ3FHU000OUF3RUhBMElBQkR4aWpEY3FDMjlja0JOb21lam4KKzliaHVhc05yNlRMZjlIOStibTFPNTZJcko4ZmZ6WnEwaUJ4MWlpdmJSVGRDb2gwQ1d6ZUxRRHQyR3VBTkMrTgpBMDJqYlRCck1BNEdBMVVkRHdFQi93UUVBd0lCcGpBZEJnTlZIU1VFRmpBVUJnZ3JCZ0VGQlFjREFnWUlLd1lCCkJRVUhBd0V3RHdZRFZSMFRBUUgvQkFVd0F3RUIvekFwQmdOVkhRNEVJZ1Fnbm56SFBNRlFsSk50d1NqRXNBUUkKdnBFb3BvK2R4RElxbVB3bW0xczErT1V3Q2dZSUtvWkl6ajBFQXdJRFNBQXdSUUloQUtCTGhsSTlTcVkwTTZzTQozdC9DVG9sSXVEcXNmUVF0eWxhTkZpOTFYZjVZQWlCb1JCVWNCdy95SExTU01BSEwwcXBqVStUWHdDVzBzZ29FCmZ3NUNnU2s4MWc9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
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
                "V1_4_2": {}
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
              "metadata": null,
              "state": "STATE_NORMAL",
              "type": "solo"
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
            "V1_4_3": {}
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

在这种格式下，一个配置看起来很吓人，但一旦你研究了它，你就会发现它是有逻辑结构的。

For example, let's take a look at the config with a few of the tabs closed.

Note that this is the configuration of an application channel, not the orderer system channel.

![Sample config simplified](./images/sample_config.png)

The structure of the config should now be more obvious. You can see the config groupings: `Channel`, `Application`, and `Orderer`, and the configuration parameters related to each config grouping (we'll talk more about these in the next section), but also where the MSPs representing organizations are. Note that the `Channel` config grouping is below the `Orderer` group config values.

### More about these parameters

In this section, we'll take a deeper look at the configurable values in the context of where they sit in the configuration.

First, there are config parameters that occur in multiple parts of the configuration:

* **Policies**. Policies are not just a configuration value (which can be updated as defined in a `mod_policy`), they define the circumstances under which all parameters can be changed. For more information, check out [Policies](./policies/policies.html).

* **Capabilities**. Ensures that networks and channels process things in the same way, creating deterministic results for things like channel configuration updates and chaincode invocations. Without deterministic results, one peer on a channel might invalidate a transaction while another peer may validate it. For more information, check out [Capabilities](./capabilities_concept.html).

#### `Channel/Application`

Governs the configuration parameters unique to application channels (for example, adding or removing channel members). By default, changing these parameters requires the signature of a majority of the application organization admins.

* **Add orgs to a channel**. To add an organization to a channel, their MSP and other organization parameters must be generated and added here (under `Channel/Application/groups`).

* **Organization-related parameters**. Any parameters specific to an organization, (identifying an anchor peer, for example, or the certificates of org admins), can be changed. Note that changing these values will by default not require the majority of application organization admins but only an admin of the organization itself.

#### `Channel/Orderer`

Governs configuration parameters unique to the ordering service or the orderer system channel, requires a majority of the ordering organizations’ admins (by default there is only one ordering organization, though more can be added, for example when multiple organizations contribute nodes to the ordering service).

* **批处理大小.** 这些参数决定了一个区块中交易的数量和大小。没有区块会大于 `absolute_max_bytes` 
的大小或有比 `max_message_count` 更多的交易在区块中。如果有可能在 `preferred_max_bytes` 
之下构建一个区块，那么区块将被提早分割，而大于此大小的交易将出现在它们自己的区块中。

* **批处理超时.** 自一个交易到达后，在分割区块前，等待另外交易的时间量。降低这个值会
改善延迟，但降低太多将因为不允许区块填充到其最大容量而减少吞吐量。

* **区块验证.** 这个策略指定了一个区块被视为有效的签名需求。默认情况下，它需要一个来自
排序组织中的一些成员的签名。

* **Consensus type**. To enable the migration of Kafka based ordering services to Raft based ordering services, it is possible to change the consensus type of a channel. For more information, check out [Migrating from Kafka to Raft](./kafka_raft_migration.html).

* **Raft ordering service parameters**. For a look at the parameters unique to a Raft ordering service, check out [Raft configuration](./raft_configuration.html).

* **Kafka 代理.** （如果可用）。当 `ConsensusType` 设置为 `kafka` 时，`brokers` 列表将遍历 Kafka 代理的某些子集（最好是全部），供排序节点在启动时进行初始连接。

#### `Channel`

Governs configuration parameters that both the peer orgs and the ordering service orgs need to consent to, requires both the agreement of a majority of application organization admins and orderer organization admins.

* **排序节点地址.** 一个地址列表，客户端可以用来调用排序节点 `Broadcast` 和 `Deliver`
功能。对等节点在这些地址中随机地选择，并在它们之间应用故障转移来获取区块。

* **哈希结构.** 区块数据是字节数组的数组。区块数据的哈希值用默克尔树进行计算。这个值
定义了默克尔树的宽度。目前，此值固定为 `4294967295`，它对应于区块字节数据的串联的简单
直接的哈希。

* **哈希算法.** 这个算法被用来计算将要被编码进区块链中的区块的哈希值。 尤其，这会影响
数据哈希，和区块的前一区块哈希字段。注意，这个字段当前仅有一个合法的值（`SHA256`），而
且不应被改变。

#### 系统通道配置参数

排序系统通道中特有的配置。

* **通道创建策略.** 定义策略值，该值将被用来设置联盟中定义的新通道的 Application 组的 
mod_policy。附加到通道创建请求中的签名集将根据策略在新通道中的实例化进行检查，以确保通道
创建是经过授权的。注意这个配置值仅在排序系统通道中设置。

* **通道限制.** 仅在排序系统通道中可编辑。排序节点愿意分配的通道总数量被定义为 `max_count`。这主要用于具有弱联盟
`ChannelCreation` 策略的预生产环境。

## 编辑配置

Updating a channel configuration is a three step operation that's conceptually simple:

1. Get the latest channel config
2. Create a modified channel config
3. Create a config update transaction

However, as you'll see, this conceptual simplicity is wrapped in a somewhat convoluted process. As a result, some users might choose to script the process of pulling, translating, and scoping a config update. Users also have the option of how to modify the channel configuration itself, either manually or by using a tool like `jq`.

We have two tutorials that deal specifically with editing a channel configuration to achieve a specific end:

* [Adding an Org to a Channel](./channel_update_tutorial.html): shows the process for adding an additional organization to an existing channel.
* [Updating channel capabilities](./updating_a_channel.html): shows how to update channel capabilities.

In this topic, we'll show the process of editing a channel configuration independent of the end goal of the configuration update.

### Set environment variables for your config update

Before you attempt to use the sample commands, make sure to export the following environment variables, which will depend on the way you have structured your deployment. Note that the channel name, `CH_NAME` will have to be set for every channel being updated, as channel configuration updates only apply to the configuration of the channel being updated (with the exception of the ordering system channel, whose configuration is copied into the configuration of application channels by default).

* `CH_NAME`: the name of the channel being updated.
* `TLS_ROOT_CA`: the path to the root CA cert of the TLS CA of the organization proposing the update.
* `CORE_PEER_LOCALMSPID`: the name of your MSP.
* `CORE_PEER_MSPCONFIGPATH`: the absolute path to the MSP of your organization.
* `ORDERER_CONTAINER`: the name of an ordering node container. Note that when targeting the ordering service, you can target any active node in the ordering service. Your requests will be forwarded to the leader automatically.

Note: this topic will provide default names for the various JSON and protobuf files being pulled and modified (`config_block.pb`, `config_block.json`, etc). You are free to use whatever names you want. However, be aware that unless you go back and erase these files at the end of each config update, you will have to select different when making an additional update.

### 步骤 1： 拉取并翻译配置

The first step in updating a channel configuration is getting the latest config block. This is a three step process. First, we'll pull the channel configuration in protobuf format, creating a file called `config_block.pb`.

确认你在 peer 容器中。

然后执行：

```
peer channel fetch config config_block.pb -o $ORDERER_CONTAINER -c $CH_NAME --tls --cafile $TLS_ROOT_CA
```

Next, we'll covert the protobuf version of the channel config into a JSON version called `config_block.json` (JSON files are easier for humans to read and understand):

```
configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
```

Finally, we'll scope out all of the unnecessary metadata from the config, which makes it easier to read. You are free to call this file whatever you want, but in this example we'll call it `config.json`.

```
jq .data.data[0].payload.data.config config_block.json > config.json
```

Now let's make a copy of `config.json` called `modified_config.json`. **Do not edit ``config.json`` directly**, as we will be using it to compute the difference between ``config.json`` and ``modified_config.json`` in a later step.

```
cp config.json modified_config.json
```

### 步骤 2： 修改配置

At this point, you have two options of how you want to modify the config.

1. Open ``modified_config.json`` using the text editor of your choice and make edits. Online tutorials exist that describe how to copy a file from a container that does not have an editor, edit it, and add it back to the container.
2. Use ``jq`` to apply edits to the config.

Whether you choose to edit the config manually or using `jq` depends on your use case. Because `jq` is concise and scriptable (an advantage when the same configuration update will be made to multiple channels), it's the recommend method for performing a channel update. For an example on how `jq` can be used, check out [Updating channel capabilities](./updating_a_channel.html#Create-a-capabilities-config-file), which shows multiple `jq` commands leveraging a capabilities config file called `capabilities.json`. If you are updating something other than the capabilities in your channel, you will have to modify your `jq` command and JSON file accordingly.

For more information about the content and structure of a channel configuration, check out our [sample channel config](#Sample-channel-configuration) above.

### 步骤 3： 重新编码并提交配置

Whether you make your config updates manually or using a tool like `jq`, you now have to run the process you ran to pull and scope the config in reverse, along with a step to calculate the difference between the old config and the new one, before submitting the config update to the other administrators on the channel to be approved.

First, we'll turn our `config.json` file back to protobuf format, creating a file called `config.pb`. Then we'll do the same with our `modified_config.json` file. Afterwards, we'll compute the difference between the two files, creating a file called `config_update.pb`.

```
configtxlator proto_encode --input config.json --type common.Config --output config.pb

configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb

configtxlator compute_update --channel_id $CH_NAME --original config.pb --updated modified_config.pb --output config_update.pb
```

Now that we have calculated the difference between the old config and the new one, we can apply the changes to the config.

```
configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json

echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CH_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json

configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb
```

提交配置更新交易：

```
peer channel update -f config_update_in_envelope.pb -c $CH_NAME -o $ORDERER_CONTAINER --tls true --cafile $TLS_ROOT_CA
```

Our config update transaction represents the difference between the original config and the modified one, but the ordering service will translate this into a full channel config.

## 获取必要的签名

Once you’ve successfully generated the new configuration protobuf file, it will need to satisfy the relevant policy for whatever it is you’re trying to change, typically (though not always) by requiring signatures from other organizations.

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
