错误处理
============================

概述
----------------

Hyperledger Fabric代码应该使用供应商提供的软件包 **github.com/pkg/errors** 来代替Go提供的标准错误类型。该软件包允许生成和显示带有错误信息的堆栈跟踪。

## 运用指南

应该使用**github.com/pkg/errors**来代替对 `fmt.Errorf()` 或`errors.New()`的所有调用。使用此程序包将生成一个调用堆栈，该调用堆栈会被附加到错误信息上。

使用该程序包很简单，只需对你的代码做轻微调整。

首先，你需要引入 **github.com/pkg/errors**

然后，更新您的代码生成的所有错误，以使用以下错误创建函数中的一个 (errors.New(), errors.Errorf(), errors.WithMessage(), errors.Wrap(), errors.Wrapf().

.. note:: See https://godoc.org/github.com/pkg/errors for complete documentation
          of the available error creation function. Also, refer to the General guidelines
          section below for more specific guidelines for using the package for Fabric
          code.

最后，将所有记录器或fmt.Printf()调用的格式指令从 ``%s`` 更改为 ``%+v`` ，以打印调用堆栈和错误信息。

Hyperledger Fabric中错误处理的通用准则
-----------------------------------------------------------

- 若要处理用户请求，应记录并返回错误。
- 若错误来自外部来源（如Go文库或vendored软件包），则用errors.Wrap()打包该错误，为其生成一个调用堆栈。
- 若错误来自另一个Fabric函数，当有需要时，在不影响调用堆栈的情况下使用errors.WithMessage()在错误信息中添加更多context。
- Panic不应被传播给其他软件包。 

示例程序
---------------

以下案列程序清楚地展示了如何使用软件包：

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