Error handling
==============

General Overview
----------------
Hyperledger Fabricのコードでは、Goが提供する標準的なエラー型の代わりに、ベンダーパッケージ **github.com/pkg/errors** を使用する必要があります。
このパッケージは、エラーメッセージを含むスタックトレースを簡単に生成し、表示することができます。

Usage Instructions
------------------

**github.com/pkg/errors** は ``fmt.Errorf()`` や ``errors.New()`` のすべての呼び出しの代わりに使用する必要があります。
このパッケージを使用すると、コールスタックが生成され、エラーメッセージに追加されます。

このパッケージを使用するのは簡単で、あなたのコードに簡単な修正を加えるだけです。

まず、 **github.com/pkg/errors** をインポートする必要があります。

次に、あなたのコードによって生成されたすべてのエラーを更新して、
エラー作成関数 (errors.New(), errors.Errorf(), errors.WithMessage(), errors.Wrap(), errors.Wrapf()) のいずれかを使用するようにしてください。

.. note:: 利用可能なエラー作成関数の完全なドキュメントは、https://godoc.org/github.com/pkg/errors を参照してください。
          また、Fabricコード用のパッケージの使用に関するより具体的なガイドラインは、以下の一般的なガイドライン (General guidelines) のセクションを参照してください。

最後に、ロガーまたは fmt.Printf() 呼び出しのフォーマットディレクティブを ``%s`` から ``%+v`` に変更して、
エラーメッセージと一緒にコールスタックを表示するようにします。

General guidelines for error handling in Hyperledger Fabric
-----------------------------------------------------------

- ユーザーリクエストを処理している場合は、エラーをログに記録し、それを返す必要があります。
- エラーがGoライブラリやベンダーパッケージなどの外部ソースから発生した場合は、 errors.Wrap() を使用してエラーをラップし、エラーのコールスタックを生成します。
- エラーが他のFabricの関数に起因する場合は、エラーメッセージにさらにコンテキストを追加し、必要であれば errors.WithMessage() を使って、コールスタックは影響を受けないようにします。
- パニックが他のパッケージに伝播することは許されません。

Example program
---------------

以下のサンプルプログラムでは、パッケージの使い方をわかりやすく説明しています:

.. code:: go

  package main

  import (
    "fmt"

    "github.com/pkg/errors"
  )

  func wrapWithStack() error {
    err := createError()
    // do this when error comes from external source (go lib or vendor)
    return errors.Wrap(err, "wrapping an error with stack")
  }
  func wrapWithoutStack() error {
    err := createError()
    // do this when error comes from internal Fabric since it already has stack trace
    return errors.WithMessage(err, "wrapping an error without stack")
  }
  func createError() error {
    return errors.New("original error")
  }

  func main() {
    err := createError()
    fmt.Printf("print error without stack: %s\n\n", err)
    fmt.Printf("print error with stack: %+v\n\n", err)
    err = wrapWithoutStack()
    fmt.Printf("%+v\n\n", err)
    err = wrapWithStack()
    fmt.Printf("%+v\n\n", err)
  }

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
