向 Gerrit 上提交变更
=============================

在向 Hyperledger Fabric 代码库提交更改之前，请仔细检查以下内容。这些指导原则适用于刚接触开源的开发人员，也适用于经验丰富的开源开发人员。

变更需求
-------------------

本节包含提交要审核的代码变更的指南。有关如何使用 Gerrit 提交更改的更多信息，请参见这里 :doc:`Gerrit 的使用 <gerrit>`。

所有对 Hyperledger Fabric 的更改都是在 Git 通过 Gerrit 提交时提交的。每次提交必须包含：

-  一个简短的描述性的主题行，长度不超过55个字符，后面跟一行空行，
-  一个变更描述，包括您的变更的逻辑或推理，后面跟一行空行，
-  Signed-off-by 签名行，后跟冒号（Signed-off-by:），和
-  Change-Id 标识符行，后跟冒号(Change-Id:)。如果没有这个标识符，Gerrit将不会接受补丁。

一个好的提交应具有上述细节。

.. note:: 您不需要为新提交提供 Change-Id 标识符；这是由与仓库关联的 Git hook 的 ``commit-msg`` 自动添加的。如果随后修改了提交内容并使用与之前相同的 Change-Id 重新提交， Gerrit 将会识别出该提交和之前的提交有关。

发送给 Gerrit 的所有更改和主题都要必须有一个规范的格式。除了上述提交的强制性内容外，提交信息还应包括：

-  **what** 这个变更做了什么，
-  **why** 你为什么选择这种方法，和
-  **how** 你如何知道它有作用，例如，你做了什么测试。

提交必须在相互应用时能够 :doc:`正确地编译 <../dev-setup/build>`，从而避免破坏耦合性。每个提交都应该处理一个可识别的 JIRA 问题，并且应该在逻辑上是自包含的。例如，一个提交可能修复空格问题，另一个提交可能重命名一个函数，而第三个提交可能更改一些代码的功能。

一份好的提交详细说明如下：

::

    [FAB-XXXX] purpose of commit, no more than 55 characters

    You can add more details here in several paragraphs, but please keep
    each line less than 80 characters long.

    Change-Id: IF7b6ac513b2eca5f2bab9728ebd8b7e504d3cebe1
    Signed-off-by: Your Name <commit-sender@email.address>

在 ``Signed-off-by:`` 行的名字和你的邮箱必须与变更的作者信息相符。确保你个人的 ``.gitconfig`` 文件设置正确。

当一个支持其他变更的变更包含在集合中，但它不属于最终集合的一部分时，请让审核人员知道这一点。

用 CI 流程检验您的变更请求是可行的
-------------------------------------------------------------

为了确保代码的稳定性并限制可能的回归，我们使用了基于 Jenkins 的持续集成（CI）过程，该过程在多个平台上都能触发构建，它针对提交的每个更改请求运行测试。您有责任检查您的 CR 是否通过这些测试。如果 CR 没有通过测试，那么它就不会被合并，在他们通过 CI 测试之前，任何人都不会关注您的CR。


要检查 CI 流程的状态，只需查看 Gerrit 上的 CR，并按照上一步中推送的结果提供给您的 URL 执行即可。页面底部的 History 部分将显示一组由 “Hyperledger Jobbuilder” 执行的操作，这些操作对应于正在执行的 CI 进程。

完成后，如果成功，"Hyperledger Jobbuilder" 将添加到 CR 一个 *+1 投票*，否则将添加 *-1 投票*。

如果失败了，请查看从 CR 历史记录中的日志。如果您发现 CR 有问题，请修改提交并推送更新，这将再次自动启动 CI 进程。

如果您的 CR 没有任何问题，那么 CI 过程可能只是由于没有与您的更改关联起来而失败。在这种情况下，您可以向 CR 发送带有 “reverify” 的回复来重新启动 CI 进程。更多信息和选择请查看  `CI 管理页面 <https://github.com/hyperledger/ci-management/blob/master/docs/source/fabric_ci_process.rst>`__ 。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
