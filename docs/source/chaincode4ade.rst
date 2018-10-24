# Chaincode for Developers -面向开发人员的链码指南

## What is Chaincode?-什么是链码？

Chaincode is a program, written in [Go](https://golang.org/), [node.js](https://nodejs.org/), that implements a prescribed interface. Eventually, other programming languages such as Java, will be supported. Chaincode runs in a secured Docker container isolated from the endorsing peer process. Chaincode initializes and manages the ledger state through transactions submitted by applications.

链码是一段程序，用`Go <https://golang.org>`_, `node.js <https://nodejs.org>`_实现特定的接口，后续也将会支持其他的编程语言例如Java。 链码运行在一个安全的Docker容器中独立于背书节点。 通过app提交交易, 链码可以初始化和管理ledger state(账本状态)。

A chaincode typically handles business logic agreed to by members of the network, so it similar to a "smart contract". A chaincode can be invoked to update or query the ledger in a proposal transaction. Given the appropriate permission, a chaincode may invoke another chaincode, either in the same channel or in different channels, to access its state. Note that, if the called chaincode is on a different channel from the calling chaincode, only read query is allowed. That is, the called chaincode on a different channel is only a Query, which does not participate in state validation checks in subsequent commit phase.

链码通常处理网络中的成员认可的业务逻辑,所以它可以被视为一种”智能合约”。 在交易提案中可以通过调用链码的方式来更新或者查询账本。 给定链码相应的权限，该链码可以调用另一个链码来访问其账本状态，不论被调用的链码是否在同一个通道中。 请注意，如果被调用的链码和调用链码不在同一个通道内，那该调用处理里只有读操作是有效的。 这意味着，调用不同通道上的链码仅仅只是”`查询`”操作，在后续的验证阶段并不会将这部分调用加入世界状态有效性检查中。

In the following sections, we will explore chaincode through the eyes of an application developer. We'll present a simple chaincode sample application and walk through the purpose of each method in the Chaincode Shim API.

在后续的章节中，我们将会从开发者的视角去探索链码。 我们将会介绍一个简单的链码例子，并逐一解释链码Shim API中的每个方法。



## Chaincode API-链码API

Every chaincode program must implement the `Chaincode interface`:

每个链码必须实现 ``链码接口``,：

> - [Go](https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#Chaincode)
> - [node.js](https://fabric-shim.github.io/ChaincodeInterface.html)

whose methods are called in response to received transactions. In particular the `Init` method is called when a chaincode receives an `instantiate` or `upgrade` transaction so that the chaincode may perform any necessary initialization, including initialization of application state. The `Invoke` method is called in response to receiving an `invoke` transaction to process transaction proposals.

这些接口的方法在去响应收到的交易时被调用。特别是当链代码接收到``instantiate``或``upgrade``事务时调用``Init``方法，以便链代码可以执行任何必要的初始化，包括应用程序状态的初始化。 ``Invoke`` 方法被调用以响应接收``invoke``交易，去处理交易提案。

The other interface in the chaincode "shim" APIs is the `ChaincodeStubInterface`:

另一个在链码的  "shim" APIs中，用来访问个修改账本，以及在链码间调用的接口是 ``ChaincodeStubInterface``:

> - [Go](https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStubInterface)
> - [node.js](https://fabric-shim.github.io/ChaincodeStub.html)

which is used to access and modify the ledger, and to make invocations between chaincodes.

In this tutorial, we will demonstrate the use of these APIs by implementing a simple chaincode application that manages simple "assets".

在本教程中，我们将通过实现管理简单“资产”的简单链代码应用程序来演示这些API的使用。



## Simple Asset Chaincode-简单资产链码

Our application is a basic sample chaincode to create assets (key-value pairs) on the ledger.

我们的应用基于一个在账本上创建资产（键值对）的简单链码。



### Choosing a Location for the Code-选择代码的位置

If you haven't been doing programming in Go, you may want to make sure that you have [:ref:`Golang`](https://github.com/figo050518/fabric-docs-cn/blob/1.2.0_zh-CN/docs/source/chaincode4ade.rst#id2) installed and your system properly configured.

如果你还没有用GO写过程序，你需要确认一下你是否安装了 [:ref:`Golang`](https://github.com/figo050518/fabric-docs-cn/blob/1.2.0_zh-CN/docs/source/chaincode4ade.rst#id2) 并且配置好了。

Now, you will want to create a directory for your chaincode application as a child directory of `$GOPATH/src/`.

现在你将在`$GOPATH/src/`的子目录中为你的链码程序创建一个文件夹。

To keep things simple, let's use the following command:

把它当成一个简单的事情，我们来运行下面命令：

```
mkdir -p $GOPATH/src/sacc && cd $GOPATH/src/sacc
```

Now, let's create the source file that we'll fill in with code:

现在让我们创建一个我们将写入代码的源文件。

```
touch sacc.go
```





### Housekeeping-一些琐碎

First, let's start with some housekeeping. As with every chaincode, it implements the [Chaincode interface](https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#Chaincode) in particular, `Init`and `Invoke` functions. So, let's add the go import statements for the necessary dependencies for our chaincode. We'll import the chaincode shim package and the [peer protobuf package](https://godoc.org/github.com/hyperledger/fabric/protos/peer). Next, let's add a struct `SimpleAsset` as a receiver for Chaincode shim functions.

现在让我们从一些琐碎的事情开始。对每一个链码来说，都需要实现[Chaincode interface](https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#Chaincode)，特别是`Init`和 `Invoke`方法。所以，让我们为我们的链码导入必要的GO依赖。我们将导入链码shim包和 [peer protobuf package](https://godoc.org/github.com/hyperledger/fabric/protos/peer). 接下来，让我们新增一个struct `SimpleAsset`  作为链码shim函数的接受者。

```
package main

import (
    "fmt"
    "github.com/hyperledger/fabric/core/chaincode/shim"
    "github.com/hyperledger/fabric/protos/peer"
)

// SimpleAsset implements a simple chaincode to manage an asset
type SimpleAsset struct {
}
```



### Initializing the Chaincode-初始化链码

Next, we'll implement the `Init` function.

接下来，我们将会实现 `Init` 方法。

```
// Init is called during chaincode instantiation to initialize any data.
func (t *SimpleAsset) Init(stub shim.ChaincodeStubInterface) peer.Response {

}
```

Note

Note that chaincode upgrade also calls this function. When writing a chaincode that will upgrade an existing one, make sure to modify the `Init` function appropriately. In particular, provide an empty "Init" method if there's no "migration" or nothing to be initialized as part of the upgrade.

注意：注意链码升级也是调用的这个方法。在编写将升级现有链码的代码时，请确保适当地修改`Init`函数。特别是如果没有“迁移”或者在升级过程中没有要初始化的话，请提供一个空的“Init”方法。

Next, we'll retrieve the arguments to the `Init` call using the [ChaincodeStubInterface.GetStringArgs](https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.GetStringArgs) function and check for validity. In our case, we are expecting a key-value pair.

接下来，我们将使用[ChaincodeStubInterface.GetStringArgs](https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.GetStringArgs) 函数检索`Init`调用的参数， 检查有效性。 在我们的例子中，我们期待一个键值对。

> ```
> // Init is called during chaincode instantiation to initialize any
> // data. Note that chaincode upgrade also calls this function to reset
> // or to migrate data, so be careful to avoid a scenario where you
> // inadvertently clobber your ledger's data!
> func (t *SimpleAsset) Init(stub shim.ChaincodeStubInterface) peer.Response {
>   // Get the args from the transaction proposal
>   args := stub.GetStringArgs()
>   if len(args) != 2 {
>     return shim.Error("Incorrect arguments. Expecting a key and a value")
>   }
> }
> ```

Next, now that we have established that the call is valid, we'll store the initial state in the ledger. To do this, we will call[ChaincodeStubInterface.PutState](https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.PutState) with the key and value passed in as the arguments. Assuming all went well, return a peer.Response object that indicates the initialization was a success.

接下来，既然我们已经确定调用有效，我们将把初始状态存储在账本中。 为此，我们将用参数传入的键和值调用[ChaincodeStubInterface.PutState](https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.PutState) 。 假设一切顺利，返回一个peer.Response对象，表明初始化成功。

```
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
```



### Invoking the Chaincode-调用链码

First, let's add the `Invoke` function's signature.

首先，让我们添加`Invoke` 函数的签名。

```
// Invoke is called per transaction on the chaincode. Each transaction is
// either a 'get' or a 'set' on the asset created by Init function. The 'set'
// method may create a new asset by specifying a new key-value pair.
func (t *SimpleAsset) Invoke(stub shim.ChaincodeStubInterface) peer.Response {

}
```

As with the `Init` function above, we need to extract the arguments from the `ChaincodeStubInterface`. The `Invoke`function's arguments will be the name of the chaincode application function to invoke. In our case, our application will simply have two functions: `set` and `get`, that allow the value of an asset to be set or its current state to be retrieved. We first call[ChaincodeStubInterface.GetFunctionAndParameters](https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.GetFunctionAndParameters) to extract the function name and the parameters to that chaincode application function.

与上面的`Init`函数一样，我们需要从`ChaincodeStubInterface`中提取参数。 `Invoke` 函数的参数将是要调用的链码应用程序函数的名称。 在我们的例子中，我们的应用程序将只有两个函数：`set`和`get`，它们允许设置资产的值或检索其当前状态。 我们首先调用[ChaincodeStubInterface.GetFunctionAndParameters](https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.GetFunctionAndParameters)来为该链代码应用程序函数提取函数名称和参数。



```
// Invoke is called per transaction on the chaincode. Each transaction is
// either a 'get' or a 'set' on the asset created by Init function. The Set
// method may create a new asset by specifying a new key-value pair.
func (t *SimpleAsset) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
    // Extract the function and args from the transaction proposal
    fn, args := stub.GetFunctionAndParameters()

}
```

Next, we'll validate the function name as being either `set` or `get`, and invoke those chaincode application functions, returning an appropriate response via the `shim.Success` or `shim.Error` functions that will serialize the response into a gRPC protobuf message.

接下来，我们将验证函数名称为`set`或`get`，并调用这些链码对应应用程序函数，通过`shim.Success`或`shim.Error`函数返回适当的响应，这些函数将序列化响应 进入gRPC 二进制消息。

```
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
```





### Implementing the Chaincode Application-实现链码应用程序

As noted, our chaincode application implements two functions that can be invoked via the `Invoke` function. Let's implement those functions now. Note that as we mentioned above, to access the ledger's state, we will leverage the [ChaincodeStubInterface.PutState](https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.PutState) and [ChaincodeStubInterface.GetState](https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.GetState) functions of the chaincode shim API.

如上所述，我们的链代码应用程序实现了两个可以通过`Invoke`函数调用的函数。 我们现在实现这些功能。 请注意，正如我们上面提到的，为了访问账本的状态，我们将利用shim API的  [ChaincodeStubInterface.PutState](https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.PutState) 和 [ChaincodeStubInterface.GetState](https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub.GetState) 函数。

```
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
```





### Pulling it All Together-整合到一起

Finally, we need to add the `main` function, which will call the [shim.Start](https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#Start) function. Here's the whole chaincode program source.

最后，我们需要添加`main`函数，它将调用[shim.Start](https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#Start) 函数。 这是整个链码程序源。

```
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
```





### Building Chaincode-编译链码

Now let's compile your chaincode.

现在让我们编译链码：

```
go get -u github.com/hyperledger/fabric/core/chaincode/shim
go build
```

Assuming there are no errors, now we can proceed to the next step, testing your chaincode.

假设没有错误，现在我们可以继续下一步，测试您的链码。



### Testing Using dev mode-用开发模式测试

Normally chaincodes are started and maintained by peer. However in “dev mode", chaincode is built and started by the user. This mode is useful during chaincode development phase for rapid code/build/run/debug cycle turnaround.

通常，链路由peer启动和维护。 然而，在“开发模式”中，链代码由用户构建和启动。在链码开发阶段，此模式非常有用，可用于快速写代码/构建/运行/调试的周期周转。

We start "dev mode" by leveraging pre-generated orderer and channel artifacts for a sample dev network. As such, the user can immediately jump into the process of compiling chaincode and driving calls.

我们通过为示例开发网络利用预先生成的peer和通道构件来启动“开发模式”。 这样，用户可以立即进入编译链码和调用的过程。





## Install Hyperledger Fabric Samples-安装Hyperledger Fabric示例

If you haven't already done so, please [:doc:`install`](https://github.com/figo050518/fabric-docs-cn/blob/1.2.0_zh-CN/docs/source/chaincode4ade.rst#id5).

如果你还没有安装，请看 [:doc:`install`](https://github.com/figo050518/fabric-docs-cn/blob/1.2.0_zh-CN/docs/source/chaincode4ade.rst#id5)

Navigate to the `chaincode-docker-devmode` directory of the `fabric-samples` clone:

跳转到`fabric-samples`克隆的`chaincode-docker-devmode`目录：

```
cd chaincode-docker-devmode
```

Now open three terminals and navigate to your `chaincode-docker-devmode` directory in each.

现在打开三个终端并跳转到每个终端的`chaincode-docker-devmode`目录。



## Terminal 1 - Start the network-终端1-启动网络

```
docker-compose -f docker-compose-simple.yaml up
```

The above starts the network with the `SingleSampleMSPSolo` orderer profile and launches the peer in "dev mode". It also launches two additional containers - one for the chaincode environment and a CLI to interact with the chaincode. The commands for create and join channel are embedded in the CLI container, so we can jump immediately to the chaincode calls.

以上内容使用`SingleSampleMSPSolo`orderer配置文件启动网络，并以“开发模式”启动peer。 它还启动了两个额外的容器 - 一个用于链码环境，另一个用于与链代码交互。 创建和加入通道的命令嵌入在CLI容器中，因此我们可以立即跳转到链代码调用。



## Terminal 2 - Build & start the chaincode -终端2-编译和运行链码

```
docker exec -it chaincode bash
```

You should see the following:

你会看到下面的内容：

```
root@d2629980e76b:/opt/gopath/src/chaincode#
```

Now, compile your chaincode:

现在编译链码：

```
cd sacc
go build
```

Now run the chaincode:

现在运行链码：

```
CORE_PEER_ADDRESS=peer:7052 CORE_CHAINCODE_ID_NAME=mycc:0 ./sacc
```

The chaincode is started with peer and chaincode logs indicating successful registration with the peer. Note that at this stage the chaincode is not associated with any channel. This is done in subsequent steps using the `instantiate` command.

链代码以peer和链码日志开始，表示向peer成功注册。 请注意，在此阶段，链码不与任何通道相关联。 这是使用`instantiate`命令在后续步骤中完成的。



## Terminal 3 - Use the chaincode - 终端3-使用链码

Even though you are in `--peer-chaincodedev` mode, you still have to install the chaincode so the life-cycle system chaincode can go through its checks normally. This requirement may be removed in future when in `--peer-chaincodedev` mode.

即使您处于`--peer-chaincodedev`模式，您仍然需要安装链码，以便生命周期系统链码可以正常进行检查。 在`--peer-chaincodedev`模式下，将来可能会删除此要求。

We'll leverage the CLI container to drive these calls.

我们将利用CLI容器来开始这些调用。

```
docker exec -it cli bash
peer chaincode install -p chaincodedev/chaincode/sacc -n mycc -v 0
peer chaincode instantiate -n mycc -v 0 -c '{"Args":["a","10"]}' -C myc
```

Now issue an invoke to change the value of "a" to "20".

现在发出一个调用，将“a”的值更改为“20”。

```
peer chaincode invoke -n mycc -c '{"Args":["set", "a", "20"]}' -C myc
```

Finally, query `a`. We should see a value of `20`.

最后，查询`a`。 我们应该看到“20”的值。

```
peer chaincode query -n mycc -c '{"Args":["query","a"]}' -C myc
```





## Testing new chaincode-测试新的链码

By default, we mount only `sacc`. However, you can easily test different chaincodes by adding them to the `chaincode`subdirectory and relaunching your network. At this point they will be accessible in your `chaincode` container.

默认情况下，我们只挂载`sacc`。 但是，您可以通过将它们添加到`chaincode`子目录并重新启动网络来轻松测试不同的链代码。 此时，它们将在您的`chaincode`容器中访问。



## Chaincode encryption-链码加密

In certain scenarios, it may be useful to encrypt values associated with a key in their entirety or simply in part. For example, if a person's social security number or address was being written to the ledger, then you likely would not want this data to appear in plaintext. Chaincode encryption is achieved by leveraging the [entities extension](https://github.com/hyperledger/fabric/tree/master/core/chaincode/shim/ext/entities) which is a BCCSP wrapper with commodity factories and functions to perform cryptographic operations such as encryption and elliptic curve digital signatures. For example, to encrypt, the invoker of a chaincode passes in a cryptographic key via the transient field. The same key may then be used for subsequent query operations, allowing for proper decryption of the encrypted state values.

在某些情况下，完全或仅部分地加密与密钥相关联的值可能是有用的。 例如，如果某人的社会安全号码或地址被写入帐本，那么您可能不希望此数据以明文形式出现。 Chaincode加密是通过利用[entities extension](https://github.com/hyperledger/fabric/tree/master/core/chaincode/shim/ext/entities)实现的，这是一个BCCSP包装器，具有大量构造器和方法来执行加密操作，如加密和椭圆曲线数字签名。 例如，为了加密，链码的调用者通过transient 字段传递加密密钥。 然后可以将相同的密钥用于后续查询操作，从而允许对加密状态值进行适当的解密。

For more information and samples, see the [Encc Example](https://github.com/hyperledger/fabric/tree/master/examples/chaincode/go/enccc_example) within the `fabric/examples` directory. Pay specific attention to the `utils.go` helper program. This utility loads the chaincode shim APIs and Entities extension and builds a new class of functions (e.g. `encryptAndPutState` & `getStateAndDecrypt`) that the sample encryption chaincode then leverages. As such, the chaincode can now marry the basic shim APIs of `Get` and `Put` with the added functionality of `Encrypt` and `Decrypt`.

有关更多信息和示例，请参阅`fabric / examples`目录中的 [Encc Example](https://github.com/hyperledger/fabric/tree/master/examples/chaincode/go/enccc_example)。 特别注意`utils.go`帮助程序。 该实用程序加载链码shimAPI和实体插件，并构建一个新的函数类（例如`encryptAndPutState`和`getStateAndDecrypt`），然后样本加密链代码将利用它。 因此，链码现在可以将“Get”和“Put”的基本shim API与“Encrypt”和“Decrypt”的附加功能相结合。





## Managing external dependencies for chaincode written in Go - 管理用Go编写的链码的外部依赖关系

If your chaincode requires packages not provided by the Go standard library, you will need to include those packages with your chaincode. There are [many tools available](https://github.com/golang/go/wiki/PackageManagementTools) for managing (or "vendoring") these dependencies. The following demonstrates how to use `govendor`:

如果您的链代码需要Go标准库未提供的包，则需要将这些包与您的链码一起包含在内。 有 [many tools available](https://github.com/golang/go/wiki/PackageManagementTools) 用于管理（或“销售”）这些依赖项。 以下演示了如何使用`govendor`：

```
govendor init
govendor add +external  // Add all external package, or
govendor add github.com/external/pkg // Add specific external package
```

This imports the external dependencies into a local `vendor` directory. `peer chaincode package` and `peer chaincode install`operations will then include code associated with the dependencies into the chaincode package.

这会将外部依赖项导入到本地`vendor`目录中。 然后，`peer chaincode package`和`peer chaincode install`操作将包含与chaincode包中的依赖关联的代码。