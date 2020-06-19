推荐的 Gerrit 练习
============================


本文提供了一些最佳实践来帮助您更有效地使用 Gerrit。其目的是展示如何轻松提交内容。使用推荐的实践来减少故障排除时间，提高社区的参与度。

浏览 Git 树
---------------------

访问 `Gerrit <https://gerrit.hyperledger.org/r/#/admin/projects/fabric>`__ 然后选择 ``Projects --> List --> SELECT-PROJECT --> Branches`` 。选择一个你感兴趣的分支，点击右手边的 ``gitweb`` 。现在，``gitweb`` 会加载你选择的内容，并进行重定向。

关注一个项目
------------------

访问 `Gerrit <https://gerrit.hyperledger.org/r/#/admin/projects/fabric>`__ ，然后选择右上角的  ``Settings`` 。选择 ``Watched Projects`` 然后添加任何你感兴趣的项目。

提交信息
---------------

Gerrit 遵循 Git 提交消息格式。确保标题位于底部，并且彼此之间不包含空行。下面的示例显示了提交消息中期望的格式和内容：

简短的（不超过55个字符）一行描述。

详细总结所做的更改，包括为什么（动机）、更改了什么以及如何进行测试。还请注意任何更改都要保持代码和文档的一致性，文本的格式应是72字符/行。

| Jira: FAB-100
| Change-Id: LONGHEXHASH
| Signed-off-by: Your Name your.email\@example.org
| AnotherExampleHeader: An Example of another Value

Gerrit 服务器提供了一个预提交钩子（hook）来自动生成一个一次性的 Change-Id。

**推荐阅读：** `如何编写 Git 提交信息 <https://chris.beams.io/posts/git-commit/>`__

不要向 Gerrit 推送未测试过的内容
----------------------------------------------

不要向 Gerrit 推送未测试过的内容。

在将更改提交给 Gerrit 之前，至少要检查三次。请慎重发布你的信息。

持续跟踪变更
------------------------

-  设置 Gerrit 自动发送邮件给你：

-  如果开发人员将您添加为审核者，或者您对特定的补丁集进行了评论，Gerrit 会将您添加到变更的电子邮件分发列表中。

-  在 Gerrit 的审核接口中打开更改是一种快速跟踪更改的方法。

-  在 ``Gerrit`` 中的 Gerrit projects 部分查看其中的项目，至少选择 *New Changes, New Patch Sets, All Comments* 和 *Submitted Changes* 这几种类型。

一直跟踪你正在做的项目；也可以查看反馈或者评论邮件列表来学习或者帮助其他人提升。

主题分支
--------------

主题分支是临时分支，您可以向它推送一组有依赖关系的提交：

从 ``REMOTE/master`` 树推送变更到 Gerrit ，并作为一个名为 **TopicName** 的主题来审核，其命令如下：

::
   $ git push REMOTE HEAD:refs/for/master/TopicName

这个主题将出现在审核 ``UI``和 ``Open Changes List``中。当主树的内容合并时，主题分支将从主树中消失。

为主题写简介
-----------------------------------

你可以决定是否让简介出现在历史记录里。

1. 要让历史记录里出现简介，可以使用以下命令：

::

    git commit --allow-empty

编辑提交消息，该消息将成为简介。使用的命令不会更改源码树中的任何文件。

2. 要使历史记录里不出现简介，可以遵循以下步骤：

-  | 将空提交放在提交列表的末尾，它会被忽视
   | 不必重新 rebase。

-  现在添加你的提交

::

    git commit ...
    git commit ...
    git commit ...

-  最后，将提交推到主题分支。下面的命令是一个例子：

::

    git push REMOTE HEAD:refs/for/master/TopicName

如果您已经提交了，但是您想要设置一个简介，那么为简介创建一个空的提交，并移动提交，使其成为列表中的最后一个提交。以下边命令为例：

::

    git rebase -i HEAD~#Commits

在移动提交之前，请注意取消注释。``#Commits`` 是提交和新简介的总和。

找到可用的主题
------------------------

::

       $ ssh -p 29418 gerrit.hyperledger.org gerrit query \ status:open project:fabric branch:master \
       | grep topic: | sort -u

-  `gerrit.hyperledger.org <https://gerrit.hyperledger.org>`__ 是项目所在的当前 URL。
-  *status* 指示主题的当前状态： open、merged、abandoned、draft、merge conflict。
-  *project* 指项目的当前名称，本例中是 fabric。
-  *branch* 在本分支中搜索主题。
-  *topic* 特定主题的名称，留空可以包含它们全部。
-  *sort* 将找到的主题排序，本例中是使用update (-u)。

下载或者检出一个变更
------------------------------------

在审核界面右上角， **Download** 链接提供了一个命令列表和检出或下载差异或文件的超链接。

我们建议使用 *git review* 插件。 安装 git review 的步骤超出了本文档的范围。 参考 `git review 文档 <https://wiki.openstack.org/wiki/Documentation/HowTo/FirstTimers>`__
进行安装。

使用 Git 检出特定的更改，通常可以使用以下命令：

::

    git review -d CHANGEID

如果你没有安装 Git-review，可参考以下命令：

::

    git fetch REMOTE refs/changes/NN/CHANGEIDNN/VERSION \ && git checkout FETCH_HEAD

例如，第4版本的变更2464，NN 是指变更 ID 的前两位数字（24）：

::

    git fetch REMOTE refs/changes/24/2464/4 \ && git checkout FETCH_HEAD

使用草稿分支
--------------------

您可以使用草稿分支在发布变更之前添加特定的审核人员。草稿分支会被推送到 ``refs/drafts/master/TopicName``。

下面的命令确保创建一个本地分支：

::

    git checkout -b BRANCHNAME

下面的命令可以将你的变更推送到 **TopicName** 名下的草稿分支：

::

    git push REMOTE HEAD:refs/drafts/master/TopicName

使用沙箱分支
----------------------

你可以创建自己的分支来开发功能。这些分支可以推动到这个位置 ``refs/sandbox/USERNAME/BRANCHNAME`` 。

这些命令可以在 Gerrit 的服务器里面创建这个分支。

::

    git checkout -b sandbox/USERNAME/BRANCHNAME
    git push --set-upstream REMOTE HEAD:refs/heads/sandbox/USERNAME/BRANCHNAME

通常，创建内容的流程是：

-  开发代码，
-  将信息分散在各个小的提交里，
-  提交变更，
-  应用反馈，
-  rebase。

下面这条命令强行推送，无需审核：

::

    git push REMOTE sandbox/USERNAME/BRANCHNAME

你也可以强行推送要求审核：

::

    git push REMOTE HEAD:ref/for/sandbox/USERNAME/BRANCHNAME

更新变更的版本
--------------------------------

在审核过程中，可能会要求您更新变更。可以提交同一变更的多个版本。每个版本的变更都称为一个补丁集。

请保持使用分配的 **Change-Id**。例如，有一个提交列表，**c0…c7**，作为主题分支提交：

::

    git log REMOTE/master..master

    c0
    ...
    c7

    git push REMOTE HEAD:refs/for/master/SOMETOPIC

你得到审核者的反馈之后，有 **c3** 和 **c4**必须修复。如果修复时需要 rebasing，rebasing 会改变commit ID，查看 `rebasing <https://git-scm.com/book/en/v2/Git-Branching-"
"Rebasing>`__ 获取更多信息。但是，你必须保证 Change-Id 相同并且重新推送变更：

::

    git push REMOTE HEAD:refs/for/master/SOMETOPIC

这个新推送会为补丁重新创建一个版本，然后清除本地历史记录。不过，您仍然可以在 Gerrit 的 ``review UI`` 模块查看变更的历史记录。

允许在推送新版本时添加多个提交。

Rebasing
--------

Rebasing 通常是将更改推入 Gerrit 之前的最后一步；这允许你添加必需的 *Change-Id*。必须保持*Change-Id* 不变。

-  **squash:** 将两个或多个提交混合到一个提交中。
-  **reword:** 改变提交信息。
-  **edit:** 改变提交的内容。
-  **reorder:** 允许您改变内部各个提交的顺序。
-  **rebase:** 在主分支顶部入栈各个提交。

拉取时 Rebasing
----------------------

在将 rebase 推给主分支之前，请确保历史记录具有连续的顺序。

如，你的 ``REMOTE/master`` 有从 **a0** 到 **a4** 的提交列表；然后，你的变更 **c0...c7** 在**a4** 上面，像这样：

::

    git log --oneline REMOTE/master..master

    a0
    a1
    a2
    a3
    a4
    c0
    c1
    ...
    c7

如果 ``REMOTE/master`` 接受了 **a5**、**a6**、**a7** 三个新的提交。拉取时要加上 rebase，像这样：

::

    git pull --rebase REMOTE master

这样就拉取了 **a5-a7** 并且重新把 **c0-c7** 应用到它们顶部：

::

       $ git log --oneline REMOTE/master..master
       a0
       ...
       a7
       c0
       c1
       ...
       c7

从 Git 获取更好的日志
----------------------------

使用这些命令来更改 Git 的配置，以便生成更好的日志：

::

    git config log.abbrevCommit true

上面的命令将日志设置为提交的哈希的缩写。

::

    git config log.abbrev 5

上面的命令将缩写长度设置为哈希的最后5个字符。
::

    git config format.pretty oneline

上面的命令避免在 Author 行之前插入不必要的行。

要针对当前 Git 用户进行这些配置更改，必须将 path 选项 ``--global`` 添加到 ``config`` 中，像这样：

::

   git config --global

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/

