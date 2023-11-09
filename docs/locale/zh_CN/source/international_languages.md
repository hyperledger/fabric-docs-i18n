# 创建新的翻译

**本章节面向的读者**: 希望为Fabric创建新翻译的作者。

如果 Hyperledger Fabric 文档没有您选择的语言版本，那么为什么不创建一个新的语言翻译呢？
对您和其他 Fabric 用户来说，创建新的语言翻译的入门相对容易，是一项非常令人满意的活动。

在这个章节中，我们将介绍：
* [Fabric语言支持简介](#简介)
* [如何加入一个已存在的翻译组](#加入小组)
* [如何建立一个新语言的翻译组](#创建新翻译)

## 简介
Hyperledger Fabric 文档正在被翻译成多种不同语言。例如

* [中文](https://github.com/hyperledger/fabric-docs-i18n/tree/main/docs/locale/zh_CN)
* [马来语](https://github.com/hyperledger/fabric-docs-i18n/tree/main/docs/locale/ml_IN)
* [巴西葡萄牙语](https://github.com/hyperledger/fabric-docs-i18n/tree/main/docs/locale/pt_BR)
* [日语](https://github.com/hyperledger/fabric-docs-i18n/tree/main/docs/locale/ja_JP)

如果您选择的语言不可用，那么首先要做的是创建一个新的语言工作组。

## Create a new workgroup

如果与其他译员合作，翻译、维护和管理语言库会容易得多。要开始翻译过程，在 [国际工作组列表 (https://wiki.hyperledger.org/display/I18N/International+groups)] 中添加一个新的工作组，并以现有的工作组页面为例。

记录工作组的合作方式；会议、聊天和邮件列表都非常有效。在您的工作组页面上明确说明这些机制将有助于建立译员社区。

然后使用 [Discord]（./advice_for_writers.html#discord）让其他人知道您已经开始了一个翻译小组，并邀请他们加入工作组。

## Create a new translation

按照这些说明创建您自己的语言存储库。我们的示例说明将向您展示如何为墨西哥使用的西班牙语创建新的语言翻译：
1. 将 [`fabric-docs-i18n` 存储库]（https://github.com/hyperledger/fabric-docs-i18n） 复刻到您的 GitHub 帐户。

1. 将存储库分支克隆到本地计算机：
   ```bash
   git clone git@github.com:YOURGITHUBID/fabric-docs-i18n.git
   ```

1. 选择要用作基线的结构版本。我们建议您从结构 2.2 开始，因为这是一个 LTS 版本。您可以稍后添加其他版本。
   ```bash
   cd fabric-docs-i18n
   git fetch origin
   git checkout release-2.2
   ```
1. 创建本地功能分支:
   ```bash
   git checkout -b newtranslation
   ```
1. 确定适当的 [两个或四个字母的语言代码]（http://www.localeplanet.com/icu/）。 墨西哥西班牙语的语言代码为“es_MX”。

1. 更新Fabric根目录中的 ['CODEOWNERS']（https://github.com/hyperledger/fabric-docs-i18n/blob/main/CODEOWNERS）文件。添加以下行：

   ```bash
   /docs/locale/ex_EX/ @hyperledger/fabric-core-doc-maintainers @hyperledger/fabric-es_MX-doc-maintainers
   ```

1. 在 `docs/locale/` 下为您的语言创建一个新的语言文件夹。
   ```bash
   cd docs/locale
   mkdir es_MX
   ```

1.从其他语言文件夹复制语言文件，例如
   ```bash
   cp -R pt_BR/ es_MX/
   ```
   或者，您可以从 `fabric` 仓库库中复制“docs/”文件夹。
   
1. 使用 [此示例]（https://github.com/hyperledger/fabric-docs-i18n/tree/main/docs/locale/pt_BR/README.md）自定义新语言的“README.md”文件。

1. 在本地提交更改：
   ```
   git add .
   git commit -s -m "First commit for Mexican Spanish"
   ```

1. Push your `newtranslation` local feature branch to the `release-2.2` branch
   of your forked `fabric-docs-i18n` repository:
   将您的 `newtranslation` 本地特性分支推送至复刻仓库 `fabric-docs-i18n` 的 `release-2.2` 分支：

   ```bash
   git push origin release-2.2:newtranslation


   Total 0 (delta 0), reused 0 (delta 0)
   remote:
   remote: Create a pull request for 'newtranslation' on GitHub by visiting:
   remote:      https://github.com/YOURGITHUBID/fabric-docs-i18n/pull/new/newtranslation
   remote:
   To github.com:ODOWDAIBM/fabric-docs-i18n.git
   * [new branch]      release-2.2 -> newtranslation
   ```

1. 使用这些 [说明]（./docs_guide.html#building-on-github） 将您的存储库分支连接到 ReadTheDocs。验证您的文档是否正确生成。

1. 通过访问以下内容，在 GitHub 上为 `newtranslation` 创建拉取请求 （PR）：

   [`https://github.com/YOURGITHUBID/fabric-docs-i18n/pull/new/newtranslation`](https://github.com/YOURGITHUBID/fabric-docs-i18n/pull/new/newtranslation)

   您的 PR 需要得到其中一个 [文档维护者]（https://github.com/orgs/hyperledger/teams/fabric-core-doc-maintenanceers）的批准。他们将通过电子邮件自动收到您的 PR 通知，您可以通过 Discord 聊天与他们联系。

1. 在 [Discord](https://discord.com/invite/hyperledger) 的 fabric-documentation 频道上，请求为您的语言创建新的维护者组，`@hyperledger/fabric-es_MX-doc-maintenanceers`。提供您的 GitHubID 以添加到此组。

   将您添加到此列表后，您可以从工作组中添加其他翻译人员。

祝贺您！翻译社区现在可以在 `fabric-docs-i18n` 存储库中翻译您新创建的语言。

## 第一个主题

在将新语言发布到文档网站之前，必须翻译以下主题。 这些主题可帮助新语言的用户和翻译人员入门。

* [Fabric首页](https://hyperledger-fabric.readthedocs.io/en/{BRANCH_DOC}/)

  这是你的广告！多亏了您，用户现在可以看到文档以他们的语言提供。它可能还没有完成，但很明显你和你的团队正在努力实现。翻译此页面将帮助您招募其他翻译人员。


* [介绍](https://hyperledger-fabric.readthedocs.io/en/{BRANCH_DOC}/whatis.html)

这个简短的主题提供了 Fabric 的高级概述，并且由于它可能是新用户首先看到的主题之一，因此对其进行翻译非常重要。
* [欢迎投稿](https://hyperledger-fabric.readthedocs.io/en/{BRANCH_DOC}/CONTRIBUTING.html)

  这个主题至关重要 - 它可以帮助贡献者理解为Fabric做出贡献的**是什么**，**为什么**和**如何做**。您需要翻译此主题，以便其他人可以帮助您协作翻译。

* [术语](https://hyperledger-fabric.readthedocs.io/en/{BRANCH_DOC}/glossary.html)

  翻译此主题提供了帮助其他语言翻译人员取得进展的基本参考材料;简而言之，它允许您的工作组进行扩展。
  

翻译完这组主题并创建语言工作组后，您的翻译就可以发布在文档网站上。例如，中文文档[此处]（https://hyperledger-fabric.readthedocs.io/zh_CN/{BRANCH_DOC}/）。

您现在可以通过 [Discord]（https://discord.com/invite/hyperledger）上的Fabric文档渠道请求将您的翻译包含在文档网站上。

## Translation tools

将主题从美式英语翻译成您的国际语言时，使用在线工具生成翻译的第一遍通常会很有帮助，然后在第二遍审核中更正该翻译。
语言工作组发现以下工具很有帮助：

* [`DocTranslator`](https://www.onlinedoctranslator.com/)

* [`TexTra`](https://mt-auto-minhon-mlt.ucri.jgn-x.jp/)

## 建议的下一个主题

在文档网站上发布强制性的初始主题集后，我们鼓励您按顺序翻译这些主题。如果您选择采用其他顺序，有没有关系。
您仍然会发现在工作组中商定翻译顺序很有帮助。
* [核心概念](https://hyperledger-fabric.readthedocs.io/en/{BRANCH_DOC}/key_concepts.html)

  对于解决方案架构师、应用架构师、系统架构师、开发人员、学者和学生而言，本专题提供了全面的概念性知识、 本专题提供了对 Fabric 的全面概念性理解。对 Fabric 的全面概念性理解。


* [开始](https://hyperledger-fabric.readthedocs.io/en/{BRANCH_DOC}/getting_started.html)

  对于想要亲身体验 Fabric 的开发人员，本主题提供了关键说明，以帮助安装、构建示例网络并亲身体验 Fabric。
* [开发应用](https://hyperledger-fabric.readthedocs.io/en/{BRANCH_DOC}/developapps/developing_applications.html)

  本主题帮助开发人员编写智能合约和应用程序;这些是使用 Fabric 的任何解决方案的核心元素。


* [教程](https://hyperledger-fabric.readthedocs.io/en/{BRANCH_DOC}/tutorials.html)

  一组实践教程，可帮助开发人员和管理员试用特定的 Fabric 特性和功能。

* [Hyperledger Fabric v2.x 中的新功能](https://hyperledger-fabric.readthedocs.io/en/{BRANCH_DOC}/whatsnew.html)

  本主题介绍 Hyperledger Fabric 中的最新功能。


最后，我们祝您好运，并感谢您对Hyperledger Fabric的贡献。

<!--- 根据 Creative Commons Attribution 4.0 International License 获得许可 
https://creativecommons.org/licenses/by/4.0/ -->
