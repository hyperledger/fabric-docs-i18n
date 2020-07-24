升级到最新版本
===============================

如果你熟悉 Hyperledger Fabric 以前的版本，那么你会知道，将节点和通道升级到 Fabric 的最新版本，总体来说，有四步。

1. 备份账本和 MSP。
2. 以滚动的方式将 orderer 二进制文件升级到最新版本。
3. 以滚动方式将 peer 二进制文件升级到最新版本。
4. 在可用的情况下，将 orderer 系统通道和所有应用通道更新到最新功能。需要注意，某些版本在所有组中将具有功能，而其他版本可能几乎没有甚至根本没有新功能。

有关功能的更多信息，请查看 :doc:`capabilities_concept` 。

有关如何完成这些升级的信息，请查询这些教程：

1. :doc:`upgrading_your_components` 。在更新任何功能之前，应将组件升级到最新版本。
2. :doc:`updating_capabilities` 。更新所有节点的版本后完成。
3. :doc:`enable_cc_lifecycle` 。对于 Fabric v2.0 的新链码生命周期，需要添加组织指定的背书策略中心。

由于现在节点升级和提高通道的功能级别是 Fabric 的标准过程，因此我们将不展示升级到最新版本的具体命令。同样，``fabric-samples`` 仓库中也没有将示例网络从以前的版本升级到该版本，之前的版本中是有的。

.. note:: 最佳做法是将 SDK 升级到最新版本，这是网络常规升级的一部分。虽然 SDK 始终与相应版本和更低的 Fabric 版本兼容，但可能有必要升级到最新的 SDK 以利用最新的 Fabric 功能。有关如何升级的信息，请查阅所用 Fabric SDK 的文档。

.. toctree::
   :maxdepth: 1
   :caption: Upgrading to the latest release

   upgrade_to_newest_version
   upgrading_your_components
   updating_capabilities
   enable_cc_lifecycle
