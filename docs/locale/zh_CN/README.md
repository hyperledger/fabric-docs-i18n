# Documentation README
## 【新人必读】文档翻译流程、要求和FAQ
**翻译流程**

1. 创建或认领任务，新建 issue ，说明你要翻译的内容并表明你要认领任务。之后管理员会将该issue分配给你 。
2. 翻译文档，完成翻译后请提交PR。操作流程见[这里](https://wiki.hyperledger.org/display/TWGC/Getting+Started) ，翻译要求见下文《二、翻译要求》部分。认领任务后7天未提交完成的，该issue可以重新被其他人认领。
3. 审核译文，完成翻译后请提交 PR。操作流程见[这里](https://wiki.hyperledger.org/display/TWGC/Getting+Started) ，审核要求见下文《三、审核要求》部分。
4. 译文提交时必须提交到对应的分支 release-1.4 或 release-2.2，翻译也必须在这两个分支上进行，**不要提交到 master 分支**。

**翻译要求**

1. 译文**必须尊重原文内容**，不可以随意增删，不可以随意按自己的理解翻译，如发现原文有错误，请在 Fabric [官方仓库](https://github.com/hyperledger/fabric) 中提交 PR 进行修正。对于某些晦涩的内容，可以增加“译者注”，格式为在原文语句后的括号中增加，如（译者注：译者要说的话。），严禁增加新的段落添加“译者注”。

2. 译文**格式必须和原文一致**，不能随意转换文档格式（如，rst 格式文档转为 md 格式文档）以及内容格式（如，将两段内容合并为一段，随意拆分文档段落等。）

> 说明：rst 文档和 md 文档均以空行分割段落，换行不会影响段落划分。

3. 原文中的加粗、斜体、引用、代码等格式，应在译文中保留。

**审核要求**

1. 审核译文格式，审核译文中的段落是否和原文一致，不能增删段落。原文中的加粗、斜体、引用、代码等格式，应在译文中保留。

2. 审核译文内容，译文内容必须和原文要表达的意思一致不可以随意增删内容，可增加“译者注”，格式为在原文语句后的括号中增加，如（译者注：译者要说的话。），严禁增加新的段落添加“译者注”。

**FAQ**

1. 如何根据issue标题找到文档源文件？

在[官方文档](https://hyperledger-fabric.readthedocs.io/en/release-2.0/) 中找到对应的文档，页面 URL 中 html 文件名就是对应源码仓库中的文件名，如 readthedocs 中对应的文档 URL 是 https://hyperledger-fabric.readthedocs.io/en/release-2.0/whatis.html ，则该 issue 源文件对应的就是仓库中的 “whatis.md”。

2. 提交 PR 后提示我 DCO 检查不通过，怎么解决？

文档仓库要求所有 commit 必须有 signed off，在提交的时候必须使用 ` commit -s -m "message"` 命令进行提交，提交时没有增加离线签名就会出现该错误。解决办法：查看 github 中 DCO 检查的报错内容，并按照提示在本地仓库执行命令并重新 push 即可。提示内容一般如下：

> You have 4 commits incorrectly signed off. To fix, head to your local branch and run:
> `git rebase HEAD~17 --signoff`
> Now your commits will have your sign off. Next run
>` git push --force-with-lease origin master`

## Introduction

If you'd like to contribute to the documentation, then read the following
[instructions](./source/docs_guide.md) to get started.

This document contains information on how the Fabric documentation is
built and published as well as a few conventions one should be aware of
before making changes to the doc.

The crux of the documentation is written in
[reStructuredText](http://docutils.sourceforge.net/rst.html) which is
converted to HTML using [Sphinx](http://www.sphinx-doc.org/en/stable/).
The HTML is then published on http://hyperledger-fabric.readthedocs.io
which has a hook so that any new content that goes into `docs/source`
on the main repository will trigger a new build and publication of the
doc.

## Conventions

* Source files are in RST format and found in the `docs/source` directory.
* The main entry point is index.rst, so to add something into the Table
  of Contents you would simply modify that file in the same manner as
  all of the other topics. It's very self-explanatory once you look at
  it.
* Relative links should be used whenever possible. The preferred
  syntax for this is: :doc:\`anchor text &lt;relativepath&gt;\`
  <br/>Do not put the .rst suffix at the end of the filepath.
* For non RST files, such as text files, MD or YAML files, link to the
  file on github, like this one for instance:
  https://github.com/hyperledger/fabric/blob/master/docs/README.md

Notes: The above means we have a dependency on the github mirror
repository. Relative links are unfortunately not working on github
when browsing through a RST file.

## Setup

Making any changes to the documentation will require you to test your
changes by building the doc in a way similar to how it is done for
production. There are two possible setups you can use to do so:
setting up your own staging repo and publication website, or building
the docs on your machine. The following sections cover both options:

### Setting up your own staging repo and publication website

You can easily build your own staging repo following these steps:

1. Go to http://readthedocs.org and sign up for an account.
2. Create a project.
   Your username will preface the URL and you may want to append `-fabric` to ensure that you can distinguish between this and other docs that you need to create for other projects. So for example:
   `yourgithubid-fabric.readthedocs.io/en/latest`.
3. Click `Admin`, click `Integrations`, click `Add integration`, choose `GitHub incoming webhook`,
   then click `Add integration`.
4. Fork [Fabric on GitHub](https://github.com/hyperledger/fabric).
5. From your fork, go to `Settings` in the upper right portion of the screen.
6. Click `Webhooks`.
7. Click `Add webhook`.
8. Add the ReadTheDocs's URL into `Payload URL`.
9. Choose `Let me select individual events`:`Pushes`、`Branch or tag creation`、`Branch or tag deletion`.
10. Click `Add webhook`.

Now anytime you modify or add documentation content to your fork, this
URL will automatically get updated with your changes!

### Building the docs on your machine

Here are the quick steps to achieve this on a local machine without
depending on ReadTheDocs, starting from the main fabric
directory. Note: you may need to adjust depending on your OS.

Prereqs:
 - [Python 3.7](https://wiki.python.org/moin/BeginnersGuide/Download)
 - [Pipenv](https://docs.pipenv.org/en/latest/#install-pipenv-today)

```
cd fabric/docs
pipenv install
pipenv shell
make html
```

This will generate all the html files in `docs/build/html` which you can
then start browsing locally using your browser. Every time you make a
change to the documentation you will of course need to rerun `make
html`.

In addition, if you'd like, you may also run a local web server with the following commands (or equivalent depending on your OS):

```
sudo apt-get install apache2
cd build/html
sudo cp -r * /var/www/html/
```

You can then access the html files at `http://localhost/index.html`.
