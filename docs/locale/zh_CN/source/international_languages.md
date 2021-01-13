# 国际语言

**本章节面向的读者**: 任何想给非英语的Fabric文档做出贡献的人。

这篇简短的指引将叙述如何为Fabric支持的众多语言做出修改。如果你刚刚开始，本文档将告诉您如何加入一个已存在的翻译小组，或新建一个尚未支持语言的翻译小组。

在这个章节中，我们将介绍：
* [Fabric语言支持简介](#简介)
* [如何加入一个已存在的翻译组](#加入小组)
* [如何建立一个新语言的翻译组](#创建小组)
* [与其它翻译贡献者交流](#联系交流)

## 简介

[Fabric主仓库](https://github.com/hyperledger/fabric)存放在GitHub的Hyperledger组织下。在它的`/docs/source`文件夹下包含英语版本的文档。当编译时，这个文件夹下的文件将在[文档网站](https://hyperledger-fabric.readthedocs.io/en/latest/)显示出来。
（译者注：本段疑为原文错误，上段为暂译，下方贴出原文:
in GitHub under the Hyperledger organization. It contains an English translation
of the documentation in the `/docs/source` folder. When built, the files in this
folder result contribute to the in the [documentation
website](https://hyperledger-fabric.readthedocs.io/en/latest/).）

这个网站也有其它语言的翻译，如[中文](https://hyperledger-fabric.readthedocs.io/zh_CN/latest/)。然而，这些语言存储在[HL
Labs organization](https://github.com/hyperledger-labs)的其它特定语言仓库中。例如，中文文档存储在[这个仓库](https://github.com/hyperledger-labs/fabric-docs-cn)下。

语言仓库有一个精简过的文件结构；它只包含文档相关的文件夹和文件：

```bash
(base) user/git/fabric-docs-ml ls -l
total 48
-rw-r--r--   1 user  staff  11357 14 May 10:47 LICENSE
-rw-r--r--   1 user  staff   3228 14 May 17:01 README.md
drwxr-xr-x  12 user  staff    384 15 May 07:40 docs
```

因为此结构是主Fabric repo的子集，所以您可以使用相同的工具和流程来帮助进行任何语言翻译；您只需使用适当的存储库即可。

## 加入小组

虽然Hyperledger Fabric的默认语言是英语，就我们所知，它也支持其它翻译。[中文文档](https://hyperledger-fabric.readthedocs.io/zh_CN/latest/)的翻译就很好，其它语言诸如巴西葡萄牙语和马拉雅姆语翻译也在进行中。

你可以在Hyperledger wiki找到所有的[当前国际化小组](https://wiki.hyperledger.org/display/fabric/International+groups)。你可以联系这些小组列出中的活跃翻译者。他们会欢迎你加入它们举行的定期会议。

请遵循[这份介绍](./docs_guide.html)来向任何语言仓库贡献文档。这里有一份当前语言仓库的列表：

* [英语](https://github.com/hyperledger/fabric/tree/master/docs)
* [中文](https://github.com/hyperledger-labs/fabric-docs-cn)
* [马拉雅姆语](https://github.com/hyperledger-labs/fabric-docs-ml)
* [巴西葡萄牙语]() -- 即将发布.

## 创建小组

如果您选择了一个还不支持的语言，那为什么不创立一个新的语言翻译？它相对容易开始。工作组能帮助你组织和分享工作来帮助翻译，维护和管理翻译仓库。对于您和其他Fabric用户来说，和其他翻译贡献者和维护者共事都是一个愉快的活动。

按照以下说明创建您自己的语言库。我们的说明将以梵文为例：

1. 找出[ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)中代表您选择语言的两个字母。代表梵文的是`sa`。

1. 克隆Fabric主仓库到您本地机器，在克隆时重命名仓库：
   ```bash
   git clone git@github.com:hyperledger/fabric.git fabric-docs-sa
   ```

1. 选择一个Fabric版本作为您开始翻译的基线。我们建议您从至少Fabric 2.1开始，最好是长支持版本例如 2.2。您可以之后添加其他版本。

   ```bash
   cd fabric-docs-sa
   git fetch origin
   git checkout release-2.1
   ```

1. 从根目录删除除`/doc`以外的其他文件夹。同样的，移除除了`LICENCE` 和 `README.md`以外的其它文件，您剩下的文件应该如下所示：

   ```bash
   ls -l
   total 40
   -rw-r--r--   1 user  staff  11358  5 Jun 14:38 LICENSE
   -rw-r--r--   1 user  staff   4822  5 Jun 15:09 README.md
   drwxr-xr-x  11 user  staff    352  5 Jun 14:38 docs
   ```

1. 用 [这个](https://github.com/hyperledger-labs/fabric-docs-ml/blob/master/README.md)作为例子更新`README.md` 文件。

   用您的新语言定制`README.md`文件。

1. [像这样](https://github.com/hyperledger-labs/fabric-docs-ml/blob/master/.readthedocs.yml)在您的顶级文件夹下添加一个`.readthedocs.yml`文件。这个文件会配置关闭ReadTheDocs PDF编译，因为如果您使用非拉丁字符集可能会编译失败。您的顶级仓库文件夹现在看起来像：

   ```bash
   (base) anthonyodowd/git/fabric-docs-sa ls -al
   total 96
   ...
   -rw-r--r--   1 anthonyodowd  staff    574  5 Jun 15:49 .readthedocs.yml
   -rw-r--r--   1 anthonyodowd  staff  11358  5 Jun 14:38 LICENSE
   -rw-r--r--   1 anthonyodowd  staff   4822  5 Jun 15:09 README.md
   drwxr-xr-x  11 anthonyodowd  staff    352  5 Jun 14:38 docs
   ```

1. 在您本地仓库提交更改:

   ```bash
   git add .
   git commit -s -m "Initial commit"
   ```

1. 在您的GitHub账户下创建一个 `fabric-docs-sa`仓库。在描述中写入`Hyperledger Fabric documentation in Sanskrit
   language`。

1. 更新您本地git `origin`指向这个仓库，把`YOURGITHUBID` 改为你的GitHub ID:

   ```bash
   git remote set-url origin git@github.com:YOURGITHUBID/fabric-docs-sa.git
   ```

   在当前步骤，还不能设置`upstream`因为`fabric-docs-sa`仓库还没有被HL Labs
   organization创建；我们晚点再来做。

   现在，确认`origin`已经配置了：

   ```bash
   git remote -v
   origin	git@github.com:ODOWDAIBM/fabric-docs-sa.git (fetch)
   origin	git@github.com:ODOWDAIBM/fabric-docs-sa.git (push)
   ```

1. 向这个仓库中推送您的 `release-2.1`分支作为`master` 分支：

   ```bash
   git push origin release-2.1:master

   Enumerating objects: 6, done.
   Counting objects: 100% (6/6), done.
   Delta compression using up to 8 threads
   Compressing objects: 100% (4/4), done.
   Writing objects: 100% (4/4), 1.72 KiB | 1.72 MiB/s, done.
   Total 4 (delta 1), reused 0 (delta 0)
   remote: Resolving deltas: 100% (1/1), completed with 1 local object.
   To github.com:ODOWDAIBM/fabric-docs-sa.git
   b3b9389be..7d627aeb0  release-2.1 -> master
   ```

1. 确认您的新仓库`fabric-docs-sa`推送到了GitHub的`master`分支下。

1. 用这篇[简介](./docs_guide.html#building-on-github)将您的仓库连接到ReadTheDocs。确认您的文档已经正确编译。

1. 您可以开始在`fabric-docs-sa`提交翻译更新了。
   
   我们建议您在开始之前至少翻译[Fabric前端页面](https://hyperledger-fabric.readthedocs.io/en/latest/) 和
   [简介](https://hyperledger-fabric.readthedocs.io/en/latest/whatis.html)。这样，用户就能知道您想翻译Fabric文档，这能帮助您获取贡献者。
   更多可以参考[later](#get-connected)。


1. 当您对您的仓库满意时，您可以在Hyperledger Labs organization创建一个请求建立相同的仓库，步骤 参考[这个简介](https://github.com/hyperledger-labs/hyperledger-labs.github.io)。

   这里是一个 [PR 示例](https://github.com/hyperledger-labs/hyperledger-labs.github.io/pull/126)来展示工作的过程。

1. 一旦您的仓库被同意创建，您可以添加 `upstream`（上游）：

   ```bash
   git remote add upstream git@github.com:hyperledger-labs/fabric-docs-sa.git
   ```

   确认您的`origin`  和 `upstream`远程现在设置成:

   ```bash
   git remote -v
   origin	git@github.com:ODOWDAIBM/fabric-docs-sa.git (fetch)
   origin	git@github.com:ODOWDAIBM/fabric-docs-sa.git (push)
   upstream	git@github.com:hyperledger-labs/fabric-docs-sa.git (fetch)
   upstream	git@github.com:hyperledger-labs/fabric-docs-sa.git (push)
   ```

   恭喜！您已经可以为您新创立的国际化语言仓库创建一个贡献者社区了。

## 联系交流

这里有些方法能让您联系其他有意向翻译国际语言的人：

  * Rocket chat

    在[Fabric documentation rocket
    channel](https://chat.hyperledger.org/channel/fabric-documentation)阅读对话或者交流问题。您可以找到新手和专家在文档共享信息。

    这还有一个专门的频道，专门针对[国际化](https://chat.hyperledger.org/channel/i18n)。


  * 加入一个文档工作组电话会议

    工作组电话会议是一个绝佳的认识为文档做出贡献的人的机会。会议通常在对东西半球都方便的时间定期举行。会议日程提前公布，每次会议都有记录和录音。[查阅这里](https://wiki.hyperledger.org/display/fabric/Documentation+Working+Group)。

  * 加入一个语言翻译工作组

    每个国际化语言都有一个工作组，欢迎和鼓励大家加入。查阅[国际化工作组列表](https://wiki.hyperledger.org/display/fabric/International+groups)。看看您最喜欢的工作组现在在做什么，并且联系他们；每个工作组都有个成员列表和他们的联系方式。


  * 创建一个语言翻译工作组页面

    如果您决定创立一个新的语言翻译，把您的工作组加在[国际化工作组列表](https://wiki.hyperledger.org/display/fabric/International+groups)中，利用一个已有的工作组页面作为一个例子。

  * 使用其他Fabric机制诸如邮件列表，贡献者会议，维护者会议。阅读更多参见[这里](./contributing.html)。

祝您好运，感谢您对Hyperledger Fabric做出的贡献。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
