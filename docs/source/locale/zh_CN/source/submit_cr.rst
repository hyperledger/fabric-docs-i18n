提交你的第一个变更请求（CR）
-----------------------------------------

我们使用 `Gerrit <https://gerrit.hyperledger.org/r/#/admin/projects/fabric>`__ 进行代码贡献和审查工作。如果你不熟悉 Gerrit，请先参考 :doc:`文档 <Gerrit/gerrit>` 。

.. note:: Gerrit 的用户体验不是很好。但是，谷歌团队已经在提升这方面了，他们添加了“新的 UI”来提升用户体验。请参考上述链接 Fabric Gerrit 页面下方的按钮。

          .. image:: images/NewGerritUI.png

设置你的 SSH 密钥
~~~~~~~~~~~~~~~~~~~~~~~

在你提交变更之前，你需要注册你的 SSH 密钥。使用你的 :doc:`LFID <Gerrit/lf-account>` 登录 `Gerrit <https://gerrit.hyperledger.org>`__ ，点击浏览器右上角你的名字，然后点击 'Settings'。

.. image:: images/Settings.png
    :width: 300px

在左边框上，你可以看到一个 ‘SSH Public Keys’ 的链接。

.. image:: images/SSHKeys.png
    :width: 200px

请点击 ``Add Key...`` 按钮。

.. image:: images/AddSSH1.png
    :width: 400px

复制-粘贴你的 `public SSH key <https://help.github.com/articles/generating-an-ssh-key/>`__ 到窗口中并点击 ‘Add’。

.. image:: images/AddSSH2.png
    :width: 600px

沙箱
~~~~~~~

我们已经创建了一个 `lf-sandbox 项目 <https://gerrit.hyperledger.org/r/#/admin/projects/lf-sandbox,branches>`__ 来让你熟悉 Gerrit。我们会在教程中使用这个项目提交您的第一个 CR。

克隆你的项目
~~~~~~~~~~~~~~~~~~

第一步是克隆你的项目到你的电脑或者开发服务器上。进入 `Projects <https://gerrit.hyperledger.org/r/#/admin/projects/>`__ 页面，然后找到 ``lf-sandbox`` 项目。

.. image:: images/lf-sandbox.png
    :width: 500px

这个项目页面会为你提供 git clone 的完整命令。选择 ``clone with commit-msg hook`` 选项，然后复制到剪切板。

.. image:: images/GitCloneCmd.png
    :width: 600px

现在，在你电脑的命令行终端中，粘贴并且运行这个命令。例如：

.. code::

   git clone ssh://foobar@gerrit.hyperledger.org:29418/lf-sandbox && scp -p -P 29418 foobar@gerrit.hyperledger.org:hooks/commit-msg lf-sandbox/.git/hooks/

检出开发分支
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

现在，你已经克隆了仓库，进入 ``lf-sandbox`` 目录。现在，我们修改一下。让我们在这个仓库下创建一个新分支来开始工作：

.. code::

   git checkout -b <newbranchname>

现在修改一个文件。任意选择一个文件，并且修改它。也可以新增一个文件或者删除一个现有的文件。不要担心，这只是一个沙箱。

提交你的变更
~~~~~~~~~~~~~~~~~~~~~~

一旦你做了修改，请检查一下当前的状态。

.. code::

   git status
   On branch foo
   Untracked files:
    (use "git add <file>..." to include in what will be committed)

	 README.md

   nothing added to commit but untracked files present (use "git add" to track)

现在让我们将变更的文件添加到 git 追踪的文件中去。

.. code::

   git add .

现在提交变更。

.. code::

   git commit -s

这将开启一个编辑器让你填写提交信息。添加提交信息。

.. note:: 请注意我们将添加一行包括问题 JIRA 号的标题来表明对 Hyperledger Fabric 做了哪些变更。请查看变更请求 :doc:`指南 <Gerrit/changes>` 。

.. code::

   FAB-1234

   I made a change

   Signed-off-by: John Doe <john.doe@example.com>

   # Please enter the commit message for your changes. Lines starting
   # with '#' will be ignored, and an empty message aborts the commit.
   # On branch foo
   # Changes to be committed:
   #       new file:   README.md
   #

提交你的变更请求
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

一旦你提交了这次修改，你就可以发送一个变更请求到 Gerrit 上去。这里，我们有几种选择。

一个是使用完整的 git 语法。

.. code::

   git push origin HEAD:refs/for/master

这将产生如下结果：

.. code::

   Counting objects: 3, done.
   Delta compression using up to 4 threads.
   Compressing objects: 100% (2/2), done.
   Writing objects: 100% (3/3), 340 bytes | 0 bytes/s, done.
   Total 3 (delta 1), reused 0 (delta 0)
   remote: Resolving deltas: 100% (1/1)
   remote: Processing changes: new: 1, refs: 1, done
   remote: Missing issue-id in commit message
   remote: Commit 539d9a1fe036f332db87d37b49cea705bdf6e432 not associated to any issue
   remote:
   remote: Hint: insert one or more issue-id anywhere in the commit message.
   remote:       Issue-ids are strings matching ([A-Z][A-Z0-9]{1,9}-\d+)
   remote:       and are pointing to existing tickets on its-jira Issue-Tracker
   remote:
   remote: New Changes:
   remote:   https://gerrit.hyperledger.org/r/16157 I made a change
   remote:
   To ssh://gerrit.hyperledger.org:29418/lf-sandbox
    * [new branch]      HEAD -> refs/for/master

第二种选择， `git review <https://www.mediawiki.org/wiki/Gerrit/git-review>`__ 大大简化了流程。上述的链接将提供如何安装和设置 ``git-review`` 的方法。

一旦安装和配置好之后，你可以通过 ``git review`` 来提交你的变更。

::

    $ git review


检查你的变更请求是否被 CI 校验通过了
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

为了确保代码的稳定性和限制可能的回归，我们使用 Jenkins 上的持续集成（CI）程序通过触发器的形式在不同的平台上运行被提交的每个变更的测试。确保你的 CR 能够通过测试也是你的责任。CR 不会在没有通过测试的情况下被合并，你也不要期望代码在没有通过测试的时候有人来审核你的 CR。

你可以在 Gerrit 上进行查看你的 CR 的 CI 进度，下面的 URL 是你之前提交的 CR 的结果。在页面的底部会有你提交的历史记录，会显示一系列带有 "Hyperledger Jobbuilder" 的动作来对应 CI 执行的进度。

当完成的时候， "Hyperledger Jobbuilder" 会添加一个 *+1 vote* 如果失败了会添加一个 *-1 vote* 。

如果失败了，请查看 CR 关联的日志。如果你发现 CR 有问题，请继续下面的部分。

如果你发现你的 CR 没有什么问题，或许 CI 程序仅仅因为一些无关的原因失败了。在这种情况下，你可以通过回复你的CR “reverify” 来重新运行 CI 程序。检查 `<https://github.com/hyperledger/ci-management/blob/master/docs/source/fabric_ci_process.rst>`__ 来关注相关信息和选项。

修改你的变更请求
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

如果你更新了你的补丁，在评论里面注明，或者修复了影响 CI 的问题，你可以再提交一个修订过的变更。

.. code::

   git commit --amend

然后重复 ``git review`` 命令，和之前一样。然后检查一下 CI 的结果。

如果你还有问题，可以在邮件列表或者 Rockt Chat 上提问，不要犹豫！