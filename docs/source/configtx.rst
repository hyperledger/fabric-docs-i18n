Channel Configuration (configtx) - 通道配置（configtx）
================================

Shared configuration for a Hyperledger Fabric blockchain network is
stored in a collection configuration transactions, one per channel. Each
configuration transaction is usually referred to by the shorter name
*configtx*.

在Hyperledger Fabric区块链网络中，每一个通道的共享配置都保存在一个配置事务集合中。每个一个配置事务通常简称为*configtx*。

Channel configuration has the following important properties:

通道配置有以下重要属性：

1. **Versioned**: All elements of the configuration have an associated
   version which is advanced with every modification. Further, every
   committed configuration receives a sequence number.

1. **版本化** ：配置中所有中的元素都关联了一个版本号，每次变动该版本号都会更新。另外，每次提交配置都会收到一个序列号。

2. **Permissioned**: Each element of the configuration has an associated
   policy which governs whether or not modification to that element is
   permitted. Anyone with a copy of the previous configtx (and no
   additional info) may verify the validity of a new config based on
   these policies.

2. **权限化** ：配置中的所有元素都关联了一个策略，用来管理是否有权限修改一个元素。所有拥有前一个configtx的人（不需要其他信息）就可以通过这些策略来验证新配置的有效性。

3. **Hierarchical**: A root configuration group contains sub-groups, and
   each group of the hierarchy has associated values and policies. These
   policies can take advantage of the hierarchy to derive policies at
   one level from policies of lower levels.

3. **层级化** ：每一个根配置组包含子组，层级中每一个组都有相关联的数值和策略。这些策略可以利用层级关系从更低层的策略中派生出一个层级的策略。

Anatomy of a configuration - 一个配置的剖析
--------------------------

Configuration is stored as a transaction of type ``HeaderType_CONFIG``
in a block with no other transactions. These blocks are referred to as
*Configuration Blocks*, the first of which is referred to as the
*Genesis Block*.

配置是一个存储在区块中类型为 ``HeaderType_CONFIG`` 的交易，该区块中没有其他交易。这些区块被称为 *配置区块* ，他们的第一个区块也被称为 *创世区块* 。

The proto structures for configuration are stored in
``fabric/protos/common/configtx.proto``. The Envelope of type
``HeaderType_CONFIG`` encodes a ``ConfigEnvelope`` message as the
``Payload`` ``data`` field. The proto for ``ConfigEnvelope`` is defined
as follows:

配置的proto结构保存在 ``fabric/protos/common/configtx.proto`` 。信封类型 ``HeaderType_CONFIG`` 编码一个 ``ConfigEnvelope`` 消息作为 ``Payload`` ``data`` 字段。 ``ConfigEnvelope`` 的proto的定义如下：

::

    message ConfigEnvelope {
        Config config = 1;
        Envelope last_update = 2;
    }

The ``last_update`` field is defined below in the **Updates to
configuration** section, but is only necessary when validating the
configuration, not reading it. Instead, the currently committed
configuration is stored in the ``config`` field, containing a ``Config``
message.

``last_update`` 字段的定义在下边的 **Updates to configuration** 节中，但是只在验证配置的时候才有必要，并不读取它。相反，现在提交的配置保存在 ``config`` 域中，包含一个 ``Config`` 消息。

::

    message Config {
        uint64 sequence = 1;
        ConfigGroup channel_group = 2;
    }

The ``sequence`` number is incremented by one for each committed
configuration. The ``channel_group`` field is the root group which
contains the configuration. The ``ConfigGroup`` structure is recursively
defined, and builds a tree of groups, each of which contains values and
policies. It is defined as follows:

``sequence`` 编号是每次提交配置的时候加1。 ``channel_group`` 字段是包含的配置的根组。 ``ConfigGroup`` 结构是递归定义，构建了一个由组构成的树，每一个都包含值和策略。它的定义如下:

::

    message ConfigGroup {
        uint64 version = 1;
        map<string,ConfigGroup> groups = 2;
        map<string,ConfigValue> values = 3;
        map<string,ConfigPolicy> policies = 4;
        string mod_policy = 5;
    }

Because ``ConfigGroup`` is a recursive structure, it has hierarchical
arrangement. The following example is expressed for clarity in golang
notation.

因为 ``ConfigGroup`` 是一个递归的结构，它就有了层级的布局。下边是为了清楚表达这个内容的一个用golang表示的例子。

::

    // Assume the following groups are defined
    var root, child1, child2, grandChild1, grandChild2, grandChild3 *ConfigGroup

    // Set the following values
    root.Groups["child1"] = child1
    root.Groups["child2"] = child2
    child1.Groups["grandChild1"] = grandChild1
    child2.Groups["grandChild2"] = grandChild2
    child2.Groups["grandChild3"] = grandChild3

    // The resulting config structure of groups looks like:
    // root:
    //     child1:
    //         grandChild1
    //     child2:
    //         grandChild2
    //         grandChild3

Each group defines a level in the config hierarchy, and each group has
an associated set of values (indexed by string key) and policies (also
indexed by string key).

每个组都在配置层级中定义了一个级别，每个组都有一个相关联的值（字符键做索引）和策略（也是字符键做索引）的集合。

Values are defined by:

值被定义为：

::

    message ConfigValue {
        uint64 version = 1;
        bytes value = 2;
        string mod_policy = 3;
    }

Policies are defined by:

策略被定义为：

::

    message ConfigPolicy {
        uint64 version = 1;
        Policy policy = 2;
        string mod_policy = 3;
    }

Note that Values, Policies, and Groups all have a ``version`` and a
``mod_policy``. The ``version`` of an element is incremented each time
that element is modified. The ``mod_policy`` is used to govern the
required signatures to modify that element. For Groups, modification is
adding or removing elements to the Values, Policies, or Groups maps (or
changing the ``mod_policy``). For Values and Policies, modification is
changing the Value and Policy fields respectively (or changing the
``mod_policy``). Each element's ``mod_policy`` is evaluated in the
context of the current level of the config. Consider the following
example mod policies defined at ``Channel.Groups["Application"]`` (Here,
we use the golang map reference syntax, so
``Channel.Groups["Application"].Policies["policy1"]`` refers to the base
``Channel`` group's ``Application`` group's ``Policies`` map's
``policy1`` policy.)

注意到值，策略和组都有一个 ``version`` 和一个 ``mod_policy`` 。 元素的 ``version`` 在每次元素被修改的时候都会递增。对于组，修改就是增加或删除值，策略或者组映射中的元素（或者改变 ``mod_policy`` ）。对于值和策略，修改就是分别改变值和策略字段（或者改变 ``mod_policy`` ）。每一个元素的 ``mod_policy`` 都是在当前级别配置上下文中被评定的。考虑一下下边例子中 ``Channel.Groups["Application"]`` 定义的策略模块。（这里，我们使用 golang 映射的参考语法，所以 ``Channel.Groups["Application"].Policies["policy1"]`` 表示基 ``Channel`` 组的 ``Application`` 组的 ``Policies`` 映射的 ``policy1`` 策略。）

* ``policy1`` maps to ``Channel.Groups["Application"].Policies["policy1"]``
* ``Org1/policy2`` maps to
  ``Channel.Groups["Application"].Groups["Org1"].Policies["policy2"]``
* ``/Channel/policy3`` maps to ``Channel.Policies["policy3"]``

Note that if a ``mod_policy`` references a policy which does not exist,
the item cannot be modified.

注意，如果一个 ``mod_policy`` 引用一个不存在的策略，这个条目就不会被更改。

Configuration updates - 配置升级
---------------------

Configuration updates are submitted as an ``Envelope`` message of type
``HeaderType_CONFIG_UPDATE``. The ``Payload`` ``data`` of the
transaction is a marshaled ``ConfigUpdateEnvelope``. The ``ConfigUpdateEnvelope``
is defined as follows:

配置升级就是提交一个 ``HeaderType_CONFIG_UPDATE`` 类型的 ``Envelope`` 消息。 交易的 ``Payload`` ``data`` 就是一个被封送的 ``ConfigUpdateEnvelope`` 。 ``ConfigUpdateEnvelope`` 的定义如下：                    

::

    message ConfigUpdateEnvelope {
        bytes config_update = 1;
        repeated ConfigSignature signatures = 2;
    }

The ``signatures`` field contains the set of signatures which authorizes
the config update. Its message definition is:

``signatures`` 字段包含一个授权配置更新的签名。它的消息定义是：

::

    message ConfigSignature {
        bytes signature_header = 1;
        bytes signature = 2;
    }

The ``signature_header`` is as defined for standard transactions, while
the signature is over the concatenation of the ``signature_header``
bytes and the ``config_update`` bytes from the ``ConfigUpdateEnvelope``
message.

``signature_header`` 被定义为标准交易，但是签名是来自 ``ConfigUpdateEnvelope`` 消息中 ``signature_header`` 字节和 ``config_update`` 字节的串联。

The ``ConfigUpdateEnvelope`` ``config_update`` bytes are a marshaled
``ConfigUpdate`` message which is defined as follows:

``ConfigUpdateEnvelope`` ``config_update`` 字节是一个封送的 ``ConfigUpdate`` 消息，定义如下： 

::

    message ConfigUpdate {
        string channel_id = 1;
        ConfigGroup read_set = 2;
        ConfigGroup write_set = 3;
    }

The ``channel_id`` is the channel ID the update is bound for, this is
necessary to scope the signatures which support this reconfiguration.

``channel_id`` 是更新绑定的通道ID，这对于支持这次重配置的签名范围是必要的。

The ``read_set`` specifies a subset of the existing configuration,
specified sparsely where only the ``version`` field is set and no other
fields must be populated. The particular ``ConfigValue`` ``value`` or
``ConfigPolicy`` ``policy`` fields should never be set in the
``read_set``. The ``ConfigGroup`` may have a subset of its map fields
populated, so as to reference an element deeper in the config tree. For
instance, to include the ``Application`` group in the ``read_set``, its
parent (the ``Channel`` group) must also be included in the read set,
but, the ``Channel`` group does not need to populate all of the keys,
such as the ``Orderer`` ``group`` key, or any of the ``values`` or
``policies`` keys.

``read_set`` 稀疏地指定现有配置的一个子集，其中只设置版本字段，而不必填充其他字段。不应该在 ``read_set`` 中设置 ``ConfigValue`` ``value`` 或 ``ConfigPolicy`` ``policy`` 字段。 ``ConfigGroup`` 可以填充其映射字段的子集，以便引用配置树中更深的元素。例如，要在 ``read_set`` 中包含 ``Application`` 组，其父级（ ``Channel`` 组）也必须包含在读取集中，但 ``Channel`` 组不需要填充所有键，例如 ``Orderer`` ``group`` 键， 或任何 ``values`` 或 ``policies`` 键。

The ``write_set`` specifies the pieces of configuration which are
modified. Because of the hierarchical nature of the configuration, a
write to an element deep in the hierarchy must contain the higher level
elements in its ``write_set`` as well. However, for any element in the
``write_set`` which is also specified in the ``read_set`` at the same
version, the element should be specified sparsely, just as in the
``read_set``.

``write_set`` 指定配置中需要修改的部分。因为配置的阶层性，对于层次结构深的元素的写入必须在其 ``write_set`` 中包含更高级别的元素。同时，每一个在 ``write_set`` 包含的元素也会在 ``read_set`` 中以同样的版本指定，这些元素也应该是像 ``read_set`` 中一样稀疏指定。

For example, given the configuration:

比如，给定配置：

::

    Channel: (version 0)
        Orderer (version 0)
        Application (version 3)
           Org1 (version 2)

To submit a configuration update which modifies ``Org1``, the
``read_set`` would be:

提交一个修改 ``Org1`` 的配置更新， ``read_set`` 应该是：

::

    Channel: (version 0)
        Application: (version 3)

and the ``write_set`` would be

``write_set`` 应该是：

::

    Channel: (version 0)
        Application: (version 3)
            Org1 (version 3)

When the ``CONFIG_UPDATE`` is received, the orderer computes the
resulting ``CONFIG`` by doing the following:

当接收到 ``CONFIG_UPDATE`` 以后，排序节点按照下边的方式计算 ``CONFIG`` 的结果： 
1. Verifies the ``channel_id`` and ``read_set``. All elements in the
   ``read_set`` must exist at the given versions.

1. 验证 ``channel_id`` 和 ``read_set`` 。``read_set`` 中所有元素必须以给定的版本存在。

2. Computes the update set by collecting all elements in the
   ``write_set`` which do not appear at the same version in the
   ``read_set``.

2. 搜集所有在 ``write_set`` 中但没有以相同的版本在 ``read_set`` 中的元素以计算更新集。

3. Verifies that each element in the update set increments the version
   number of the element update by exactly 1.

3. 验证每一个更新集中的元素的版本号增加了1。

4. Verifies that the signature set attached to the
   ``ConfigUpdateEnvelope`` satisfies the ``mod_policy`` for each
   element in the update set.

4. 验证更新集中的每一个元素的签名集附属的 ``ConfigUpdateEnvelope`` 满足 ``mod_policy`` 。

5. Computes a new complete version of the config by applying the update
   set to the current config.

5. 将更新集应用到当前配置来计算配置的一个新的完整版本。

6. Writes the new config into a ``ConfigEnvelope`` which includes the
   ``CONFIG_UPDATE`` as the ``last_update`` field and the new config
   encoded in the ``config`` field, along with the incremented
   ``sequence`` value.

6. 将新配置写入一个 ``ConfigEnvelope`` ，其中包含 ``CONFIG_UPDATE`` 作为 ``last_update`` 字段， 新配置被编码为 ``config`` 字段，同时 ``sequence`` 的值递增。

7. Writes the new ``ConfigEnvelope`` into a ``Envelope`` of type
   ``CONFIG``, and ultimately writes this as the sole transaction in a
   new configuration block.

7. 将新 ``ConfigEnvelope`` 写入一个 ``Envelope`` 类型的 ``CONFIG`` ， 最终将这作为专有交易写入一个配置区块。

When the peer (or any other receiver for ``Deliver``) receives this
configuration block, it should verify that the config was appropriately
validated by applying the ``last_update`` message to the current config
and verifying that the orderer-computed ``config`` field contains the
correct new configuration.

当节点（或者其他 ``Deliver`` 的接收者）接收到这个配置区块的时候，它会通过将 ``last_update`` 消息应用到当前配置和验证排序节点计算的 ``config`` 字段包含当前的新配置的方式来验证这个配置是否被合理的验证了。 

Permitted configuration groups and values - 被许可的配置组和值
-----------------------------------------

Any valid configuration is a subset of the following configuration. Here
we use the notation ``peer.<MSG>`` to define a ``ConfigValue`` whose
``value`` field is a marshaled proto message of name ``<MSG>`` defined
in ``fabric/protos/peer/configuration.proto``. The notations
``common.<MSG>``, ``msp.<MSG>``, and ``orderer.<MSG>`` correspond
similarly, but with their messages defined in
``fabric/protos/common/configuration.proto``,
``fabric/protos/msp/mspconfig.proto``, and
``fabric/protos/orderer/configuration.proto`` respectively.

所有有效的配置都是如下配置的子集。这里我们使用标记 ``peer.<MSG>`` 定义一个 ``ConfigValue`` ， ``ConfigValue`` 的 ``value`` 字段是一个定义在 ``fabric/protos/peer/configuration.proto`` 的名字为 ``<MSG>`` 的封送proto消息。标记 ``common.<MSG>`` ， ``msp.<MSG>`` ，和 ``orderer.<MSG>`` 是类似的，他们消息的定义分别是
``fabric/protos/common/configuration.proto`` ，
``fabric/protos/msp/mspconfig.proto`` ， 和 
``fabric/protos/orderer/configuration.proto`` 。

Note, that the keys ``{{org_name}}`` and ``{{consortium_name}}``
represent arbitrary names, and indicate an element which may be repeated
with different names.

注意，键值 ``{{org_name}}`` 和 ``{{consortium_name}}`` 表示任意名称，也表明一个元素可能被重复指定为不同的名字。

::

    &ConfigGroup{
        Groups: map<string, *ConfigGroup> {
            "Application":&ConfigGroup{
                Groups:map<String, *ConfigGroup> {
                    {{org_name}}:&ConfigGroup{
                        Values:map<string, *ConfigValue>{
                            "MSP":msp.MSPConfig,
                            "AnchorPeers":peer.AnchorPeers,
                        },
                    },
                },
            },
            "Orderer":&ConfigGroup{
                Groups:map<String, *ConfigGroup> {
                    {{org_name}}:&ConfigGroup{
                        Values:map<string, *ConfigValue>{
                            "MSP":msp.MSPConfig,
                        },
                    },
                },

                Values:map<string, *ConfigValue> {
                    "ConsensusType":orderer.ConsensusType,
                    "BatchSize":orderer.BatchSize,
                    "BatchTimeout":orderer.BatchTimeout,
                    "KafkaBrokers":orderer.KafkaBrokers,
                },
            },
            "Consortiums":&ConfigGroup{
                Groups:map<String, *ConfigGroup> {
                    {{consortium_name}}:&ConfigGroup{
                        Groups:map<string, *ConfigGroup> {
                            {{org_name}}:&ConfigGroup{
                                Values:map<string, *ConfigValue>{
                                    "MSP":msp.MSPConfig,
                                },
                            },
                        },
                        Values:map<string, *ConfigValue> {
                            "ChannelCreationPolicy":common.Policy,
                        }
                    },
                },
            },
        },

        Values: map<string, *ConfigValue> {
            "HashingAlgorithm":common.HashingAlgorithm,
            "BlockHashingDataStructure":common.BlockDataHashingStructure,
            "Consortium":common.Consortium,
            "OrdererAddresses":common.OrdererAddresses,
        },
    }

Orderer system channel configuration - 排序系统通道配置
------------------------------------

The ordering system channel needs to define ordering parameters, and
consortiums for creating channels. There must be exactly one ordering
system channel for an ordering service, and it is the first channel to
be created (or more accurately bootstrapped). It is recommended never to
define an Application section inside of the ordering system channel
genesis configuration, but may be done for testing. Note that any member
with read access to the ordering system channel may see all channel
creations, so this channel's access should be restricted.

排序系统通道需要为创建通道定义排序参数和联盟。必须有一个排序系统通道提供排序服务，而且它是被创建（或者更准确地引导）的第一个通道。建议不要在排序配置通道中定义应用部分，但是在测试的时候可以。注意，所有在排序系统通道拥有读权限的成员都可以看到所有通道创建，所以应该限制通道的访问。

The ordering parameters are defined as the following subset of config:

排序参数被定义为如下配置的子集：

::

    &ConfigGroup{
        Groups: map<string, *ConfigGroup> {
            "Orderer":&ConfigGroup{
                Groups:map<String, *ConfigGroup> {
                    {{org_name}}:&ConfigGroup{
                        Values:map<string, *ConfigValue>{
                            "MSP":msp.MSPConfig,
                        },
                    },
                },

                Values:map<string, *ConfigValue> {
                    "ConsensusType":orderer.ConsensusType,
                    "BatchSize":orderer.BatchSize,
                    "BatchTimeout":orderer.BatchTimeout,
                    "KafkaBrokers":orderer.KafkaBrokers,
                },
            },
        },

Each organization participating in ordering has a group element under
the ``Orderer`` group. This group defines a single parameter ``MSP``
which contains the cryptographic identity information for that
organization. The ``Values`` of the ``Orderer`` group determine how the
ordering nodes function. They exist per channel, so
``orderer.BatchTimeout`` for instance may be specified differently on
one channel than another.

每一个参与到排序的组织在 ``Orderer`` 组下都有一个组元素。这个组定义了单独的包含这个组织加密身份信息的参数 ``MSP`` 。 ``Orderer`` 组中的 ``Values`` 决定排序节点的功能。他们存在于每一个通道，所以在不同通道的实例的 ``orderer.BatchTimeout`` 可能指定的不同。

At startup, the orderer is faced with a filesystem which contains
information for many channels. The orderer identifies the system channel
by identifying the channel with the consortiums group defined. The
consortiums group has the following structure.

在开始的时候，一个排序节点会面临一个包含很多通道的信息的文件系统。排序节点通过识别通道中联盟组的定义来识别系统通道。联盟组有如下结构：

::

    &ConfigGroup{
        Groups: map<string, *ConfigGroup> {
            "Consortiums":&ConfigGroup{
                Groups:map<String, *ConfigGroup> {
                    {{consortium_name}}:&ConfigGroup{
                        Groups:map<string, *ConfigGroup> {
                            {{org_name}}:&ConfigGroup{
                                Values:map<string, *ConfigValue>{
                                    "MSP":msp.MSPConfig,
                                },
                            },
                        },
                        Values:map<string, *ConfigValue> {
                            "ChannelCreationPolicy":common.Policy,
                        }
                    },
                },
            },
        },
    },

Note that each consortium defines a set of members, just like the
organizational members for the ordering orgs. Each consortium also
defines a ``ChannelCreationPolicy``. This is a policy which is applied
to authorize channel creation requests. Typically, this value will be
set to an ``ImplicitMetaPolicy`` requiring that the new members of the
channel sign to authorize the channel creation. More details about
channel creation follow later in this document.

注意，每一个联盟都定义了一个成员集合，就像排序组织中的组织成员一样。每一个联盟也定义了一个 ``ChannelCreationPolicy`` 。这是一个用于授权通道创建请求的策略。通常，这个值被设置为一个让通道中新成员签发授权通道创建请求的 ``ImplicitMetaPolicy`` 请求。本文档的后边会有更多关于创建通道的细节。

Application channel configuration - 应用通道配置
---------------------------------

Application configuration is for channels which are designed for
application type transactions. It is defined as follows:

应用配置是为应用类型交易设计的。它的定义如下：

::

    &ConfigGroup{
        Groups: map<string, *ConfigGroup> {
            "Application":&ConfigGroup{
                Groups:map<String, *ConfigGroup> {
                    {{org_name}}:&ConfigGroup{
                        Values:map<string, *ConfigValue>{
                            "MSP":msp.MSPConfig,
                            "AnchorPeers":peer.AnchorPeers,
                        },
                    },
                },
            },
        },
    }

Just like with the ``Orderer`` section, each organization is encoded as
a group. However, instead of only encoding the ``MSP`` identity
information, each org additionally encodes a list of ``AnchorPeers``.
This list allows the peers of different organizations to contact each
other for peer gossip networking.

就像 ``Orderer`` 部分，每一个组织都被编码成一个组。然而，每一个组织都会编码一个 ``AnchorPeers`` 身份信息列表，而不是值编码一个 ``MSP`` 身份信息。这个列表允许不同组织的节点通过节点gossip网络互相通信。

The application channel encodes a copy of the orderer orgs and consensus
options to allow for deterministic updating of these parameters, so the
same ``Orderer`` section from the orderer system channel configuration
is included. However from an application perspective this may be largely
ignored.

应用通道编码一个排序组织和共识选项的拷贝用来动态更新这些参数，排序系统通道配置中的 ``Orderer`` 部分也一样。然而，从应用程序的角度来看，这在很大程度上可以忽略。

Channel creation - 通道创建
----------------

When the orderer receives a ``CONFIG_UPDATE`` for a channel which does
not exist, the orderer assumes that this must be a channel creation
request and performs the following.

当排序节点接收到一个不存在的通道的 ``CONFIG_UPDATE`` 的时候，排序节点会认为这是一个通道创建请求并执行如下操作。

1. The orderer identifies the consortium which the channel creation
   request is to be performed for. It does this by looking at the
   ``Consortium`` value of the top level group.

1. 排序节点会识别通道创建请求要创建哪些联盟。它通过查找最顶层组的 ``Consortium`` 值来做到这一点。

2. The orderer verifies that the organizations included in the
   ``Application`` group are a subset of the organizations included in
   the corresponding consortium and that the ``ApplicationGroup`` is set
   to ``version`` ``1``.

2. 排序节点验证包含在 ``Application`` 组中的组织是相应联盟中组织的一个子集并且 ``ApplicationGroup`` 被设置为 ``version`` ``1`` 。

3. The orderer verifies that if the consortium has members, that the new
   channel also has application members (creation consortiums and
   channels with no members is useful for testing only).

3. 排序节点闫恒联盟中是否有成员，新通道也有应用成员（只在测试的时候创建没有成员的通道和联盟是有用的）。

4. The orderer creates a template configuration by taking the
   ``Orderer`` group from the ordering system channel, and creating an
   ``Application`` group with the newly specified members and specifying
   its ``mod_policy`` to be the ``ChannelCreationPolicy`` as specified
   in the consortium config. Note that the policy is evaluated in the
   context of the new configuration, so a policy requiring ``ALL``
   members, would require signatures from all the new channel members,
   not all the members of the consortium.

4. 排序节点通过获取排序系统通道中的 ``Orderer`` 组，以及创建一个新指定成员的 ``Application`` 组并将它的 ``mod_policy`` 指定为联盟配置中的 ``ChannelCreationPolicy`` ，来创建一个配置模板。注意，策略是通过新配置的上下文中评估出来的，所以一个需要请求 ``ALL`` 成员的策略，将请求所有新通道成员的签名，而不是联盟中所有的成员。

5. The orderer then applies the ``CONFIG_UPDATE`` as an update to this
   template configuration. Because the ``CONFIG_UPDATE`` applies
   modifications to the ``Application`` group (its ``version`` is
   ``1``), the config code validates these updates against the
   ``ChannelCreationPolicy``. If the channel creation contains any other
   modifications, such as to an individual org's anchor peers, the
   corresponding mod policy for the element will be invoked.

5. 排序节点将 ``CONFIG_UPDATE`` 作为一个更新应用到这个模板配置。因为 ``CONFIG_UPDATE`` 在 ``Application`` 组中应用了变更（它的 ``version`` 是 ``1`` ），所以配置代码会通过 ``ChannelCreationPolicy`` 来验证这些更新。如果通道创建包含了任何其他变更，比如单个组织的锚节点的修改，将调用该元素相关的策略。

6. The new ``CONFIG`` transaction with the new channel config is wrapped
   and sent for ordering on the ordering system channel. After ordering,
   the channel is created.

6. 新的通道配置的新 ``CONFIG`` 交易会被打包并发送给系统排序通道进行排序。排完续后通道就被建立了。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/

