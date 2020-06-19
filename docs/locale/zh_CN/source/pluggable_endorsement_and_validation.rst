可插拔交易背书与交易验证
================================================

动机
----------

交易提交时会接受验证，此时节点会在执行交易本身带来的状态改变前进行以下检查：
  
- 对签署交易者的身份进行验证；
- 对交易上背书者的签名进行核实：
- 确认交易满足对应链码命名区间的相关背书政策。
  
在某些情况下，需要自定义交易验证规则，与Fabric默认的验证规则不同，例如：
  
- **未花费的交易输出（UTXO）**：验证过程要考虑交易是否没有对其输入使用两次，此时需要自定义交易验证规则。
- **匿名交易**：当背书不包含节点身份，被共享的签名和公钥也无法与节点的身份联系起立时，需要自定义交易验证规则。

可插拔背书和验证逻辑
------------------------------------------

Fabric支持对节点实行、部署自定义的背书和验证逻辑，并实现了以可插拔方式将其与链码执行联系起来。这种逻辑既可作为内置型可选逻辑编进节点中，也可作为一个Golang插件与节点一起接受编译和部署。`Golang 插件 <https://golang.org/pkg/plugin/>`_ 。

默认情况下，链码将使用内置的背书和验证逻辑。不过，用户可以选择使用自定义的背书和验证插件来作为链码定义的一部分。管理员可通过自定义节点的本地配置来扩展对方可用的背书或验证逻辑。

配置
-------------

每个节点都有一个本地配置（``core.yaml``），其中包括了背书或验证逻辑名与将进行的逻辑实现之间的映射关系。

默认的逻辑叫做 ``ESCC``（其中“E”代表背书）和 ``VSCC`` （验证）， ``handlers`` 部分的节点本地配置中包含了该默认逻辑。

.. code-block:: YAML

    handlers:
        endorsers:
          escc:
            name: DefaultEndorsement
        validators:
          vscc:
            name: DefaultValidation

当背书或验证的实现被编译到节点中，``name`` 属性就代表了即将运行的初始化函数，以便获得生成背书或验证逻辑相关实例的工厂。

该函数是基于 ``core/handlers/library/library.go`` 构建的 ``HandlerLibrary`` 的实例方法。并且为添加自定义背书或验证逻辑，需要使用其他方法对该架构进行扩展。

由于这种方法十分繁琐，而且还给逻辑部署带来巨大挑战，因此用户可以通过在 ``name`` 属性下增加另一个名为 ``library`` 的属性来将自定义背书和验证部署为一个 Golang 插件。

比如，如果我们有被作为插件来实现的自定义背书和验证逻辑，那么 ``core.yaml`` 的配置中就会有以下记录：

.. code-block:: YAML

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

并且我们需要把 ``.so`` 插件文件放置在节点的本地文件系统中。

.. note:: Hereafter, custom endorsement or validation logic implementation is
          going to be referred to as "plugins", even if they are compiled into
          the peer.

背书插件的实现
---------------------------------

若要实现一个背书插件，用户必须实现 ``core/handlers/endorsement/api/endorsement.go`` 中的 ``Plugin`` 界面。

.. code-block:: Go

    // Plugin endorses a proposal response
    type Plugin interface {
    	// Endorse signs the given payload(ProposalResponsePayload bytes), and optionally mutates it.
    	// Returns:
    	// The Endorsement: A signature over the payload, and an identity that is used to verify the signature
    	// The payload that was given as input (could be modified within this function)
    	// Or error on failure
    	Endorse(payload []byte, sp *peer.SignedProposal) (*peer.Endorsement, []byte, error)

    	// Init injects dependencies into the instance of the Plugin
    	Init(dependencies ...Dependency) error
    }

通过让节点调用  ``PluginFactory`` 界面的 New  方法，为每个通道创建一个给定插件类型（或是通过方法名称被识别为  ``HandlerLibrary``   的实例方法，亦或是通过插件  ``.so``   文件路径被识别为HandlerLibrary 的实例方法）的背书插件实例，该 ``New``   方法预计也将由插件开发人员实现。

.. code-block:: Go

    // PluginFactory creates a new instance of a Plugin
    type PluginFactory interface {
    	New() Plugin
    }

``Init`` 方法预计将接收在 ``core/handlers/endorsement/api/`` 中声明的所有依赖项作为输入，并将其标识为嵌入 ``Dependency`` 界面。

创建了 ``Plugin`` 实例后，节点在实例上调用 ``Init`` 方法，并且把 ``dependencies`` 作为参数来通过。

目前，Fabric 存在以下背书插件的依赖项：

- ``SigningIdentityFetcher``：返回一个基于给定的签署提案的 ``SigningIdentity`` 示例

.. code-block:: Go

    // SigningIdentity signs messages and serializes its public identity to bytes
    type SigningIdentity interface {
    	// Serialize returns a byte representation of this identity which is used to verify
    	// messages signed by this SigningIdentity
    	Serialize() ([]byte, error)

    	// Sign signs the given payload and returns a signature
    	Sign([]byte) ([]byte, error)
    }

- ``StateFetcher``：获取一个与世界状态交互的 **状态** 对象

.. code-block:: Go

    // State defines interaction with the world state
    type State interface {
    	// GetPrivateDataMultipleKeys gets the values for the multiple private data items in a single call
    	GetPrivateDataMultipleKeys(namespace, collection string, keys []string) ([][]byte, error)

    	// GetStateMultipleKeys gets the values for multiple keys in a single call
    	GetStateMultipleKeys(namespace string, keys []string) ([][]byte, error)

    	// GetTransientByTXID gets the values private data associated with the given txID
    	GetTransientByTXID(txID string) ([]*rwset.TxPvtReadWriteSet, error)

    	// Done releases resources occupied by the State
    	Done()
     }

验证插件实现
--------------------------------

要实现一个验证插件，用户必须实现 ``core/handlers/validation/api/validation.go`` 中的 ``Plugin`` 界面：

.. code-block:: Go

    // Plugin validates transactions
    type Plugin interface {
    	// Validate returns nil if the action at the given position inside the transaction
    	// at the given position in the given block is valid, or an error if not.
    	Validate(block *common.Block, namespace string, txPosition int, actionPosition int, contextData ...ContextDatum) error

    	// Init injects dependencies into the instance of the Plugin
    	Init(dependencies ...Dependency) error
    }

每个 ``ContextDatum`` 都是运行时派生的额外元数据，由节点负责传递给验证插件。目前，代表链码背书政策的  ``ContextDatum``  是唯一被传递的一个 。

.. code-block:: Go

   // SerializedPolicy defines a serialized policy
  type SerializedPolicy interface {
	validation.ContextDatum

	// Bytes returns the bytes of the SerializedPolicy
	Bytes() []byte
   }

与上述的背书插件一样，通过让节点调用  ``PluginFactory``   接口的 New 方法，为每个通道创建一个给定插件类型（或是通过方法名称被识别为  ``HandlerLibrary``  的实例方法，亦或是通过插件 ``.so`` 文件路径被识别为 ``HandlerLibrary``  的实例方法）的验证插件实例，该 New 方法预计也将由插件开发人员实现。

.. code-block:: Go

    // PluginFactory creates a new instance of a Plugin
    type PluginFactory interface {
    	New() Plugin
    }

``Init``  方法预计将接收在  ``core/handlers/validation/api/``中声明的所有依赖项作为输入，并将其标识为嵌入  ``Dependency``  界面。

创建了  ``Plugin``  实例后，节点会在实例上调用 **Init** 方法，并且把 dependencies 作为参数来通过。

目前，Fabric存在以下验证插件的依赖项：

- ``IdentityDeserializer``：将身份的字节表示转换为 ``Identity`` 对象，该对象可用于验证由这些身份所签署的签名，还能根据这些身份各自的成员服务提供者（MSP）来对自身进行验证，以确保它们满给定的 **MSP 准则**。  ``core/handlers/validation/api/identities/identities.go`` 中包含了全部的规范。

- ``PolicyEvaluator``：评估被给定的策略是否满足要求：

.. code-block:: Go

    // PolicyEvaluator evaluates policies
    type PolicyEvaluator interface {
    	validation.Dependency

    	// Evaluate takes a set of SignedData and evaluates whether this set of signatures satisfies
    	// the policy with the given bytes
    	Evaluate(policyBytes []byte, signatureSet []*common.SignedData) error
    }

- ``StateFetcher``：获取一个与世界状态交互的  ``State``  对象：

.. code-block:: Go

    // State defines interaction with the world state
    type State interface {
        // GetStateMultipleKeys gets the values for multiple keys in a single call
        GetStateMultipleKeys(namespace string, keys []string) ([][]byte, error)

        // GetStateRangeScanIterator returns an iterator that contains all the key-values between given key ranges.
        // startKey is included in the results and endKey is excluded. An empty startKey refers to the first available key
        // and an empty endKey refers to the last available key. For scanning all the keys, both the startKey and the endKey
        // can be supplied as empty strings. However, a full scan should be used judiciously for performance reasons.
        // The returned ResultsIterator contains results of type *KV which is defined in protos/ledger/queryresult.
        GetStateRangeScanIterator(namespace string, startKey string, endKey string) (ResultsIterator, error)

        // GetStateMetadata returns the metadata for given namespace and key
        GetStateMetadata(namespace, key string) (map[string][]byte, error)

        // GetPrivateDataMetadata gets the metadata of a private data item identified by a tuple <namespace, collection, key>
        GetPrivateDataMetadata(namespace, collection, key string) (map[string][]byte, error)

        // Done releases resources occupied by the State
        Done()
    }

重要提示
---------------

- **各节点上的验证插件保持一致：** 在后期版本中，Fabric 通道基础设施将确保在给定区块链高度上，通道内所有节点对给定链码使用相同的验证逻辑，以消除可能导致节点间状态分歧的错误配置风险，若发生错配置，则可能会致使节点运行不同的实现。但就目前来说，系统操作员和管理员的唯一责任就是确保以上问题不会发生。

- **验证插件错误处理：** 当因发生某些暂时性执行问题（比如无法访问数据库）而导致验证插件不能确定一给定交易是否有效时，插件应返回 ``core/handlers/validation/api/validation.go`` 中定义的 *执行失败错误* 类错误。任何其他被返回的错误将被视为背书策略错误，并且被验证逻辑标记为无效。但是，若返回的错误是 ``ExecutionFailureError``   ，区块链处理不会将该交易标志为无效，而是暂停该易。目的是防止不同节点之间发生状态分歧。

- **私有元数据索取的错误处理：** 当一个插件利用 ``StateFetcher`` 界面来为私有数据索取元数据，错误处理必须遵循以下方法：

- **将Fabric代码导入插件：** 如果把 Fabric 代码导入插件，当代码随着版本升级而改变时可能会产生一些问题；其次，当运行混合节点版本时，可能行不通。因此，不建议将 Fabric 代码导入插件。理想状况下插件代码应该仅使用为其提供的依赖项，并且应导入除 protobufs 之外的最低限度。

  .. Licensed under Creative Commons Attribution 4.0 International License
     https://creativecommons.org/licenses/by/4.0/