# 为文档做贡献

**读者**: 任何愿意为Fabric文档做出贡献的人.

这篇简短的指导手册描述了Fabric文档的结构，编译及发布方式，以及方便编写者更改Fabric文档的一些规约。

在本章中，我们会介绍：
* [文档简介](#文档简介)
* [仓库文件结构](#仓库结构)
* [国际化语言文件结构](#国际化语言文件结构)
* [修改文档](#修改文档)
* [本地编译文档](#本地编译文档)
* [使用ReadTheDocs在GitHub上编译文档](#使用ReadTheDocs在GitHub上编译文档)
* [便于更改获得批准](#便于更改获得批准)
* [更新命令参考](#更新命令参考)
* [增加一个新CLI命令](#增加一个新CLI命令)

## 文档简介

Fabric文档是由[Markdown](https://www.markdownguide.org/)和[reStructuredText](http://docutils.sourceforge.net/rst.html)源文件的组合编写的，作为一个新的作者，您可以使用任意一种格式。我们建议您使用Markdown，因为它既简单又强大；
如果您有Python基础，您可能会倾向于使用rST。

在编译文档的过程中，请使用[Sphinx](http://www.sphinx-doc.org/en/stable/)将文档源文件转换为HTML，并发布在[公共文档网站上](http://hyperledger-fabric.readthedocs.io/)。用户可以选择不同语言和不同版本的Fabric文档。

比如：

  * [英文最新版](https://hyperledger-fabric.readthedocs.io/en/%7BBRANCH_DOC%7D/)
  * [中文最新版](https://hyperledger-fabric.readthedocs.io/zh_CN/%7BBRANCH_DOC%7D/)
  * [英文V2.2](https://hyperledger-fabric.readthedocs.io/en/release-2.2/)
  * [英文V1.4](https://hyperledger-fabric.readthedocs.io/en/release-1.4/)

由于历史原因，英文源文件位于主[Fabric文件库](https://github.com/hyperledger/fabric/)中，而所有国际语言对应的源文件位于单个[Fabric i18n文件库](https://github.com/hyperledger/fabric-docs-i18n)中。不同版本的文档保存在相应的GitHub分支中。

## 仓库结构

英语和国际语言文件库的结构基本相同，因此我们首先看下英语源文件的结构。

与文档相关的所有文件都位于Fabric/docs/文件夹中：

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

source/是最重要的文件夹，因为它保存了所有的源语言文件。使用make命令编译，将这些源文件转换为HTML，存储在动态构建的build/html/文件夹中：

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

* [/docs/source/index.rst](https://raw.githubusercontent.com/hyperledger/fabric/main/docs/source/index.rst)映射到[Hyperledger Fabric标题页](https://hyperledger-fabric.readthedocs.io/en/%7BRTD_TAG%7D/)

* [/docs/source/developapps/developing-applications.rst](https://raw.githubusercontent.com/hyperledger/fabric/main/docs/source/developapps/developing_applications.rst)映射到[开发应用程序](https://hyperledger-fabric.readthedocs.io/en/%7BRTD_TAG%7D/developapps/developing_applications.html)

* [/docs/source/peers/peers.md](https://raw.githubusercontent.com/hyperledger/fabric/main/docs/source/peers/peers.md)映射到[Peers](https://hyperledger-fabric.readthedocs.io/en/%7BRTD_TAG%7D/peers/peers.html)

稍后我们看看如何更改这些文件。

## 国际化语言文件结构

在提交一个PR前，我们强烈建议您测试您的修改。您应该先在您的机器上编译文档，然后将您的修改推送到您自己的GitHub阶段仓库中，它们可以迁移到您的发布网站[ReadheDocs](https://readthedocs.org/)上。一旦您对您的修改感到满意，您就可以通过发起一个PR把它纳入到Fabric主仓库中。

下述章节包含了如何在本地编译文档，并使用您自己的Github分支发布在ReadTheDocs上。

## 本地编译文档

一旦您将Fabric [repository]()克隆到您的本机，使用这简单的几步来在本机编译Fabric文档。注意：您可能需要根据您的操作系统来做一些调整。

前置需求:
 - [Python 3.7](https://wiki.python.org/moin/BeginnersGuide/Download)
 - [Pipenv](https://docs.pipenv.org/en/latest/#install-pipenv-today) 

```
cd fabric/docs
pipenv install
pipenv shell
make html
```

这会在 `docs/build/html`中生成所有Fabric文档的html文件，您可以在您自己的浏览器中查看；您可以从`index.html`进行导航。

对一个文件做些小修改，然后重新编译文档来确认您的修改是否已在本地编译。当然，您的对文档的每一次修改都需要重新运行`make html`。

另外，如果您愿意的话，您可以使用如下命令来启动一个本地web服务器（或者根据您的操作系统使用其它替代）：

```
sudo apt-get install apache2
cd build/html
sudo cp -r * /var/www/html/
```

然后您可以通过 `http://localhost/index.html`访问html文件。

## 在GitHub上编译文档

使用您自己的Fabric仓库分支编译Fabric文档总是有用的，它是公开的，可以被其它人看见。下述方法将告诉您如何使用ReadTheDocs做到这些。

1. 到http://readthedocs.org注册一个账号。
2. 创建一个工程。您的用户名非常适合作为URL地址，并且您可以在后面添加`-fabric`以将其和其它工程的文档做出区分。例如：`YOURGITHUBID-fabric.readthedocs.io/en/latest`。
3. 点击`Admin`,点击`Integrations`,点击`Add integration`,选择`GitHub incoming webhook`,然后点击`Add integration`。
4. Fork [Fabric on GitHub](https://github.com/hyperledger/fabric)。
5. 在您的分支中，在右上角找到 `Settings`。
6. 点击`Webhooks`。
7. 点击`Add webhook`。
8. 将ReadTheDocs的 URL地址添加到`Payload URL`。
9. 选择`Let me select individual events`:`Pushes`、`Branch or tag creation`、
   `Branch or tag deletion`。
10. 点击`Add webhook``Add webhook`。

现在一旦您在您的分支上修改或新增了任何文档内容，这个URL地址都会自动更新您的改动！

## 更新命令参考

更新[命令参考](https://hyperledger-fabric.readthedocs.io/en/latest/command_ref.html)中的文件需要额外的步骤。因为命令参考章节中的内容是生成出来的，您不能仅仅更新关连的markdown文件。
- 您需要更新`src/github.com/hyperledger/fabric/docs/wrappers`下的`_preamble.md` 或 `_postscript.md`文件。
- 更新命令帮助需要您编辑命令关连的`.go`文件，在`/fabric/internal/peer`文件夹下。
- 然后，对于 `fabric` 文件夹，您需要运行`make help-docs`来生成更新过的markdown文件，它们在`docs/source/commands`文件夹下。

记住，当您将变更push到GitHuB时，您需要将修改过的`_preamble.md`, `_postscript.md` 或 `_.go` 文件如同生成的markdown文件一样包含在内。

这个过程仅适用于英语版本翻译。命令参考翻译目前不支持国际语言。

## 增加一个新CLI命令

添加一个新的CLI命令，请执行如下步骤：

- 在`/fabric/internal/peer`下为新命令创建一个新的文件夹并添加帮助文本。您可以将`internal/peer/version`作为一个简单的例子来帮助您开始。
- 在`src/github.com/hyperledger/fabric/scripts/generateHelpDoc.sh`中为您的CLI命令增加一个章节。
- 在`/src/github.com/hyperledger/fabric/docs/wrappers`中创建如下两个新文件:
  - `<command>_preamble.md` (命令名和语法)
  - `<command>_postscript.md` (样例)
- 运行`make help-docs`生成markdown内容然后将所有变更的文件push到GitHub。


这个过程仅应用于英语版本翻译。CLI命令翻译目前不支持国际语言。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
