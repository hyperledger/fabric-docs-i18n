Coding guidelines
-----------------

Coding in Go
~~~~~~~~~~~~

我々は Go™ でコーディングし、 `Effective Go <https://golang.org/doc/effective_go.html>`__ で
概説されているベストプラクティスとスタイルおよび `Go Code Review Comments wiki
<https://github.com/golang/go/wiki/CodeReviewComments>`__ の補足ルールに従うように努めています。

また、プルリクエストを送信する前に、新しいコントリビュータが以下を確認することをおすすめします:

  - `Practical Go <https://dave.cheney.net/practical-go/presentations/qcon-china.html>`__
  - `Go Proverbs <https://go-proverbs.github.io/>`__

次のツールは、すべてのプルリクエストに対して実行されます。
これらのツールによってフラグが付けられたエラーは、コードをマージする前に対処する必要があります:

  - `gofmt -s <https://golang.org/cmd/gofmt/>`__
  - `goimports <https://godoc.org/golang.org/x/tools/cmd/goimports>`__
  - `go vet <https://golang.org/cmd/vet/>`__

Testing
^^^^^^^

単体テストは、すべての製品コードの変更に付随して行われることが期待されています。
これらのテストは高速で、新規および変更されたコードに対して非常に優れたカバレッジを提供し、
並列実行をサポートしなければなりません。

我々のテストでは、2つのマッチングライブラリ (訳者補足: テストの条件マッチライブラリ) が一般的に使用されます。
コードを変更するときは、パッケージ用にすでに選択されているマッチングライブラリを使用してください。

  - `gomega <https://onsi.github.io/gomega/>`__
  - `testify/assert <https://godoc.org/github.com/stretchr/testify/assert>`__

テストに必要なフィクスチャまたはデータは、生成するか、バージョン管理下に置く必要があります。
フィクスチャが生成されるとき、それらは  ``ioutil.TempDir`` によって作成された一時ディレクトリに配置され、
テストの終了時にクリーンアップされる必要があります。
フィクスチャをバージョン管理下に置く場合は、 ``testdata`` フォルダ内に作成する必要があります。
フィクスチャを再生成する方法を説明するドキュメントは、テストまたは ``README.txt`` で提供する必要があります。
パッケージ間でフィクスチャを共有することは強くおすすめしません。

フェイクやモックが必要な場合は、それらを生成する必要があります。
ハードコードしたモックはメンテナンスの負担であり、
必然的に現実から乖離したシミュレーションが含む傾向があります。
Fabric 内では、 ``go generate`` ディレクティブを使用して、次のツールでその生成を管理します:

  - `counterfeiter <https://github.com/maxbrunsfeld/counterfeiter>`__
  - `mockery <https://github.com/vektra/mockery>`__

API Documentation
^^^^^^^^^^^^^^^^^

Hyperledger Fabric の Go API の API ドキュメントは、 `GoDoc <https://godoc.org/github.com/hyperledger/fabric>`_ で入手できます。

Adding or updating Go packages
------------------------------

Hyperledger Fabric は、 go モジュール (go modules) を使用して、依存関係を管理およびベンダー化します。
これは、バイナリのビルドに必要なすべての外部パッケージが、リポジトリのトップにある ``vendor`` フォルダにあることを意味します。
Go は、 go コマンドの実行時に、モジュールキャッシュの代わりにこのフォルダ内のパッケージを使用します。

コードを変更した結果、依存関係が新規または更新された場合は、必ず ``go mod tidy`` と ``go mod vendor`` を実行して、
``vendor`` フォルダと依存関係のメタデータを最新の状態に保ってください。

詳細については、 `Go Modules Wiki <https://github.com/golang/go/wiki/Modules>`__ を参照してください。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
