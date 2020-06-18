定义功能需求
================================

如文档 :doc:`capabilities_concept` 中所述，在通道配置（在通道的最新配置区块中找到）中，为每个通道定义了功能需求。通道配置包含三个位置，每个位置定义了不同类型的功能。

+------------------+-----------------------------------+----------------------------------------------------+
| Capability Type  | Canonical Path                    | JSON Path                                          |
+==================+===================================+====================================================+
| Channel          | /Channel/Capabilities             | .channel_group.values.Capabilities                 |
+------------------+-----------------------------------+----------------------------------------------------+
| Orderer          | /Channel/Orderer/Capabilities     | .channel_group.groups.Orderer.values.Capabilities  |
+------------------+-----------------------------------+----------------------------------------------------+
| Application      | /Channel/Application/Capabilities | .channel_group.groups.Application.values.          |
|                  |                                   | Capabilities                                       |
+------------------+-----------------------------------+----------------------------------------------------+

功能设置
--------------------

功能设置是通道配置的一部分（要么作为初始配置，要么作为重新配置的一部分）。

.. note:: 有关如何更新通道配置的更多信息，请查看 doc:`channel_update_tutorial`。要了解不同的通道更新类型，请查看 :doc:`config_update`。

默认情况下，新通道将复制排序系统通道的配置，因此新通道将被自动配置为和排序系统通道中的排序节点、通道功能以及通道创建交易是指定的应用功能一起工作。通道已经存在了，但是必须被重新配置。

功能的值在 protobuf 定义如下：

.. code:: bash

  message Capabilities {
        map<string, Capability> capabilities = 1;
  }

  message Capability { }

JSON 格式如下：

.. code:: bash

  {
      "capabilities": {
          "V1_1": {}
      }
  }

初始配置中的功能
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

在发布的构件中 ``config`` 目录下的 ``configtx.yaml`` 文件中，有一个 ``Capabilities`` 部分，列举了每种功能类型（通道、排序节点和应用程序）的可能功能。

使用功能最简答的方法就是将 v1.1 中的示例结构复制过来并修改。例如：

.. code:: bash

    SampleSingleMSPRaftV1_1:
        Capabilities:
            <<: *GlobalCapabilities
        Orderer:
            <<: *OrdererDefaults
            Organizations:
                - *SampleOrg
            Capabilities:
                <<: *OrdererCapabilities
        Consortiums:
            SampleConsortium:
                Organizations:
                    - *SampleOrg

请注意， ``Capabilities`` 在根级别（用于通道功能）和 Orderer 级别（用于排序节点功能）各有一个定义部分。上边的示例使用 YAML 引用了在 YAML 文件底部定义的功能。

 定义排序服务通道的时候没有 Application 部分，它在创建应用通道的时候会被创建。要在创建通道的时候定义新通道中应用的功能，应用程序管理员需要在 ``SampleSingleMSPChannelV1_1`` 结构后边定义他们的通道创建交易。

 .. code:: bash

   SampleSingleMSPChannelV1_1:
        Consortium: SampleConsortium
        Application:
            Organizations:
                - *SampleOrg
            Capabilities:
                <<: *ApplicationCapabilities

这里，Application 部分有一个新元素 ``Capabilities``，引用了 YAML 最后部分的 ``ApplicationCapabilities``。

.. note:: Channel 和 Orderer 部分的功能继承了排序系统通道的定义，并被在创建通道时自动包含到了排序节点中。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
