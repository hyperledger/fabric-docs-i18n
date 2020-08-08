# ドキュメントに貢献する

**対象読者**: Fabricドキュメントに貢献したい方.

この短いガイドでは、Fabricドキュメントの構成、構築、公開方法、およびFabricドキュメントの変更に役立ついくつかの規則について説明します。

このトピックでは、次の内容について説明します:
* [はじめに](#introduction)
* [リポジトリフォルダ構成](#repository-folders)
* [国際言語フォルダ構成](#international-folders)
* [ドキュメントを変更する](#making-changes)
* [ローカルマシン上のドキュメントをビルドする](#building-locally)
* [GitHub上のドキュメントをReadTheDocsを利用してビルドする](#building-on-github)
* [修正に対して承認をもらう](#making-a-pr)
* [コマンドリファレンスを変更する](#commands-reference-updates)
* [新しいCLIコマンドを追加する](#adding-a-new-cli-command)

## Introduction

Fabricドキュメントは、[Markdownソース・ファイル](https://www.markdownguide.org/)と[reStructuredTextソース・ファイル](http://docutils.sourceforge.net/rst.html)を組み合わせて作成されています。新規作成者は、どちらの形式でも使用できます。使い勝手が良いMarkdownを使用することをお勧めします。Pythonの経験がある場合は、rSTの方が扱い易いかもしれません。

ドキュメントのビルド・プロセスにおいて、ドキュメントのソース・ファイルは[Sphinx](http://www.sphinx-doc.org/en/stable/)を使用してHTMLに変換されます。生成されたHTMLファイルは、その後、パブリックのドキュメントサイトに公開されます。ユーザーは、Fabricマニュアルの言語とバージョンの両方を選択できます。

例:

  * [最新バージョンの英語（US）ドキュメント](https://hyperledger-fabric.readthedocs.io/en/latest/)
  * [最新バージョンの中国語ドキュメント](https://hyperledger-fabric.readthedocs.io/zh_CN/latest/)
  * [バージョン2.2の英語（US）ドキュメント](https://hyperledger-fabric.readthedocs.io/en/release-2.2/)
  * [バージョン1.4の英語（US）ドキュメント](https://hyperledger-fabric.readthedocs.io/en/release-1.4/)

歴史的な理由から、英語（US）ドキュメントのソース・ファイルはメインの[Fabricリポジトリ](https://github.com/hyperledger/fabric/)で管理されますが、国際言語向けドキュメントのソース・ファイルはすべて1つの[Fabric i18nリポジトリ](https://github.com/hyperledger/fabric-docs-i18n)で管理されます。ドキュメントの異なるバージョンは、適切なGitHubリリースブランチに保持されています。

## Repository folders

英語（US）ドキュメントのリポジトリと国際言語向けドキュメントのリポジトリは基本的に同じ構成を持つため、まず英語（US）ドキュメントのソースファイルを見ていくところからスタートします。

ドキュメントに関連するすべてのファイルは、`fabric/docs/`フォルダ内にあります:

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

最も重要なフォルダは、ソースとなる言語ファイルが格納されている `source/` フォルダです。ドキュメントのビルドプロセスでは、`make`コマンドを使用して、このソースファイルをHTMLに変換し、動的に作成される`build/html/`フォルダに格納します:

```bash
fabric/docs
├── build
│   ├── html
├── custom_theme
├── source
│   ├── _static
│   ├── _templates
│   ├── commands
│   ├── create_channel
│   ├── dev-setup
│   ├── developapps
│   ├── diagrams
    ...
```

Hyperledger Fabricリポジトリ内の[docsフォルダ](https://github.com/hyperledger/fabric/tree/master/docs)内を見るのに少し時間を割いてみてください。次のリンクをクリックすると、ソースファイルが対応する公開トピックにどのようにマッピングされているか確認できます。

* [`/docs/source/index.rst`](https://raw.githubusercontent.com/hyperledger/fabric/master/docs/source/index.rst) maps to [Hyperledger Fabric title page](https://hyperledger-fabric.readthedocs.io/en/master/)

* [`/docs/source/developapps/developing-applications.rst`](https://raw.githubusercontent.com/hyperledger/fabric/master/docs/source/developapps/developing_applications.rst)
  maps to [Developing
  applications](https://hyperledger-fabric.readthedocs.io/en/master/developapps/developing_applications.html)

* [`/docs/source/peers/peers.md`](https://raw.githubusercontent.com/hyperledger/fabric/master/docs/source/peers/peers.md)
  maps to
  [Peers](https://hyperledger-fabric.readthedocs.io/en/master/peers/peers.html)

これらのファイルの変更方法については、後ほど説明します。

## International folders
国際言語リポジトリ[`fabric-docs-i18n`](https://github.com/hyperledger/fabric-docs-i18n)は、英語（US）ファイルを保持する[`fabric`](https://github.com/hyperledger/fabric)リポジトリとほぼ同じ構成に従います。違いは、各言語のファイルが`docs/locale/`の個別のフォルダに格納されている点です:

```bash
fabric-docs-i18n/docs
└── locale
    ├── ja_JP
    ├── ml_IN
    ├── pt_BR
    └── zh_CN
```
これらのフォルダのどれを見ても、既に馴染みのある構成であることが分かります:
```bash
locale/ml_IN
├── custom_theme
├── source
│   ├── _static
│   ├── _templates
│   ├── commands
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

後で説明しますが、多言語と英語（US）のフォルダ構成が似ているため、同じ手順とコマンドを使用してさまざまな言語の翻訳を管理できます。

ここでも、[国際言語リポジトリ](https://github.com/hyperledger/fabric-docs-i18n)を見るのに少し時間を割いてみてください。

## Making changes

ドキュメントを更新するには、ローカルのgit作業用ブランチ上でで1つ以上の言語ソースファイルを変更し、ローカルで変更をビルドして問題がないことを確認し、Pull request(PR)を送ってブランチを適切なFabricリポジトリのブランチにマージします。あなたのPRがその言語の適切なメンテナによってレビューされ、承認されると、それはリポジトリにマージされ、公開されたドキュメントの一部になります。本当に簡単です!

ドキュメントの変更をリポジトリに取り込むよう要求する前に、その変更をテストすることは、マナーであるというだけでなく、本当に大事なことです。次の節では、以下の方法について説明します:

* 自分のマシンでドキュメントの変更をビルドして確認します。

* これらの変更をフォークしたあなたのGitHubリポジトリにプッシュして、あなた個人の[ReadTheDocs](https://readthedocs.org/)Webサイトに反映することで共同作業者がレビューできるようになります。

* `fabric`または`fabric-docs-i18n`リポジトリに取り込むドキュメントのPRを送信します。

## Building locally

次の簡単な手順に従ってドキュメントをビルドします。

1. 適切な[`fabric`](https://github.com/hyperledger/fabric)または[`fabric-docs-i18n`](https://github.com/hyperledger/fabric-docs-i18n)リポジトリのforkをGitHubアカウントに作成します。

2. 以下の必要なツールをインストールします。ご使用のOSによっては、調整が必要な場合があります:

   * [Python 3.7](https://wiki.python.org/moin/BeginnersGuide/Download)
   * [Pipenv](https://docs.pipenv.org/en/latest/#install-pipenv-today)

3. 英語（US）の場合:
   ```bash
   cd $HOME/git
   git clone git@github.com:hyperledger/fabric.git
   cd fabric/docs
   pipenv install
   pipenv shell
   make html
   ```

   マラヤーラム語の場合(例):
   ```bash
   cd $HOME/git
   git clone git@github.com:hyperledger/fabric-docs-i18n.git
   cd fabric-docs-18n/docs/locale/ml_IN
   pipenv install
   pipenv shell
   make -e SPHINXOPTS="-D language='ml'" html
   ```

   `make`コマンドを実行すると、`build/html/`フォルダにドキュメントのhtmlファイルが生成されます。このファイルはローカルで表示できます。ブラウザで`build/html/index.html`ファイルに移動するだけです。

4. ここで、ファイルを少し変更し、ドキュメントを再構築して、変更が期待どおりであることを確認します。ドキュメントに変更を加えるたびに、当然のことながら`make html`を再実行する必要があります。

5. 必要に応じて、次のコマンド(またはご使用のOS準じた同等の手順）でローカルWebサーバを立ち上げることもできます:

   ```bash
   sudo apt-get install apache2
   cd build/html
   sudo cp -r * /var/www/html/
   ```

   その後、`http://localhost/index.html`にあるhtmlファイルにアクセスできます。

6. PRの作成方法については[こちら](./github/github.html)から学ぶことができます。さらに、gitやGitHubを初めて使う人にとっては、[Git book](https://git-scm.com/book/en/v2)は非常に役に立ちます。

## Building on GitHub

多くの場合、Fabricリポジトリからフォークしたあなた自身のレポジトリを使用してFabricドキュメントをビルドし、あなたが承認依頼を送信する前に他のユーザが変更を確認できるようにすることが有用です。次の手順では、ReadTheDocsを使用してこれを行う方法を示します。

1. [`http://readthedocs.org`](http://readthedocs.org)にアクセスして、アカウントにサインアップします。

2. プロジェクトを作成します。ユーザ名はURLの前に挿入されます。他のプロジェクト用に作成するドキュメントと区別できるように、`-fabric`を追加することもできます。例えば以下の通りです:
   `YOURGITHUBID-fabric.readthedocs.io/en/latest`.
3. `Admin`をクリックし、`Integrations`をクリックし、`Add integration`をクリックし、`GitHub incoming webhook`を選択し、`Add integration`をクリックします。
4. [`fabric`](https://github.com/hyperledger/fabric)リポジトリをフォークします。
5. フォークしたレポジトリから、画面右上の`Settings`に移動します。
6. `Webhooks`をクリックします。
7. `Add webhook`をクリックします。
8. ReadTheDocsのURLを`Payload URL`に追加します。
9. `Let me select individual events`:`Pushs`、`Branch or tag creation`、`Branch or tag deletion`を選択します。
10. `Add webhook`をクリックします。

国際言語翻訳をビルドする場合は、上記の手順で`fabric`の代わりに`fabric-docs-i18n`を使用します。

ドキュメントの内容をあなたのフォーク上で変更または追加するたびに、このURL上の内容が自動的にあなたの修正で更新されます!

## Making a PR

次の[手順](./github/github.html)に従って、修正取り込みのPRを送信することができます。

`-s`オプションを使用してコミットに署名することに特に注意してください。

```bash
git commit -s -m "My Doc change"
```

これは、変更が[Developer Certificate of Origin](https://en.wikipedia.org/wiki/Developer_Certificate_of_Origin)に準拠していることを示します。

PRを適切な`fabric`または`fabric-docs-i18n`リポジトリに含めるには、適切なメンテナの承認が必要です。たとえば、日本語の翻訳は日本語のメンテナの承認が必要です。メンテナは、次の`CODEOWNERS`ファイルにリストされています。

* US English
  [`CODEOWNERS`](https://github.com/hyperledger/fabric/blob/master/CODEOWNERS)
  and their [maintainer GitHub
  IDs](https://github.com/orgs/hyperledger/teams/fabric-core-doc-maintainers)
* International language
  [`CODEOWNERS`](https://github.com/hyperledger/fabric-docs-i18n/blob/master/CODEOWNERS)
  and their [maintainer GitHub
  IDs](https://github.com/orgs/hyperledger/teams/fabric-contributors)

どちらの言語リポジトリにもGitHubのwebhookが定義されているので、いったん承認されると、`docs/`フォルダに新しくマージされたコンテンツが自動的にビルドされ、更新されたドキュメントが発行されます。

## Commands Reference updates

[コマンドリファレンス](https://hyperledger-fabric.readthedocs.io/en/latest/command_ref.html)トピックの内容を更新するには、追加の手順が必要です。コマンドリファレンストピックの情報は生成されたコンテンツであるため、関連するMarkdownファイルを単純に更新することはできません。

- 代わりに、`src/github.com/hyperledger/fabric/docs/wrappers`の下にある、このコマンドの`_preamble.md`または`_postscript.md`ファイルを更新する必要があります。
- コマンドのヘルプテキストを更新するには、`/fabric/internal/peer`の下にあるコマンドに関連付けられた`.go`ファイルを編集する必要があります。
- 次に`fabric`フォルダ内で`make help-docs`コマンドを実行し、`docs/source/commands`の下に更新されたMarkdownファイルを生成します。

GitHubに変更をプッシュするときは、生成されたMarkdownファイルと同様に、変更された`_preamble.md`、`_postscript.md`、`_.go`ファイルを含める必要があることに注意してください。

このプロセスは、英語の翻訳にのみ適用されます。現在、コマンドリファレンスの翻訳は、国際言語向けには使用できません。

## Adding a new CLI command

新しいCLIコマンドを追加するには、次の手順を実行します:

- 新しいコマンドと関連するヘルプテキストのために、`/fabric/internal/peer`の下に新しいフォルダを作成します。新しいコマンド追加を始めるための簡単な例については、`internal/peer/version`を参照してください。
- あなたが追加したCLIコマンドのセクションを`src/github.com/hyperledger/fabric/scripts/generateHelpDoc.sh`に追加します。
- `/src/github.com/hyperledger/fabric/docs/wrappers`の下に、関連するコンテンツとともに2つの新しいファイルを作成します:
  - `<command>_preamble.md` (コマンド名と構文)
  - `<command>_postscript.md` (使用例)
- `make help-docs`を実行してMarkdownコンテンツを生成し、変更されたすべてのファイルをGitHubにプッシュします。


このプロセスは、英語の翻訳にのみ適用されます。CLIコマンドの翻訳は、現在、国際言語では使用できません。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
