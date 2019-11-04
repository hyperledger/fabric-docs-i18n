# 操作服务

Peer和orderer管理一个HTTP服务器，该服务器提供RESTful “操作”API（应用程序编程接口）。此API与Fabric网络服务无关，旨在供操作人员使用，而非网络管理员或“用户”。



该API揭露了以下能力：



* 日志级别管理

* 健康检查

* （当API被配置时）操作指标数据的Prometheus目标

 

## 配置操作服务

操作服务需要两层基本的配置



* 要监听的**地址**和**端口**

* 用于身份验证和加密的**TLS（传输层安全协议）证书**和**密钥**

注意，**这些证书必须由另外一个专门的CA（证书授权中心）来生成**，不能由已为某通道上的组织生成过证书的CA来生成。

 

### 节点

对每个peer来说，可在`core.yaml`部分的 `operations`中配置操作服务器：

```go
operations:
  # host and port for the operations server
  listenAddress: 127.0.0.1:9443

  # TLS configuration for the operations endpoint
  tls:
    # TLS enabled
    enabled: true

    # path to PEM encoded server certificate for the operations server
    cert:
      file: tls/server.crt

    # path to PEM encoded server key for the operations server
    key:
      file: tls/server.key

    # most operations service endpoints require client authentication when TLS
    # is enabled. clientAuthRequired requires client certificate authentication
    # at the TLS layer to access all resources.
    clientAuthRequired: false

    # paths to PEM encoded ca certificates to trust for client authentication
    clientRootCAs:
      files: []
```



 

`listenAddress` 键定义了操作服务器将执行监听的主机和端口。如果服务器要监听所有地址，则可以忽略主机部分。

`tls` 部分用于指明是否为操作服务启用了TLS，还指明了该服务的证书和私钥的位置以及客户端身份验证应该信任的证书颁发机构根证书的位置。当 `enabled` 是真实的，多数操作服务端点会要要求客户验证，因此必须设定 `clientRootCAs.files` 。当`clientAuthRequired` 是 `true`，TLS层将需要客户在每次请求时都提供一份证书以供验证。参考下面操作安全部分的内容来获取更多信息。

 

### 排序节点

对每个orderer来说，运行服务器都可配置在的 `orderer.yaml`的*Operation*s部分。

```go
Operations:
  # host and port for the operations server
  ListenAddress: 127.0.0.1:8443

  # TLS configuration for the operations endpoint
  TLS:
    # TLS enabled
    Enabled: true

    # PrivateKey: PEM-encoded tls key for the operations endpoint
    PrivateKey: tls/server.key

    # Certificate governs the file location of the server TLS certificate.
    Certificate: tls/server.crt

    # Paths to PEM encoded ca certificates to trust for client authentication
    ClientRootCAs: []

    # Most operations service endpoints require client authentication when TLS
    # is enabled. ClientAuthRequired requires client certificate authentication
    # at the TLS layer to access all resources.
    ClientAuthRequired: false
```



`ListenAddress`键定义了操作服务器将监听的主机和端口。如果服务器要监听所有地址，则可忽略主机部分。

`TLS `部分用于指明是否为操作服务启用了TLS，还指明了该服务的证书和私钥的位置以及客户端身份验证应该信任的证书授权中心根证书的位置。当 `Enabled` 是真实的，多数操作服务端点会要要求客户验证，因此必须设定 `RootCAs` 。当`clientAuthRequired` 是 `true`，TLS层将需要客户在每次请求时都提供一份证书以供验证。参考下面 操作安全部分的内容来获取更多信息。

 

### 操作安全

由于操作服务专注于操作，与Fabric网络无关，因此它不是用MSP（成员服务提供者）来进行访问控制，而是完全依赖于具有客户端证书身份验证功能的双向TLS。

禁用TLS后，授权将被绕过，这样一来，任何能连接到运行端点的客户端都可以使用API（应用程序编程接口）。

启用TLS后，除非下面另有说明，否则必须提供有效的客户端证书才能访问所有资源。

若同时启用了clientAuthRequired时，无论访问的是什么资源，TLS层都将需要有效的客户端证书。

 

### 日志级别管理

操作服务提供了 `/logspec`资源，操作人员可用该资源来管理peer或orderer的活跃日志记录规范。该资源是常规的REST资源，支持 `GET` 和`PUT `请求。

当操作服务接收到`GET /logspec `请求时，它将使用包含当前日志记录规范的 JSON有效负载进行响应：

```go
{"spec":"info"}
```

当操作服务接收到`PUT /logspec` 请求时，它将把body读取为JASON有效负载。有效负载必须包含名为`spec`的单个属性。

```go
{"spec":"chaincode=debug:info"}
```

如果规范成功激活，服务将回复`204 "No Content"` 。如果出现错误，服务将回复`400 "Bad Request" `以及一个错误有效负载：

```go
{"error":"error message"}
```



## 健康检查

操作服务提供了` /healthz` 资源，操作人员可用该资源来确定peer和orderer的活跃度及健康状况。该资源是支持GET请求的常规REST资源。它的实现旨在与Kubernetes使用的活跃度探针模型兼容，不过还可以在其他场景中进行。

当操作服务收到 `GET/healthz` 请求，它将调用所有已注册的运行状况检查程序来执行该流程。当所有运行状况检查程序都成功返回时，操作服务将以`200 "OK"` 和JSON body进行回应：

```go
{
  "status": "OK",
  "time": "2009-11-10T23:00:00Z"
}
```

如果运行状况检查程序中的一个或多个返回错误时，运行服务将响应 `503 "Service Unavailable"` 和一个包含未成功的运行状况检查程序的JASON body：

```go
{
  "status": "Service Unavailable",
  "time": "2009-11-10T23:00:00Z",
  "failed_checks": [
    {
      "component": "docker",
      "reason": "failed to connect to Docker daemon: invalid endpoint"
    }
  ]
}
```

在当前版本中，唯一注册的运行状况检查程序是针对Docker的。后期版本将增加额外的运行状况检查程序。



当启用TLS时，不需要提供有效的客户端证书就可以使用该服务，除非 `clientAuthRequired` 被设置为`true`。

 

## (metrics)指标数据

Fabric的peer和orderer的某些组件获取metrics，这些metrics可帮助深入了解系统行为。通过这些信息，操作人员和管理人员可以更好地理解系统随着时间的推移是如何运行的。

 

### 配置metrics

Fabric提供了两种获取metrics的方法：一种是基于Prometheus的**拉式**模型，另一种是基于StatsD的**推式**模型。

 

### Prometheus

典型的Prometheus部署通过从已检测目标公开的HTTP端点请求指标来获取指标数据。由于Prometheus负责请求metrics，因此它被看成是一种拉式系统。

当配置完成，Fabric的peer或orderer将在操作服务中展示 /metrics 资源。

 

### 节点

通过在`core.yaml`部分的`metrics` 中将metrics获取方式设置为prometheus ，可对peer进行配置，从而获取 `/metrics` 端点，以供Prometheus使用。

```go
metrics:
  provider: prometheus
```



### 排序节点

通过在`orderer.yaml`部分的 `Metrics`中将metrics获取方式设置为prometheus ，可对orderer进行配置，从而获取 `/metrics` 端点，以供Prometheus使用。

```go
Metrics:
  Provider: prometheus

```



###  StatsD

StatsD是一个简单的统计聚合守护程序。Metrics被发送到 `statsd`守护程序进行收集、汇总并推送至后端以进行可视化和警报。由于该模型需要辅助型流程来将metrics数据发送至StatsD,因此它被视为一种推式系统。

 

### 节点

通过在 `core.yaml`部分的 `metrics` 中将metrics获取方式设置为 `statsd`，可对节点进行配置，从而使metrics被发送至StatsD.  `statsd`子节必须配置有StatsD守护程序的地址、要使用的网络类型(`tcp` or `udp`)以及发送metrics的频率。通过指定一个可选`prefix` ，可帮助区分metrics的来源（例如，区分来自不同peer的metrics），这些metrics将被添加到所有已生成的metrics中。

```go
metrics:
  provider: statsd
  statsd:
    network: udp
    address: 127.0.0.1:8125
    writeInterval: 10s
    prefix: peer-0

```



### 排序节点

通过在 `orderer.yaml`部分的 `Metrics`中将metrics获取方式设置为 `statsd` ，可对排序节点进行配置，使得metrics被发送至StatsD.  `Statsd`子节必须配置有StatsD守护程序的地址、要使用的网络类型(`tcp` or `udp`)以及发送metrics的频率。通过指定一个可选`prefix` ，可帮助区分metrics的来源。

```go
Metrics:
    Provider: statsd
    Statsd:
      Network: udp
      Address: 127.0.0.1:8125
      WriteInterval: 30s
      Prefix: org-orderer

```

想了解已生成的不同metrics，请前往[Metrics参考](https://hyperledger-fabric-cn.readthedocs.io/zh/latest/metrics_reference.html)。The Operations Service

The peer and the orderer host an HTTP server that offers a RESTful "operations"
API. This API is unrelated to the Fabric network services and is intended to be
used by operators, not administrators or "users" of the network.

The API exposes the following capabilities:

- Log level management
- Health checks
- Prometheus target for operational metrics (when configured)

Configuring the Operations Service
----------------------------------

The operations service requires two basic pieces of configuration:

- The **address** and **port** to listen on.
- The **TLS certificates** and **keys** to use for authentication and encryption.
  Note, **these certificates should be generated by a separate and dedicated CA**.
  Do not use a CA that has generated certificates for any organizations
  in any channels.

Peer
~~~~

For each peer, the operations server can be configured in the ``operations``
section of ``core.yaml``:

.. code:: yaml

  operations:
    # host and port for the operations server
    listenAddress: 127.0.0.1:9443

    # TLS configuration for the operations endpoint
    tls:
      # TLS enabled
      enabled: true

      # path to PEM encoded server certificate for the operations server
      cert:
        file: tls/server.crt

      # path to PEM encoded server key for the operations server
      key:
        file: tls/server.key

      # most operations service endpoints require client authentication when TLS
      # is enabled. clientAuthRequired requires client certificate authentication
      # at the TLS layer to access all resources.
      clientAuthRequired: false

      # paths to PEM encoded ca certificates to trust for client authentication
      clientRootCAs:
        files: []

The ``listenAddress`` key defines the host and port that the operation server
will listen on. If the server should listen on all addresses, the host portion
can be omitted.

The ``tls`` section is used to indicate whether or not TLS is enabled for the
operations service, the location of the service's certificate and private key,
and the locations of certificate authority root certificates that should be
trusted for client authentication. When ``enabled`` is true, most of the operations
service endpoints require client authentication, therefore
``clientRootCAs.files`` must be set. When ``clientAuthRequired`` is ``true``,
the TLS layer will require clients to provide a certificate for authentication
on every request. See Operations Security section below for more details.

Orderer
~~~~~~~

For each orderer, the operations server can be configured in the `Operations`
section of ``orderer.yaml``:

.. code:: yaml

  Operations:
    # host and port for the operations server
    ListenAddress: 127.0.0.1:8443

    # TLS configuration for the operations endpoint
    TLS:
      # TLS enabled
      Enabled: true
    
      # PrivateKey: PEM-encoded tls key for the operations endpoint
      PrivateKey: tls/server.key
    
      # Certificate governs the file location of the server TLS certificate.
      Certificate: tls/server.crt
    
      # Paths to PEM encoded ca certificates to trust for client authentication
      ClientRootCAs: []
    
      # Most operations service endpoints require client authentication when TLS
      # is enabled. ClientAuthRequired requires client certificate authentication
      # at the TLS layer to access all resources.
      ClientAuthRequired: false

The ``ListenAddress`` key defines the host and port that the operations server
will listen on. If the server should listen on all addresses, the host portion
can be omitted.

The ``TLS`` section is used to indicate whether or not TLS is enabled for the
operations service, the location of the service's certificate and private key,
and the locations of certificate authority root certificates that should be
trusted for client authentication.   When ``Enabled`` is true, most of the operations
service endpoints require client authentication, therefore
``RootCAs`` must be set. When ``ClientAuthRequired`` is ``true``,
the TLS layer will require clients to provide a certificate for authentication
on every request. See Operations Security section below for more details.

Operations Security
~~~~~~~~~~~~~~~~~~~

As the operations service is focused on operations and intentionally unrelated
to the Fabric network, it does not use the Membership Services Provider for
access control. Instead, the operations service relies entirely on mutual TLS with
client certificate authentication.

When TLS is disabled, authorization is bypassed and any client that can
connect to the operations endpoint will be able to use the API.

When TLS is enabled, a valid client certificate must be provided in order to
access all resources unless explicitly noted otherwise below.

When clientAuthRequired is also enabled, the TLS layer will require
a valid client certificate regardless of the resource being accessed.

Log Level Management
~~~~~~~~~~~~~~~~~~~~

The operations service provides a ``/logspec`` resource that operators can use to
manage the active logging spec for a peer or orderer. The resource is a
conventional REST resource and supports ``GET`` and ``PUT`` requests.

When a ``GET /logspec`` request is received by the operations service, it will
respond with a JSON payload that contains the current logging specification:

.. code:: json

  {"spec":"info"}

When a ``PUT /logspec`` request is received by the operations service, it will
read the body as a JSON payload. The payload must consist of a single attribute
named ``spec``.

.. code:: json

  {"spec":"chaincode=debug:info"}

If the spec is activated successfully, the service will respond with a ``204 "No Content"``
response. If an error occurs, the service will respond with a ``400 "Bad Request"``
and an error payload:

.. code:: json

  {"error":"error message"}

Health Checks
-------------

The operations service provides a ``/healthz`` resource that operators can use to
help determine the liveness and health of peers and orderers. The resource is
a conventional REST resource that supports GET requests. The implementation is
intended to be compatible with the liveness probe model used by Kubernetes but
can be used in other contexts.

When a ``GET /healthz`` request is received, the operations service will call all
registered health checkers for the process. When all of the health checkers
return successfully, the operations service will respond with a ``200 "OK"`` and a
JSON body:

.. code:: json

  {
    "status": "OK",
    "time": "2009-11-10T23:00:00Z"
  }

If one or more of the health checkers returns an error, the operations service
will respond with a ``503 "Service Unavailable"`` and a JSON body that includes
information about which health checker failed:

.. code:: json

  {
    "status": "Service Unavailable",
    "time": "2009-11-10T23:00:00Z",
    "failed_checks": [
      {
        "component": "docker",
        "reason": "failed to connect to Docker daemon: invalid endpoint"
      }
    ]
  }

In the current version, the only health check that is registered is for Docker.
Future versions will be enhanced to add additional health checks.

When TLS is enabled, a valid client certificate is not required to use this
service unless ``clientAuthRequired`` is set to ``true``.

Metrics
-------

Some components of the Fabric peer and orderer expose metrics that can help
provide insight into the behavior of the system. Operators and administrators
can use this information to better understand how the system is performing
over time.

Configuring Metrics
~~~~~~~~~~~~~~~~~~~

Fabric provides two ways to expose metrics: a **pull** model based on Prometheus
and a **push** model based on StatsD.

Prometheus
~~~~~~~~~~

A typical Prometheus deployment scrapes metrics by requesting them from an HTTP
endpoint exposed by instrumented targets. As Prometheus is responsible for
requesting the metrics, it is considered a pull system.

When configured, a Fabric peer or orderer will present a ``/metrics`` resource
on the operations service.

Peer
^^^^

A peer can be configured to expose a ``/metrics`` endpoint for Prometheus to
scrape by setting the metrics provider to ``prometheus`` in the ``metrics`` section
of ``core.yaml``.

.. code:: yaml

  metrics:
    provider: prometheus

Orderer
^^^^^^^

An orderer can be configured to expose a ``/metrics`` endpoint for Prometheus to
scrape by setting the metrics provider to ``prometheus`` in the ``Metrics``
section of ``orderer.yaml``.

.. code:: yaml

  Metrics:
    Provider: prometheus

StatsD
~~~~~~

StatsD is a simple statistics aggregation daemon. Metrics are sent to a
``statsd`` daemon where they are collected, aggregated, and pushed to a backend
for visualization and alerting. As this model requires instrumented processes
to send metrics data to StatsD, this is considered a push system.

Peer
^^^^

A peer can be configured to send metrics to StatsD by setting the metrics
provider to ``statsd`` in the ``metrics`` section of ``core.yaml``. The ``statsd``
subsection must also be configured with the address of the StatsD daemon, the
network type to use (``tcp`` or ``udp``), and how often to send the metrics. An
optional ``prefix`` may be specified to help differentiate the source of the
metrics --- for example, differentiating metrics coming from separate peers ---
that would be prepended to all generated metrics.

.. code:: yaml

  metrics:
    provider: statsd
    statsd:
      network: udp
      address: 127.0.0.1:8125
      writeInterval: 10s
      prefix: peer-0

Orderer
^^^^^^^

An orderer can be configured to send metrics to StatsD by setting the metrics
provider to ``statsd`` in the ``Metrics`` section of ``orderer.yaml``. The ``Statsd``
subsection must also be configured with the address of the StatsD daemon, the
network type to use (``tcp`` or ``udp``), and how often to send the metrics. An
optional ``prefix`` may be specified to help differentiate the source of the
metrics.

.. code:: yaml

  Metrics:
      Provider: statsd
      Statsd:
        Network: udp
        Address: 127.0.0.1:8125
        WriteInterval: 30s
        Prefix: org-orderer

For a look at the different metrics that are generated, check out
:doc:`metrics_reference`.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/

~~~~~~