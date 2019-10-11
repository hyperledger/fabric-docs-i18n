日志控制
===============

概览
--------

在 ``peer`` 和 ``orderer`` 中的日志功能是 ``common/flogging`` 包提供的。
如果使用 Go 语言编写的链码使用了 ``shim`` 提供的日志记录方法，那么它也使
用这个包。这个包支持

-  基于消息的严重程度的日志控制
-  基于软件 *记录器* 生成的消息的日志控制
-  基于不同严重程度的各种漂亮的输出选项

目前所有的日志都输出到 ``stderr`` 。为用户和开发者都提供了全局的和根据严重
程度的记录器级别的日志控制。目前对不同严重程度的信息没有固定的格式。当提交 
bug 报告的时候，开发者可能会想看到 DEBUG 级别下的日志全文。

在一个精美的日志输出中，日志级别要同时有颜色和四个字符的错误码标识，比如：
“ERRO” 代表 ERROR， “DEBU” 代表 DEBUG 等。在一个日志上下文中， *记录器* 是
开发者给出的一组相关信息的任意的名称。在下边精美的输出示例中，记录器 ``ledgermgmt`` 、 
``kvledger`` 、 和 ``peer`` 正在生成日志。

::

   2018-11-01 15:32:38.268 UTC [ledgermgmt] initialize -> INFO 002 Initializing ledger mgmt
   2018-11-01 15:32:38.268 UTC [kvledger] NewProvider -> INFO 003 Initializing ledger provider
   2018-11-01 15:32:38.342 UTC [kvledger] NewProvider -> INFO 004 ledger provider Initialized
   2018-11-01 15:32:38.357 UTC [ledgermgmt] initialize -> INFO 005 ledger mgmt initialized
   2018-11-01 15:32:38.357 UTC [peer] func1 -> INFO 006 Auto-detected peer address: 172.24.0.3:7051
   2018-11-01 15:32:38.357 UTC [peer] func1 -> INFO 007 Returning peer0.org1.example.com:7051

在运行的时候，可以创建任意数量的记录器，但是没有记录器的“主列表”，所以日志控制
结构不能检查日志记录器在工作或者即将退出。

日志规范
----

``peer`` 和 ``orderer`` 命令的日志级别由一个日志规范控制，该规范通过 ``FABRIC_LOGGING_SPEC`` 
环境变量来控制。

完整的日志界别规范是这样一个表单

::

    [<logger>[,<logger>...]=]<level>[:[<logger>[,<logger>...]=]<level>...]

日志的严重程度由下边这些大小写敏感的字符串指明

::

   FATAL | PANIC | ERROR | WARNING | INFO | DEBUG


日志级别有一个默认值。但是，可以通过下边的语法来覆盖一个或者一组记录器的
日志级别

::

    <logger>[,<logger>...]=<level>

示例规范：

::

    info                                        - Set default to INFO
    warning:msp,gossip=warning:chaincode=info   - Default WARNING; Override for msp, gossip, and chaincode
    chaincode=info:msp,gossip=warning:warning   - Same as above

日志格式
----

``peer`` 和 ``orderer`` 命令的日志格式通过 ``FABRIC_LOGGING_FORMAT`` 环境变
量来控制。它可以设置为一个格式化字符串，默认为

::

   "%{color}%{time:2006-01-02 15:04:05.000 MST} [%{module}] %{shortfunc} -> %{level:.4s} %{id:03x}%{color:reset} %{message}"

把日志打印为我们可读的终端格式。它还可以设置为 ``json`` 来输出 JSON 格式的日
志。

Go 链码
-------------

链码应用中的标准机制是和日志传输整合在一起，通过 peer 节点暴露给每一个链码实
例。链码的 ``shim`` 包提供了允许链码创建和管理日志对象的 API，它们的日志将进
行格式化并被插入到 ``shim`` 的日志中。

就像独立执行的程序，用户链码在技术上同样可以输出到标准输出或者标准错误。这通
常对“开发模式”很有用，这些通道通常在生产网络上被禁用，以减轻损坏或恶意代码的
滥用。但是在被管理的节点管理容器（例如 “netmode” ）中，在每个节点上可以设置 
CORE\_VM\_DOCKER\_ATTACHSTDOUT=true 选项来打开输出。


当打开之后，每一个链码将接收到以它的容器 id 为键的日志通道。任何写入标准输出
或者标准错误的输出都将以行的方式整合到节点的日志中。在生产环境中不建议开启这
个设置。

API
~~~

``NewLogger(name string) *ChaincodeLogger`` - 创建一个链码使用的日志对象

``(c *ChaincodeLogger) SetLevel(level LoggingLevel)`` - 设置记录器的日志级别

``(c *ChaincodeLogger) IsEnabledFor(level LoggingLevel) bool`` - 当给定级别的日志生成时，返回 true

``LogLevel(levelString string) (LoggingLevel, error)`` - 将字符串转换为 ``LoggingLevel``

``LoggingLevel`` 是枚举中的一个成员

::

    LogDebug, LogInfo, LogNotice, LogWarning, LogError, LogCritical

可以被直接使用，或者通过传递的一个大小写敏感的字符串给 ``LogLevel``  API 来生成。

::

    DEBUG, INFO, NOTICE, WARNING, ERROR, CRITICAL

to the ``LogLevel`` API.

不同严重程度级别的日志的格式通过如下函数提供：

::

    (c *ChaincodeLogger) Debug(args ...interface{})
    (c *ChaincodeLogger) Info(args ...interface{})
    (c *ChaincodeLogger) Notice(args ...interface{})
    (c *ChaincodeLogger) Warning(args ...interface{})
    (c *ChaincodeLogger) Error(args ...interface{})
    (c *ChaincodeLogger) Critical(args ...interface{})

    (c *ChaincodeLogger) Debugf(format string, args ...interface{})
    (c *ChaincodeLogger) Infof(format string, args ...interface{})
    (c *ChaincodeLogger) Noticef(format string, args ...interface{})
    (c *ChaincodeLogger) Warningf(format string, args ...interface{})
    (c *ChaincodeLogger) Errorf(format string, args ...interface{})
    (c *ChaincodeLogger) Criticalf(format string, args ...interface{})

日志 API 中的 ``f`` 表示提供了对日志格式的精细控制。没有使用 ``f`` 标示的话，
目前的 API 会在输出的参数标示之间插入一个空格，并且任意选择一种样式使用。

在目前的实现中，日志通过 ``shim`` 和打了时间戳的 ``ChaincodeLogger`` 产生，
由记录器 *名字* 和严重程度的级别标记，写入到 ``stderr`` 。注意，当 ``ChaincodeLogger`` 
创建的时候，日志级别控制基于 *名字* 提供。为了避免歧义，所有 ``ChaincodeLogger`` 
都应该赋予一个唯一的名字而不是 “shim” 。记录器的 *名字* 在所有的日志消息中都会显示。 
``shim`` 日志是 “shim” 。

在链码容器中记录器的默认日志级别可以在 `core.yaml <https://github.com/hyperledger/fabric/blob/master/sampleconfig/core.yaml>`__ 
文件中设置。 ``chaincode.logging.level`` 键设置了链码容器中所有记录器的默认级别。 
``chaincode.logging.shim`` 键覆盖了 ``shim`` 记录器的默认级别。

::

    # Logging section for the chaincode container
    logging:
      # Default level for all loggers within the chaincode container
      level:  info
      # Override default level for the 'shim' logger
      shim:   warning

默认的日志界别可以通过环境变量覆盖。 ``CORE_CHAINCODE_LOGGING_LEVEL`` 设置了所有记
录器的默认日志级别。 ``CORE_CHAINCODE_LOGGING_SHIM`` 覆盖了 ``shim`` 记录器的级别。

Go 语言链码同样可以通过链码 ``shim`` 接口的 ``SetLoggingLevel`` API 来控制日志级别。

``SetLoggingLevel(LoggingLevel level)`` - 控制 shim 的日志级别

下边是一个链码如何在 ``LogInfo`` 级别下创建私有日志对象记录日志的简单例子。

::

    var logger = shim.NewLogger("myChaincode")

    func main() {

        logger.SetLevel(shim.LogInfo)
        ...
    }

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/

