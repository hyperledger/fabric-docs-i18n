Chaincode for Developers - 链码开发者教程
========================

What is Chaincode? - 链码是什么
------------------

Chaincode is a program, written in `Go <https://golang.org>`_, `node.js <https://nodejs.org>`_,
or `Java <https://java.com/en/>`_ that implements a prescribed interface.
Chaincode runs in a secured Docker container isolated from the endorsing peer
process. Chaincode initializes and manages the ledger state through transactions
submitted by applications.

链码是一个程序，由 `Go <https://golang.org>`_  、 `node.js <https://nodejs.org>`_ 、或者 
`Java <https://java.com/en/>`_ 编写，来实现一些预定义的接口。链码运行在一个和背书节点进
程隔离的一个安全的 Docker 容器中。链码的初始化和账本状态的管理通过应用提交的交易来实现。

A chaincode typically handles business logic agreed to by members of the
network, so it similar to a "smart contract". A chaincode can be invoked to update or query
the ledger in a proposal transaction. Given the appropriate permission, a chaincode
may invoke another chaincode, either in the same channel or in different channels, to access its state.
Note that, if the called chaincode is on a different channel from the calling chaincode,
only read query is allowed. That is, the called chaincode on a different channel is only a ``Query``,
which does not participate in state validation checks in subsequent commit phase.

链码一般处理网络中的成员一致认可的商业逻辑，所以它类似与“智能合约”。链码在交易提案中被调
用来升级或者查询账本。赋予适当的权限，链码就可以调用其他链码来访问它的状态，不管是在同一
个通道还是不同的通道。注意，如果被调用的链码和当前链码在不同的通道，就只能执行只读的查询。
就是说，调用不同通道的链码只能进行“查询”，在提交的子语句中不能参与状态的合法性检查。

In the following sections, we will explore chaincode through the eyes of an
application developer. We'll present a simple chaincode sample application
and walk through the purpose of each method in the Chaincode Shim API.

在下边的章节中，我们站在应用开发者的角度来介绍链码。我们将演示一个简单的链码应用，并且逐个
查看链码 Shim API 中每一个方法的作用。

Chaincode API - 链码 API
-------------

Every chaincode program must implement the ``Chaincode`` interface:

每个链码程序必须实现 ``Chaincode`` 接口：

  - `Go <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#Chaincode>`__
  - `node.js <https://fabric-shim.github.io/ChaincodeInterface.html>`__
  - `Java <https://fabric-chaincode-java.github.io/org/hyperledger/fabric/shim/Chaincode.html>`_

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

链码 “shim” API 中的其他接口是 ``ChaincodeStubInterface`` ：

  - `Go <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStubInterface>`__
  - `node.js <https://fabric-shim.github.io/ChaincodeStub.html>`__
  - `Java <https://fabric-chaincode-java.github.io/org/hyperledger/fabric/shim/ChaincodeStub.html>`_

which is used to access and modify the ledger, and to make invocations between
chaincodes.

用来访问和修改账本，并且可以调用链码。

In this tutorial using Go chaincode, we will demonstrate the use of these APIs
by implementing a simple chaincode application that manages simple "assets".

在本教程中使用 Go 链码，我们将通过实现一个管理简单“资产”的示例链码应用来演示如何使用这些 API 。

.. _Simple Asset Chaincode:

Simple Asset Chaincode - 简单资产链码
----------------------
Our application is a basic sample chaincode to create assets
(key-value pairs) on the ledger.

我们的应用程序是一个基本的示例链码，用来在账本上创建资产（键-值对）。

Choosing a Location for the Code - 选择一个位置存放代码
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you haven't been doing programming in Go, you may want to make sure that
you have :ref:`Golang` installed and your system properly configured.

如果你没有写过 Go 的程序，你可能需要确认一下你是否安装了 :ref:`Golang` 并且你的系统上的配
置是否合适。

Now, you will want to create a directory for your chaincode application as a
child directory of ``$GOPATH/src/``.

现在你需要在 ``$GOPATH/src/`` 子目录为你的链码应用程序创建一个目录。

To keep things simple, let's use the following command:

简单起见，我们使用如下命令：

.. code:: bash

  mkdir -p $GOPATH/src/sacc && cd $GOPATH/src/sacc

Now, let's create the source file that we'll fill in with code:

现在，我们创建一个用于编写代码的源文件：

.. code:: bash

  touch sacc.go

Housekeeping - 家务
^^^^^^^^^^^^

First, let's start with some housekeeping. As with every chaincode, it implements the
`Chaincode interface <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#Chaincode>`_
in particular, ``Init`` and ``Invoke`` functions. So, let's add the Go import
statements for the necessary dependencies for our chaincode. We'll import the
chaincode shim package and the
`peer protobuf package <https://godoc.org/github.com/hyperledger/fabric/protos/peer>`_.
Next, let's add a struct ``SimpleAsset`` as a receiver for Chaincode shim functions.

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

Initializing the Chaincode - 初始化链码
^^^^^^^^^^^^^^^^^^^^^^^^^^

Next, we'll implement the ``Init`` function.

然后，我们将实现 ``Init`` 方法。

.. code:: go

  // Init is called during chaincode instantiation to initialize any data.
  func (t *SimpleAsset) Init(stub shim.ChaincodeStubInterface) peer.Response {

  }

.. note:: Note that chaincode upgrade also calls this function. When writing a
          chaincode that will upgrade an existing one, make sure to modify the ``Init``
          function appropriately. In particular, provide an empty "Init" method if there's
          no "migration" or nothing to be initialized as part of the upgrade.

.. note:: 注意，链码升级的时候也要条用这个方法。当写用来升级一个已存在的链码的时候，
          请确保合理更改 ``Init`` 方法。特别地，当没有“迁移”或者初始化不是升级的一部
          分时，可以提供一个空的 ``Init`` 方法。

Next, we'll retrieve the arguments to the ``Init`` call using the
`ChaincodeStubInterface.GetStringArgs <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.GetStringArgs>`_
function and check for validity. In our case, we are expecting a key-value pair.

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

Next, now that we have established that the call is valid, we'll store the
initial state in the ledger. To do this, we will call
`ChaincodeStubInterface.PutState <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.PutState>`_
with the key and value passed in as the arguments. Assuming all went well,
return a peer.Response object that indicates the initialization was a success.

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

Invoking the Chaincode - 调用链码
^^^^^^^^^^^^^^^^^^^^^^

First, let's add the ``Invoke`` function's signature.

首先，我们增加一个 ``Invoke`` 函数的签名。

.. code:: go

    // Invoke is called per transaction on the chaincode. Each transaction is
    // either a 'get' or a 'set' on the asset created by Init function. The 'set'
    // method may create a new asset by specifying a new key-value pair.
    func (t *SimpleAsset) Invoke(stub shim.ChaincodeStubInterface) peer.Response {

    }

As with the ``Init`` function above, we need to extract the arguments from the
``ChaincodeStubInterface``. The ``Invoke`` function's arguments will be the
name of the chaincode application function to invoke. In our case, our application
will simply have two functions: ``set`` and ``get``, that allow the value of an
asset to be set or its current state to be retrieved. We first call
`ChaincodeStubInterface.GetFunctionAndParameters <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.GetFunctionAndParameters>`_
to extract the function name and the parameters to that chaincode application
function.

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

Next, we'll validate the function name as being either ``set`` or ``get``, and
invoke those chaincode application functions, returning an appropriate
response via the ``shim.Success`` or ``shim.Error`` functions that will
serialize the response into a gRPC protobuf message.

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

Implementing the Chaincode Application - 实现链码应用程序
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

As noted, our chaincode application implements two functions that can be
invoked via the ``Invoke`` function. Let's implement those functions now.
Note that as we mentioned above, to access the ledger's state, we will leverage
the `ChaincodeStubInterface.PutState <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.PutState>`_
and `ChaincodeStubInterface.GetState <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.GetState>`_
functions of the chaincode shim API.

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

Pulling it All Together - 把它们组合在一起
^^^^^^^^^^^^^^^^^^^^^^^

Finally, we need to add the ``main`` function, which will call the
`shim.Start <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#Start>`_
function. Here's the whole chaincode program source.

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

Building Chaincode - 编译链码
^^^^^^^^^^^^^^^^^^

Now let's compile your chaincode.

现在我们编译你的链码。

.. code:: bash

  go get -u github.com/hyperledger/fabric/core/chaincode/shim
  go build

Assuming there are no errors, now we can proceed to the next step, testing
your chaincode.

假设没有错误，现在你可以进行下一步操作，测试你的链码。

Testing Using dev mode - 使用开发模式测试 
^^^^^^^^^^^^^^^^^^^^^^

Normally chaincodes are started and maintained by peer. However in “dev
mode", chaincode is built and started by the user. This mode is useful
during chaincode development phase for rapid code/build/run/debug cycle
turnaround.

一般链码是通过节点执行和维护的。然而在“开发模式”下，链码通过用户编译和执
行。这个模式在链码“编码/编译/运行/调试”的开发生命周期中很有用。

We start "dev mode" by leveraging pre-generated orderer and channel artifacts for
a sample dev network.  As such, the user can immediately jump into the process
of compiling chaincode and driving calls.

我们通过一个示例开发网络预先生成的排序和通道构件来启动“开发模式”。这样用户
就可以快速的进入编译链码和调用的过程。

Install Hyperledger Fabric Samples - 安装 Hyperledger Fabric 示例
----------------------------------

If you haven't already done so, please :doc:`install`.

如果你还没有完成这些，请参考 :doc:`install` 。

Navigate to the ``chaincode-docker-devmode`` directory of the ``fabric-samples``
clone:

克隆如下命令导航至 ``fabric-samples`` 目录下的 ``chaincode-docker-devmode`` ：

.. code:: bash

  cd chaincode-docker-devmode

Now open three terminals and navigate to your ``chaincode-docker-devmode``
directory in each.

现在打开三个终端，并且每个终端都导航至 ``chaincode-docker-devmode`` 目录。

Terminal 1 - Start the network - 终端1 - 启动网络
------------------------------

.. code:: bash

    docker-compose -f docker-compose-simple.yaml up

The above starts the network with the ``SingleSampleMSPSolo`` orderer profile and
launches the peer in "dev mode".  It also launches two additional containers -
one for the chaincode environment and a CLI to interact with the chaincode.  The
commands for create and join channel are embedded in the CLI container, so we
can jump immediately to the chaincode calls.

上边的命令启动了一个网络，网络的排序模式为 ``SingleSampleMSPSolo`` ，并且以“开发模式”
启动了 peer 节点。它还启动了另外两个容器 - 一个是链码环境，另一个是和链码交互的 CLI。
创建和加入通道的命令在 CLI 容器中，所以我们直接跳入了链码调用。

Terminal 2 - Build & start the chaincode - 终端2 - 编译并启动链码
----------------------------------------

.. code:: bash

  docker exec -it chaincode bash

You should see the following:

你应该看到如下内容：

.. code:: bash

  root@d2629980e76b:/opt/gopath/src/chaincode#

Now, compile your chaincode:

现在，编译你的链码：

.. code:: bash

  cd sacc
  go build

Now run the chaincode:

现在运行链码：

.. code:: bash

  CORE_PEER_ADDRESS=peer:7052 CORE_CHAINCODE_ID_NAME=mycc:0 ./sacc

The chaincode is started with peer and chaincode logs indicating successful registration with the peer.
Note that at this stage the chaincode is not associated with any channel. This is done in subsequent steps
using the ``instantiate`` command.

链码从 peer 节点启动并且日志表示链码成功注册到了 peer 节点上。注意，在这个阶段链码
没有关联任何通道。这个过程通过 ``instantiate`` 命令的之后的步骤完成。

Terminal 3 - Use the chaincode - 终端3 - 使用链码
------------------------------

Even though you are in ``--peer-chaincodedev`` mode, you still have to install the
chaincode so the life-cycle system chaincode can go through its checks normally.
This requirement may be removed in future when in ``--peer-chaincodedev`` mode.

即使你在 ``--peer-chaincodedev`` 模式下，你仍然需要安装链码，这样链码才能正常地通生
命周期系统链码的检查。这个需求能会在未来的版本中移除。

We'll leverage the CLI container to drive these calls.

我们将进入 CLI 容器来执行这些调用。

.. code:: bash

  docker exec -it cli bash

.. code:: bash

  peer chaincode install -p chaincodedev/chaincode/sacc -n mycc -v 0
  peer chaincode instantiate -n mycc -v 0 -c '{"Args":["a","10"]}' -C myc

Now issue an invoke to change the value of "a" to "20".

现在执行一个调用来将 “a” 的值改为 20 。

.. code:: bash

  peer chaincode invoke -n mycc -c '{"Args":["set", "a", "20"]}' -C myc

Finally, query ``a``.  We should see a value of ``20``.

最后，查询 ``a`` 。我们将看到一个为 ``20`` 的值。

.. code:: bash

  peer chaincode query -n mycc -c '{"Args":["query","a"]}' -C myc

Testing new chaincode - 测试新链码
---------------------

By default, we mount only ``sacc``.  However, you can easily test different
chaincodes by adding them to the ``chaincode`` subdirectory and relaunching
your network.  At this point they will be accessible in your ``chaincode`` container.

默认地，我们只挂载 ``sacc`` 。然而，你可以很容易地通过将他们加入 ``chaincode`` 子目录
并重启你的网络来测试不同的链码。这时，它们在你的 ``chaincode`` 容器中是可访问的。

Chaincode access control - 链码访问控制
------------------------

Chaincode can utilize the client (submitter) certificate for access
control decisions by calling the GetCreator() function. Additionally
the Go shim provides extension APIs that extract client identity
from the submitter's certificate that can be used for access control decisions,
whether that is based on client identity itself, or the org identity,
or on a client identity attribute.

链码可以通过调用 getCreator() 函数来使用客户端（提交者）证书进行访问控制决策。另外， 
Go shim 提供了扩展 API ，用于从提交者的证书中提取客户端标识，该证书可用于访问控制决
策，无论是基于客户端标识本身，还是基于组织标识，还是基于客户端标识属性。

For example an asset that is represented as a key/value may include the
client's identity as part of the value (for example as a JSON attribute
indicating that asset owner), and only this client may be authorized
to make updates to the key/value in the future. The client identity
library extension APIs can be used within chaincode to retrieve this
submitter information to make such access control decisions.

例如，

See the `client identity (CID) library documentation <https://github.com/hyperledger/fabric/blob/master/core/chaincode/shim/ext/cid/README.md>`_
for more details.

To add the client identity shim extension to your chaincode as a dependency, see :ref:`vendoring`.

Chaincode encryption
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

For more information and samples, see the
`Encc Example <https://github.com/hyperledger/fabric/tree/master/examples/chaincode/go/enccc_example>`__
within the ``fabric/examples`` directory.  Pay specific attention to the ``utils.go``
helper program.  This utility loads the chaincode shim APIs and Entities extension
and builds a new class of functions (e.g. ``encryptAndPutState`` & ``getStateAndDecrypt``)
that the sample encryption chaincode then leverages.  As such, the chaincode can
now marry the basic shim APIs of ``Get`` and ``Put`` with the added functionality of
``Encrypt`` and ``Decrypt``.

To add the encryption entities extension to your chaincode as a dependency, see :ref:`vendoring`.

.. _vendoring:

Managing external dependencies for chaincode written in Go
----------------------------------------------------------
If your chaincode requires packages not provided by the Go standard library,
you will need to include those packages with your chaincode. It is also a
good practice to add the shim and any extension libraries to your chaincode
as a dependency.

There are `many tools available <https://github.com/golang/go/wiki/PackageManagementTools>`__
for managing (or "vendoring") these dependencies.  The following demonstrates how to use
``govendor``:

.. code:: bash

  govendor init
  govendor add +external  // Add all external package, or
  govendor add github.com/external/pkg // Add specific external package

This imports the external dependencies into a local ``vendor`` directory.
If you are vendoring the Fabric shim or shim extensions, clone the
Fabric repository to your $GOPATH/src/github.com/hyperledger directory,
before executing the govendor commands.

Once dependencies are vendored in your chaincode directory, ``peer chaincode package``
and ``peer chaincode install`` operations will then include code associated with the
dependencies into the chaincode package.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
