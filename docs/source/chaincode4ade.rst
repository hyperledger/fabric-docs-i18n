<<<<<<< HEAD
链码开发者教程
========================

链码是什么?
------------------

=======
Chaincode for Developers - 链码开发者教程
========================

What is Chaincode? - 链码是什么
------------------

Chaincode is a program, written in `Go <https://golang.org>`_, `node.js <https://nodejs.org>`_,
or `Java <https://java.com/en/>`_ that implements a prescribed interface.
Chaincode runs in a secured Docker container isolated from the endorsing peer
process. Chaincode initializes and manages the ledger state through transactions
submitted by applications.

>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
链码是一个程序，由 `Go <https://golang.org>`_  、 `node.js <https://nodejs.org>`_ 、或者 
`Java <https://java.com/en/>`_ 编写，来实现一些预定义的接口。链码运行在一个和背书节点进
程隔离的一个安全的 Docker 容器中。链码的初始化和账本状态的管理通过应用提交的交易来实现。

<<<<<<< HEAD
=======
A chaincode typically handles business logic agreed to by members of the
network, so it similar to a "smart contract". A chaincode can be invoked to update or query
the ledger in a proposal transaction. Given the appropriate permission, a chaincode
may invoke another chaincode, either in the same channel or in different channels, to access its state.
Note that, if the called chaincode is on a different channel from the calling chaincode,
only read query is allowed. That is, the called chaincode on a different channel is only a ``Query``,
which does not participate in state validation checks in subsequent commit phase.

>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
链码一般处理网络中的成员一致认可的商业逻辑，所以它类似于“智能合约”。链码在交易提案中被调
用来升级或者查询账本。赋予适当的权限，链码就可以调用其他链码来访问它的状态，不管是在同一
个通道还是不同的通道。注意，如果被调用的链码和当前链码在不同的通道，就只能执行只读的查询。
就是说，调用不同通道的链码只能进行“查询”，在提交的子语句中不能参与状态的合法性检查。

<<<<<<< HEAD
在下边的章节中，我们站在应用开发者的角度来介绍链码。我们将演示一个简单的链码应用，并且逐个
查看链码 Shim API 中每一个方法的作用。

链码 API
=======
In the following sections, we will explore chaincode through the eyes of an
application developer. We'll present a simple chaincode sample application
and walk through the purpose of each method in the Chaincode Shim API.

在下边的章节中，我们站在应用开发者的角度来介绍链码。我们将演示一个简单的链码应用，并且逐个
查看链码 Shim API 中每一个方法的作用。

Chaincode API - 链码 API
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
-------------

Every chaincode program must implement the ``Chaincode`` interface whose methods
are called in response to received transactions. You can find the reference
documentation of the Chaincode Shim API for different languages below:

每个链码程序必须实现 ``Chaincode`` 接口：

  - `Go <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#Chaincode>`__
  - `node.js <https://fabric-shim.github.io/ChaincodeInterface.html>`__
  - `Java <https://fabric-chaincode-java.github.io/org/hyperledger/fabric/shim/Chaincode.html>`_

<<<<<<< HEAD
In each language, the ``Invoke`` method is called by clients to submit transaction
proposals. This method allows you to use the chaincode to read and write data on
the channel ledger.

You also need to include an ``Init`` method that will serve as the initialization
function for your chaincode. This method will be called in order to initialize
the chaincode when it is started or upgraded. By default, this function is never
executed. However, you can use the chaincode definition to request that the ``Init``
function be executed. If execution of ``Init`` is requested, fabric will ensure
that ``Init`` is invoked before any other function and is only invoked once.
This option provides you additional control over which users can initialize the
chaincode and the ability to add initial data to the ledger. If you are using
the peer CLI to approve the chaincode definition, use the ``--init-required``
flag to request the execution of the ``Init`` function. Then call the ``Init``
function by using the `peer chaincode invoke` command and passing the
``--isInit`` flag. If you are using the Fabric SDK for Node.js, visit
`How to install and start your chaincode <https://fabric-sdk-node.github.io/master/tutorial-chaincode-lifecycle.html>`__. For more information, see :doc:`chaincode4noah`.

链码 “shim” API 中的其他接口是 ``ChaincodeStubInterface`` ：
=======
whose methods are called in response to received transactions.
In particular the ``Init`` method is called when a
chaincode receives an ``instantiate`` or ``upgrade`` transaction so that the
chaincode may perform any necessary initialization, including initialization of
application state. The ``Invoke`` method is called in response to receiving an
``invoke`` transaction to process transaction proposals.

调用这些方法来相应接收到的交易。 ``Init`` 方法在链码接收到 ``instantiate`` 或者 ``upgrade`` 
交易的时候被调用，来执行一些必要的初始化，包括应用状态的初始化。 ``Invoke`` 方法相应链码接收
到的 ``invoke`` 交易来处理链码提案。

The other interface in the chaincode "shim" APIs is the ``ChaincodeStubInterface``:
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f

链码 “shim” API 中的其他接口是 ``ChaincodeStubInterface`` ：

  - `Go <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStubInterface>`__
  - `node.js <https://fabric-shim.github.io/ChaincodeStub.html>`__
  - `Java <https://fabric-chaincode-java.github.io/org/hyperledger/fabric/shim/ChaincodeStub.html>`_

用来访问和修改账本，并且可以调用链码。

在本教程中使用 Go 链码，我们将通过实现一个管理简单“资产”的示例链码应用来演示如何使用这些 API 。

<<<<<<< HEAD
=======
用来访问和修改账本，并且可以调用链码。

In this tutorial using Go chaincode, we will demonstrate the use of these APIs
by implementing a simple chaincode application that manages simple "assets".
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f

在本教程中使用 Go 链码，我们将通过实现一个管理简单“资产”的示例链码应用来演示如何使用这些 API 。

.. _Simple Asset Chaincode:

<<<<<<< HEAD
简单资产链码
=======
Simple Asset Chaincode - 简单资产链码
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
----------------------
我们的应用程序是一个基本的示例链码，用来在账本上创建资产（键-值对）。

<<<<<<< HEAD
选择一个位置存放代码
=======
我们的应用程序是一个基本的示例链码，用来在账本上创建资产（键-值对）。

Choosing a Location for the Code - 选择一个位置存放代码
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

如果你没有写过 Go 的程序，你可能需要确认一下你是否安装了 :ref:`Golang` 并且你的系统上的配
置是否合适。

<<<<<<< HEAD
现在你需要在 ``$GOPATH/src/`` 子目录为你的链码应用程序创建一个目录。

简单起见，我们使用如下命令：
=======
如果你没有写过 Go 的程序，你可能需要确认一下你是否安装了 :ref:`Golang` 并且你的系统上的配
置是否合适。

Now, you will want to create a directory for your chaincode application as a
child directory of ``$GOPATH/src/``.

现在你需要在 ``$GOPATH/src/`` 子目录为你的链码应用程序创建一个目录。

To keep things simple, let's use the following command:
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f

简单起见，我们使用如下命令：

.. code:: bash

  mkdir -p $GOPATH/src/sacc && cd $GOPATH/src/sacc

现在，我们创建一个用于编写代码的源文件：

现在，我们创建一个用于编写代码的源文件：

.. code:: bash

  touch sacc.go

<<<<<<< HEAD
家务
=======
Housekeeping - 家务
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
^^^^^^^^^^^^

首先，我们先做一些家务。每一个链码都要实现 `Chaincode interface <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#Chaincode>`_ 
中的 ``Init`` 和 ``Invoke`` 方法。所以，我们先使用 Go import 语句来导入链码必要的依赖。
我们将导入链码 shim 包和 `peer protobuf package <https://godoc.org/github.com/hyperledger/fabric/protos/peer>`_ 。
然后，我们加入一个 ``SimpleAsset`` 结构体来作为链码 shim 方法的接受者。

首先，我们先做一些家务。每一个链码都要实现 `Chaincode interface <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#Chaincode>`_ 
中的 ``Init`` 和 ``Invoke`` 方法。所以，我们先使用 Go import 语句来导入链码必要的依赖。
我们将导入链码 shim 包和 `peer protobuf package <https://godoc.org/github.com/hyperledger/fabric/protos/peer>`_ 。
然后，我们加入一个 ``SimpleAsset`` 结构体来作为链码 shim 方法的接受者。

.. code:: go

    package main

    import (
    	"fmt"

    	"github.com/hyperledger/fabric/core/chaincode/shim"
    	"github.com/hyperledger/fabric/protos/peer"
    )

    // SimpleAsset implements a simple chaincode to manage an asset
    type SimpleAsset struct {
    }

<<<<<<< HEAD
初始化链码
=======
Initializing the Chaincode - 初始化链码
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
^^^^^^^^^^^^^^^^^^^^^^^^^^

然后，我们将实现 ``Init`` 方法。

然后，我们将实现 ``Init`` 方法。

.. code:: go

  // Init is called during chaincode instantiation to initialize any data.
  func (t *SimpleAsset) Init(stub shim.ChaincodeStubInterface) peer.Response {

  }

.. note:: 注意，链码升级的时候也要条用这个方法。当写用来升级一个已存在的链码的时候，
          请确保合理更改 ``Init`` 方法。特别地，当没有“迁移”或者初始化不是升级的一部
          分时，可以提供一个空的 ``Init`` 方法。

<<<<<<< HEAD
然后，我们将使用 `ChaincodeStubInterface.GetStringArgs <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.GetStringArgs>`_ 
方法取回调用 ``Init`` 的参数，并且检查合法性。在我们的用例中，我们希望得到一个键-值对。
=======
.. note:: 注意，链码升级的时候也要条用这个方法。当写用来升级一个已存在的链码的时候，
          请确保合理更改 ``Init`` 方法。特别地，当没有“迁移”或者初始化不是升级的一部
          分时，可以提供一个空的 ``Init`` 方法。

Next, we'll retrieve the arguments to the ``Init`` call using the
`ChaincodeStubInterface.GetStringArgs <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.GetStringArgs>`_
function and check for validity. In our case, we are expecting a key-value pair.
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f

然后，我们将使用 `ChaincodeStubInterface.GetStringArgs <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.GetStringArgs>`_ 
方法取回调用 ``Init`` 的参数，并且检查合法性。在我们的用例中，我们希望得到一个键-值对。

  .. code:: go

    // Init is called during chaincode instantiation to initialize any
    // data. Note that chaincode upgrade also calls this function to reset
    // or to migrate data, so be careful to avoid a scenario where you
    // inadvertently clobber your ledger's data!
    func (t *SimpleAsset) Init(stub shim.ChaincodeStubInterface) peer.Response {
      // Get the args from the transaction proposal
      args := stub.GetStringArgs()
      if len(args) != 2 {
        return shim.Error("Incorrect arguments. Expecting a key and a value")
      }
    }

然后，我们已经确定了调用是合法的，我们将把初始状态存入账本中。我们将调用 
`ChaincodeStubInterface.PutState <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.PutState>`_ 
并将键和值作为参数传递给它。假设一切正常，将返回一个 peer.Response 对象，表明初始化成功。

然后，我们已经确定了调用是合法的，我们将把初始状态存入账本中。我们将调用 
`ChaincodeStubInterface.PutState <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.PutState>`_ 
并将键和值作为参数传递给它。假设一切正常，将返回一个 peer.Response 对象，表明初始化成功。

.. code:: go

  // Init is called during chaincode instantiation to initialize any
  // data. Note that chaincode upgrade also calls this function to reset
  // or to migrate data, so be careful to avoid a scenario where you
  // inadvertently clobber your ledger's data!
  func (t *SimpleAsset) Init(stub shim.ChaincodeStubInterface) peer.Response {
    // Get the args from the transaction proposal
    args := stub.GetStringArgs()
    if len(args) != 2 {
      return shim.Error("Incorrect arguments. Expecting a key and a value")
    }

    // Set up any variables or assets here by calling stub.PutState()

    // We store the key and the value on the ledger
    err := stub.PutState(args[0], []byte(args[1]))
    if err != nil {
      return shim.Error(fmt.Sprintf("Failed to create asset: %s", args[0]))
    }
    return shim.Success(nil)
  }

<<<<<<< HEAD
调用链码
=======
Invoking the Chaincode - 调用链码
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
^^^^^^^^^^^^^^^^^^^^^^
首先，我们增加一个 ``Invoke`` 函数的签名。

首先，我们增加一个 ``Invoke`` 函数的签名。

.. code:: go

    // Invoke is called per transaction on the chaincode. Each transaction is
    // either a 'get' or a 'set' on the asset created by Init function. The 'set'
    // method may create a new asset by specifying a new key-value pair.
    func (t *SimpleAsset) Invoke(stub shim.ChaincodeStubInterface) peer.Response {

    }

就像上边的 ``Init`` 函数一样，我们需要从 ``ChaincodeStubInterface`` 中解析参数。 
``Invoke`` 函数的参数是将要调用的链码应用程序的函数名。在我们的用例中，我们的应
用程序将有两个方法： ``set`` 和 ``get`` ，用来设置或者获取资产当前的状态。我们先调用 
`ChaincodeStubInterface.GetFunctionAndParameters <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.GetFunctionAndParameters>`_ 
来解析链码应用程序方法的方法名和参数。

就像上边的 ``Init`` 函数一样，我们需要从 ``ChaincodeStubInterface`` 中解析参数。 
``Invoke`` 函数的参数是将要调用的链码应用程序的函数名。在我们的用例中，我们的应
用程序将有两个方法： ``set`` 和 ``get`` ，用来设置或者获取资产当前的状态。我们先调用 
`ChaincodeStubInterface.GetFunctionAndParameters <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.GetFunctionAndParameters>`_ 
来解析链码应用程序方法的方法名和参数。

.. code:: go

    // Invoke is called per transaction on the chaincode. Each transaction is
    // either a 'get' or a 'set' on the asset created by Init function. The Set
    // method may create a new asset by specifying a new key-value pair.
    func (t *SimpleAsset) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
    	// Extract the function and args from the transaction proposal
    	fn, args := stub.GetFunctionAndParameters()

    }

然后，我们将验证函数名是否为 ``set`` 或者 ``get`` ，并执行链码应用程序的方法，通过 
``shim.Success`` 或 ``shim.Error`` 返回一个适当的响应，这个响应将被序列化为 
gRPC protobuf 消息。


然后，我们将验证函数名是否为 ``set`` 或者 ``get`` ，并执行链码应用程序的方法，通过 
``shim.Success`` 或 ``shim.Error`` 返回一个适当的响应，这个响应将被序列化为 
gRPC protobuf 消息。

.. code:: go

    // Invoke is called per transaction on the chaincode. Each transaction is
    // either a 'get' or a 'set' on the asset created by Init function. The Set
    // method may create a new asset by specifying a new key-value pair.
    func (t *SimpleAsset) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
    	// Extract the function and args from the transaction proposal
    	fn, args := stub.GetFunctionAndParameters()

    	var result string
    	var err error
    	if fn == "set" {
    		result, err = set(stub, args)
    	} else {
    		result, err = get(stub, args)
    	}
    	if err != nil {
    		return shim.Error(err.Error())
    	}

    	// Return the result as success payload
    	return shim.Success([]byte(result))
    }

<<<<<<< HEAD
实现链码应用程序
=======
Implementing the Chaincode Application - 实现链码应用程序
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

就像我们说的，我们的链码应用程序实现了两个功能，它们可以通过 ``Invoke`` 方
法调用。我们现在来实现这写方法。注意我们之前提到的，要访问账本状态，我们需要使用 
链码 shim API 中的 
`ChaincodeStubInterface.PutState <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.PutState>`_
和 
`ChaincodeStubInterface.GetState <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.GetState>`_ 
方法。

就像我们说的，我们的链码应用程序实现了两个功能，它们可以通过 ``Invoke`` 方
法调用。我们现在来实现这写方法。注意我们之前提到的，要访问账本状态，我们需要使用 
链码 shim API 中的 
`ChaincodeStubInterface.PutState <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.PutState>`_
和 
`ChaincodeStubInterface.GetState <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.GetState>`_ 
方法。
.. code:: go

    // Set stores the asset (both key and value) on the ledger. If the key exists,
    // it will override the value with the new one
    func set(stub shim.ChaincodeStubInterface, args []string) (string, error) {
    	if len(args) != 2 {
    		return "", fmt.Errorf("Incorrect arguments. Expecting a key and a value")
    	}

    	err := stub.PutState(args[0], []byte(args[1]))
    	if err != nil {
    		return "", fmt.Errorf("Failed to set asset: %s", args[0])
    	}
    	return args[1], nil
    }

    // Get returns the value of the specified asset key
    func get(stub shim.ChaincodeStubInterface, args []string) (string, error) {
    	if len(args) != 1 {
    		return "", fmt.Errorf("Incorrect arguments. Expecting a key")
    	}

    	value, err := stub.GetState(args[0])
    	if err != nil {
    		return "", fmt.Errorf("Failed to get asset: %s with error: %s", args[0], err)
    	}
    	if value == nil {
    		return "", fmt.Errorf("Asset not found: %s", args[0])
    	}
    	return string(value), nil
    }

.. _Chaincode Sample:

<<<<<<< HEAD
把它们组合在一起
=======
Pulling it All Together - 把它们组合在一起
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
^^^^^^^^^^^^^^^^^^^^^^^

最后，我们增加一个 ``main`` 方法，它将被 
`shim.Start <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#Start>`_
函数调用。下边是我们链码程序的完整源码。

最后，我们增加一个 ``main`` 方法，它将被 
`shim.Start <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#Start>`_
函数调用。下边是我们链码程序的完整源码。

.. code:: go

    package main

    import (
    	"fmt"

    	"github.com/hyperledger/fabric/core/chaincode/shim"
    	"github.com/hyperledger/fabric/protos/peer"
    )

    // SimpleAsset implements a simple chaincode to manage an asset
    type SimpleAsset struct {
    }

    // Init is called during chaincode instantiation to initialize any
    // data. Note that chaincode upgrade also calls this function to reset
    // or to migrate data.
    func (t *SimpleAsset) Init(stub shim.ChaincodeStubInterface) peer.Response {
    	// Get the args from the transaction proposal
    	args := stub.GetStringArgs()
    	if len(args) != 2 {
    		return shim.Error("Incorrect arguments. Expecting a key and a value")
    	}

    	// Set up any variables or assets here by calling stub.PutState()

    	// We store the key and the value on the ledger
    	err := stub.PutState(args[0], []byte(args[1]))
    	if err != nil {
    		return shim.Error(fmt.Sprintf("Failed to create asset: %s", args[0]))
    	}
    	return shim.Success(nil)
    }

    // Invoke is called per transaction on the chaincode. Each transaction is
    // either a 'get' or a 'set' on the asset created by Init function. The Set
    // method may create a new asset by specifying a new key-value pair.
    func (t *SimpleAsset) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
    	// Extract the function and args from the transaction proposal
    	fn, args := stub.GetFunctionAndParameters()

    	var result string
    	var err error
    	if fn == "set" {
    		result, err = set(stub, args)
    	} else { // assume 'get' even if fn is nil
    		result, err = get(stub, args)
    	}
    	if err != nil {
    		return shim.Error(err.Error())
    	}

    	// Return the result as success payload
    	return shim.Success([]byte(result))
    }

    // Set stores the asset (both key and value) on the ledger. If the key exists,
    // it will override the value with the new one
    func set(stub shim.ChaincodeStubInterface, args []string) (string, error) {
    	if len(args) != 2 {
    		return "", fmt.Errorf("Incorrect arguments. Expecting a key and a value")
    	}

    	err := stub.PutState(args[0], []byte(args[1]))
    	if err != nil {
    		return "", fmt.Errorf("Failed to set asset: %s", args[0])
    	}
    	return args[1], nil
    }

    // Get returns the value of the specified asset key
    func get(stub shim.ChaincodeStubInterface, args []string) (string, error) {
    	if len(args) != 1 {
    		return "", fmt.Errorf("Incorrect arguments. Expecting a key")
    	}

    	value, err := stub.GetState(args[0])
    	if err != nil {
    		return "", fmt.Errorf("Failed to get asset: %s with error: %s", args[0], err)
    	}
    	if value == nil {
    		return "", fmt.Errorf("Asset not found: %s", args[0])
    	}
    	return string(value), nil
    }

    // main function starts up the chaincode in the container during instantiate
    func main() {
    	if err := shim.Start(new(SimpleAsset)); err != nil {
    		fmt.Printf("Error starting SimpleAsset chaincode: %s", err)
    	}
    }

<<<<<<< HEAD
编译链码
=======
Building Chaincode - 编译链码
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
^^^^^^^^^^^^^^^^^^

现在我们编译你的链码。

现在我们编译你的链码。

.. code:: bash

  go get -u github.com/hyperledger/fabric/core/chaincode/shim
  go build

假设没有错误，现在你可以进行下一步操作，测试你的链码。

<<<<<<< HEAD
使用开发模式测试
=======
假设没有错误，现在你可以进行下一步操作，测试你的链码。

Testing Using dev mode - 使用开发模式测试 
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
^^^^^^^^^^^^^^^^^^^^^^

一般链码是通过节点执行和维护的。然而在“开发模式”下，链码通过用户编译和执
行。这个模式在链码“编码/编译/运行/调试”的开发生命周期中很有用。

<<<<<<< HEAD
我们通过一个示例开发网络预先生成的排序和通道构件来启动“开发模式”。这样用户
就可以快速的进入编译链码和调用的过程。

 装 Hyperledger Fabric 示例
=======
一般链码是通过节点执行和维护的。然而在“开发模式”下，链码通过用户编译和执
行。这个模式在链码“编码/编译/运行/调试”的开发生命周期中很有用。

We start "dev mode" by leveraging pre-generated orderer and channel artifacts for
a sample dev network.  As such, the user can immediately jump into the process
of compiling chaincode and driving calls.

我们通过一个示例开发网络预先生成的排序和通道构件来启动“开发模式”。这样用户
就可以快速的进入编译链码和调用的过程。

Install Hyperledger Fabric Samples - 安装 Hyperledger Fabric 示例
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
----------------------------------

如果你还没有完成这些，请参考 :doc:`install` 。

<<<<<<< HEAD
克隆如下命令导航至 ``fabric-samples`` 目录下的 ``chaincode-docker-devmode`` ：
=======
如果你还没有完成这些，请参考 :doc:`install` 。

Navigate to the ``chaincode-docker-devmode`` directory of the ``fabric-samples``
clone:
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f

克隆如下命令导航至 ``fabric-samples`` 目录下的 ``chaincode-docker-devmode`` ：

.. code:: bash

  cd chaincode-docker-devmode

现在打开三个终端，并且每个终端都导航至 ``chaincode-docker-devmode`` 目录。

<<<<<<< HEAD
终端1 - 启动网络
=======
现在打开三个终端，并且每个终端都导航至 ``chaincode-docker-devmode`` 目录。

Terminal 1 - Start the network - 终端1 - 启动网络
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
------------------------------

.. code:: bash

    docker-compose -f docker-compose-simple.yaml up

上边的命令启动了一个网络，网络的排序模式为 ``SingleSampleMSPSolo`` ，并且以“开发模式”
启动了 peer 节点。它还启动了另外两个容器 - 一个是链码环境，另一个是和链码交互的 CLI。
创建和加入通道的命令在 CLI 容器中，所以我们直接跳入了链码调用。

<<<<<<< HEAD
 终端2 - 编译并启动链码
=======
上边的命令启动了一个网络，网络的排序模式为 ``SingleSampleMSPSolo`` ，并且以“开发模式”
启动了 peer 节点。它还启动了另外两个容器 - 一个是链码环境，另一个是和链码交互的 CLI。
创建和加入通道的命令在 CLI 容器中，所以我们直接跳入了链码调用。

Terminal 2 - Build & start the chaincode - 终端2 - 编译并启动链码
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
----------------------------------------

.. code:: bash

  docker exec -it chaincode bash

你应该看到如下内容：

你应该看到如下内容：

.. code:: bash

  root@d2629980e76b:/opt/gopath/src/chaincode#

现在，编译你的链码：

现在，编译你的链码：

.. code:: bash

  cd sacc
  go build

现在运行链码：

现在运行链码：

.. code:: bash

  CORE_PEER_ADDRESS=peer:7052 CORE_CHAINCODE_ID_NAME=mycc:0 ./sacc

链码从 peer 节点启动并且日志表示链码成功注册到了 peer 节点上。注意，在这个阶段链码
没有关联任何通道。这个过程通过 ``instantiate`` 命令的之后的步骤完成。

<<<<<<< HEAD
终端3 - 使用链码
=======
链码从 peer 节点启动并且日志表示链码成功注册到了 peer 节点上。注意，在这个阶段链码
没有关联任何通道。这个过程通过 ``instantiate`` 命令的之后的步骤完成。

Terminal 3 - Use the chaincode - 终端3 - 使用链码
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
------------------------------

即使你在 ``--peer-chaincodedev`` 模式下，你仍然需要安装链码，这样链码才能正常地通生
命周期系统链码的检查。这个需求能会在未来的版本中移除。

<<<<<<< HEAD
我们将进入 CLI 容器来执行这些调用。
=======
即使你在 ``--peer-chaincodedev`` 模式下，你仍然需要安装链码，这样链码才能正常地通生
命周期系统链码的检查。这个需求能会在未来的版本中移除。

We'll leverage the CLI container to drive these calls.
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f

我们将进入 CLI 容器来执行这些调用。

.. code:: bash

  docker exec -it cli bash

.. code:: bash

  peer chaincode install -p chaincodedev/chaincode/sacc -n mycc -v 0
  peer chaincode instantiate -n mycc -v 0 -c '{"Args":["a","10"]}' -C myc

现在执行一个调用来将 “a” 的值改为 20 。

现在执行一个调用来将 “a” 的值改为 20 。

.. code:: bash

  peer chaincode invoke -n mycc -c '{"Args":["set", "a", "20"]}' -C myc

最后，查询 ``a`` 。我们将看到一个为 ``20`` 的值。

最后，查询 ``a`` 。我们将看到一个为 ``20`` 的值。

.. code:: bash

  peer chaincode query -n mycc -c '{"Args":["query","a"]}' -C myc

<<<<<<< HEAD
测试新链码
=======
Testing new chaincode - 测试新链码
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
---------------------

默认地，我们只挂载 ``sacc`` 。然而，你可以很容易地通过将他们加入 ``chaincode`` 子目录
并重启你的网络来测试不同的链码。这时，它们在你的 ``chaincode`` 容器中是可访问的。

<<<<<<< HEAD
链码访问控制
=======
默认地，我们只挂载 ``sacc`` 。然而，你可以很容易地通过将他们加入 ``chaincode`` 子目录
并重启你的网络来测试不同的链码。这时，它们在你的 ``chaincode`` 容器中是可访问的。

Chaincode access control - 链码访问控制
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
------------------------

链码可以通过调用 getCreator() 函数来使用客户端（提交者）证书进行访问控制决策。另外， 
Go shim 提供了扩展 API ，用于从提交者的证书中提取客户端标识，该证书可用于访问控制决
策，无论是基于客户端标识本身，还是基于组织标识，还是基于客户端标识属性。

<<<<<<< HEAD
例如，一个以键或值对表示的资产可以将客户端的身份作为值的一部分保存其中（比如作为代表资产主人
的 JSON 属性），以后就只有被授权的客户端才可以更新键或值。

更多详情请查阅 `client identity (CID) library documentation <https://github.com/hyperledger/fabric/blob/master/core/chaincode/shim/ext/cid/README.md>`_
=======
链码可以通过调用 getCreator() 函数来使用客户端（提交者）证书进行访问控制决策。另外， 
Go shim 提供了扩展 API ，用于从提交者的证书中提取客户端标识，该证书可用于访问控制决
策，无论是基于客户端标识本身，还是基于组织标识，还是基于客户端标识属性。

For example an asset that is represented as a key/value may include the
client's identity as part of the value (for example as a JSON attribute
indicating that asset owner), and only this client may be authorized
to make updates to the key/value in the future. The client identity
library extension APIs can be used within chaincode to retrieve this
submitter information to make such access control decisions.

例如，一个以键或值对表示的资产可以将客户端的身份作为值的一部分保存其中（比如作为代表资产主人
的 JSON 属性），以后就只有被授权的客户端才可以更新键或值。

See the `client identity (CID) library documentation <https://github.com/hyperledger/fabric/blob/master/core/chaincode/shim/ext/cid/README.md>`_
for more details.
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f

更多详情请查阅 `client identity (CID) library documentation <https://github.com/hyperledger/fabric/blob/master/core/chaincode/shim/ext/cid/README.md>`_

To add the client identity shim extension to your chaincode as a dependency, see :ref:`vendoring`.

<<<<<<< HEAD
链码加密
--------------------

=======
Chaincode encryption - 链码加密
--------------------

In certain scenarios, it may be useful to encrypt values associated with a key
in their entirety or simply in part.  For example, if a person's social security
number or address was being written to the ledger, then you likely would not want
this data to appear in plaintext.  Chaincode encryption is achieved by leveraging
the `entities extension <https://github.com/hyperledger/fabric/tree/master/core/chaincode/shim/ext/entities>`__
which is a BCCSP wrapper with commodity factories and functions to perform cryptographic
operations such as encryption and elliptic curve digital signatures.  For example,
to encrypt, the invoker of a chaincode passes in a cryptographic key via the
transient field.  The same key may then be used for subsequent query operations, allowing
for proper decryption of the encrypted state values.

>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
在一些场景中，将一个键的全部或者部分值进行加密是有必要的。例如，如果把一个人的社会安全吗或者
地址写入账本中了账本中，你是不会想让这些数据显示为明文的。链码的加密功能由 
`entities extension <https://github.com/hyperledger/fabric/tree/master/core/chaincode/shim/ext/entities>`__ 
提供，它是一个 BCCSP 包装器，包含了通用的工厂和函数函来进行加密操作，比如加密和椭圆曲线数字签
名。例如，要实现加密，链码的调用者就要通过传输域传入一个密钥。同样的密钥可能也要用于子查询操
作，以允许对加密的状态数据进行解密。

<<<<<<< HEAD
=======
For more information and samples, see the
`Encc Example <https://github.com/hyperledger/fabric/tree/master/examples/chaincode/go/enccc_example>`__
within the ``fabric/examples`` directory.  Pay specific attention to the ``utils.go``
helper program.  This utility loads the chaincode shim APIs and Entities extension
and builds a new class of functions (e.g. ``encryptAndPutState`` & ``getStateAndDecrypt``)
that the sample encryption chaincode then leverages.  As such, the chaincode can
now marry the basic shim APIs of ``Get`` and ``Put`` with the added functionality of
``Encrypt`` and ``Decrypt``.
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f

更多的信息和示例请参阅 ``fabric/example`` 文件夹中的 
`Encc Example <https://github.com/hyperledger/fabric/tree/master/examples/chaincode/go/enccc_example>`__ 。
重点关注 ``utils.go`` 帮助程序。这个工具加载了链码 shim API 和实体扩展，并构件了一个新类和其中
的方法（比如 ``encryptAndPutState`` 和 ``getStateAndDecrypt`` ），这些方法会被示例加密链码调用。
像这样，链码现在可以使用增加了 ``Encryp`` 和 ``Decrypt`` 的基础 shim API 中的 ``Get`` 和 ``Put`` 。

<<<<<<< HEAD
要把加密扩展作为一个以来增加到你的链码中，请参考 :ref:`vendoring` 。
=======
To add the encryption entities extension to your chaincode as a dependency, see :ref:`vendoring`.
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f

要把加密扩展作为一个以来增加到你的链码中，请参考 :ref:`vendoring` 。

.. _vendoring:

<<<<<<< HEAD
管理 Go 链码的扩展依赖
=======
Managing external dependencies for chaincode written in Go - 管理 Go 链码的扩展依赖
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
----------------------------------------------------------
如果你的链码需要 Go 标准库之外的以来的话，你需要在你的链码中引入这些包。这也是一个很好的做法，
把 shim 和任何扩展库作为依赖加入到你的链码中。

<<<<<<< HEAD
有很多 `可用工具 <https://github.com/golang/go/wiki/PackageManagementTools>`__ 来管理这些依赖。
下面演示如何使用 ``govendor`` ：
=======
如果你的链码需要 Go 标准库之外的以来的话，你需要在你的链码中引入这些包。这也是一个很好的做法，
把 shim 和任何扩展库作为依赖加入到你的链码中。

There are `many tools available <https://github.com/golang/go/wiki/PackageManagementTools>`__
for managing (or "vendoring") these dependencies.  The following demonstrates how to use
``govendor``:
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f

有很多 `可用工具 <https://github.com/golang/go/wiki/PackageManagementTools>`__ 来管理这些依赖。
下面演示如何使用 ``govendor`` ：

.. code:: bash

  govendor init
  govendor add +external  // Add all external package, or
  govendor add github.com/external/pkg // Add specific external package

这就把扩展依赖导入了本地的 ``vendor`` 目录。如果你要引用 Fabric shim 或者 shim 的扩展，在执行 
govendor 命令之前，先把 Fabric 仓库复制到 $GOPATH/src/github.com/hyperledger 目录。

<<<<<<< HEAD
当依赖都引入到你的链码目录后， ``peer chaincode package`` 和 ``peer chaincode install`` 操作将
把这些依赖一起放入链码包中。
=======
这就把扩展依赖导入了本地的 ``vendor`` 目录。如果你要引用 Fabric shim 或者 shim 的扩展，在执行 
govendor 命令之前，先把 Fabric 仓库复制到 $GOPATH/src/github.com/hyperledger 目录。

Once dependencies are vendored in your chaincode directory, ``peer chaincode package``
and ``peer chaincode install`` operations will then include code associated with the
dependencies into the chaincode package.
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f

当依赖都引入到你的链码目录后， ``peer chaincode package`` 和 ``peer chaincode install`` 操作将
把这些依赖一起放入链码包中。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
