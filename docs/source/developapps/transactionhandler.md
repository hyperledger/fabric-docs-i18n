# Transaction handlers - 交易处理器

**Audience**: Architects, Application and smart contract developers

**受众**：架构师，应用和智能合约开发者

Transaction handlers allow smart contract developers to define common processing
at key points during the interaction between an application and a smart
contract. Transaction handlers are optional but, if defined, they will receive
control before or after every transaction in a smart contract is invoked. There
is also a specific handler which receives control when a request is made to
invoke a transaction not defined in a smart contract.

交易处理器允许智能合约开发人员在应用程序和智能合约交互期间的关键点上定义通用处理。交易
处理器是可选的，但是如果定义了，它们将在调用智能合约中的每个交易之前或之后接收控制权。
还有一个特定的处理器，当请求调用未在智能合约中定义的交易时，该处理程序接收控制。

Here's an example of transaction handlers for the [commercial paper smart
contract sample](./smartcontract.html):

这里是一个[商业票据智能合约样例](./smartcontract.html)的交易处理器例子：

![develop.transactionhandler](./develop.diagram.2.png)

*Before, After and Unknown transaction handlers. In this example,
`BeforeFunction()` is called before the **issue**, **buy** and **redeem**
transactions. `AfterFunction()` is called after the **issue**, **buy** and
**redeem** transactions. `UnknownFunction()` is only called if a request is made
to invoke a transaction not defined in the smart contract.  (The diagram is
simplified by not repeating `BeforeFunction` and `AfterFunction` boxes for each
transaction.*

*前置、后置和未知交易处理器。在这个例子中，`BeforeFunction()` 在 **issue**, **buy** 和 **redeem**
交易之前被调用。`AfterFunction()` 在 **issue**, **buy** 和 **redeem**交易之后调用。`UnknownFunction()`
当请求调用未在智能合约中定义的交易时调用。（通过不为每个交易重复 `BeforeFunction` 和 `AfterFunction` 框来简化该图）*

## Types of handler  处理器类型

There are three types of transaction handlers which cover different aspects
of the interaction between an application and a smart contract:

有三种类型的交易处理器，它们涵盖应用程序和智能合约之间交互的不同方面：

  * **Before handler**: is called before every smart contract transaction is
    invoked. The handler will usually modify the transaction context to be used
    by the transaction. The handler has access to the full range of Fabric APIs;
    for example, it can issue `getState()` and `putState()`.

    **前置处理器**：在每个智能合约交易执行之前调用。该处理器通常用来改变交易使用的交易上下文。
    处理器可以访问所有 Fabric API；如，可以使用 `getState()` 和 `putState()`。


  * **After handler**: is called after every smart contract transaction is
    invoked. The handler will usually perform post-processing common to all
    transactions, and also has full access to the Fabric APIs.

    **后置处理器**：在每个智能合约交易执行之后调用。处理器通常会对所有的交易执行通用的后置
    处理，同样可以访问所有的 Fabric API。


  * **Unknown handler**: is called if an attempt is made to invoke a transaction
    that is not defined in a smart contract. Typically, the handler will record
    the failure for subsequent processing by an administrator. The handler has
    full access to the Fabric APIs.

    **未知处理器**：试图执行未在智能合约中定义的交易时被调用。通常，处理器将记录管理员
    后续处理的失败。处理器可以访问所有的 Fabric API。


## Defining a handler  定义处理器

Transaction handlers are added to the smart contract as methods with well
defined names.  Here's an example which adds a handler of each type:

交易处理器作为具有明确定义名称的方法添加到智能合约中。这是一个添加每种类型的处理器的示例：

```JavaScript
CommercialPaperContract extends Contract {

    ...

    async beforeTransaction(ctx) {
        // Write the transaction ID as an informational to the console
        console.info(ctx.stub.getTxID());
    };

    async afterTransaction(ctx, result) {
        // This handler interacts with the ledger
        ctx.stub.cpList.putState(...);
    };

    async unknownTransaction(ctx) {
        // This handler throws an exception
        throw new Error('Unknown transaction function');
    };

}
```

The form of a transaction handler definition is the similar for all handler
types, but notice how the `afterTransaction(ctx, result)` also receives any
result returned by the transaction.

交易处理器定义的形式对于所有处理程序类型都是类似的，但请注意 `afterTransaction(ctx，result)` 
如何接收交易返回的任何结果。

## Handler processing  处理器处理

Once a handler has been added to the smart contract, it can be invoked during
transaction processing. During processing, the handler receives `ctx`, the
[transaction context](./transationcontext.md), performs some processing, and
returns control as it completes. Processing continues as follows:

一旦处理器添加到智能合约中，它可以在交易处理期间调用。在处理期间，处理器接收 `ctx`，
[交易上下文](./transationcontext.md)执行一些处理，完成后返回控制权。继续如下的处理：

* **Before handler**: If the handler completes successfully, the transaction is
  called with the updated context. If the handler throws an exception, then the
  transaction is not called and the smart contract fails with the exception
  error message.

  **前置处理器**：如果处理器成功完成，使用更新后的上下文调用交易。如果处理器抛出异常，
  不会调用交易，智能合约失败并显示异常错误消息。


* **After handler**: If the handler completes successfully, then the smart
  contract completes as determined by the invoked transaction. If the handler
  throws an exception, then the transaction fails with the exception error
  message.

  **后置处理器**：如果处理器成功完成，则智能合约将按调用的交易确定完成。如果处理程序抛出
  异常，则交易将失败并显示异常错误消息。


* **Unknown handler**: The handler should complete by throwing an exception with
  the required error message. If an **Unknown handler** is not specified, or an
  exception is not thrown by it, there is sensible default processing; the smart
  contract will fail with an **unknown transaction** error message.

  **未知处理器**：处理器应该通过抛出包含所需错误消息的异常来完成。如果未指定 **未知处理器**，
  或者未引发异常，则存在合理的默认处理; 智能合约将以 **未知交易** 错误消息失败。

If the handler requires access to the function and parameters, then it is easy to do this:

如果处理器需要访问函数和参数，这很容易做到：

```JavaScript
async beforeTransaction(ctx) {
    // Retrieve details of the transaction
    let txnDetails = ctx.stub.getFunctionAndParameters();

    console.info(`Calling function: ${txnDetails.fcn} `);
    console.info(util.format(`Function arguments : %j ${stub.getArgs()} ``);
}
```

## Multiple handlers  多处理器

It is only possible to define at most one handler of each type for a smart
contract. If a smart contract needs to invoke multiple functions during before,
after or unknown handling, it should coordinate this from within the appropriate
function.

只能为智能合约的每种类型至多定义一个处理器。如果智能合约需要在之前，之后或未知处理期间调用
多个函数，它应该在相应的函数内协调它。
