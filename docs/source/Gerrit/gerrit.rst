Working with Gerrit-使用Gerrit进行工作
-------------------

Follow these instructions to collaborate on Hyperledger Fabric
through the Gerrit review system.

按照这些说明通过Gerrit审查系统在Hyperledger Fabric上进行协作。

Please be sure that you are subscribed to the `mailing
list <https://lists.hyperledger.org/mailman/listinfo/hyperledger-fabric>`__
and of course, you can reach out on
`chat <https://chat.hyperledger.org/>`__ if you need help.

请确保你已经订阅了 `邮件列表 <https://lists.hyperledger.org/mailman/listinfo/hyperledger-fabric>`__ 。
当然如果你需要帮助的话也可以在 `chat <https://chat.hyperledger.org/>`__ 寻求帮助。

Gerrit assigns the following roles to users:

Gerrit为用户分配了以下角色：

-  **Submitters**: May submit changes for consideration, review other
   code changes, and make recommendations for acceptance or rejection by
   voting +1 or -1, respectively.

-  **Submitters**: 可以提交变更以供考虑，审查别人的代码变更，分别通过投票 +1 或者 -1 接受或者拒绝的建议。

-  **Maintainers**: May approve or reject changes based upon feedback
   from reviewers voting +2 or -2, respectively.

-  **Maintainers**: 基于审查者的反馈进行 +2 或者 -2 的投票，以此来批准或者拒绝变更。

-  **Builders**: (e.g. Jenkins) May use the build automation
   infrastructure to verify the change.

-  **Builders**: (例如 Jenkins)可以使用自动化基础架构来验证变更。

Maintainers should be familiar with the :doc:`review
process <reviewing>`. However, anyone is welcome to (and
encouraged!) review changes, and hence may find that document of value.

维护者应当熟悉  :doc:`审核流程 <reviewing>` 。
但是，任何人都是非常欢迎来审核变更的，因此这个文档才有存在的价值。

Git-review
~~~~~~~~~~

There's a **very** useful tool for working with Gerrit called
`git-review <https://www.mediawiki.org/wiki/Gerrit/git-review>`__. This
command-line tool can automate most of the ensuing sections for you. Of
course, reading the information below is also highly recommended so that
you understand what's going on behind the scenes.

有一个非常有用的和Gerrit合作的工具叫做
`git-review <https://www.mediawiki.org/wiki/Gerrit/git-review>`__ 。
这个命令行工具可以帮你执行大部分后续工作。
当然，强烈推荐阅读以下内容，以便了解幕后发生的事情。

Getting deeper into Gerrit-深入了解 Gerrit
~~~~~~~~~~~~~~~~~~~~~~~~~~

A comprehensive walk-through of Gerrit is beyond the scope of this
document. There are plenty of resources available on the Internet. A
good summary can be found
`here <https://www.mediawiki.org/wiki/Gerrit/Tutorial>`__. We have also
provided a set of :doc:`Best Practices <best-practices>` that you may
find helpful.

Gerrit的全面演练超出了本文档的范围。互联网上有大量的资源可供使用。
可以在 `这里 <https://www.mediawiki.org/wiki/Gerrit/Tutorial>`__ 找到一个好的总结。
我们还为你提供了一份有用的  :doc:`最佳实践 <best-practices>` 。

Working with a local clone of the repository-配合本地仓库使用
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To work on something, whether a new feature or a bugfix:

无论处理新特性还是错误：

1. Open the Gerrit `Projects
   page <https://gerrit.hyperledger.org/r/#/admin/projects/>`__

1. 打开Gerrit的 `项目页面 <https://gerrit.hyperledger.org/r/#/admin/projects/>`__ 。

2. Select the project you wish to work on.

2. 选择一个你希望工作的项目。

3. Open a terminal window and clone the project locally using the
   ``Clone with git hook`` URL. Be sure that ``ssh`` is also selected,
   as this will make authentication much simpler:

3. 打开一个终端窗口，然后使用 ``Clone with git hook`` URL克隆项目。
确定使用  ``ssh`` ，这将会简化授权：

.. code::

   git clone ssh://LFID@gerrit.hyperledger.org:29418/fabric && scp -p -P 29418 LFID@gerrit.hyperledger.org:hooks/commit-msg fabric/.git/hooks/

.. note:: If you are cloning the fabric project repository, you will
          want to clone it to the ``$GOPATH/src/github.com/hyperledger``
          directory so that it will build, and so that you can use it
          with the Vagrant :doc:`development environment <../dev-setup/devenv>`.

.. note:: 如果要克隆项目仓库，你需要将它克隆到 ``$GOPATH/src/github.com/hyperledger`` 目录下，
          这样它才能构建，这样你才能使用Vagrant :doc:`开发环境 <../dev-setup/devenv>` 。

4. Create a descriptively-named branch off of your cloned repository

4. 在你克隆的仓库创建描述性的分支。

::

    cd fabric
    git checkout -b issue-nnnn

5. Commit your code. For an in-depth discussion of creating an effective
   commit, please read :doc:`this document on submitting changes <changes>`.

5. 提交你的代码。创建有关深入探讨的提交，请阅读  :doc:`如何提交更改的文档 <changes>` 。

::

    git commit -s -a

Then input precise and readable commit msg and submit.

请输入精确的可读的消息进行提交。

6. Any code changes that affect documentation should be accompanied by
   corresponding changes (or additions) to the documentation and tests.
   This will ensure that if the merged PR is reversed, all traces of the
   change will be reversed as well.

6. 任何影响文档的代码变更都应该伴随对文档和测试的相应更改（或者添加）。
   这保证了如果变更被合并了，那同样所有的有关的文档和测试都会更新。

Submitting a Change-提交变更
~~~~~~~~~~~~~~~~~~~

Currently, Gerrit is the only method to submit a change for review.

目前，Gerrit是提交用以审核的变更的唯一方法。

.. note:: Please review the :doc:`guidelines <changes>` for making and
          submitting a change.

.. note:: 请查看创建和提交变更的 :doc:`指南 <changes>` 。

Using git review-使用 git review
~~~~~~~~~~~~~~~~

.. note:: if you prefer, you can use the `git-review <#git-review>`__
          tool instead of the following. e.g.

.. note:: 如果你希望，你可以使用  `git-review <#git-review>`__ 
          工具替代以下内容。例如

Add the following section to ``.git/config``, and replace ``<USERNAME>``
with your gerrit id.

添加以下部分 ``.git/config`` ，并用你的gerrit id替换 ``<USERNAME>`` 。

::

    [remote "gerrit"]
        url = ssh://<USERNAME>@gerrit.hyperledger.org:29418/fabric.git
        fetch = +refs/heads/*:refs/remotes/gerrit/*

Then submit your change with ``git review``.

然后用 ``git review`` 提交你的更改。

::

    $ cd <your code dir>
    $ git review

When you update your patch, you can commit with ``git commit --amend``,
and then repeat the ``git review`` command.

当你更新补丁的时候，你可以使用 ``git commit --amend`` 来提交，然后重复 ``git review`` 命令。

Not using git review-不使用git review
~~~~~~~~~~~~~~~~~~~~

See the :doc:`directions for building the source code <../dev-setup/build>`.

请参考 :doc:`构建源代码指南 <../dev-setup/build>`

When a change is ready for submission, Gerrit requires that the change
be pushed to a special branch. The name of this special branch contains
a reference to the final branch where the code should reside, once
accepted.

当准备好提交变更的时候，Gerrit要求将变更推送到特殊的分支上。
这个特殊的分支需要包含当代码被接受之后被合并的对最终代码分支的引用。

For the Hyperledger Fabric repository, the special branch is called
``refs/for/master``.

对于Hyperledger Fabric的仓库来说，特殊的分支叫做``refs/for/master`` 。

To push the current local development branch to the gerrit server, open
a terminal window at the root of your cloned repository:

打开本地仓库的根目录的终端窗口，推送本地开发分支的代码到服务器上：

::

    cd <your clone dir>
    git push origin HEAD:refs/for/master

If the command executes correctly, the output should look similar to
this:

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

The gerrit server generates a link where the change can be tracked.

Gerrit服务器生成了一个可以被追踪的链接。

Reviewing Using Gerrit-使用Gerrit进行审核
----------------------

-  **Add**: This button allows the change submitter to manually add
   names of people who should review a change; start typing a name and
   the system will auto-complete based on the list of people registered
   and with access to the system. They will be notified by email that
   you are requesting their input.

-  **Add**: 这个按钮可以让提交者添加进行审查的人员的名字；
   开始输入一个名字，系统会基于注册的用户和系统的权限进行自动补全。
   如果你请求他们来审查代码，他们会收到邮件。

-  **Abandon**: This button is available to the submitter only; it
   allows a committer to abandon a change and remove it from the merge
   queue.

-  **Abandon**: 这个按钮仅提供给提交者使用；它允许提交者放弃更改并将其从合并队列中删除。

-  **Change-ID**: This ID is generated by Gerrit (or system). It becomes
   useful when the review process determines that your commit(s) have to
   be amended. You may submit a new version; and if the same Change-ID
   header (and value) are present, Gerrit will remember it and present
   it as another version of the same change.

-  **Change-ID**: 这个ID由Gerrit（或者系统）生成。
   当审核过程中确定你的提交必须被修改时，将会变得有用。
   你需要提交一个新的版本；如果 Change-ID是同样的，Gerrit会记住，并且呈现同一个变更的另一个版本。

-  **Status**: Currently, the example change is in review status, as
   indicated by “Needs Verified” in the upper-left corner. The list of
   Reviewers will all emit their opinion, voting +1 if they agree to the
   merge, -1 if they disagree. Gerrit users with a Maintainer role can
   agree to the merge or refuse it by voting +2 or -2 respectively.

-  **Status**: 目前，示例已经进入审查状态，在左上角显示 “Needs Verified” 。
   审查者将会发表他们的意见，如果同意则+1，不同意则-1。
   具有维护者角色的Gerrit用户可以通过投票+2或者-2来表示同意或者拒绝合并。

Notifications are sent to the email address in your commit message's
Signed-off-by line. Visit your `Gerrit
dashboard <https://gerrit.hyperledger.org/r/#/dashboard/self>`__, to
check the progress of your requests.

通知将发送到您的提交消息的Signed-by-by行中的电子邮件地址。访问您的
 `Gerrit 仪表盘 <https://gerrit.hyperledger.org/r/#/dashboard/self>`__ ，检查您的请求进度。

The history tab in Gerrit will show you the in-line comments and the
author of the review.

Gerrit中的历史记录将显示内嵌注释和审阅者信息。

Viewing Pending Changes-查看待定的更改
-----------------------

Find all pending changes by clicking on the ``All --> Changes`` link in
the upper-left corner, or `open this
link <https://gerrit.hyperledger.org/r/#/q/project:fabric>`__.

点击左上角 ``All --> Changes`` 查看所有待定的变更，或者
`打开这个链接 <https://gerrit.hyperledger.org/r/#/q/project:fabric>`__ 。

If you collaborate in multiple projects, you may wish to limit searching
to the specific branch through the search bar in the upper-right side.

如果你在多个项目中协作，你可能希望通过右上方的搜索栏限制搜索特定分支。

Add the filter *project:fabric* to limit the visible changes to only
those from Hyperledger Fabric.

添加 *project:fabric* 过滤器来限制仅显示Hyperledger Fabric的更改。

List all current changes you submitted, or list just those changes in
need of your input by clicking on ``My --> Changes`` or `open this
link <https://gerrit.hyperledger.org/r/#/dashboard/self>`__

通过选择 ``My --> Changes`` 或者 `打开这个链接 <https://gerrit.hyperledger.org/r/#/dashboard/self>`__ 
列出你提交的所有变更。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
