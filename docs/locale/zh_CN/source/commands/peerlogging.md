#  节点日志记录

管理者可以使用`peer logging`子命令来动态查看和配置节点旳日志等级。



## 语法

` peer logging` 命令包含以下子命令：

* getlogspec

* setlogspec



还包括以下已弃用的子命令，这些将不会出现在后期版本中：



* getlevel

* setlevel

* revertlevels

  

不同的子命令选项(`getlogspec`, `setlogspec`, `getlevel`, `setlevel`, 和`revertlevels`) 涉及了与同节点相关的不同记录操作。



本章节将在每个节点日志子命令的部分分别描述各节点日志子命令及其选项。



## 节点日志记录

```go
Logging configuration: getlevel|setlevel|getlogspec|setlogspec|revertlevels.

Usage:
  peer logging [command]

Available Commands:
  getlevel     Returns the logging level of the requested logger.
  getlogspec   Returns the active log spec.
  revertlevels Reverts the logging spec to the peer's spec at startup.
  setlevel     Adds the logger and log level to the current logging spec.
  setlogspec   Sets the logging spec.

Flags:
  -h, --help   help for logging

Use "peer logging [command] --help" for more information about a command.
```



## 节点日志记录getlevel

```go
Returns the logging level of the requested logger. Note: the logger name should exactly match the name that is displayed in the logs.

Usage:
  peer logging getlevel <logger> [flags]

Flags:
  -h, --help   help for getlevel
```



## 节点日志记录revertlevel

```go
Reverts the logging spec to the peer's spec at startup.

Usage:
  peer logging revertlevels [flags]

Flags:
  -h, --help   help for revertlevels
```



## 节点日志记录setlevel

```go
Adds the logger and log level to the current logging specification.

Usage:
  peer logging setlevel <logger> <log level> [flags]

Flags:
  -h, --help   help for setlevel
```



## 实例运用

### 获取级别运用

以下是 `pee logging getlevel` 命令的一个实例：

* 获取记录器 peer的日志级别

  ```go
  peer logging getlevel peer
  
  2018-11-01 14:18:11.276 UTC [cli.logging] getLevel -> INFO 001 Current log level for logger 'peer': INFO
  ```

  

### 获取日志特定运用

以下是`peer logging getlogspec` 命令的一个实例：

* 获取节点的活跃日志记录规定：

  ```go
  peer logging getlogspec
  
  2018-11-01 14:21:03.591 UTC [cli.logging] getLogSpec -> INFO 001 Current logging spec: info
  ```

  

### 设定级别运用

以下是 `peer logging setlevel` 命令的一些实例：

* 对记录器的日志级别进行设定，使记录器的名称前缀 `gossip`  对应日志级别 `WARNING`: 

  ```go
  peer logging setlevel gossip warning
  2018-11-01 14:21:55.509 UTC [cli.logging] setLevel -> INFO 001 Log level set for logger name/prefix 'gossip': WARNING
  ```

  

* 仅将与所提供名完全匹配的记录器的日志级别设定为 `ERROR `,并在该记录器的名称后加一个标点：

  ```go
  peer logging setlevel gossip. error
  
  2018-11-01 14:27:33.080 UTC [cli.logging] setLevel -> INFO 001 Log level set for logger name/prefix 'gossip.': ERROR
  ```

  

### 设定日志的特定运用

以下为 `peer logging setlogspec` 命令的一个实例：

* 以 `gossip` 和`msp` 开头的记录器被设置为日志级别 WARNING，为该记录器所在的peer设定活跃日志记录规范；除以 `gossip` 和 `msp` 开头的记录器以外的所有记录器的默认设置是日志级别`INFO`:

  ```go
  peer logging setlogspec gossip=warning:msp=warning:info
  
  2018-11-01 14:32:12.871 UTC [cli.logging] setLogSpec -> INFO 001 Current logging spec set to: gossip=warning:msp=warning:info
  
  ```

  

注意：只存在一个活跃日志规范。包括经“setlevel”更新的模块在内的所有之前的规范都将不适用。

### 恢复级别运用

以下是 `peer logging revertlevels` 命令的一个实例：

* 将日志规范恢复到初始值：

  ```go
  peer logging revertlevels
  
  2018-11-01 14:37:12.402 UTC [cli.logging] revertLevels -> INFO 001 Logging spec reverted to the peer's spec at startup.
  
  ```

  