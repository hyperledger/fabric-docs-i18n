Gerrit 的使用
-------------------

按照这些说明通过 Gerrit 审查系统在 Hyperledger Fabric 上进行协作。

请确保你已经订阅了 `邮件列表 <https://lists.hyperledger.org/mailman/listinfo/hyperledger-fabric>`__ 。当然如果你需要帮助的话也可以在 `chat <https://chat.hyperledger.org/>`__ 寻求帮助。

Gerrit 为用户分配了以下角色：

-  **提交者（Submitters）**: 可以提交变更，审查别人的代码变更，分别通过投票 +1 或者 -1 接受或者拒绝的建议。
-  **维护者（Maintainers）**: 基于审查者的反馈进行 +2 或者 -2 的投票，以此来批准或者拒绝变更。
-  **构建者（Builders）**: （例如 Jenkins）可以使用自动化基础架构来验证变更。

维护者应当熟悉 :doc:`审核流程 <reviewing>` 。但是，非常欢迎任何人来审核变更，这样才会发现文档的价值。

Git-review
~~~~~~~~~~

有一个非常有用的和 Gerrit 合作的工具叫做 `git-review <https://www.mediawiki.org/wiki/Gerrit/git-review>`__ 。这个命令行工具可以帮你执行大部分后续工作。当然，强烈推荐阅读以下内容，以便了解幕后发生的事情。

深入了解 Gerrit
~~~~~~~~~~~~~~~~~~~~~~~~~~

Gerrit 的全面学习超出了本文档的范围。互联网上有大量的资源可供使用。可以在 `这里 <https://www.mediawiki.org/wiki/Gerrit/Tutorial>`__ 找到一个好的总结。我们还为你提供了一份有用的 :doc:`最佳实践 <best-practices>` 。

配合本地仓库使用
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

无论处理新特性还是错误：

1. 打开 Gerrit 的 `项目页面 <https://gerrit.hyperledger.org/r/#/admin/projects/>`__ 。
2. 选择一个你希望工作的项目。
3. 打开一个终端窗口，然后使用 ``Clone with git hook`` URL 克隆项目。确定使用 ``ssh``，这将会简化授权：

.. code::

   git clone ssh://LFID@gerrit.hyperledger.org:29418/fabric && scp -p -P 29418 LFID@gerrit.hyperledger.org:hooks/commit-msg fabric/.git/hooks/

.. note:: 如果要克隆项目仓库，你需要将它克隆到 ``$GOPATH/src/github.com/hyperledger`` 目录下，这样它才能构建，并使用 Vagrant :doc:`开发环境 <../dev-setup/devenv>` 。

4. 在你克隆的仓库创建一个分支，分支的名字最好能描述该分支的功能。

::

    cd fabric
    git checkout -b issue-nnnn

5. 提交你的代码。要创建可以深入探讨的提交，请阅读 :doc:`如何提交更改的文档 <changes>` 。

::

    git commit -s -a

请输入准确的可读的消息然后提交。

6. 任何影响文档的代码变更都应该有对文档和测试的相应更改（或者添加）。这保证了如果变更被合并了，那同样所有的有关的文档和测试都会更新。

提交变更
~~~~~~~~~~~~~~~~~~~

目前，Gerrit 是提交用以审核的变更的唯一方法。

.. note:: 请查看创建和提交变更的 :doc:`指南 <changes>` 。

使用 git review
~~~~~~~~~~~~~~~~

.. note:: 如果你希望，你可以使用  `git-review <#git-review>`__ 
          工具替代以下内容。例如

添加以下部分 ``.git/config`` ，并用你的gerrit id替换 ``<USERNAME>`` 。

::

    [remote "gerrit"]
        url = ssh://<USERNAME>@gerrit.hyperledger.org:29418/fabric.git
        fetch = +refs/heads/*:refs/remotes/gerrit/*

然后用 ``git review`` 提交你的更改。

::

    $ cd <your code dir>
    $ git review

当你更新补丁的时候，你可以使用 ``git commit --amend`` 来提交，然后重复 ``git review`` 命令。

不使用git review
~~~~~~~~~~~~~~~~~~~~

请参考 :doc:`构建源代码指南 <../dev-setup/build>`

当准备好提交变更的时候，Gerrit要求将变更推送到特殊的分支上。
这个特殊的分支需要包含当代码被接受之后被合并的对最终代码分支的引用。

对于Hyperledger Fabric的仓库来说，特殊的分支叫做``refs/for/master`` 。

打开本地仓库的根目录的终端窗口，推送本地开发分支的代码到服务器上：

::

    cd <your clone dir>
    git push origin HEAD:refs/for/master

如果命令正确执行了，输出将和下述类似：

::

    Counting objects: 3, done.
    Writing objects: 100% (3/3), 306 bytes | 0 bytes/s, done.
    Total 3 (delta 0), reused 0 (delta 0)
    remote: Processing changes: new: 1, refs: 1, done
    remote:
    remote: New Changes:
    remote:   https://gerrit.hyperledger.org/r/6 Test commit
    remote:
    To ssh://LFID@gerrit.hyperledger.org:29418/fabric
    * [new branch]      HEAD -> refs/for/master

Gerrit服务器生成了一个可以被追踪的链接。

使用Gerrit进行审核
----------------------

-  **Add**: 这个按钮可以让提交者添加进行审查的人员的名字；
   开始输入一个名字，系统会基于注册的用户和系统的权限进行自动补全。
   如果你请求他们来审查代码，他们会收到邮件。

-  **Abandon**: 这个按钮仅提供给提交者使用；它允许提交者放弃更改并将其从合并队列中删除。

-  **Change-ID**: 这个ID由Gerrit（或者系统）生成。
   当审核过程中确定你的提交必须被修改时，将会变得有用。
   你需要提交一个新的版本；如果 Change-ID是同样的，Gerrit会记住，并且呈现同一个变更的另一个版本。

-  **Status**: 目前，示例已经进入审查状态，在左上角显示 “Needs Verified” 。
   审查者将会发表他们的意见，如果同意则+1，不同意则-1。
   具有维护者角色的Gerrit用户可以通过投票+2或者-2来表示同意或者拒绝合并。

通知将发送到您的提交消息的Signed-by-by行中的电子邮件地址。访问您的
 `Gerrit 仪表盘 <https://gerrit.hyperledger.org/r/#/dashboard/self>`__ ，检查您的请求进度。

Gerrit中的历史记录将显示内嵌注释和审阅者信息。

查看待定的更改
-----------------------

点击左上角 ``All --> Changes`` 查看所有待定的变更，或者
`打开这个链接 <https://gerrit.hyperledger.org/r/#/q/project:fabric>`__ 。

如果你在多个项目中协作，你可能希望通过右上方的搜索栏限制搜索特定分支。

添加 *project:fabric* 过滤器来限制仅显示Hyperledger Fabric的更改。

通过选择 ``My --> Changes`` 或者 `打开这个链接 <https://gerrit.hyperledger.org/r/#/dashboard/self>`__ 
列出你提交的所有变更。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
