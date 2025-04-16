Contributions Welcome!
======================

私たちは、Hyperledgerへのさまざまな形での貢献を歓迎しています。

まず最初に、Hyperledger `Code of Conduct <https://wiki.hyperledger.org/community/hyperledger-project-code-of-conduct>`__
を確認してから参加してください。私たちは物事を市民的なものに保つことが重要です。

.. note:: このドキュメントに貢献したい方は、 :doc:`style_guide` をご覧ください。

Ways to contribute
------------------
ユーザーとしても開発者としても、Hyperledger Fabricに貢献できる方法はたくさんあります。

ユーザーとして:

- `Making Feature/Enhancement Proposals`_
- `Reporting bugs`_

ライターまたはインフォメーション・デベロッパーとして:

- あなたのFabricの経験とこのドキュメントを使用して、既存のトピックを改善したり、新規トピックを作成するなど、このドキュメントを更新します。
  ドキュメントの変更は、コントリビュータとして作業を開始する簡単な方法であり、他のユーザーがFabricを理解して使用するのを容易にし、オープンソースのコミット実績を増やします。

- 言語翻訳作業に参加して、選択した言語でFabricドキュメントを最新の状態に保ちます。
  Fabricのドキュメントは、英語、中国語、マラヤーラム語、ポルトガル語(ブラジル)など、さまざまな言語で提供されています。
  お気に入りのドキュメントを最新の状態に保つチームに参加してみてはいかがでしょうか。
  ユーザー、ライター、および開発者が集まり、共同作業を行うための友好的なコミュニティーがあります。

- 使用している言語でFabricのドキュメントがない場合は、新しい言語への翻訳を開始します。
  中国チーム、マラヤーラムチーム、ポルトガル系ブラジルチームはこの方法でスタートしました。あなたにもできます。
  ライターのコミュニティを形成したり、貢献をまとめる必要があるため、作業量は多くなりますが、
  使用している言語でFabricのドキュメントを利用できることは非常に嬉しいことです。

`Contributing documentation`_ にアクセスして、貢献活動を始めてください。

開発者として:

- 時間が少ししかない場合は、`"good first issue" <https://github.com/hyperledger/fabric/labels/good%20first%20issue>`_ にあるタスクを選択することを検討するか、
  もしくは `Fixing issues and working stories`_ を参照してください。
- フルタイムで開発を行うことができるのであれば、新しい機能を提案して(`Making Feature/Enhancement Proposals`_ を参照してください)
  それを実装するチームを作るか、あるいは既にEpicで作業しているチームの1つに参加します。
  `GitHub epic backlog <https://github.com/hyperledger/fabric/labels/Epic>`_ で興味のあるEpicを見つけたら、GithubのissueでEpicの担当者に連絡してください。

Contributing documentation
--------------------------

最初の変更をドキュメントの変更にすることをお勧めします。
これは迅速かつ簡単に行うことができ、適切に構成されたマシン(必要な事前要件ソフトウェアを含む)があることを確認しつつ、
貢献のプロセスに慣れることができます。
以下のトピックを参照してください。

.. toctree::
   :maxdepth: 1

   advice_for_writers
   docs_guide
   international_languages
   style_guide

Project Governance
------------------

Hyperledger Fabricは、我々の `charter <https://www.hyperledger.org/about/charter>`__ に記述されているように、オープンなガバナンスモデルの下で管理されています。
プロジェクトとサブプロジェクトは、メンテナのグループによりリードされています。
新規サブプロジェクトは、最初のメンテナグループが指名でき、このメンテナグループはそのプロジェクトが最初に承認されるときに、
最上位レベルのプロジェクトの既存のメンテナによって承認されます。

Maintainers
~~~~~~~~~~~

Fabricプロジェクトは、プロジェクトのトップレベルの `maintainers <https://github.com/hyperledger/fabric/blob/main/MAINTAINERS.md>`__ によってリードされています。
メンテナは、レビューのために提出されたすべてのパッチをレビューしてマージする責任があり、
Hyperledger Technical Steering Committee(TSC)によって確立されたガイドラインの範囲内でプロジェクトの全体的な技術的方向性をガイドします。

Becoming a maintainer
~~~~~~~~~~~~~~~~~~~~~

プロジェクトのメンテナは、以下の基準に基づいて、時々メンテナを追加することを検討します。

- PRレビューの実績（レビューの質と量の両方）
- プロジェクトにおける思想的リーダーシップの実証
- プロジェクトの作業とコントリビュータの主導・管理の実績

既存のメンテナは、プルリクエストを `maintainers <https://github.com/hyperledger/fabric/blob/main/MAINTAINERS.md>`__ fileにサブミットできます。
指名されたコントリビューターは、既存のメンテナによる提案の過半数の承認によってメンテナになることができます。
承認されると、変更がマージされ、メンテナグループに追加されます。

メンテナは、明示的な辞任、長期間の活動停止(例えば、レビューコメントを更新せずに3ヶ月以上経過する)、
`code of conduct <https://wiki.hyperledger.org/community/hyperledger-project-code-of-conduct>`__ の違反、
または一貫して不十分な判断を示すことによって、解任されることがあります。
解任の提案についても、過半数の承認が必要です。
活動がなかったために解任されたメンテナは、プロジェクトへの新たなコミットメントを示す貢献とレビューの継続的な再開(1ヶ月以上)の後、
メンテナに復帰することができます。

Release cadence
~~~~~~~~~~~~~~~

Fabricは、およそ4カ月ごとに新しい機能や改善のリリースを提供します。
新しい機能は、 `Github <https://github.com/hyperledger/fabric>`__ 上のFabricのmainブランチにマージされます。
コードの安定化のためにリリースブランチが各リリース前に作られ、新しい機能はmainブランチにマージされ続けます。
重要な修正は、最も新しいLTS(長期サポート)のリリースブランチにもバックポートされ、またLTSのリリース期間が重なる場合には、その前のLTSリリースにもバックポートされます。

より詳細は、 `releases <https://github.com/hyperledger/fabric#releases>`__ を参照してください。

Making Feature/Enhancement Proposals
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

軽微な改良であれば、通常の `GitHub pull request workflow <https://guides.github.com/introduction/flow/>`__ を使って実装やレビューを行うことができますが、より実質的な変更については、FabricはRFC（request for comments）プロセスに従います。

このプロセスは、Fabricや他の公式なプロジェクトコンポーネントへの大きな変更に対して、一貫し管理された方法を提供することを意図しており、すべての利害関係者がFabricの進化の方向性について信頼できるようにするものです。

新しい機能を提案するには、まず `GitHub issues backlog <https://github.com/hyperledger/fabric/issues>`__ と `Fabric RFC repository <https://github.com/hyperledger/fabric-rfcs/>`__ をチェックし、同じ機能の提案がすでにオープンになっていないか（あるいは最近クローズされたか）を確認します。該当する提案がない場合は、`the RFC process <https://github.com/hyperledger/fabric-rfcs/blob/main/README.md>`__ に従って提案を作成してください。

Contributor meeting
~~~~~~~~~~~~~~~~~~~

メンテナは定期的にコントリビュータミーティングを行います。
コントリビュータミーティングの目的は、リリースとコントリビュータの進捗を計画し、レビューし、プロジェクトとサブプロジェクトの技術的および運用上の方向性を議論することです。

メンテナミーティングの詳細については、`wiki <https://wiki.hyperledger.org/display/fabric/Contributor+Meetings>`__ を参照してください。

上記のような新機能/機能拡張の提案は、検討、フィードバック、承認のためにメンテナミーティングに提出されるべきです。

Release roadmap
~~~~~~~~~~~~~~~

EpicのFabricリリースロードマップは `GitHub issues with Epic label <https://github.com/hyperledger/fabric/labels/Epic>`__ のリストとして管理されています。

Communications and Getting Help
~~~~~~~~~~~~~~

公式なコミュニケーションには `Fabric mailing list <https://lists.hyperledger.org/g/fabric/>`__ を、コミュニティチャットには `Discord <https://discord.com/invite/hyperledger/>`__ を使用しています。
困ったことがあれば、Fabricチャンネルのいずれかに気軽に連絡してください！貢献の手助けや提案が必要な場合は、#fabric-code-contributors チャンネルに連絡してください。

私たちの開発計画や優先順位付けは `GitHub Issues ZenHub board <https://app.zenhub.com/workspaces/fabric-57c43689b6f3d8060d082cf1/board>`__ を使って行われ、長めの議論や決定は `Fabric contributor meeting <https://wiki.hyperledger.org/display/fabric/Contributor+Meetings>`__ で行われます。

メーリングリスト、Discord、GitHubには初回のみそれぞれログインが必要です。

Hyperledger Fabricの `wiki <https://wiki.hyperledger.org/display/fabric>`__ と `Jira <https://jira.hyperledger.org/projects/FAB/issues>`__ のレガシー課題管理システムには `Linux Foundation ID <https://identity.linuxfoundation.org/>`__ が必要ですが、これらのリソースは主に読み取り専用の参照用であり、おそらくIDは必要ないでしょう。

Contribution guide
------------------

Install prerequisites
~~~~~~~~~~~~~~~~~~~~~

最初に、まだ行っていない場合は、ブロックチェーンアプリケーションの開発やHyperledger Fabricのオペレーションを行うプラットフォームに
:doc:`prerequisites <prereqs>` が全てインストールされていることを確認してください。

Reporting bugs
~~~~~~~~~~~~~~

あなたがユーザーで、バグを見つけたら、 `GitHub Issues <https://github.com/hyperledger/fabric/issues>`__ を使って問題を報告してください。
新しいGithub issueを作成する前に、既存のissueを検索して、他の誰もそれを報告していないことを確認してください。
以前に報告されたことがある場合は、不具合の修正を確認したいというコメントを追加できます。

.. note:: 不具合がセキュリティ関連の場合は、
          `security bug reporting process <https://wiki.hyperledger.org/display/SEC/Defect+Response>`__ に従ってください。

これまでに報告されていない場合は、不具合と修正を記述した文書化されたコミットメッセージとともにPRを提出するか、新しいGithub issueを作成することができます。
他のユーザーが問題を再現できるだけの十分な情報を提供してください。
プロジェクトのメンテナが24時間以内にあなたの問題に対応します。
そうでない場合は、問題にコメントを付けてレビューを依頼してください。
`Hyperledger Discord <https://discord.com/servers/hyperledger-foundation-905194001349627914>`__ では、関連するHyperledger Fabricチャネルに投稿することもできます。
例えば、ドキュメントのバグは ``#fabric-documentation`` に、データベースのバグは ``#fabric-ledger`` にブロードキャストされるべきです。

Submitting your fix
~~~~~~~~~~~~~~~~~~~

バグの発見をGithub issueで報告して、修正を提供したいのであれば、喜んで歓迎します。
Githubのissueを自分に割り当て、プルリクエスト(PR)を提出してください
詳細なワークフローについては、 :doc:`github/github` を参照してください。

Fixing issues and working stories
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Fabricのissueとバグは、 `GitHub issues <https://github.com/hyperledger/fabric/issues>`__ で管理されています。
このissueリストを見て、興味のあるものを見つけてください。
`"good first issue" <https://github.com/hyperledger/fabric/labels/good%20first%20issue>`__ も確認してください。
比較的単純で達成可能なもので、誰もアサインされていないものから始めるのが賢明です。誰もアサインされていない場合は、issueに自分をアサインします。
適切な時間内に終了できない場合は、慎重に検討し、割り当てを取り消してください。また、もう少し時間が必要な場合は、まだ問題に取り組んでいるというコメントを追加してください。

Github issueは、後で取り掛かる既知のissueのバックログを追跡していますが、対応するissueがまだない変更にすぐにとりかかる場合には、
既存のissueにリンクすることなく、 `Github <https://github.com/hyperledger/fabric>`__ にプルリクエストを送ることができます。

Reviewing submitted Pull Requests (PRs)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Hyperledger Fabricに貢献し、Hyperledger Fabricについて学ぶためのもう1つの方法は、オープンなPRのレビューを行うことで、メンテナを支援することです。
実際、メンテナには、提出されるすべてのPRをレビューし、それらをマージすべきかどうかを評価するという難しい役割があります。
コードやドキュメントの変更をレビューしたり、変更をテストしたり、サブミッタやメンテナに自分の考えを伝えることができます。
レビューおよび/またはテストが完了したら、コメントおよび/または投票を追加して、結果をPRに返信するだけです。
「システムXで試してみましたが、動作しました」または「システムXでエラーが発生しました:xxx」などのコメントは、メンテナの評価に役立ちます。
その結果、メンテナンス担当者はPRをより迅速に処理できるようになり、誰もがそれから利益を得ることができます。

まずは `the open PRs on GitHub <https://github.com/hyperledger/fabric/pulls>`__ を参照してください。

PR Aging
~~~~~~~~

Fabricプロジェクトが成長するにつれて、オープンPRのバックログも増加しています。
ほとんどのプロジェクトが直面している問題の1つは、バックログを効果的に管理することで、Fabricも例外ではありません。
Fabricと関連プロジェクトのPRのバックログを管理可能にするために、ボットによって実施されるエージングポリシーを導入しています。
これは、他の大規模プロジェクトがPRバックログを管理する方法と同様です。

PR Aging Policy
~~~~~~~~~~~~~~~

Fabricプロジェクトのメンテナは、延滞に関するすべてのPR活動を自動的に監視します。
PRが2週間更新されていない場合は、PRを更新して未解決のコメントに対処するか、またはPRが撤回されるべき場合は破棄するかのいずれかを求める注意喚起コメントが追加されます。
延滞PRが更新されずにさらに2週間経過すると、自動的に破棄されます。
PRが最初に送信されてから2か月以上経過している場合は、アクティビティがあっても、メンテナレビュー用にフラグが付けられます。

提出されたPRがすべての検証に合格したが、72時間(3日間)の間にレビューされなかった場合、レビューコメントを受け取るまで、毎日#fabric-pr-reviewチャネルに通知されます。

このポリシーは、すべての公式Fabricプロジェクト(fabric、fabric-ca、fabric-samples、fabric-test、fabric-sdk-node、fabric-sdk-java、fabric-sdk-go、fabric-gateway-java、
fabric-chaincode-node、fabric-chaincode-java、fabric-chaincode-evm、fabric-baseimage、およびfabric-amcl)に適用されます。

Setting up development environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

次に、ローカルの開発環境で :doc:`building the project <dev-setup/build>` を行って、すべてが正しくセットアップされていることを確認します。

What makes a good pull request?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-  一度に1つの変更にとどめてください。
   3つ、5つ、あるいは10の変更をしないでください。１つ、たった一つだけの変更にしてください。それにより、変更箇所を制限できるからです。
   リグレッションがあった場合、コードの大部分に影響を与える複合的な変更がある場合よりも、原因となるコミットを特定する方がはるかに容易です。

-  もし対応するGitHub issueがある場合には、PRのサマリとコミットメッセージにGitHubのissueへのリンクを含めてください。
   なぜかといえば、GitHub issueに提案された変更やバグに関してさらに議論することがよくあるからです。
   加えて、PRのサマリやコミットメッセージで "Resolves #<GitHub issue number>" のような構文を使うと、PRがマージされたときにGitHub issueが自動的にクローズされます。

-  変更ごとに、単体テストと統合テスト(または既存のテストの変更)を含めてください。
   これは、単にハッピーパステストだけではありません。入力エラーを正しくキャッチするために、防御的プログラミングに対してネガティブテストすることも意味します。
   コードを作成するときには、コードをテストし、変更が要求どおりに行われていることを示すテストを提示する必要があります。
   これがなければ、現在のコードが実際に機能するかどうか見当がつきません。

-  単体テストには外部依存性を持たせないでください。
   ``go test`` やその言語と同等のものを使って、単体テストを実行できます。
   何らかの外部依存性を必要とするテスト(例えば、別のコンポーネントを実行するためにスクリプト化する必要がある)には、適切なモックの作成が必要です。
   それ以外はユニット・テストではなく、定義によれば統合テストです。なぜなら、多くのオープンソース開発者がテスト駆動開発を行っているからです。
   コードが変更されると、自動的にテストを呼び出すウォッチをディレクトリに置きます。これは、コードを変更するたびにビルド全体を実行するよりもはるかに効率的です。
   効果的な単体テストを作成するために留意すべき適切な基準については、 `この単体テストの定義 <http://artofunittesting.com/definition-of-a-unit-test/>`__ を参照してください。

-  PRごとのコード行を最小限に抑えてください。
   なぜか？メンテナには本業もあります。1,000または2,000のLOCの変更を行った場合、すべてのコードを確認するのにどのくらいの時間がかかると思いますか。
   可能な場合は、変更内容を200〜300LOC以下に抑えてください。大きな変更がある場合は、それを複数の変更に分割してください。
   新しい機能の要件を満たすために多くの新しい関数を追加する場合は、それらの関数をテストするとともに個別に追加してから、それらの関数を使用して機能を提供するコードを記述します。
   もちろん、例外はあります。例えば、小さな変更を加えてから300LOCのテストを加えた場合などは許可されます;-)。
   他に、例えば、広範な影響を与える変更や、大量の生成コード(プロトコルバッファーなど)が必要な場合などです。ここでも例外があります。

.. note:: 例えば、LOCが300を超えるような大規模なプルリクエストは、承認を得られない可能性が高く、このガイダンスに従って変更をリファクタリングするよう求められるでしょう。

-  意味のあるコミットメッセージを作成してください。
   意味のある55文字(またはそれ以下)のタイトル、空白行、変更のより包括的な説明を含めてください。

.. note:: コミットメッセージの例：

          ::

              [FAB-1234] fix foobar() panic

              Fix [FAB-1234] added a check to ensure that when foobar(foo string)
              is called, that there is a non-empty string argument.

最後に、反応は素早く行ってください。
リベースが必要になるほどまで、レビューコメントのついたプルリクエストを放置してはなりません。
そのリクエストがマージされるのがさらに遅れるだけで、マージの競合を修正するための作業が増えます。

Legal stuff
-----------

**注意:** 各ソースファイルには、Apache Software License 2.0のライセンスヘッダーを含める必要があります。
`license header <https://github.com/hyperledger/fabric/blob/main/docs/source/dev-setup/headers.txt>`__ のテンプレートを参照してください。

できるだけ貢献しやすいように努めています。これは、私たちが貢献の法的側面をどのように扱うかに当てはまります。
Linux®、Linux®Kernel `community <https://elinux.org/Developer_Certificate_Of_Origin>`__ がコードの貢献を管理するために使用しているのと同じ方法
つまり `Developer's Certificate of Origin 1.1(DCO) <https://github.com/hyperledger/fabric/blob/main/docs/source/DCO1.1. txt>`__ を使用します。

パッチをレビューのために提出する場合、開発者はコミットメッセージにsign-offステートメントを含める必要があります。

次に、送信者がDCOを受け入れることを示すSigned-off-by行の例を示します。

::

    Signed-off-by: John Doe <john.doe@example.com>

ローカルのgitリポジトリに変更をコミットする際に ``git commit -s`` を使うことで、これを自動的に含めることができます。

Related Topics
--------------

.. toctree::
   :maxdepth: 1

   dev-setup/devenv
   dev-setup/build
   style-guides/go-style

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
