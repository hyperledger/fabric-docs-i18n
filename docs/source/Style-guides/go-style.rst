Coding guidelines-编程指南
-----------------

Coding Golang-Golang编程
~~~~~~~~~~~~~~

We code in Go™ and strictly follow the `best
practices <https://golang.org/doc/effective_go.html>`__ and will not
accept any deviations. You must run the following tools against your Go
code and fix all errors and warnings: -
`golint <https://github.com/golang/lint>`__ - `go
vet <https://golang.org/cmd/vet/>`__ -
`goimports <https://godoc.org/golang.org/x/tools/cmd/goimports>`__

我们使用Go™编程，遵循 `最佳实践 <https://golang.org/doc/effective_go.html>`__ 
并且不允许有偏差。你必须使用下述工具来检测你的代码，修复错误和警告：-
`golint <https://github.com/golang/lint>`__ - `go
vet <https://golang.org/cmd/vet/>`__ -
`goimports <https://godoc.org/golang.org/x/tools/cmd/goimports>`__

API Documentation-API 文档
^^^^^^^^^^^^^^^^^

The API documentation for Hyperledger Fabric's Golang APIs is available
in `GoDoc <https://godoc.org/github.com/hyperledger/fabric>`_.

Hyperledger Fabric的 Golang API文档在
`GoDoc <https://godoc.org/github.com/hyperledger/fabric>`_
中可以看到。

Generating gRPC code-生成 gRPC 代码
---------------------

If you modify any ``.proto`` files, run the following command to
generate/update the respective ``.pb.go`` files.

如果你修改任何 ``.proto`` 文件，运行下面的命令来生成/更新各自的 ``.pb.go`` 文件。

::

    cd $GOPATH/src/github.com/hyperledger/fabric
    make protos

Adding or updating Go packages-添加或者更新Go第三方包
------------------------------

Hyperledger Fabric uses Go Vendoring for package
management. This means that all required packages reside in the
``$GOPATH/src/github.com/hyperledger/fabric/vendor`` folder. Go will use
packages in this folder instead of the GOPATH when the ``go install`` or
``go build`` commands are executed. To manage the packages in the
``vendor`` folder, we use
`dep <https://golang.github.io/dep/>`__.

Hyperledger Fabric使用Go Vendoring来进行包管理。
这意味着所有的包都存放于
``$GOPATH/src/github.com/hyperledger/fabric/vendor`` 文件夹中。
当执行 ``go install`` 或者 ``go build`` Go将使用这个文件夹中的包来替代PGOPATH中的包。
我们使用 `dep <https://golang.github.io/dep/>`__ 来管理 ``vendor`` 目录中的包。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
