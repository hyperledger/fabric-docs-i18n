链码开发者教程
========================

链码是什么?
------------------

链码是一个程序，由 `Go <https://golang.org>`_  、 `node.js <https://nodejs.org>`_ 、或者
`Java <https://java.com/en/>`_ 编写，来实现一些预定义的接口。链码运行在一个和背书节点进
程隔离的一个安全的 Docker 容器中。链码的初始化和账本状态的管理通过应用提交的交易来实现。

链码一般处理网络中的成员一致认可的商业逻辑，所以它类似于“智能合约”。链码在交易提案中被调
用来升级或者查询账本。赋予适当的权限，链码就可以调用其他链码来访问它的状态，不管是在同一
个通道还是不同的通道。注意，如果被调用的链码和当前链码在不同的通道，就只能执行只读的查询。
就是说，调用不同通道的链码只能进行“查询”，在提交的子语句中不能参与状态的合法性检查。

在下边的章节中，我们站在应用开发者的角度来介绍链码。我们将演示一个简单的链码应用，并且逐个
查看链码 Shim API 中每一个方法的作用。
In the following sections, we will explore chaincode through the eyes of an
application developer. We'll present a simple chaincode sample application
and walk through the purpose of each method in the Chaincode Shim API. If you
are a network operator who is deploying a chaincode to running network,
visit the :doc:`deploy_chaincode` tutorial and the :doc:`chaincode_lifecycle`
concept topic.

This tutorial provides an overview of the low level APIs provided by the Fabric
Chaincode Shim API. You can also use the higher level APIs provided by the
Fabric Contract API. To learn more about developing smart contracts
using the Fabric contract API, visit the :doc:`developapps/smartcontract` topic.

链码 API
-------------

每一个链码程序都必须实现 ``Chaincode`` 接口，该接口的方法在接受到交易时会被调用。你可以在下边找到不同语言 Chaincode Shim API 的参考文档：

  - `Go <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#Chaincode>`__
  - `Node.js <https://hyperledger.github.io/fabric-chaincode-node/{BRANCH}/api/fabric-shim.ChaincodeInterface.html>`__
  - `Java <https://hyperledger.github.io/fabric-chaincode-java/{BRANCH}/api/org/hyperledger/fabric/shim/Chaincode.html>`__

在每种语言中，客户端提交交易提案都会调用 ``Invoke`` 方法。该方法可以让你使用链码来读写通道账本上的数据。

你还需要引入 ``Init`` 方法，该方法用于链码的实例化。当链码启动或者升级的时候会调用该方法实例化链码。同时，你尅使用链码定义来请求执行 ``Init`` 方法。如果需要执行 ``Init`` 方法，fabric 需要确保 ``Init`` 的调用是在任何其他方法之前的，并且只能调用一次。该选项为你提供了更多的控制，比如哪些用户可以初始化链码和有能力向账本添加初始化数据。如果你使用 peer CLI 来批准链码定义，请使用 ``--init-required`` 参数来请求 ``Init`` 方法的执行。然后使用 `peer chaincode invoke` 和 ``--isInit`` 标记调用 ``Init`` 方法。如果你想使用 Fabric 的 Node.js SDK，请访问 `如何安装和启动你的链码 <https://hyperledger.github.io/fabric-sdk-node/master/tutorial-chaincode-lifecycle.html>`__ 。更多内容请参阅 :doc:`chaincode4noah`。 

链码 "shim" API 中的其他接口是 ``ChaincodeStubInterface``：

  - `Go <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStubInterface>`__
  - `Node.js <https://hyperledger.github.io/fabric-chaincode-node/{BRANCH}/api/fabric-shim.ChaincodeStub.html>`__
  - `Java <https://hyperledger.github.io/fabric-chaincode-java/{BRANCH}/api/org/hyperledger/fabric/shim/ChaincodeStub.html>`__

用来访问和修改账本，并且可以调用链码。

在本教程中使用 Go 链码，我们将通过实现一个管理简单“资产”的示例链码应用来演示如何使用这些 API 。

.. _Simple Asset Chaincode:

简单资产链码
----------------------
我们的应用程序是一个基本的示例链码，用来在账本上创建资产（键-值对）。

选择一个位置存放代码
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

如果你没有写过 Go 的程序，你可能需要确认一下你是否安装了 :ref:`Golang` 并且你的系统上的配置是否合适。我们假设你用的是支持模块的版本。

现在你需要在 ``$GOPATH/src/`` 子目录为你的链码应用程序创建一个目录。

简单起见，我们使用如下命令：

.. code:: bash

  mkdir sacc && cd sacc

现在，我们创建一个用于编写代码的源文件：

.. code:: bash

  go mod init sacc
  touch sacc.go

家务
^^^^^^^^^^^^

首先，我们先做一些家务。每一个链码都要实现 `Chaincode interface <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#Chaincode>`_ 中的 ``Init`` 和 ``Invoke`` 方法。所以，我们先使用 Go import 语句来导入链码必要的依赖。我们将导入链码 shim 包和 `peer protobuf package <https://godoc.org/github.com/hyperledger/fabric-protos-go/peer>`_ 。然后，我们加入一个 ``SimpleAsset`` 结构体来作为链码 shim 方法的接受者。

.. code:: go

    package main

    import (
    	"fmt"

    	"github.com/hyperledger/fabric-chaincode-go/shim"
    	"github.com/hyperledger/fabric-protos-go/peer"
    )

    // SimpleAsset implements a simple chaincode to manage an asset
    type SimpleAsset struct {
    }

初始化链码
^^^^^^^^^^^^^^^^^^^^^^^^^^

然后，我们将实现 ``Init`` 方法。

.. code:: go

  // Init is called during chaincode instantiation to initialize any data.
  func (t *SimpleAsset) Init(stub shim.ChaincodeStubInterface) peer.Response {

  }

.. note:: 注意，链码升级的时候也要条用这个方法。当写用来升级一个已存在的链码的时候，
          请确保合理更改 ``Init`` 方法。特别地，当没有“迁移”或者初始化不是升级的一部
          分时，可以提供一个空的 ``Init`` 方法。

然后，我们将使用 `ChaincodeStubInterface.GetStringArgs <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStub.GetStringArgs>`_ 方法取回调用 ``Init`` 的参数，并且检查合法性。在我们的用例中，我们希望得到一个键-值对。

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
`ChaincodeStubInterface.PutState <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStub.PutState>`_
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

调用链码
^^^^^^^^^^^^^^^^^^^^^^

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
`ChaincodeStubInterface.GetFunctionAndParameters <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStub.GetFunctionAndParameters>`_
来解析链码应用程序方法的方法名和参数。

    }

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

实现链码应用程序
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

就像我们说的，我们的链码应用程序实现了两个功能，它们可以通过 ``Invoke`` 方
法调用。我们现在来实现这写方法。注意我们之前提到的，要访问账本状态，我们需要使用
链码 shim API 中的
`ChaincodeStubInterface.PutState <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStub.PutState>`_
和
`ChaincodeStubInterface.GetState <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStub.GetState>`_
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

把它们组合在一起
^^^^^^^^^^^^^^^^^^^^^^^

最后，我们增加一个 ``main`` 方法，它将被
`shim.Start <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#Start>`_
函数调用。下边是我们链码程序的完整源码。

.. code:: go

    package main

    import (
    	"fmt"

    	"github.com/hyperledger/fabric-chaincode-go/shim"
    	"github.com/hyperledger/fabric-protos-go/peer"
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

链码访问控制
------------------------

链码可以通过调用 getCreator() 函数来使用客户端（提交者）证书进行访问控制决策。另外，
Go shim 提供了扩展 API ，用于从提交者的证书中提取客户端标识，该证书可用于访问控制决
策，无论是基于客户端标识本身，还是基于组织标识，还是基于客户端标识属性。

例如，一个以键或值对表示的资产可以将客户端的身份作为值的一部分保存其中（比如作为代表资产主人
的 JSON 属性），以后就只有被授权的客户端才可以更新键或值。

更多详情请查阅 `client identity (CID) library documentation <https://github.com/hyperledger/fabric-chaincode-go/blob/master/pkg/cid/README.md>`_

To add the client identity shim extension to your chaincode as a dependency, see :ref:`vendoring`.

.. _vendoring:

管理 Go 链码的扩展依赖
----------------------------------------------------------
你的 Go 链码需要 Go 标准库之外的一些依赖包（比如 shim）。你必须把这些包包含在你的链码包中。Your Go chaincode depends on Go packages (like the chaincode shim) that are not
part of the standard library. The source to these packages must be included in
your chaincode package when it is installed to a peer. If you have structured
your chaincode as a module, the easiest way to do this is to "vendor" the
dependencies with ``go mod vendor`` before packaging your chaincode.

.. code:: bash

  go mod tidy
  go mod vendor

这就把你链码的扩展依赖导入了本地的 ``vendor`` 目录。

当依赖都引入到你的链码目录后， ``peer chaincode package`` 和 ``peer chaincode install`` 操作将把这些依赖一起放入链码包中。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
