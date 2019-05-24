Logging Control - 日志控制
===============

Overview - 概览
--------

Logging in the ``peer`` and ``orderer`` is provided by the
``common/flogging`` package. Chaincodes written in Go also use this
package if they use the logging methods provided by the ``shim``.
This package supports

在 ``peer`` 和 ``orderer`` 中的日志功能是 ``common/flogging`` 包提供的。
如果使用 Go 语言编写的链码使用了 ``shim`` 提供的日志记录方法，那么它也使
用这个包。这个包支持

-  Logging control based on the severity of the message
-  基于消息的严重程度的日志控制
-  Logging control based on the software *logger* generating the message
-  基于软件 *记录器* 生成的消息的日志控制
-  Different pretty-printing options based on the severity of the
   message
-  基于不同严重程度的各种漂亮的输出选项

All logs are currently directed to ``stderr``. Global and logger-level
control of logging by severity is provided for both users and developers.
There are currently no formalized rules for the types of information
provided at each severity level. When submitting bug reports, developers
may want to see full logs down to the DEBUG level.

目前所有的日志都输出到 ``stderr`` 。为用户和开发者都提供了全局的和根据严重
程度的记录器级别的日志控制。目前对不同严重程度的信息没有固定的格式。当提交 
bug 报告的时候，开发者可能会想看到 DEBUG 级别下的日志全文。

In pretty-printed logs the logging level is indicated both by color and
by a four-character code, e.g, "ERRO" for ERROR, "DEBU" for DEBUG, etc. In
the logging context a *logger* is an arbitrary name (string) given by
developers to groups of related messages. In the pretty-printed example
below, the loggers ``ledgermgmt``, ``kvledger``, and ``peer`` are
generating logs.

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

An arbitrary number of loggers can be created at runtime, therefore there is
no "master list" of loggers, and logging control constructs can not check
whether logging loggers actually do or will exist.

在运行的时候，可以创建任意数量的记录器，但是没有记录器的“主列表”，所以日志控制
结构不能检查日志记录器在工作或者即将退出。

Logging specification - 日志规范
----

The logging levels of the ``peer`` and ``orderer`` commands are controlled
by a logging specification, which is set via the ``FABRIC_LOGGING_SPEC``
environment variable.

``peer`` 和 ``orderer`` 命令的日志级别由一个日志规范控制，该规范通过 ``FABRIC_LOGGING_SPEC`` 
环境变量来控制。

The full logging level specification is of the form

完整的日志界别规范是这样一个表单

::

    [<logger>[,<logger>...]=]<level>[:[<logger>[,<logger>...]=]<level>...]

Logging severity levels are specified using case-insensitive strings
chosen from

日志的严重程度由下边这些大小写敏感的字符串指明

::

   FATAL | PANIC | ERROR | WARNING | INFO | DEBUG


A logging level by itself is taken as the overall default. Otherwise,
overrides for individual or groups of loggers can be specified using the

日志级别有一个默认值。但是，可以通过下边的语法来覆盖一个或者一组记录器的
日志级别

::

    <logger>[,<logger>...]=<level>

syntax. Examples of specifications:

示例规范：

::

    info                                        - Set default to INFO
    warning:msp,gossip=warning:chaincode=info   - Default WARNING; Override for msp, gossip, and chaincode
    chaincode=info:msp,gossip=warning:warning   - Same as above

Logging format - 日志格式
----

The logging format of the ``peer`` and ``orderer`` commands is controlled
via the ``FABRIC_LOGGING_FORMAT`` environment variable. This can be set to
a format string, such as the default

``peer`` 和 ``orderer`` 命令的日志格式通过 ``FABRIC_LOGGING_FORMAT`` 环境变
量来控制。它可以设置为一个格式化字符串，默认为

::

   "%{color}%{time:2006-01-02 15:04:05.000 MST} [%{module}] %{shortfunc} -> %{level:.4s} %{id:03x}%{color:reset} %{message}"

to print the logs in a human-readable console format. It can be also set to
``json`` to output logs in JSON format.

把日志打印为我们可读的终端格式。它还可以设置为 ``json`` 来输出 JSON 格式的日
志。

Go chaincodes - Go 链码
-------------

The standard mechanism to log within a chaincode application is to
integrate with the logging transport exposed to each chaincode instance
via the peer. The chaincode ``shim`` package provides APIs that allow a
chaincode to create and manage logging objects whose logs will be
formatted and interleaved consistently with the ``shim`` logs.

链码应用中的标准机制是和日志传输整合在一起，通过 peer 节点暴露给每一个链码实
例。链码的 ``shim`` 包提供了允许链码创建和管理日志对象的 API，它们的日志将进
行格式化并被插入到 ``shim`` 的日志中。

As independently executed programs, user-provided chaincodes may
technically also produce output on stdout/stderr. While naturally useful
for "devmode", these channels are normally disabled on a production
network to mitigate abuse from broken or malicious code. However, it is
possible to enable this output even for peer-managed containers (e.g.
"netmode") on a per-peer basis via the
CORE\_VM\_DOCKER\_ATTACHSTDOUT=true configuration option.

就像独立执行的程序，用户链码在技术上同样可以输出到标准输出或者标准错误。这通
常对“开发模式”很有用，这些通道通常在生产网络上被禁用，以减轻损坏或恶意代码的
滥用。但是在被管理的节点管理容器（例如 “netmode” ）中，在每个节点上可以设置 
CORE\_VM\_DOCKER\_ATTACHSTDOUT=true 选项来打开输出。

Once enabled, each chaincode will receive its own logging channel keyed
by its container-id. Any output written to either stdout or stderr will
be integrated with the peer's log on a per-line basis. It is not
recommended to enable this for production.

当打开之后，每一个链码将接收到以它的容器 id 为键的日志通道。任何写入标准输出
或者标准错误的输出都将以行的方式整合到节点的日志中。在生产环境中不建议开启这
个设置。

API - API
~~~

``NewLogger(name string) *ChaincodeLogger`` - Create a logging object
for use by a chaincode

``NewLogger(name string) *ChaincodeLogger`` - 创建一个链码使用的日志对象

``(c *ChaincodeLogger) SetLevel(level LoggingLevel)`` - Set the logging
level of the logger

``(c *ChaincodeLogger) SetLevel(level LoggingLevel)`` - 设置记录器的日志级别

``(c *ChaincodeLogger) IsEnabledFor(level LoggingLevel) bool`` - Return
true if logs will be generated at the given level

``(c *ChaincodeLogger) IsEnabledFor(level LoggingLevel) bool`` - 当给定级别的日志生成时，返回 true

``LogLevel(levelString string) (LoggingLevel, error)`` - Convert a
string to a ``LoggingLevel``

``LogLevel(levelString string) (LoggingLevel, error)`` - 将字符串转换为 ``LoggingLevel``

A ``LoggingLevel`` is a member of the enumeration

``LoggingLevel`` 是枚举中的一个成员

::

    LogDebug, LogInfo, LogNotice, LogWarning, LogError, LogCritical

which can be used directly, or generated by passing a case-insensitive
version of the strings

可以被直接使用，或者通过传递的一个大小写敏感的字符串给 ``LogLevel``  API 来生成。

::

    DEBUG, INFO, NOTICE, WARNING, ERROR, CRITICAL

to the ``LogLevel`` API.

Formatted logging at various severity levels is provided by the
functions

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

The ``f`` forms of the logging APIs provide for precise control over the
formatting of the logs. The non-\ ``f`` forms of the APIs currently
insert a space between the printed representations of the arguments, and
arbitrarily choose the formats to use.

日志 API 中的 ``f`` 表示提供了对日志格式的精细控制。没有使用 ``f`` 标示的话，
目前的 API 会在输出的参数标示之间插入一个空格，并且任意选择一种样式使用。

In the current implementation, the logs produced by the ``shim`` and a
``ChaincodeLogger`` are timestamped, marked with the logger *name* and
severity level, and written to ``stderr``. Note that logging level
control is currently based on the *name* provided when the
``ChaincodeLogger`` is created. To avoid ambiguities, all
``ChaincodeLogger`` should be given unique names other than "shim". The
logger *name* will appear in all log messages created by the logger. The
``shim`` logs as "shim".

在目前的实现中，日志通过 ``shim`` 和打了时间戳的 ``ChaincodeLogger`` 产生，
由记录器 *名字* 和严重程度的级别标记，写入到 ``stderr`` 。注意，当 ``ChaincodeLogger`` 
创建的时候，日志级别控制基于 *名字* 提供。为了避免歧义，所有 ``ChaincodeLogger`` 
都应该赋予一个唯一的名字而不是 “shim” 。记录器的 *名字* 在所有的日志消息中都会显示。 
``shim`` 日志是 “shim” 。

The default logging level for loggers within the Chaincode container can
be set in the
`core.yaml <https://github.com/hyperledger/fabric/blob/master/sampleconfig/core.yaml>`__
file. The key ``chaincode.logging.level`` sets the default level for all
loggers within the Chaincode container. The key ``chaincode.logging.shim``
overrides the default level for the ``shim`` logger.

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

The default logging level can be overridden by using environment
variables. ``CORE_CHAINCODE_LOGGING_LEVEL`` sets the default logging
level for all loggers. ``CORE_CHAINCODE_LOGGING_SHIM`` overrides the
level for the ``shim`` logger.

默认的日志界别可以通过环境变量覆盖。 ``CORE_CHAINCODE_LOGGING_LEVEL`` 设置了所有记
录器的默认日志级别。 ``CORE_CHAINCODE_LOGGING_SHIM`` 覆盖了 ``shim`` 记录器的级别。

Go language chaincodes can also control the logging level of the
chaincode ``shim`` interface through the ``SetLoggingLevel`` API.

Go 语言链码同样可以通过链码 ``shim`` 接口的 ``SetLoggingLevel`` API 来控制日志级别。

``SetLoggingLevel(LoggingLevel level)`` - Control the logging level of
the shim

``SetLoggingLevel(LoggingLevel level)`` - 控制 shim 的日志级别


Below is a simple example of how a chaincode might create a private
logging object logging at the ``LogInfo`` level.

下边是一个链码如何在 ``LogInfo`` 级别下创建私有日志对象记录日志的简单例子。

::

    var logger = shim.NewLogger("myChaincode")

    func main() {

        logger.SetLevel(shim.LogInfo)
        ...
    }

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/

