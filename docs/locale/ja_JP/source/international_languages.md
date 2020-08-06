# Creating a new translation

**対象読者**: 新しくFabricの翻訳を作成したい方

Hyperledger Fabricのドキュメントに、あなたのほしい言語がなかったら、ぜひ新しい翻訳を始めてみましょう！
これは比較的簡単に始められますし、新しく翻訳を始めることは、あなたにとっても他のFabricユーザーにとっても、
とても満足いく活動となりうるはずです。

このトピックでは、以下について説明します。
* [国際言語サポートの紹介](#introduction)
* [新しい言語ワーキンググループの作成](#create-a-new-workgroup)
* [新しい翻訳の作成](#create-a-new-translation)

## Introduction

Hyperledger Fabricのドキュメントは、多くの異なる言語に翻訳されつつあります。例えば、

* [中国語(簡体字)](https://github.com/hyperledger/fabric-docs-i18n/tree/master/docs/locale/zh_CN)
* [マラヤーラム語](https://github.com/hyperledger/fabric-docs-i18n/tree/master/docs/locale/ml_IN)
* [ブラジル・ポルトガル語](https://github.com/hyperledger/fabric-docs-i18n/tree/master/docs/locale/pt_BR)
* [日本語](https://github.com/hyperledger/fabric-docs-i18n/tree/master/docs/locale/ja_JP)

もし、あなたの求める言語が存在しない場合には、まず最初に新しい言語ワーキンググループを作成しましょう。

## Create a new workgroup

他の翻訳者と協力することで、翻訳、メンテナンス、その言語のレポジトリの管理がより簡単になります。
このためには、既存のワーキングループのページを参考にして、まず新しいワーキンググループを
[国際ワーキンググループのリスト](https://wiki.hyperledger.org/display/fabric/International+groups)
に追加します。


ここには、ワーキンググループがどのように共同作業をしていくかを記述してください。ミーティング、チャット、
メーリングリストなどは、すべてとても有用でしょう。ワーキンググループのページで、
これらの共同作業の方法について明確にしておくことは、翻訳者のコミュニティを形成するのに役立つでしょう。

そして、[Rocket.Chatのチャネル](./advice_for_writers.html#rocket-chat)を使って、
他の皆さんに翻訳を始めたことをお知らせし、ワーキンググループへの参加を募集しましょう。

## Create a new translation

新しい言語のレポジトリを作成するにあたっては、下記の手順を守りましょう。ここでは、メキシコで使われているスペイン語への
翻訳を例にとって、新しい言語への翻訳を開始する手順を説明します。

1. [`fabric-docs-i18n` レポジトリ](https://github.com/hyperledger/fabric-docs-i18n)
   を、あなたのGitHubアカウントにフォークします。

1. ローカルマシンにフォークしたレポジトリをcloneします。
   ```bash
   git clone git@github.com:(あなたのGitHub ID)/fabric-docs-i18n.git
   ```

1. ベースにするFabricのバージョンを選びます。Fabric 2.2がLTSリリースなので、まずはこれを使うことを
   お勧めします。他のバージョンは後で追加することができます。

   ```bash
   cd fabric-docs-i18n
   git fetch origin
   git checkout release-2.2
   ```
1. ローカルにフィーチャーブランチを作成します。
   ```bash
   git checkout -b newtranslation
   ```
1. 適切な [2文字か4文字の言語コード](http://www.localeplanet.com/icu/) を選択します。メキシコのスペイン語は、
   `es_MX` です。

1. レポジトリのルートにある
   [`CODEOWNERS`](https://github.com/hyperledger/fabric-docs-i18n/blob/master/CODEOWNERS) ファイル
   を編集します。次の行を追加します。
   ```bash
   /docs/locale/ex_EX/ @hyperledger/fabric-core-doc-maintainers @hyperledger/fabric-es_MX-doc-maintainers
   ```

1. 新しい言語用のフォルダを `docs/locale/` 以下に作成します。
   ```bash
   cd docs/locale
   mkdir es_MX
   ```

1. 他の言語フォルダから、ファイルをコピーします。例えば、
   ```bash
   cp -R pt_BR/ es_MX/
   ```
   もしくは、`fabric` レポジトリの `docs/` フォルダからコピーしてもかまいません。

1. 新しい言語用に、[この例](https://github.com/hyperledger/fabric-docs-i18n/tree/master/docs/locale/pt_BR/README.md)
   を参考に `README.md` を編集します。

1. 変更した内容を、ローカルにコミットします。
   ```
   git add .
   git commit -s -m "First commit for Mexican Spanish"
   ```

1. ローカルの `newtranslation` ブランチを、フォークした `fabric-docs-i18n` レポジトリの
   `release-2.2` ブランチに対してpushします。

   ```bash
   git push origin release-2.2:newtranslation


   Total 0 (delta 0), reused 0 (delta 0)
   remote:
   remote: Create a pull request for 'newtranslation' on GitHub by visiting:
   remote:      https://github.com/(あなたのGitHub ID)/fabric-docs-i18n/pull/new/newtranslation
   remote:
   To github.com:(あなたのGitHub ID)/fabric-docs-i18n.git
   * [new branch]      release-2.2 -> newtranslation
   ```

1. フォークしたレポジトリとReadTheDocsを [この手順](./docs_guide.html#building-on-github) にしたがって連携させます。
   ドキュメントが正しくビルドされることを確認します。

1. `newtranslation`のプルリクエスト(PR)を、GitHubの下記のURLから作成します。

   [`https://github.com/(あなたのGitHub ID)/fabric-docs-i18n/pull/new/newtranslation`](https://github.com/YOURGITHUBID/fabric-docs-i18n/pull/new/newtranslation)

   PRは、[ドキュメントメンテナ](https://github.com/orgs/hyperledger/teams/fabric-core-doc-maintainers)
   の誰かによって承認される必要があります。
   PRがあると自動的にメンテナにe-mailで通知されますが、Rocket.Chat経由でコンタクトをとってもかまいません。

1. [Rocket.Chatの `i18n` チャネル](https://chat.hyperledger.org/channel/i18n) で、
   新しい言語のメンテナのグループである `@hyperledger/fabric-es_MX-doc-maintainers`
   の作成を依頼します。グループに登録するため、あなたのGitHub IDも伝えてください。

   このリストに追加されると、他の翻訳者をワーキンググループに自分で追加することができるようになります。

おめでとうございます！ これで、新しい言語の翻訳者のコミュニティが、 `fabric-docs-i18n` レポジトリで
翻訳を行えるようになります。

## First topics

新しい言語が、ドキュメントのWebサイトに掲載されるためには、下記のトピックについて翻訳を行う必要があります。
その言語の利用者や翻訳者が新たに参加するために、これらのトピックが役立つでしょう。

* [Fabric front page](https://hyperledger-fabric.readthedocs.io/zh_CN/latest/)

  ここがあなたの看板となるでしょう！ あなたのおかげで、利用者は、その言語のドキュメントがあることを
  知ることができます。完全ではないかもしれませんが、少なくとも、あなたとそのチームが何を達成しようと
  しているかは明確になります。このトピックを翻訳することで、他の翻訳者を勧誘するのにも役立つでしょう。


* [Introduction](https://hyperledger-fabric.readthedocs.io/en/latest/whatis.html)

  この短いトピックは、Fabricのハイレベルの概要について述べています。新しいユーザーは、おそらくこのトピックを
  最初に見るでしょうから、これが翻訳されているということは重要でしょう。


* [Contributions Welcome!](https://hyperledger-fabric.readthedocs.io/en/latest/CONTRIBUTING.html)

  このトピックは非常に重要です。コントリビューターは、Fabricに対する貢献の方法について、 **何** **なぜ** **どうやって**
  を理解することができるからです。翻訳で共同作業を行うためにも、このトピックを翻訳する必要があります。


* [Glossary](https://hyperledger-fabric.readthedocs.io/en/latest/glossary.html)

  このトピックの翻訳は、ほかの翻訳者が作業を進めるうえで必須のリファレンスとなります。いいかえると、
  このトピックの翻訳によって、ワーキンググループをスケールさせることができます。

これらのトピックの翻訳が終わり、新しい言語のワーキンググループができれば、あなたの翻訳をドキュメントの
Webサイトに掲載することができます。
例えば、中国語(簡体字)の翻訳は、 [ここ](https://hyperledger-fabric.readthedocs.io/zh_CN/latest/)
にあります。

[Rocket.Chatの `i18n` チャネル](https://chat.hyperledger.org/channel/i18n) で、
あなたの翻訳をWebサイトに追加するように依頼できます。

## Translation tools

アメリカ英語からあなたの言語に翻訳を行う際に、最初のパスでオンラインツールを利用し、
二回目のパスでそれを修正するというのが、便利なことが多いです。

各ワーキンググループでは、下記のようなツールを有用だとしています。

* [`DocTranslator`](https://www.onlinedoctranslator.com/)

* [`TexTra`](https://mt-auto-minhon-mlt.ucri.jgn-x.jp/)

## Suggested next topics

必須のトピックがドキュメントのWebサイトに掲載されたら、下記の順に翻訳を進めるのがよいでしょう。
他の順番で行うことにしてもかまいませんが、その場合でも、ワーキンググループで、翻訳の順番について合意しておくとよいでしょう。

* [Key concepts](https://hyperledger-fabric.readthedocs.io/en/latest/key_concepts.html)

  ソリューション・アーキテクト、アプリケーション・アーキテクト、システム・アーキテクト、開発者、
  研究者、学生など向けに、Fabricのコンセプトを包括的に説明しています。


* [Getting started](https://hyperledger-fabric.readthedocs.io/en/latest/getting_started.html)

  Fabricのハンズオンが必要な開発者向けに、インストール・サンプルネットワークの構築・Fabricで
  手を動かすための主要な手順について説明しています。


* [Developing applications](https://hyperledger-fabric.readthedocs.io/en/latest/developapps/developing_applications.html)

  開発者向けに、Fabricを使ったどんなソリューションでもコア要素となる、スマートコントラクトと
  アプリケーションの書き方を説明しています。


* [Tutorials](https://hyperledger-fabric.readthedocs.io/en/latest/tutorials.html)

  開発者と管理者向けに、Fabricの特定の機能について試すためのハンズオン・チュートリアルを
  集めたものです。


* [What's new in Hyperledger Fabric
  v2.x](https://hyperledger-fabric.readthedocs.io/en/latest/whatsnew.html)

  Hyperledger Fabricの最新の機能について説明しています。


最後に、あなたの健闘を祈るとともに、Hyperledger Fabricへの貢献に感謝します。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->