欢迎贡献！
======================

我们欢迎以各种形式来为 Hyperledger 做贡献，这里有很多事可以做！

首先，最重要的是请在参与之前仔细阅读Hyperledger的 `行为准则 <https://wiki.hyperledger.org/community/hyperledger-project-code-of-conduct>`_ 。
保证文明合法是很重要的。

.. note:: 如果你想贡献此文档，请查看 :doc:`style_guide`。

贡献的方法
------------------
不管作为用户还是开发者，这里都有很多为 Hyperledger Fabric 做贡献的方法。

作为一个用户：

- `撰写功能或改进的提案`_
- `报告错误`_


作为一名作者或信息开发者：

- 利用你的Fabri经验和本文档来更新文档，以便改进现有主题并创建新主题。改变文档是成为贡献者的简单方法，
它使其他用户更容易理解和使用Fabric，并增加你的开源提交历史记录。

- 参与语言翻译，使Fabric文档在你选择的语言里保持最新状态。Fabric文档提供多种语言版本——英语、中文、
马拉雅拉姆语和巴西葡萄牙语——所以为什么不加入一个团队使你最爱的文档保持更新呢？你会发现一个友好的社区，与用户、作者和开发者一起合作。

- 如果Fabric文档在你的语言中不可用，请开始一个新的语言翻译项目。中文、马拉雅拉姆语和葡萄牙语巴西语团队就是这样开始的，
你也可以！这需要更多的工作，因为你需要组建一个作者团队并组织贡献，但是看到Fabric文档在你选择的语言中出现，非常有成就感。

跳转到 `贡献文档`_ 开始你的旅程。

作为一个开发者：

- 如果你的时间不多，可以考虑从 `"第一个好问题" <https://github.com/hyperledger/fabric/labels/good%20first%20issue>`_ 中选择一些任务，参考 `修复问题和认领正在进行的故事`_。
- 如果你承诺当全职开发，可以提出一个新的特性（参考 `提出功能或改进的建议`_ ）并带领一个团队来实现它，或者加入正在处理现有Epic（大型用户故事）的团队。
如果你在 `GitHub epic backlog <https://github.com/hyperledger/fabric/labels/Epic>`_ 上看到感兴趣的Epic，请通过GitHub问题联系该Epic的指派人员（Epic assignee）

贡献文档
--------------------------

将你的第一个更改作为文档更改是一个好主意。这样做快速简单，并确保你的机器已正确配置（包括所需的先决条件软件），还能使你熟悉贡献流程。
使用以下主题帮助你入门：

.. toctree::
   :maxdepth: 1

   advice_for_writers
   docs_guide
   international_languages
   style_guide

项目治理
------------------

正如我们的 `章程 <https://www.hyperledger.org/about/charter>`_ 中所说，Hyperledger Fabric 是在一个开放治理的模型下管理的。
项目和子项目由维护者主导。新的子项目可以指定一组初始的维护人员，这些维护人员将在项目首次批准时由顶级项目的现有维护人员批准。

维护者
~~~~~~~~~~~~~~~~~~

Hyperledger Fabric 是按照开放治理模型进行管理的，该模型在我们的 `章程 <https://www.hyperledger.org/about/charter>`_ 中有详细描述。
维护者负责评审和合并提交评审的所有补丁，并在超级账本技术委员会的方针下指导项目的技术发展路线。

成为一名维护者
~~~~~~~~~~~~~~~~~~~~~

项目的维护者会时不时地根据以下标准来考虑添加维护者：

- 提供（足质足量的）PR记录
- 在项目中表现出足够的领导能力
- 展现出引导项目工作和贡献者的能力

现有的维护者可以提交变更到 `维护者 <https://github.com/hyperledger/fabric/blob/master/MAINTAINERS.md>`_ 文件中。
一个提名的维护者可以由大多数现有的维护者批准通过成为正式的维护者。一旦批准通过，变更就会被合并，同时该维护者也会被添加到维护者组中。

维护者可能会因为明确的辞职、长时间的不活动（例如超过3个月或者更长的时间没评审评论），或者因为违反相关的 `行为准则 <https://wiki.hyperledger.org/community/hyperledger-project-code-of-conduct>`_ 
或持续表现出糟糕的判断而被移出维护者的队列。移除维护者的提案也需要大多数人同意。一个因为不活跃而被移除的维护者，如果在之后的一段时间（一个月或更长时间）内展示了持续的贡献和审查，表明对项目有重新承诺，可以被恢复成维护者的身份。

发布
~~~~~~~~~~~~~~~

Fabric大约每四个月发布一个版本，其中包含新功能和改进。新功能的工作会合并到Fabric的主分支 `GitHub <https://github.com/hyperledger/fabric>`_ 上。
在每次发布之前会创建发布分支，以便代码可以稳定，同时新功能继续合并到主分支。
重要的修复补丁也会被迁移到最近的LTS（长期支持）发布分支，以及在LTS发布重叠期间，会被迁移到上一个LTS发布分支。

提出功能或改进的建议
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

小的改进可以通过正常的 `GitHub拉取请求工作流程 <https://guides.github.com/introduction/flow/>`_ 来实现和审核
，但对于更重大的改变，Fabric遵循RFC（请求评论）过程。

这个过程旨在为Fabric和其他官方项目组件的重大改变提供一条一致且受控的路径，以便所有利益相关者可以对Fabric的发展方向有信心。

要提出一个新的功能，请首先检查 `GitHub问题积压 <https://github.com/hyperledger/fabric/issues>`_ 和
`Fabric RFC存储库 <https://github.com/hyperledger/fabric-rfcs/>`_ ，确保没有已经存在相同功能的提案（或者最近关闭的）。
如果没有，请按照 `RFC过程 <https://github.com/hyperledger/fabric-rfcs/blob/main/README.md>`_ 提出一个提案。

维护者会议
~~~~~~~~~~~~~~~~~~~

维护者会定期举行维护者会议。会议的目的是计划和审核发布进程，以及讨论项目和子项目的技术和维护方向。

维护者会议详情请查看 `wiki <https://wiki.hyperledger.org/display/fabric/Maintainer+Meetings>`_ 。

如上所述新特性或增强的建议应该在维护者的会议上进行探讨、反馈和接受。

发布路线
~~~~~~~~~~~~~~~

Fabric的发布路线图是通过一系列带有 `Epic标签的GitHub问题 <https://github.com/hyperledger/fabric/labels/Epic>`_
来管理的。

交流和获得帮助
~~~~~~~~~~~~~~

我们使用`Fabric邮件列表<https://lists.hyperledger.org/g/fabric/>`_ 作为正式沟通渠道并且使用
`Discord <https://discord.com/invite/hyperledger/>`_ 作为社区沟交谈。
如果你需要帮助或建议，请随时在Fabric频道上寻求帮助！
如果你需要有关贡献或建议的帮助，请在#fabric-code-contributors频道上寻求帮助。

我们通过github来管理我们项目的计划和优先级
`GitHub Issues ZenHub board <https://app.zenhub.com/workspaces/fabric-57c43689b6f3d8060d082cf1/board>`_, 并使用github
`Fabric contributor meeting <https://wiki.hyperledger.org/display/fabric/Contributor+Meetings>`_ 进行长期讨论决议.

邮件列表、Discord和GitHub分别需要自己的登录，你可以在首次互动时申请登录凭证。

The Hyperledger Fabric `wiki <https://wiki.hyperledger.org/display/fabric>`_
和在jira上的历史上的issues `Jira <https://jira.hyperledger.org/projects/FAB/issues>`_
需要你拥有一个`Linux Foundation ID <https://identity.linuxfoundation.org/>`_,
但是这些资源主要用来只读的，所以你大概率不需要一个Linux Foundation ID。

贡献指南
------------------

安装准备
~~~~~~~~~~~~~~~~~~~~~

在开始之前，如果你还没有这样做，你可能希望检查是否已经在将要开发区块链应用程序和/或操作Hyperledger Fabric的平台上安装了所有的先决条件。
请查阅 :doc:`先决条件 <prereqs>`。


报告错误
~~~~~~~~~~~~~~

如果你是一名用户并且已经发现一个问题，请可以通过
`GitHub Issues <https://github.com/hyperledger/fabric/issues>`_来提交问题。
在你提交一个新的GitHub issue之前，请尝试搜索现有问题列表，来确保没人已经提过了。
如果该问题之前已经被报告过，你可以添加一条评论表示你也希望看到这个缺陷被修复.

.. note:: 对于安全相关问题，请参考安全问题相关汇报流程
          `<https://wiki.hyperledger.org/display/SEC/Defect+Response>`_.

如果之前没有报告过该问题，你可以选择提交一个带有详细文档的PR，描述缺陷和修复的内容，或者你也可以创建一个新的GitHub问题。请尽量提供足够的信息，
以便其他人能够重现这个问题。项目的维护人员应该会在24小时内回复你的问题。如果没有回复，请在问题下方添加一条评论，并请求进行审核。
你还可以在 `Hyperledger Discord <https://discord.com/servers/hyperledger-foundation-905194001349627914>`_ 中广播相关问题。
例如，有关文档的问题应该发布到 ``#fabric-documentation``，有关数据库的问题应该发布到 ``#fabric-ledger``，等等...


提交你的修复
~~~~~~~~~~~~~~~~~~~

如果你在github上提交了你发现的问题并愿意提供一个修复，我们非常欢迎你这么做。请将github issue分配给你自己，并提交一个PR。
请参考 :doc:`github/github` PR提交的流程。

修复问题和在进行的故事上工作
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Fabric的问题和错误在 `GitHub issues <https://github.com/hyperledger/fabric/issues>`_ 中进行管理。请浏览问题列表，找到你感兴趣的问题。
你还可以查看 `“good first issue” <https://github.com/hyperledger/fabric/labels/good%20first%20issue>`_ 列表。建议你从相对简单和可行的问题开始，
并确保该问题还没有被其他人认领。如果没有其他人认领该问题，你可以将该问题指派给自己。如果你在合理的时间内无法完成该问题，请考虑撤销认领，或者在评论中说明你仍在积极处理该问题，
但需要一点额外的时间。

尽管GitHub issues跟踪了一系列已知可未来需要解决的问题的待办列表，但如果你打算立即处理一个还没有相应问题的更改，你可以提交一个没有链接到现有问题的Pull Request到
`Github <https://github.com/hyperledger/fabric>`_。


审核提交的PR
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

另一种参与和了解Hyperledger Fabric的方式是帮助维护人员审核开放的Pull Requests（PR）。维护人员拥有复杂的角色，需要审查所有被提交的PR，并评估是否应该合并。
你可以审查代码和/或文档更改，测试这些更改，并向提交者和维护人员反馈您的意见。完成你的审查和/或测试后，只需在PR中回复你的发现，通过添加评论和/或投票。
像“我在X系统上尝试过，它运行正常”或可能是“在X系统上出现了错误：xxx”这样的评论将有助于维护人员进行评估。结果，维护人员将能够更快地处理PR，并且每个人都会从中受益。

只需浏览 `GitHub上的开放PR <https://github.com/hyperledger/fabric/pulls>`_ 即可开始。

PR 老化
~~~~~~~~~~~~

随着Fabric项目的发展，未合并的PR数量也不断增加。几乎所有项目都会面临一个共同的问题，那就是如何有效地管理这些未合并的PR，Fabric也不例外。
为了保持Fabric和相关项目的PR backlog的可控性，我们将引入一项老化政策，并由机器人来执行。这与其他大型项目管理其PR backlog的方式是一致的。


PR 老化策略
~~~~~~~~~~~~~~~

Fabric项目的维护者将自动监控所有PR的活动情况。如果一个PR在2周内没有更新，将添加一条提醒评论，要求更新PR以解决未解决的评论问题，或者如果要撤回PR，
则将其放弃。如果一个迟延的PR在另外2周内没有更新，将自动放弃。如果一个PR自从提交以来已经过了2个月，即使它有活动，也会被标记为维护者审查。

如果一个提交的PR已经通过了所有验证，但在72小时（3天）内没有被审查，将每天在#fabric-pr-review频道中被标记，直到收到审查意见。

此政策适用于所有官方的Fabric项目（fabric、fabric-ca、fabric-samples、fabric-test、fabric-sdk-node、fabric-sdk-java、
fabric-sdk-go、fabric-gateway-java、fabric-chaincode-node、fabric-chaincode-java、fabric-chaincode-evm、fabric-baseimage 和 fabric-amcl）。


设置开发环境
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

接下来，在你本地开发环境中尝试 :doc:`构建项目 <dev-setup/build>` ，以确保所有配置都是正确的。

什么是好的 PR?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- 一次只做一个改变。不是五个，不是三个，也不是十个。只有一个. 为什么？因为这限制了改变的影响范围。
如果我们有一个回归，很容易确定是哪个提交导致的，而如果我们有一些影响代码更多的复合改变，就难以确定。

- 如果有相应的GitHub问题，请在PR摘要和提交消息中包含链接到GitHub问题。
为什么？因为通常会围绕拟议的改变或错误有额外的讨论。此外，如果在PR摘要和提交消息中使用类似“解决＃<GitHub问题编号>”的语法，
当PR合并时，GitHub问题将自动关闭。

- 在每次更改中包含单元测试和集成测试（或对现有测试的更改）。这不仅意味着测试正常路径，还意味着对任何防御性代码进行负面测试，
以确保它正确捕捉输入错误。当你编写代码时，你负责测试它并提供测试来证明更改符合其要求。
为什么？因为没有这些，我们不知道我们的当前代码库是否真正有效。

- 单元测试不应该有外部依赖性。 你应该能够使用go test或类似语言的等效方式直接运行单元测试。任何需要某些外部依赖的测试
（例如需要脚本运行另一个组件）需要适当的模拟。其他测试都不是单元测试，根据定义而言，它是集成测试。
为什么？因为许多开源开发者都在进行测试驱动开发。他们在调用测试的目录上放置一个监视器，当代码发生更改时，测试会自动启动。
这比在代码更改之间运行整个构建要高效得多。有关编写有效单元测试的一组好标准，请参见 `此定义 <http://artofunittesting.com/definition-of-a-unit-test/>`_。

- 最小化每个PR的代码行数。
为什么？维护者也有白天的工作。如果你发送1000或2000行代码更改，估计需要多长时间来审查所有代码？
尽可能将你的更改保持在<200-300行代码范围内。如果你有较大的更改，可以将其分解为多个独立的更改。
如果你要添加一堆新函数以满足新功能的要求，请单独添加它们及其测试，然后再编写使用它们提供新功能的代码。
当然，也有例外情况。如果你添加了一个小的更改，然后添加了300行测试代码，你将会被原谅；-)
如果你需要进行广泛影响或大量生成代码的更改（如protobuf等）。同样，可能会有例外情况。

.. 注意:: 大型的pull request，例如超过300行代码的，很可能不会得到批准，你将被要求将更改调整以符合此指南。

编写有意义的提交消息。包括一个有意义的55个字符（或更少）的标题，后面是一个空行，然后是更全面的更改描述。
.. 注意:: 示例提交消息：- 

          ::

              [FAB-1234] fix foobar() panic

              Fix [FAB-1234] added a check to ensure that when foobar(foo string)
              is called, that there is a non-empty string argument.

最后，要有回应。不要让一个pull request被挂起，以至于需要rebase。这只会进一步延迟合并，并给你增加更多的工作-以解决合并冲突。

法律事项
-----------

**注意:** 每一个源文件必须包括 Apache Software License 2.0。查看 `许可证头模板 <https://github.com/hyperledger/fabric/blob/main/docs/source/dev-setup/headers.txt>`_。

我们尽可能努力让贡献变得简单。这个协议为我们提供了贡献相关的法律相关的知识。我们使用和 Linux® Kernel `社区 <https://elinux.org/Developer_Certificate_Of_Origin>`_ 
一样的管理贡献的方法 `Developer's Certificate of Origin 1.1 (DCO) <https://github.com/hyperledger/fabric/blob/master/docs/source/DCO1.1.txt>`_ 来管理 Hyperledger Fabric。

我们只要求在提交要审查的补丁时，开发者在 commit 消息中带上他们的离线签名即可。

这里是一个离线签名的签名例子，表示提交者接受 DCO 约定：

::

    Signed-off-by: John Doe <john.doe@example.com>

在提交更改到本地 git 仓库时，你可以使用 git commit -s 自动包含这个签名行。

相关主题
-------------------

.. toctree::
   :maxdepth: 1

   jira_navigation
   dev-setup/devenv
   dev-setup/build
   style-guides/go-style

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
