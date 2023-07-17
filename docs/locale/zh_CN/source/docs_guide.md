# 为文档做贡献

**读者**: 任何愿意为Fabric文档做出贡献的人.

这篇简短的指导手册描述了Fabric文档的结构，编译及发布方式，以及方便编写者更改Fabric文档的一些规约。

在本章中，我们会介绍：
* [文档简介](#文档简介)
* [仓库文件结构](#仓库结构)
* [国际化语言文件结构](#国际化语言文件结构)
* [修改文档](#修改文档)
* [编译本地文档](#编译本地文档)
* [在GitHub上编译文档](#在GitHub上编译文档)
* [提交一个PR](#提交一个PR)
* [命令参考的文档更新](#命令参考的文档更新)
* [增加一个新CLI命令](#增加一个新CLI命令)

## 文档简介

Fabric文档是由[Markdown](https://www.markdownguide.org/)和[reStructuredText](http://docutils.sourceforge.net/rst.html)源文件的组合编写的，作为一个新的作者，您可以使用任意一种格式。我们建议您使用Markdown，因为它既简单又强大；
如果您有Python基础，您可能会倾向于使用rST。

在编译文档的过程中，请使用[Sphinx](http://www.sphinx-doc.org/en/stable/)将文档源文件转换为HTML，并发布在[公共文档网站上](http://hyperledger-fabric.readthedocs.io/)。用户可以选择不同语言和不同版本的Fabric文档。

比如：

  * [英文最新版](https://hyperledger-fabric.readthedocs.io/en/%7BBRANCH_DOC%7D/)
  * [中文最新版](https://hyperledger-fabric.readthedocs.io/zh_CN/%7BBRANCH_DOC%7D/)
  * [英文版V2.2](https://hyperledger-fabric.readthedocs.io/en/release-2.2/)
  * [英文版V1.4](https://hyperledger-fabric.readthedocs.io/en/release-1.4/)

由于历史原因，英文源文件位于主[Fabric文件库](https://github.com/hyperledger/fabric/)中，而所有国际语言对应的源文件位于单个[Fabric i18n文件库](https://github.com/hyperledger/fabric-docs-i18n)中。不同版本的文档保存在相应的GitHub分支中。

## 仓库结构

英语和国际语言文件库的结构基本相同，因此我们首先看下英语源文件的结构。

与文档相关的所有文件都位于`Fabric/docs/`文件夹中：

```bash
fabric/docs
├── custom_theme
├── source
│   ├── _static
│   ├── _templates
│   ├── commands
│   ├── create_channel
│   ├── dev-setup
│   ├── developapps
│   ├── diagrams
│   ...
│   ├── orderer
│   ├── peers
│   ├── policies
│   ├── private-data
│   ├── smartcontract
│   ├── style-guides
│   └── tutorial
└── wrappers
```

`source/`是最重要的文件夹，因为它保存了所有的源语言文件。使用`make`命令编译，将这些源文件转换为HTML，存储在动态构建的`build/html/`文件夹中：

```bash
fabric/docs
├── build
│   ├── html
├── custom_theme
├── source
│   ├── _static
│   ├── _templates
│   ├── commands
│   ├── create_channel
│   ├── dev-setup
│   ├── developapps
│   ├── diagrams
...
```

我们花一点时间来浏览Hyperledger Fabric代码库中的[docs文件夹](https://github.com/hyperledger/fabric/tree/main/docs)。单击以下链接可查看不同的源文件是如何映射到其相应的已发布主题的。

* [`/docs/source/index.rst`](https://raw.githubusercontent.com/hyperledger/fabric/main/docs/source/index.rst)映射到[Hyperledger Fabric标题页](https://hyperledger-fabric.readthedocs.io/en/%7BRTD_TAG%7D/)

* [`/docs/source/developapps/developing-applications.rst`](https://raw.githubusercontent.com/hyperledger/fabric/main/docs/source/developapps/developing_applications.rst)映射到[开发应用程序](https://hyperledger-fabric.readthedocs.io/en/%7BRTD_TAG%7D/developapps/developing_applications.html)

* [`/docs/source/peers/peers.md`](https://raw.githubusercontent.com/hyperledger/fabric/main/docs/source/peers/peers.md)映射到[Peers](https://hyperledger-fabric.readthedocs.io/en/%7BRTD_TAG%7D/peers/peers.html)

稍后我们看看如何更改这些文件。

## 国际化语言文件结构

[`Fabric-docs-i18n`](https://github.com/hyperledger/fabric-docs-i18n)是国际化的语言存储库，它的文件结构与英文版的[`Fabric`](https://github.com/hyperledger/fabric)存储库几乎完全相同。不同之处在于每种语言都位于`docs/locale/`中自己的文件夹中：

```bash
fabric-docs-i18n/docs
└── locale
    ├── ja_JP
    ├── ml_IN
    ├── pt_BR
    └── zh_CN
```

每个文件夹都有类似的文件架构，如下：

```bash
locale/ml_IN
├── custom_theme
├── source
│   ├── _static
│   ├── _templates
│   ├── commands
│   ├── dev-setup
│   ├── developapps
│   ├── diagrams
│   ...
│   ├── orderer
│   ├── peers
│   ├── policies
│   ├── private-data
│   ├── smartcontract
│   ├── style-guides
│   └── tutorial
└── wrappers
```

我们可以看到，国际语言和英文版的文件结构具有相似性，意味着可以使用相同的指令和命令来管理不同的语言版本。

所以，有必要花一些时间查看下[国际语言存储库](https://github.com/hyperledger/fabric-docs-i18n)。

## 修改文档

如果要更新文档，只需更改本地git分支中的一个或多个语言对应的源文件，先在本地编译以确保正确，然后提交PR请求，将本地分支与相应的Fabric存储库分支合并。一旦你的PR通过了该语言版本的维护人员的审查和批准，它就会被合并到存储库中，并成为发布文档的一部分。是不是很简单？

出于礼貌，在请求将本地文档合并到存储库之前，最好先对修改的文档进行测试。以下步骤展示了如何进行测试：

* 在本地机器上编译并再次审核修改的文档。

* 将这些更改推送到你自己的GitHub存储库分支，它保存了你的个人网站信息[ReadTheDocs](https://readthedocs.org/)，可以供合作者审阅。

* 提交文档PR，以包含到fabric或fabric-docs-i18n存储库中。

## 编译本地文档

按照以下的简单步骤来编译文档。

1. 适当选择[`Fabric`](https://github.com/hyperledger/fabric)或[`Fabric-i18n`](https://github.com/hyperledger/fabric-docs-i18n)存储库，在你的Github账户上创建它们的分支；
   
2. 安装以下必备组件，需要根据操作系统自行调整：

    * [Docker](https://docs.docker.com/get-docker/)

3. 如果选择英语版本：
   ```bash
   git clone git@github.com:hyperledger/fabric.git
   cd fabric
   make docs
   ```
   对于国际语言（以马拉雅拉姆语为例）：
   ```bash
   git clone git@github.com:hyperledger/fabric-docs-i18n.git
   cd fabric-docs-i18n
   make docs-lang-ml_IN
   ```

   使用`make`命令，可以在`docs/build/html/`文件夹下生成 html 文件，可以在本地查看该文件；只需将浏览器导航到`docs/build/html/index.html`文件即可。 对于国际语言，需要将 `docs/build/html/`路径修改为`docs/locale/${LANG_CODE}/_build/html/`（例如`docs/locale/ml_IN/_build/html/`）。

4. 现在可以微调文件，并重新编译以验证更改是否符合预期。每次对文档进行更改时，都需要重新运行`make docs`。
   
5. 或者你还可以使用以下命令运行本地web服务器(命令的具体形式取决于你的操作系统)：

   ```bash
   sudo apt-get install apache2
   cd docs/build/html
   sudo cp -r * /var/www/html/
   ```

   你可以在以下位置访问html文件：http://localhost/index.html.

6. 你可以自行学习如何提交一个[PR](https://github.com/winterpi/fabric-docs-i18n/blob/release-2.5/docs/locale/en_US/source/github/github.html)。此外，如果你是git或GitHub的新手，可以参照[Git书籍](https://git-scm.com/book/en/v2)自学。


## 在GitHub上编译文档

使用Fabric存储库的分支来编译Fabric文档是很有必要的，以便其他人在批准你的PR之前查看你所做的更改。以下说明展示了如何使用ReadTheDocs来执行此操作。

1. 到`http://readthedocs.org`注册一个账号，选择"注册Github"选项。
2. 创建一个`Fabric`项目分支。
3. 导入一个项目。选择你的`Fabric`存储库的分支，需要为该项目创建一个唯一的名称，例如YOUR_USERNAME-fabric。
4. 查看`Admin`,`Integrations`的设置，确保有`GitHub incoming webhook`选项。
5. 从分叉转到屏幕右上角的`Settings`选项。
6. 单击`Webhooks`。
7. 查找新的webhook，比如`https://readthedocs.org/api/v2/webhook/YOUR_PROJECT_NAME`。
8. 滚动到`Which events would you like to trigger this webhook？` 设置并取消选择`Pull request PR请求`。
9. 单击`Update webhook`。

如果你正在编译国际语言版本，请使用上述说明中的`Fabric-docs-i18n`而不是`Fabric`目录。

现在，每当您修改文档内容或将文档内容添加到您的 fork 时，此 URL 都会根据您的更改自动更新！

每当你在这个分支上修改或新增了文档内容，这个URL地址都会自动更新你的改动！

## 提交一个PR

可以按照[以下说明](https://github.com/winterpi/fabric-docs-i18n/blob/release-2.5/docs/locale/en_US/source/github/github.html)提交你的PR以便于快速通过。

请特别注意使用`-s`选项对提交的PR进行签名：

   ```bash
   git commit -s -m "My Doc change"
   ```

这表明你的更改符合[开发者原创认证](https://en.wikipedia.org/wiki/Developer_Certificate_of_Origin)。

在你的PR被包含到`Fabric`或`Fabric-docs-i18n`存储库之前，必须得到相应的维护者的批准。例如，日语翻译必须得到日语维护者的批准，以此类推。你可以找到以下`CODEOWNERS`文件中列出的维护者：

* 美国英语[代码所有者](https://github.com/hyperledger/fabric/blob/main/CODEOWNERS)及其[维护者GitHub ID](https://github.com/orgs/hyperledger/teams/fabric-core-doc-maintainers)
* 国际语言[代码所有者](https://github.com/hyperledger/fabric-docs-i18n/blob/main/CODEOWNERS)及其[维护者GitHub ID](https://github.com/orgs/hyperledger/teams/fabric-contributors)
  
这两种语言文件库都定义了GitHub Webhook，因此，一旦获得批准，`docs/`文件夹中新合并的内容将触发更新文档的自动编译和发布。

注意：文档维护者无法通过单击`Merge pull request`来合并文档PR。相反，如果您是文档维护者并已批准PR，只需给PR打上`doc-merge`的标签，自动运行的`Mergify`机器人就会合并 PR。

## 命令参考的文档更新

[命令参考](https://hyperledger-fabric.readthedocs.io/en/%7BBRANCH_DOC%7D/command_ref.html)中的文件更新需要额外的步骤。因为命令参考章节中的内容是生成出来的，不能仅仅更新关连的markdown文件。

- 需要更新`src/github.com/hyperledger/fabric/docs/wrappers`下的`_preamble.md`或`_postscript.md`文件。
- 要更新命令相关的帮助说明，需要编辑命令相关的`.go`文件，通常位于`/fabric/internal/peer`文件夹下。
- 之后，在`fabric`文件夹下，运行`make help-docs`生成更新后的markdown文件，位于`docs/source/commands`文件夹下。

记住，当你将变更发布到GitHuB时，需要将修改过的`_preamble.md`, `_postscript.md`或`_.go`文件连同生成的markdown文件一同提交发布。

这个过程仅适用于英语版本的翻译。命令参考的翻译目前暂不支持国际语言。

## 增加一个新CLI命令

添加一个新的CLI命令，请执行如下步骤：

- 在`/fabric/internal/peer`下，为新命令创建一个新的文件夹及相应的帮助文本。可以参考`internal/peer/version`，。
- 在`src/github.com/hyperledger/fabric/scripts/generateHelpDoc.sh`中为新的CLI命令增加一个章节。
- 在`/src/github.com/hyperledger/fabric/docs/wrappers`中创建如下两个新文件:
  - `<command>_preamble.md` (命令名称和语法)
  - `<command>_postscript.md` (样例)
- 运行`make help-docs`生成markdown内容，然后将所有变更的文件push到GitHub。

这个过程仅适用于英语版本的翻译。CLI命令的翻译目前暂不支持国际语言。
