可插拔交易背书与交易验证
================================================
Pluggable transaction endorsement and validation
================================================

动机
----------

Motivation
----------

交易在提交时会被验证，在应用交易带来的状态改变之前，节点会对交易进行以下检查：

When a transaction is validated at time of commit, the peer performs various
checks before applying the state changes that come with the transaction itself:

- 验证交易签名者的身份；
- 验证交易背书者的签名；
- 确认交易满足对应链码命名空间的相关背书策略。

- Validating the identities that signed the transaction.
- Verifying the signatures of the endorsers on the transaction.
- Ensuring the transaction satisfies the endorsement policies of the namespaces
  of the corresponding chaincodes.

在某些情况下，需要自定义不同于 Fabric 默认的交易验证规则，例如：

There are use cases which demand custom transaction validation rules different
from the default Fabric validation rules, such as:

- **UTXO（未花费的交易输出）**： 当需要验证账户是否有双花的情况时；
- **匿名交易**： 当背书中不包含节点身份，并且共享的签名和公钥也无法与节点的身份联系起来时。

- **UTXO (Unspent Transaction Output):** When the validation takes into account
  whether the transaction doesn't double spend its inputs.
- **Anonymous transactions:** When the endorsement doesn't contain the identity
  of the peer, but a signature and a public key are shared that can't be linked
  to the peer's identity.

可插拔的背书和验证逻辑
------------------------------------------

Pluggable endorsement and validation logic
------------------------------------------

Fabric 支持以可插拔的方式在 Peer 节点中实现和部署与链码相关的自定义的背书和验证逻辑。这种逻辑既可作为可选逻辑内置到  Peer 节点中，也可作为一个 `Golang 插件 <https://golang.org/pkg/plugin/>`_ 与 Peer 节点一起编译和部署。

Fabric allows for the implementation and deployment of custom endorsement and
validation logic into the peer to be associated with chaincode handling. This
logic can be compiled into the peer or built with the peer and deployed
alongside it as a `Go plugin <https://golang.org/pkg/plugin/>`_.

默认情况下，链码将使用内置的背书和验证逻辑。不过，用户可以选择使用自定义的背书和验证插件来作为链码定义的一部分。管理员可通过自定义 Peer 节点的本地配置来扩展背书或验证逻辑。

.. note:: Go plugins have a number of practical restrictions that require them
   to be compiled and linked in the same build environment as the peer.
   Differences in Go package versions, compiler versions, tags, and even GOPATH
   values will result in runtime failures when loading or executing the plugin
   logic.

配置
-------------

By default, A chaincode will use the built in endorsement and validation logic.
However, users have the option of selecting custom endorsement and validation
plugins as part of the chaincode definition. An administrator can extend the
endorsement/validation logic available to the peer by customizing the peer's
local configuration.

每个 Peer 节点都有一个本地配置（``core.yaml``），其中包括了背书或验证逻辑的名称与具体实现的映射关系。

Configuration
-------------

默认的逻辑叫做 ``ESCC`` （其中“E”代表 endorsement，背书）和 ``VSCC`` （validation，验证）， Peer 节点本地配置中的 ``handlers`` 部分包含了该默认逻辑。

Each peer has a local configuration (``core.yaml``) that declares a mapping
between the endorsement/validation logic name and the implementation that is to
be run.

.. code-block:: YAML

The default logic are called ``ESCC`` (with the "E" standing for endorsement) and
``VSCC`` (validation), and they can be found in the peer local configuration in
the ``handlers`` section:

    handlers:
        endorsers:
          escc:
            name: DefaultEndorsement
        validators:
          vscc:
            name: DefaultValidation

.. code-block:: YAML

当背书或验证的实现被编译到 Peer 节点中时，``name`` 属性就代表了即将运行的初始化函数，以便获得生成背书或验证逻辑相关实例的工厂。

    handlers:
        endorsers:
          escc:
            name: DefaultEndorsement
        validators:
          vscc:
            name: DefaultValidation

该函数是 ``core/handlers/library/library.go`` 中 ``HandlerLibrary`` 结构的实例方法，而且为了添加自定义的背书或验证逻辑，就需要额外的方法对该结构进行扩展。

When the endorsement or validation implementation is compiled into the peer, the
``name`` property represents the initialization function that is to be run in order
to obtain the factory that creates instances of the endorsement/validation logic.

由于这种方法十分繁琐且不容易部署，因此用户可以在 ``name`` 下增加一个 ``library`` 属性，以此将自定义背书和验证部署为一个 Golang 插件。

The function is an instance method of the ``HandlerLibrary`` construct under
``core/handlers/library/library.go`` and in order for custom endorsement or
validation logic to be added, this construct needs to be extended with any
additional methods.

比如，我们以插件来实现自定义背书和验证逻辑，那么 ``core.yaml`` 的配置中就会有以下内容：

If the custom code is built as a Go plugin, the ``library`` property must be
provided and set to the location of the shared library.

.. code-block:: YAML

For example, if we have custom endorsement and validation logic which is
implemented as a plugin, we would have the following entries in the configuration
in ``core.yaml``:

    handlers:
        endorsers:
          escc:
            name: DefaultEndorsement
          custom:
            name: customEndorsement
            library: /etc/hyperledger/fabric/plugins/customEndorsement.so
        validators:
          vscc:
            name: DefaultValidation
          custom:
            name: customValidation
            library: /etc/hyperledger/fabric/plugins/customValidation.so

.. code-block:: YAML

并且我们需要把 ``.so`` 插件文件放置在 Peer 节点的本地文件系统中。

    handlers:
        endorsers:
          escc:
            name: DefaultEndorsement
          custom:
            name: customEndorsement
            library: /etc/hyperledger/fabric/plugins/customEndorsement.so
        validators:
          vscc:
            name: DefaultValidation
          custom:
            name: customValidation
            library: /etc/hyperledger/fabric/plugins/customValidation.so

自定义插件的名称需要在使用的链码定义中引用。如果你使用 CLI 来执行链码定义，请使用 ``--escc`` 和 ``--vscc`` 标识来选择自定义的背书或者验证库。如果使用 Fabric Node.js SDK，请访问 `如何安装和启动你的链码 <https://hyperledger.github.io/fabric-sdk-node/master/tutorial-chaincode-lifecycle.html>`__ 。更多信息查阅 :doc:`chaincode4noah` 。

And we'd have to place the ``.so`` plugin files in the peer's local file system.

.. note:: 后边内容中，自定义背书和验证逻辑的实现都将表述为“插件”，即使被编译到 Peer 节点中。

The name of the custom plugin needs to be referenced by the chaincode definition
to be used by the chaincode. If you are using the peer CLI to approve the
chaincode definition, use the ``--escc`` and ``--vscc`` flag to select the name
of the custom endorsement or validation library. If you are using the
Fabric SDK for Node.js, visit `How to install and start your chaincode <https://hyperledger.github.io/fabric-sdk-node/{BRANCH}/tutorial-chaincode-lifecycle.html>`__.
For more information, see :doc:`chaincode_lifecycle`.

背书插件的实现
---------------------------------

.. note:: Hereafter, custom endorsement or validation logic implementation is
          going to be referred to as "plugins", even if they are compiled into
          the peer.

要实现一个背书插件，用户必须实现 ``core/handlers/endorsement/api/endorsement.go`` 中的 ``Plugin`` 接口。

Endorsement plugin implementation
---------------------------------

.. code-block:: Go

To implement an endorsement plugin, one must implement the ``Plugin`` interface
found in ``core/handlers/endorsement/api/endorsement.go``:

    // Plugin endorses a proposal response
    type Plugin interface {
    	// Endorse signs the given payload(ProposalResponsePayload bytes), and optionally mutates it.
    	// Returns:
    	// The Endorsement: A signature over the payload, and an identity that is used to verify the signature
    	// The payload that was given as input (could be modified within this function)
    	// Or error on failure
    	Endorse(payload []byte, sp *peer.SignedProposal) (*peer.Endorsement, []byte, error)

.. code-block:: Go

    	// Init injects dependencies into the instance of the Plugin
    	Init(dependencies ...Dependency) error
    }

    // Plugin endorses a proposal response
    type Plugin interface {
    	// Endorse signs the given payload(ProposalResponsePayload bytes), and optionally mutates it.
    	// Returns:
    	// The Endorsement: A signature over the payload, and an identity that is used to verify the signature
    	// The payload that was given as input (could be modified within this function)
    	// Or error on failure
    	Endorse(payload []byte, sp *peer.SignedProposal) (*peer.Endorsement, []byte, error)

当 Peer 节点调用 ``PluginFactory`` 接口中的 ``New`` 方法时，会为每个通道创建给定类型（无论是 ``HandlerLibrary`` 示例方法的方法名还是 ``.so`` 文件路径）的背书插件实例，``PluginFactory`` 接口需要由插件开发者实现。

    	// Init injects dependencies into the instance of the Plugin
    	Init(dependencies ...Dependency) error
    }

.. code-block:: Go

An endorsement plugin instance of a given plugin type (identified either by the
method name as an instance method of the ``HandlerLibrary`` or by the plugin ``.so``
file path) is created for each channel by having the peer invoke the ``New``
method in the ``PluginFactory`` interface which is also expected to be implemented
by the plugin developer:

    // PluginFactory creates a new instance of a Plugin
    type PluginFactory interface {
    	New() Plugin
    }

.. code-block:: Go


    // PluginFactory creates a new instance of a Plugin
    type PluginFactory interface {
    	New() Plugin
    }

``Init`` 方法将接收 ``core/handlers/endorsement/api/`` 中声明的所有依赖项作为输入，这些依赖项会被识别为内嵌 ``Dependency`` 接口。


创建了 ``Plugin`` 实例后，Peer 节点在实例上调用 ``Init`` 方法，并把 ``dependencies`` 作为参数传递。

The ``Init`` method is expected to receive as input all the dependencies declared
under ``core/handlers/endorsement/api/``, identified as embedding the ``Dependency``
interface.

目前，Fabric 存在以下背书插件的依赖项：

After the creation of the ``Plugin`` instance, the ``Init`` method is invoked on
it by the peer with the ``dependencies`` passed as parameters.

- ``SigningIdentityFetcher``：返回一个基于给定签名提案的 ``SigningIdentity`` 示例

Currently Fabric comes with the following dependencies for endorsement plugins:

.. code-block:: Go

- ``SigningIdentityFetcher``: Returns an instance of ``SigningIdentity`` based
  on a given signed proposal:

    // SigningIdentity signs messages and serializes its public identity to bytes
    type SigningIdentity interface {
    	// Serialize returns a byte representation of this identity which is used to verify
    	// messages signed by this SigningIdentity
    	Serialize() ([]byte, error)

.. code-block:: Go

    	// Sign signs the given payload and returns a signature
    	Sign([]byte) ([]byte, error)
    }

    // SigningIdentity signs messages and serializes its public identity to bytes
    type SigningIdentity interface {
    	// Serialize returns a byte representation of this identity which is used to verify
    	// messages signed by this SigningIdentity
    	Serialize() ([]byte, error)

- ``StateFetcher``：获取一个与世界状态交互的 **状态** 对象

    	// Sign signs the given payload and returns a signature
    	Sign([]byte) ([]byte, error)
    }

.. code-block:: Go

- ``StateFetcher``: Fetches a **State** object which interacts with the world
  state:

    // State defines interaction with the world state
    type State interface {
    	// GetPrivateDataMultipleKeys gets the values for the multiple private data items in a single call
    	GetPrivateDataMultipleKeys(namespace, collection string, keys []string) ([][]byte, error)

.. code-block:: Go

    	// GetStateMultipleKeys gets the values for multiple keys in a single call
    	GetStateMultipleKeys(namespace string, keys []string) ([][]byte, error)

    // State defines interaction with the world state
    type State interface {
    	// GetPrivateDataMultipleKeys gets the values for the multiple private data items in a single call
    	GetPrivateDataMultipleKeys(namespace, collection string, keys []string) ([][]byte, error)

    	// GetTransientByTXID gets the values private data associated with the given txID
    	GetTransientByTXID(txID string) ([]*rwset.TxPvtReadWriteSet, error)

    	// GetStateMultipleKeys gets the values for multiple keys in a single call
    	GetStateMultipleKeys(namespace string, keys []string) ([][]byte, error)

    	// Done releases resources occupied by the State
    	Done()
     }

    	// GetTransientByTXID gets the values private data associated with the given txID
    	GetTransientByTXID(txID string) ([]*rwset.TxPvtReadWriteSet, error)

验证插件的实现
--------------------------------

    	// Done releases resources occupied by the State
    	Done()
     }

要实现一个验证插件，用户必须实现 ``core/handlers/validation/api/validation.go`` 中的 ``Plugin`` 接口：

Validation plugin implementation
--------------------------------

.. code-block:: Go

To implement a validation plugin, one must implement the ``Plugin`` interface
found in ``core/handlers/validation/api/validation.go``:

    // Plugin validates transactions
    type Plugin interface {
    	// Validate returns nil if the action at the given position inside the transaction
    	// at the given position in the given block is valid, or an error if not.
    	Validate(block *common.Block, namespace string, txPosition int, actionPosition int, contextData ...ContextDatum) error

.. code-block:: Go

    	// Init injects dependencies into the instance of the Plugin
    	Init(dependencies ...Dependency) error
    }

    // Plugin validates transactions
    type Plugin interface {
    	// Validate returns nil if the action at the given position inside the transaction
    	// at the given position in the given block is valid, or an error if not.
    	Validate(block *common.Block, namespace string, txPosition int, actionPosition int, contextData ...ContextDatum) error

每个 ``ContextDatum`` 都是运行时派生的额外元数据，由节点负责传递给验证插件。目前，代表链码背书策略的 ``ContextDatum`` 是唯一被传递的数据 。

    	// Init injects dependencies into the instance of the Plugin
    	Init(dependencies ...Dependency) error
    }

.. code-block:: Go

Each ``ContextDatum`` is additional runtime-derived metadata that is passed by
the peer to the validation plugin. Currently, the only ``ContextDatum`` that is
passed is one that represents the endorsement policy of the chaincode:

   // SerializedPolicy defines a serialized policy
  type SerializedPolicy interface {
	validation.ContextDatum

.. code-block:: Go

	// Bytes returns the bytes of the SerializedPolicy
	Bytes() []byte
   }

   // SerializedPolicy defines a serialized policy
  type SerializedPolicy interface {
	validation.ContextDatum

当 Peer 节点调用 ``PluginFactory`` 接口中的 ``New`` 方法时，会为每个通道创建给定类型（无论是 ``HandlerLibrary`` 示例方法的方法名还是 ``.so`` 文件路径）的验证插件实例，``PluginFactory`` 接口需要由插件开发者实现。

	// Bytes returns the bytes of the SerializedPolicy
	Bytes() []byte
   }

.. code-block:: Go

A validation plugin instance of a given plugin type (identified either by the
method name as an instance method of the ``HandlerLibrary`` or by the plugin ``.so``
file path) is created for each channel by having the peer invoke the ``New``
method in the ``PluginFactory`` interface which is also expected to be implemented
by the plugin developer:

    // PluginFactory creates a new instance of a Plugin
    type PluginFactory interface {
    	New() Plugin
    }

.. code-block:: Go

``Init`` 方法将接收 ``core/handlers/validation/api/`` 中声明的所有依赖项作为输入，这些依赖项会被识别为内嵌 ``Dependency`` 接口。

    // PluginFactory creates a new instance of a Plugin
    type PluginFactory interface {
    	New() Plugin
    }

创建了 ``Plugin`` 实例后，Peer 节点在实例上调用 ``Init`` 方法，并把 ``dependencies`` 作为参数传递。

The ``Init`` method is expected to receive as input all the dependencies declared
under ``core/handlers/validation/api/``, identified as embedding the ``Dependency``
interface.

目前，Fabric 存在以下验证插件的依赖项：

After the creation of the ``Plugin`` instance, the **Init** method is invoked on
it by the peer with the dependencies passed as parameters.

- ``IdentityDeserializer``：将表示身份的字节转换为 ``Identity`` 对象，该对象可用于验证由这些身份的签名，并根据各自的 MSP 对自身进行验证，以查看它们是否满足给定的 **MSP 准则**。``core/handlers/validation/api/identities/identities.go`` 中包含了全部的规范。

Currently Fabric comes with the following dependencies for validation plugins:

- ``PolicyEvaluator``：评估是否满足给定的策略：

- ``IdentityDeserializer``: Converts byte representation of identities into
  ``Identity`` objects that can be used to verify signatures signed by them, be
  validated themselves against their corresponding MSP, and see whether they
  satisfy a given **MSP Principal**. The full specification can be found in
  ``core/handlers/validation/api/identities/identities.go``.

.. code-block:: Go

- ``PolicyEvaluator``: Evaluates whether a given policy is satisfied:

    // PolicyEvaluator evaluates policies
    type PolicyEvaluator interface {
    	validation.Dependency

.. code-block:: Go

    	// Evaluate takes a set of SignedData and evaluates whether this set of signatures satisfies
    	// the policy with the given bytes
    	Evaluate(policyBytes []byte, signatureSet []*common.SignedData) error
    }

    // PolicyEvaluator evaluates policies
    type PolicyEvaluator interface {
    	validation.Dependency

- ``StateFetcher``：获取一个与世界状态中的 ``State`` 对象：

    	// Evaluate takes a set of SignedData and evaluates whether this set of signatures satisfies
    	// the policy with the given bytes
    	Evaluate(policyBytes []byte, signatureSet []*common.SignedData) error
    }

.. code-block:: Go

- ``StateFetcher``: Fetches a ``State`` object which interacts with the world state:

    // State defines interaction with the world state
    type State interface {
        // GetStateMultipleKeys gets the values for multiple keys in a single call
        GetStateMultipleKeys(namespace string, keys []string) ([][]byte, error)

.. code-block:: Go

        // GetStateRangeScanIterator returns an iterator that contains all the key-values between given key ranges.
        // startKey is included in the results and endKey is excluded. An empty startKey refers to the first available key
        // and an empty endKey refers to the last available key. For scanning all the keys, both the startKey and the endKey
        // can be supplied as empty strings. However, a full scan should be used judiciously for performance reasons.
        // The returned ResultsIterator contains results of type *KV which is defined in fabric-protos/ledger/queryresult.
        GetStateRangeScanIterator(namespace string, startKey string, endKey string) (ResultsIterator, error)

    // State defines interaction with the world state
    type State interface {
        // GetStateMultipleKeys gets the values for multiple keys in a single call
        GetStateMultipleKeys(namespace string, keys []string) ([][]byte, error)

        // GetStateMetadata returns the metadata for given namespace and key
        GetStateMetadata(namespace, key string) (map[string][]byte, error)

        // GetStateRangeScanIterator returns an iterator that contains all the key-values between given key ranges.
        // startKey is included in the results and endKey is excluded. An empty startKey refers to the first available key
        // and an empty endKey refers to the last available key. For scanning all the keys, both the startKey and the endKey
        // can be supplied as empty strings. However, a full scan should be used judiciously for performance reasons.
        // The returned ResultsIterator contains results of type *KV which is defined in fabric-protos/ledger/queryresult.
        GetStateRangeScanIterator(namespace string, startKey string, endKey string) (ResultsIterator, error)

        // GetPrivateDataMetadata gets the metadata of a private data item identified by a tuple <namespace, collection, key>
        GetPrivateDataMetadata(namespace, collection, key string) (map[string][]byte, error)

        // GetStateMetadata returns the metadata for given namespace and key
        GetStateMetadata(namespace, key string) (map[string][]byte, error)

        // Done releases resources occupied by the State
        Done()
    }

        // GetPrivateDataMetadata gets the metadata of a private data item identified by a tuple <namespace, collection, key>
        GetPrivateDataMetadata(namespace, collection, key string) (map[string][]byte, error)

重要提示
---------------

        // Done releases resources occupied by the State
        Done()
    }

- **各节点上的验证插件保持一致：** 在以后的版本中，Fabric 通道基础设施将确保在给定区块链高度上，通道内所有节点对给定链码使用相同的验证逻辑，以消除可能导致节点间状态分歧的错误配置风险，若发生错配置，则可能会致使节点运行不同的实现。但就目前来说，系统操作员和管理员的唯一责任就是确保以上问题不会发生。

Important notes
---------------

- **验证插件错误处理：** 当因发生某些暂时性执行问题（比如无法访问数据库）而导致验证插件不能确定一笔交易是否有效时，插件应返回 ``core/handlers/validation/api/validation.go`` 中定义的 **ExecutionFailureError** 类型的错误。任何其他被返回的错误将被视为背书策略错误，并且被验证逻辑标记为无效。但是，如果返回的错误是 ``ExecutionFailureError``，链处理程序不会将该交易标志为无效，而是暂停处理。目的是防止不同节点之间发生状态分歧。

- **Validation plugin consistency across peers:** In future releases, the Fabric
  channel infrastructure would guarantee that the same validation logic is used
  for a given chaincode by all peers in the channel at any given blockchain
  height in order to eliminate the chance of mis-configuration which would might
  lead to state divergence among peers that accidentally run different
  implementations. However, for now it is the sole responsibility of the system
  operators and administrators to ensure this doesn't happen.

- **私有元数据索取的错误处理：** 当一个插件利用 ``StateFetcher`` 接口来为私有数据索取元数据时，错误处理需要按一下方式来处理：``CollConfigNotDefinedError'' 和 ``InvalidCollNameError''，表明指定的集合不存在，应该按照确定性的错误来处理，而不是 ``ExecutionFailureError``。

- **Validation plugin error handling:** Whenever a validation plugin can't
  determine whether a given transaction is valid or not, because of some transient
  execution problem like inability to access the database, it should return an
  error of type **ExecutionFailureError** that is defined in ``core/handlers/validation/api/validation.go``.
  Any other error that is returned, is treated as an endorsement policy error
  and marks the transaction as invalidated by the validation logic. However,
  if an ``ExecutionFailureError`` is returned, the chain processing halts instead
  of marking the transaction as invalid. This is to prevent state divergence
  between different peers.

- **将 Fabric 代码导入插件：** 强烈不建议将 Fabric 代码导入插件而不使用 protobufs，这样做会在 Fabric 代码更新时出现问题，或者当运行不同版本的节点时，引起操作问题。理想情况下，插件代码应该只使用提供的依赖，并除了 protobufs 之外的最小化导入项。

- **Error handling for private metadata retrieval**: In case a plugin retrieves
  metadata for private data by making use of the ``StateFetcher`` interface,
  it is important that errors are handled as follows: ``CollConfigNotDefinedError``
  and ``InvalidCollNameError``, signalling that the specified collection does
  not exist, should be handled as deterministic errors and should not lead the
  plugin to return an ``ExecutionFailureError``.

- **Importing Fabric code into the plugin**: Importing code that belongs to Fabric
  other than protobufs as part of the plugin is highly discouraged, and can lead
  to issues when the Fabric code changes between releases, or can cause inoperability
  issues when running mixed peer versions. Ideally, the plugin code should only
  use the dependencies given to it, and should import the bare minimum other
  than protobufs.
