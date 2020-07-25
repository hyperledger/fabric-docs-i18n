# peer lifecycle chaincode

`peer lifecycle chaincode`子命令允许管理员使用Fabric链码生命周期来打包链码，在节点上安装链码，为组织审核链码的定义，然后提交链码的定义到通道。当链码的定义被成功提交通道之后就可以使用链码了。有关更多信息，请访问[链码运维人员教程](../chaincode4noah.html)。

The `peer lifecycle chaincode` subcommand allows administrators to use the
Fabric chaincode lifecycle to package a chaincode, install it on your peers,
approve a chaincode definition for your organization, and then commit the
definition to a channel. The chaincode is ready to be used after the definition
has been successfully committed to the channel. For more information, visit
[Fabric chaincode lifecycle](../chaincode_lifecycle.html).

*注意：这些说明使用的是Fabric v2.0版本引入的链码生命周期。如果你想使用旧的生命周期进行安装和实例化链码，请访问[peer chaincode](peerchaincode.html)命令参考。*

*Note: These instructions use the Fabric chaincode lifecycle introduced in the
v2.0 release. If you would like to use the old lifecycle to install and
instantiate a chaincode, visit the [peer chaincode](peerchaincode.html) command
reference.*

## 语法

## Syntax

`peer lifecycle chaincode`命令有以下子命令：

The `peer lifecycle chaincode` command has the following subcommands:

  * package
  * install
  * queryinstalled
  * getinstalledpackage
  * approveformyorg
  * checkcommitreadiness
  * commit
  * querycommitted

  * package
  * install
  * queryinstalled
  * getinstalledpackage
  * approveformyorg
  * queryapproved
  * checkcommitreadiness
  * commit
  * querycommitted

每个链码生命周期子命令的描述和选项都在本主题对应的章节中。

Each peer lifecycle chaincode subcommand is described together with its options in its own
section in this topic.

## peer lifecycle
```
Perform _lifecycle operations

Usage:
  peer lifecycle [command]

Available Commands:
  chaincode   Perform chaincode operations: package|install|queryinstalled|getinstalledpackage|approveformyorg|checkcommitreadiness|commit|querycommitted

Available Commands:
  chaincode   Perform chaincode operations: package|install|queryinstalled|getinstalledpackage|approveformyorg|queryapproved|checkcommitreadiness|commit|querycommitted

Flags:
  -h, --help   help for lifecycle

Use "peer lifecycle [command] --help" for more information about a command.
```


## peer lifecycle chaincode
```
Perform chaincode operations: package|install|queryinstalled|getinstalledpackage|approveformyorg|checkcommitreadiness|commit|querycommitted

## peer lifecycle chaincode
```
Perform chaincode operations: package|install|queryinstalled|getinstalledpackage|approveformyorg|queryapproved|checkcommitreadiness|commit|querycommitted

Usage:
  peer lifecycle chaincode [command]

Available Commands:
  approveformyorg      Approve the chaincode definition for my org.
  checkcommitreadiness Check whether a chaincode definition is ready to be committed on a channel.
  commit               Commit the chaincode definition on the channel.
  getinstalledpackage  Get an installed chaincode package from a peer.
  install              Install a chaincode.
  package              Package a chaincode
  querycommitted       Query the committed chaincode definitions by channel on a peer.
  queryinstalled       Query the installed chaincodes on a peer.

Available Commands:
  approveformyorg      Approve the chaincode definition for my org.
  checkcommitreadiness Check whether a chaincode definition is ready to be committed on a channel.
  commit               Commit the chaincode definition on the channel.
  getinstalledpackage  Get an installed chaincode package from a peer.
  install              Install a chaincode.
  package              Package a chaincode
  queryapproved        Query an org's approved chaincode definition from its peer.
  querycommitted       Query the committed chaincode definitions by channel on a peer.
  queryinstalled       Query the installed chaincodes on a peer.

Flags:
      --cafile string                       Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --certfile string                     Path to file containing PEM-encoded X509 public key to use for mutual TLS communication with the orderer endpoint
      --clientauth                          Use mutual TLS when communicating with the orderer endpoint
      --connTimeout duration                Timeout for client to connect (default 3s)
  -h, --help                                help for chaincode
      --keyfile string                      Path to file containing PEM-encoded private key to use for mutual TLS communication with the orderer endpoint
  -o, --orderer string                      Ordering service endpoint
      --ordererTLSHostnameOverride string   The hostname override to use when validating the TLS connection to the orderer.
      --tls                                 Use TLS when communicating with the orderer endpoint

Use "peer lifecycle chaincode [command] --help" for more information about a command.
```


## peer lifecycle chaincode package
```
Package a chaincode and write the package to a file.

Usage:
  peer lifecycle chaincode package [outputfile] [flags]

Flags:
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -h, --help                           help for package
      --label string                   The package label contains a human-readable description of the package
  -l, --lang string                    Language the chaincode is written in (default "golang")
  -p, --path string                    Path to the chaincode
      --peerAddresses stringArray      The addresses of the peers to connect to
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag

Global Flags:
      --cafile string                       Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --certfile string                     Path to file containing PEM-encoded X509 public key to use for mutual TLS communication with the orderer endpoint
      --clientauth                          Use mutual TLS when communicating with the orderer endpoint
      --connTimeout duration                Timeout for client to connect (default 3s)
      --keyfile string                      Path to file containing PEM-encoded private key to use for mutual TLS communication with the orderer endpoint
  -o, --orderer string                      Ordering service endpoint
      --ordererTLSHostnameOverride string   The hostname override to use when validating the TLS connection to the orderer.
      --tls                                 Use TLS when communicating with the orderer endpoint
```


## peer lifecycle chaincode install
```
Install a chaincode on a peer.

Usage:
  peer lifecycle chaincode install [flags]

Flags:
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -h, --help                           help for install
      --peerAddresses stringArray      The addresses of the peers to connect to
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag

Global Flags:
      --cafile string                       Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --certfile string                     Path to file containing PEM-encoded X509 public key to use for mutual TLS communication with the orderer endpoint
      --clientauth                          Use mutual TLS when communicating with the orderer endpoint
      --connTimeout duration                Timeout for client to connect (default 3s)
      --keyfile string                      Path to file containing PEM-encoded private key to use for mutual TLS communication with the orderer endpoint
  -o, --orderer string                      Ordering service endpoint
      --ordererTLSHostnameOverride string   The hostname override to use when validating the TLS connection to the orderer.
      --tls                                 Use TLS when communicating with the orderer endpoint
```


## peer lifecycle chaincode queryinstalled
```
Query the installed chaincodes on a peer.

Usage:
  peer lifecycle chaincode queryinstalled [flags]

Flags:
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -h, --help                           help for queryinstalled
  -O, --output string                  The output format for query results. Default is human-readable plain-text. json is currently the only supported format.
      --peerAddresses stringArray      The addresses of the peers to connect to
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag

Global Flags:
      --cafile string                       Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --certfile string                     Path to file containing PEM-encoded X509 public key to use for mutual TLS communication with the orderer endpoint
      --clientauth                          Use mutual TLS when communicating with the orderer endpoint
      --connTimeout duration                Timeout for client to connect (default 3s)
      --keyfile string                      Path to file containing PEM-encoded private key to use for mutual TLS communication with the orderer endpoint
  -o, --orderer string                      Ordering service endpoint
      --ordererTLSHostnameOverride string   The hostname override to use when validating the TLS connection to the orderer.
      --tls                                 Use TLS when communicating with the orderer endpoint
```


## peer lifecycle chaincode getinstalledpackage
```
Get an installed chaincode package from a peer.

Usage:
  peer lifecycle chaincode getinstalledpackage [outputfile] [flags]

Flags:
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -h, --help                           help for getinstalledpackage
      --output-directory string        The output directory to use when writing a chaincode install package to disk. Default is the current working directory.
      --package-id string              The identifier of the chaincode install package
      --peerAddresses stringArray      The addresses of the peers to connect to
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag

Global Flags:
      --cafile string                       Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --certfile string                     Path to file containing PEM-encoded X509 public key to use for mutual TLS communication with the orderer endpoint
      --clientauth                          Use mutual TLS when communicating with the orderer endpoint
      --connTimeout duration                Timeout for client to connect (default 3s)
      --keyfile string                      Path to file containing PEM-encoded private key to use for mutual TLS communication with the orderer endpoint
  -o, --orderer string                      Ordering service endpoint
      --ordererTLSHostnameOverride string   The hostname override to use when validating the TLS connection to the orderer.
      --tls                                 Use TLS when communicating with the orderer endpoint
```


## peer lifecycle chaincode approveformyorg
```
Approve the chaincode definition for my organization.

Usage:
  peer lifecycle chaincode approveformyorg [flags]

Flags:
      --channel-config-policy string   The endorsement policy associated to this chaincode specified as a channel config policy reference
  -C, --channelID string               The channel on which this command should be executed
      --collections-config string      The fully qualified path to the collection JSON file including the file name
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -E, --endorsement-plugin string      The name of the endorsement plugin to be used for this chaincode
  -h, --help                           help for approveformyorg
      --init-required                  Whether the chaincode requires invoking 'init'
  -n, --name string                    Name of the chaincode
      --package-id string              The identifier of the chaincode install package
      --peerAddresses stringArray      The addresses of the peers to connect to
      --sequence int                   The sequence number of the chaincode definition for the channel (default 1)
      --signature-policy string        The endorsement policy associated to this chaincode specified as a signature policy
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag
  -V, --validation-plugin string       The name of the validation plugin to be used for this chaincode
  -v, --version string                 Version of the chaincode
      --waitForEvent                   Whether to wait for the event from each peer's deliver filtered service signifying that the transaction has been committed successfully (default true)
      --waitForEventTimeout duration   Time to wait for the event from each peer's deliver filtered service signifying that the 'invoke' transaction has been committed successfully (default 30s)

Flags:
      --channel-config-policy string   The endorsement policy associated to this chaincode specified as a channel config policy reference
  -C, --channelID string               The channel on which this command should be executed
      --collections-config string      The fully qualified path to the collection JSON file including the file name
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -E, --endorsement-plugin string      The name of the endorsement plugin to be used for this chaincode
  -h, --help                           help for approveformyorg
      --init-required                  Whether the chaincode requires invoking 'init'
  -n, --name string                    Name of the chaincode
      --package-id string              The identifier of the chaincode install package
      --peerAddresses stringArray      The addresses of the peers to connect to
      --sequence int                   The sequence number of the chaincode definition for the channel
      --signature-policy string        The endorsement policy associated to this chaincode specified as a signature policy
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag
  -V, --validation-plugin string       The name of the validation plugin to be used for this chaincode
  -v, --version string                 Version of the chaincode
      --waitForEvent                   Whether to wait for the event from each peer's deliver filtered service signifying that the transaction has been committed successfully (default true)
      --waitForEventTimeout duration   Time to wait for the event from each peer's deliver filtered service signifying that the 'invoke' transaction has been committed successfully (default 30s)

Global Flags:
      --cafile string                       Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --certfile string                     Path to file containing PEM-encoded X509 public key to use for mutual TLS communication with the orderer endpoint
      --clientauth                          Use mutual TLS when communicating with the orderer endpoint
      --connTimeout duration                Timeout for client to connect (default 3s)
      --keyfile string                      Path to file containing PEM-encoded private key to use for mutual TLS communication with the orderer endpoint
  -o, --orderer string                      Ordering service endpoint
      --ordererTLSHostnameOverride string   The hostname override to use when validating the TLS connection to the orderer.
      --tls                                 Use TLS when communicating with the orderer endpoint
```


## peer lifecycle chaincode checkcommitreadiness
```
Check whether a chaincode definition is ready to be committed on a channel.

## peer lifecycle chaincode queryapproved
```
Query an organization's approved chaincode definition from its peer.

Usage:
  peer lifecycle chaincode checkcommitreadiness [flags]

Usage:
  peer lifecycle chaincode queryapproved [flags]

Flags:
      --channel-config-policy string   The endorsement policy associated to this chaincode specified as a channel config policy reference
  -C, --channelID string               The channel on which this command should be executed
      --collections-config string      The fully qualified path to the collection JSON file including the file name
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -E, --endorsement-plugin string      The name of the endorsement plugin to be used for this chaincode
  -h, --help                           help for checkcommitreadiness
      --init-required                  Whether the chaincode requires invoking 'init'
  -n, --name string                    Name of the chaincode
  -O, --output string                  The output format for query results. Default is human-readable plain-text. json is currently the only supported format.
      --peerAddresses stringArray      The addresses of the peers to connect to
      --sequence int                   The sequence number of the chaincode definition for the channel (default 1)
      --signature-policy string        The endorsement policy associated to this chaincode specified as a signature policy
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag
  -V, --validation-plugin string       The name of the validation plugin to be used for this chaincode
  -v, --version string                 Version of the chaincode

Flags:
  -C, --channelID string               The channel on which this command should be executed
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -h, --help                           help for queryapproved
  -n, --name string                    Name of the chaincode
  -O, --output string                  The output format for query results. Default is human-readable plain-text. json is currently the only supported format.
      --peerAddresses stringArray      The addresses of the peers to connect to
      --sequence int                   The sequence number of the chaincode definition for the channel
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag

Global Flags:
      --cafile string                       Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --certfile string                     Path to file containing PEM-encoded X509 public key to use for mutual TLS communication with the orderer endpoint
      --clientauth                          Use mutual TLS when communicating with the orderer endpoint
      --connTimeout duration                Timeout for client to connect (default 3s)
      --keyfile string                      Path to file containing PEM-encoded private key to use for mutual TLS communication with the orderer endpoint
  -o, --orderer string                      Ordering service endpoint
      --ordererTLSHostnameOverride string   The hostname override to use when validating the TLS connection to the orderer.
      --tls                                 Use TLS when communicating with the orderer endpoint
```


## peer lifecycle chaincode commit
```
Commit the chaincode definition on the channel.

## peer lifecycle chaincode checkcommitreadiness
```
Check whether a chaincode definition is ready to be committed on a channel.

Usage:
  peer lifecycle chaincode commit [flags]

Usage:
  peer lifecycle chaincode checkcommitreadiness [flags]

Flags:
      --channel-config-policy string   The endorsement policy associated to this chaincode specified as a channel config policy reference
  -C, --channelID string               The channel on which this command should be executed
      --collections-config string      The fully qualified path to the collection JSON file including the file name
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -E, --endorsement-plugin string      The name of the endorsement plugin to be used for this chaincode
  -h, --help                           help for commit
      --init-required                  Whether the chaincode requires invoking 'init'
  -n, --name string                    Name of the chaincode
      --peerAddresses stringArray      The addresses of the peers to connect to
      --sequence int                   The sequence number of the chaincode definition for the channel (default 1)
      --signature-policy string        The endorsement policy associated to this chaincode specified as a signature policy
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag
  -V, --validation-plugin string       The name of the validation plugin to be used for this chaincode
  -v, --version string                 Version of the chaincode
      --waitForEvent                   Whether to wait for the event from each peer's deliver filtered service signifying that the transaction has been committed successfully (default true)
      --waitForEventTimeout duration   Time to wait for the event from each peer's deliver filtered service signifying that the 'invoke' transaction has been committed successfully (default 30s)

Flags:
      --channel-config-policy string   The endorsement policy associated to this chaincode specified as a channel config policy reference
  -C, --channelID string               The channel on which this command should be executed
      --collections-config string      The fully qualified path to the collection JSON file including the file name
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -E, --endorsement-plugin string      The name of the endorsement plugin to be used for this chaincode
  -h, --help                           help for checkcommitreadiness
      --init-required                  Whether the chaincode requires invoking 'init'
  -n, --name string                    Name of the chaincode
  -O, --output string                  The output format for query results. Default is human-readable plain-text. json is currently the only supported format.
      --peerAddresses stringArray      The addresses of the peers to connect to
      --sequence int                   The sequence number of the chaincode definition for the channel
      --signature-policy string        The endorsement policy associated to this chaincode specified as a signature policy
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag
  -V, --validation-plugin string       The name of the validation plugin to be used for this chaincode
  -v, --version string                 Version of the chaincode

Global Flags:
      --cafile string                       Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --certfile string                     Path to file containing PEM-encoded X509 public key to use for mutual TLS communication with the orderer endpoint
      --clientauth                          Use mutual TLS when communicating with the orderer endpoint
      --connTimeout duration                Timeout for client to connect (default 3s)
      --keyfile string                      Path to file containing PEM-encoded private key to use for mutual TLS communication with the orderer endpoint
  -o, --orderer string                      Ordering service endpoint
      --ordererTLSHostnameOverride string   The hostname override to use when validating the TLS connection to the orderer.
      --tls                                 Use TLS when communicating with the orderer endpoint
```


## peer lifecycle chaincode querycommitted
```
Query the committed chaincode definitions by channel on a peer. Optional: provide a chaincode name to query a specific definition.

## peer lifecycle chaincode commit
```
Commit the chaincode definition on the channel.

Usage:
  peer lifecycle chaincode querycommitted [flags]

Usage:
  peer lifecycle chaincode commit [flags]

Flags:
  -C, --channelID string               The channel on which this command should be executed
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -h, --help                           help for querycommitted
  -n, --name string                    Name of the chaincode
  -O, --output string                  The output format for query results. Default is human-readable plain-text. json is currently the only supported format.
      --peerAddresses stringArray      The addresses of the peers to connect to
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag

Flags:
      --channel-config-policy string   The endorsement policy associated to this chaincode specified as a channel config policy reference
  -C, --channelID string               The channel on which this command should be executed
      --collections-config string      The fully qualified path to the collection JSON file including the file name
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -E, --endorsement-plugin string      The name of the endorsement plugin to be used for this chaincode
  -h, --help                           help for commit
      --init-required                  Whether the chaincode requires invoking 'init'
  -n, --name string                    Name of the chaincode
      --peerAddresses stringArray      The addresses of the peers to connect to
      --sequence int                   The sequence number of the chaincode definition for the channel
      --signature-policy string        The endorsement policy associated to this chaincode specified as a signature policy
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag
  -V, --validation-plugin string       The name of the validation plugin to be used for this chaincode
  -v, --version string                 Version of the chaincode
      --waitForEvent                   Whether to wait for the event from each peer's deliver filtered service signifying that the transaction has been committed successfully (default true)
      --waitForEventTimeout duration   Time to wait for the event from each peer's deliver filtered service signifying that the 'invoke' transaction has been committed successfully (default 30s)

Global Flags:
      --cafile string                       Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --certfile string                     Path to file containing PEM-encoded X509 public key to use for mutual TLS communication with the orderer endpoint
      --clientauth                          Use mutual TLS when communicating with the orderer endpoint
      --connTimeout duration                Timeout for client to connect (default 3s)
      --keyfile string                      Path to file containing PEM-encoded private key to use for mutual TLS communication with the orderer endpoint
  -o, --orderer string                      Ordering service endpoint
      --ordererTLSHostnameOverride string   The hostname override to use when validating the TLS connection to the orderer.
      --tls                                 Use TLS when communicating with the orderer endpoint
```


## 示例用法

## peer lifecycle chaincode querycommitted
```
Query the committed chaincode definitions by channel on a peer. Optional: provide a chaincode name to query a specific definition.

### peer lifecycle chaincode package示例

Usage:
  peer lifecycle chaincode querycommitted [flags]

在你的Peer节点上安装每个链码前都需要先打包。该示例使用`peer lifecycle chaincode package`命令打包Golang链码。

Flags:
  -C, --channelID string               The channel on which this command should be executed
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -h, --help                           help for querycommitted
  -n, --name string                    Name of the chaincode
  -O, --output string                  The output format for query results. Default is human-readable plain-text. json is currently the only supported format.
      --peerAddresses stringArray      The addresses of the peers to connect to
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag

  * 使用`--label`标志可以给`myccv1`链码包提供标签，组织将使用该标签来标识包。

Global Flags:
      --cafile string                       Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --certfile string                     Path to file containing PEM-encoded X509 public key to use for mutual TLS communication with the orderer endpoint
      --clientauth                          Use mutual TLS when communicating with the orderer endpoint
      --connTimeout duration                Timeout for client to connect (default 3s)
      --keyfile string                      Path to file containing PEM-encoded private key to use for mutual TLS communication with the orderer endpoint
  -o, --orderer string                      Ordering service endpoint
      --ordererTLSHostnameOverride string   The hostname override to use when validating the TLS connection to the orderer.
      --tls                                 Use TLS when communicating with the orderer endpoint
```

    ```
    peer lifecycle chaincode package mycc.tar.gz --path github.com/hyperledger/fabric-samples/chaincode/abstore/go/ --lang golang --label myccv1
    ```


### peer lifecycle chaincode install示例

## Example Usage

当链码打包好之后，你可以用`peer chaincode install`命令在节点上安装链码。

### peer lifecycle chaincode package example

  * 安装`mycc.tar.gz`程序包安装到`peer0.org1.example.com:7051`节点上（Peer节点通过`--peerAddresses`指定）。

A chaincode needs to be packaged before it can be installed on your peers.
This example uses the `peer lifecycle chaincode package` command to package
a Go chaincode.

    ```
    peer lifecycle chaincode install mycc.tar.gz --peerAddresses peer0.org1.example.com:7051
    ```
    如果安装成功，该命令会返回包标识。包ID是由程序包的标签加上Peer采用的链码程序包的哈希值组成的。
    ```
    2019-03-13 13:48:53.691 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 001 Installed remotely: response:<status:200 payload:"\nEmycc:ebd89878c2bbccf62f68c36072626359376aa83c36435a058d453e8dbfd894cc" >
    2019-03-13 13:48:53.691 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 002 Chaincode code package identifier: mycc:a7ca45a7cc85f1d89c905b775920361ed089a364e12a9b6d55ba75c965ddd6a9
    ```

  * Use the `--path` flag to indicate the location of the chaincode.
    The path must be a fully qualified path or a path relative to your present working directory.
  * Use the `--label` flag to provide a chaincode package label of `myccv1`
    that your organization will use to identify the package.

### peer lifecycle chaincode queryinstalled示例

    ```
    peer lifecycle chaincode package mycc.tar.gz --path $CHAINCODE_DIR --lang golang --label myccv1
    ```

你需要使用链码程序包的标识去给组织批准链码的定义。你可以通过`peer lifecycle chaincode queryinstalled`命令找到安装的链码的包ID：

### peer lifecycle chaincode install example

```
peer lifecycle chaincode queryinstalled --peerAddresses peer0.org1.example.com:7051
```

After the chaincode is packaged, you can use the `peer chaincode install` command
to install the chaincode on your peers.

命令执行成功后会返回包的ID和标签。

  * Install the `mycc.tar.gz ` package on `peer0.org1.example.com:7051` (the
    peer defined by `--peerAddresses`).

```
Get installed chaincodes on peer:
Package ID: myccv1:a7ca45a7cc85f1d89c905b775920361ed089a364e12a9b6d55ba75c965ddd6a9, Label: myccv1
```

    ```
    peer lifecycle chaincode install mycc.tar.gz --peerAddresses peer0.org1.example.com:7051
    ```
    If successful, the command will return the package identifier. The
    package ID is the package label combined with a hash of the chaincode
    package taken by the peer.
    ```
    2019-03-13 13:48:53.691 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 001 Installed remotely: response:<status:200 payload:"\nEmycc:ebd89878c2bbccf62f68c36072626359376aa83c36435a058d453e8dbfd894cc" >
    2019-03-13 13:48:53.691 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 002 Chaincode code package identifier: mycc:a7ca45a7cc85f1d89c905b775920361ed089a364e12a9b6d55ba75c965ddd6a9
    ```

### peer lifecycle chaincode getinstalledpackage示例

### peer lifecycle chaincode queryinstalled example

你可以通过使用该命令`peer lifecycle chaincode getinstalledpackage`获取已经安装了的链码程序包。使用`queryinstalled`返回的包的标识。

You need to use the chaincode package identifier to approve a chaincode
definition for your organization. You can find the package ID for the
chaincodes you have installed by using the
`peer lifecycle chaincode queryinstalled` command:

  * 使用`--package-id`标志传入链码包的标识。使用`--output-directory`标识指定链码包的写入目录。如果未指定目录，链码会写入到当前目录。

```
peer lifecycle chaincode queryinstalled --peerAddresses peer0.org1.example.com:7051
```

  ```
  peer lifecycle chaincode getinstalledpackage --package-id myccv1:a7ca45a7cc85f1d89c905b775920361ed089a364e12a9b6d55ba75c965ddd6a9 --output-directory /tmp --peerAddresses peer0.org1.example.com:7051
  ```

A successful command will return the package ID associated with the
package label.


```
Get installed chaincodes on peer:
Package ID: myccv1:a7ca45a7cc85f1d89c905b775920361ed089a364e12a9b6d55ba75c965ddd6a9, Label: myccv1
```

### peer lifecycle chaincode approveformyorg示例

  * You can also use the `--output` flag to have the CLI format the output as
    JSON.

一旦在Peer上安装了链码程序包，就可以在组织中批准链码定义了。链码定义包括链码治理的重要参数，包括链码名称，版本和背书策略。

    ```
    peer lifecycle chaincode queryinstalled --peerAddresses peer0.org1.example.com:7051 --output json
    ```

这是一个`peer lifecycle chaincode approveformyorg`命令的示例，在通道`mychannel`上批准了名称为`mycc`，版本为`1.0`的链码定义。

    If successful, the command will return the chaincodes you have installed as JSON.

  * 使用`--package-id`标志传入链码包的标识。使用`--signature-policy`标志给链码定义背书策略。使用`init-required`标志要求执行`Init`函数初始化链码。

    ```
    {
      "installed_chaincodes": [
        {
          "package_id": "mycc_1:aab9981fa5649cfe25369fce7bb5086a69672a631e4f95c4af1b5198fe9f845b",
          "label": "mycc_1",
          "references": {
            "mychannel": {
              "chaincodes": [
                {
                  "name": "mycc",
                  "version": "1"
                }
              ]
            }
          }
        }
      ]
    }
    ```

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

### peer lifecycle chaincode getinstalledpackage example

    peer lifecycle chaincode approveformyorg  -o orderer.example.com:7050 --tls --cafile $ORDERER_CA --channelID mychannel --name mycc --version 1.0 --init-required --package-id myccv1:a7ca45a7cc85f1d89c905b775920361ed089a364e12a9b6d55ba75c965ddd6a9 --sequence 1 --signature-policy "AND ('Org1MSP.peer','Org2MSP.peer')"

You can retrieve an installed chaincode package from a peer using the
`peer lifecycle chaincode getinstalledpackage` command. Use the package
identifier returned by `queryinstalled`.

    2019-03-18 16:04:09.046 UTC [cli.lifecycle.chaincode] InitCmdFactory -> INFO 001 Retrieved channel (mychannel) orderer endpoint: orderer.example.com:7050
    2019-03-18 16:04:11.253 UTC [chaincodeCmd] ClientWait -> INFO 002 txid [efba188ca77889cc1c328fc98e0bb12d3ad0abcda3f84da3714471c7c1e6c13c] committed with status (VALID) at peer0.org1.example.com:7051
    ```

  * Use the `--package-id` flag to pass in the chaincode package identifier. Use
  the `--output-directory` flag to specify where to write the chaincode package.
  If the output directory is not specified, the chaincode package will be written
  in the current directory.

  * 你也可以使用`--channel-config-policy`标志使用通道配置中的策略做诶链码的背书策略。默认的背书策略为`Channel/Application/Endorsement`。

  ```
  peer lifecycle chaincode getinstalledpackage --package-id myccv1:a7ca45a7cc85f1d89c905b775920361ed089a364e12a9b6d55ba75c965ddd6a9 --output-directory /tmp --peerAddresses peer0.org1.example.com:7051
  ```

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem


    peer lifecycle chaincode approveformyorg -o orderer.example.com:7050 --tls --cafile $ORDERER_CA --channelID mychannel --name mycc --version 1.0 --init-required --package-id myccv1:a7ca45a7cc85f1d89c905b775920361ed089a364e12a9b6d55ba75c965ddd6a9 --sequence 1 --channel-config-policy Channel/Application/Admins

### peer lifecycle chaincode approveformyorg example

    2019-03-18 16:04:09.046 UTC [cli.lifecycle.chaincode] InitCmdFactory -> INFO 001 Retrieved channel (mychannel) orderer endpoint: orderer.example.com:7050
    2019-03-18 16:04:11.253 UTC [chaincodeCmd] ClientWait -> INFO 002 txid [efba188ca77889cc1c328fc98e0bb12d3ad0abcda3f84da3714471c7c1e6c13c] committed with status (VALID) at peer0.org1.example.com:7051
    ```

Once the chaincode package has been installed on your peers, you can approve
a chaincode definition for your organization. The chaincode definition includes
the important parameters of chaincode governance, including the chaincode name,
version and the endorsement policy.

### peer lifecycle chaincode checkcommitreadiness示例

Here is an example of the `peer lifecycle chaincode approveformyorg` command,
which approves the definition of a chaincode  named `mycc` at version `1.0` on
channel `mychannel`.

你可以使用该命令`peer lifecycle chaincode checkcommitreadiness`检查链码定义是否能够被提交，如果期望后续链码定义的提交能够成功则会返回成功。同时也会返回是哪些组织批准了链码定义。如果一个组织批准了命令中指定的链码定义，那么该命令返回的值为true。在链码定义能被提交到通道之前，你可以通过该命令知道是否有足够的通道成员批准了链码定义以满足`Application/Channel/Endorsement`策略（默认为majority）。

  * Use the `--package-id` flag to pass in the chaincode package identifier. Use
    the `--signature-policy` flag to define an endorsement policy for the chaincode.
    Use the `init-required` flag to request the execution of the `Init`
    function to initialize the chaincode.

  * 这里有一个`peer lifecycle chaincode checkcommitreadiness`命令的示例，在通道`mychannel`上检查名称为`mycc`，版本为`1.0`的链码。

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    peer lifecycle chaincode approveformyorg  -o orderer.example.com:7050 --tls --cafile $ORDERER_CA --channelID mychannel --name mycc --version 1.0 --init-required --package-id myccv1:a7ca45a7cc85f1d89c905b775920361ed089a364e12a9b6d55ba75c965ddd6a9 --sequence 1 --signature-policy "AND ('Org1MSP.peer','Org2MSP.peer')"

    peer lifecycle chaincode checkcommitreadiness -o orderer.example.com:7050 --channelID mychannel --tls --cafile $ORDERER_CA --name mycc --version 1.0 --init-required --sequence 1
    ```

    2019-03-18 16:04:09.046 UTC [cli.lifecycle.chaincode] InitCmdFactory -> INFO 001 Retrieved channel (mychannel) orderer endpoint: orderer.example.com:7050
    2019-03-18 16:04:11.253 UTC [chaincodeCmd] ClientWait -> INFO 002 txid [efba188ca77889cc1c328fc98e0bb12d3ad0abcda3f84da3714471c7c1e6c13c] committed with status (VALID) at peer0.org1.example.com:7051
    ```

    如果成功了，该命令会返回批准了链码定义的组织。

  * You can also use the `--channel-config-policy` flag use a policy inside
    the channel configuration as the chaincode endorsement policy. The default
    endorsement policy is `Channel/Application/Endorsement`

    ```
    Chaincode definition for chaincode 'mycc', version '1.0', sequence '1' on channel
    'mychannel' approval status by org:
    Org1MSP: true
    Org2MSP: true
    ```

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  * 你也可以使用`--output`标志将命令行的输出格式设置为JSON。

    peer lifecycle chaincode approveformyorg -o orderer.example.com:7050 --tls --cafile $ORDERER_CA --channelID mychannel --name mycc --version 1.0 --init-required --package-id myccv1:a7ca45a7cc85f1d89c905b775920361ed089a364e12a9b6d55ba75c965ddd6a9 --sequence 1 --channel-config-policy Channel/Application/Admins

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    2019-03-18 16:04:09.046 UTC [cli.lifecycle.chaincode] InitCmdFactory -> INFO 001 Retrieved channel (mychannel) orderer endpoint: orderer.example.com:7050
    2019-03-18 16:04:11.253 UTC [chaincodeCmd] ClientWait -> INFO 002 txid [efba188ca77889cc1c328fc98e0bb12d3ad0abcda3f84da3714471c7c1e6c13c] committed with status (VALID) at peer0.org1.example.com:7051
    ```

    peer lifecycle chaincode checkcommitreadiness -o orderer.example.com:7050 --channelID mychannel --tls --cafile $ORDERER_CA --name mycc --version 1.0 --init-required --sequence 1 --output json
    ```

### peer lifecycle chaincode queryapproved example

    如果成功了，该命令会以JSON格式返回批准了链码定义的组织。

You can query an organization's approved chaincode definition by using the `peer lifecycle chaincode queryapproved` command.
You can use this command to see the details (including package ID) of approved chaincode definitions.

    ```
    {
       "Approvals": {
          "Org1MSP": true,
          "Org2MSP": true
       }
    }
    ```

  * Here is an example of the `peer lifecycle chaincode queryapproved` command,
    which queries the approved definition of a chaincode named `mycc` at sequence number `1` on
    channel `mychannel`.

### peer lifecycle chaincode commit示例

    ```
    peer lifecycle chaincode queryapproved -C mychannel -n mycc --sequence 1

一旦有足够的组织成员批准了链码定义（默认为majority），一个组织可以使用`peer lifecycle chaincode commit`命令提交链码定义到通道：

    Approved chaincode definition for chaincode 'mycc' on channel 'mychannel':
    sequence: 1, version: 1, init-required: true, package-id: mycc_1:d02f72000e7c0f715840f51cb8d72d70bc1ba230552f8445dded0ec8b6e0b830, endorsement plugin: escc, validation plugin: vscc
    ```

  * 该命令需要指定通道上其他组织的Peer节点，以收集其他组织对链码定义的背书。

    If NO package is specified for the approved definition, this command will display an empty package ID.

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  * You can also use this command without specifying the sequence number in order to query the latest approved definition (latest: the newer of the currently defined sequence number and the next sequence number).

    peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID mychannel --name mycc --version 1.0 --sequence 1 --init-required --tls --cafile $ORDERER_CA --peerAddresses peer0.org1.example.com:7051 --peerAddresses peer0.org2.example.com:9051

    ```
    peer lifecycle chaincode queryapproved -C mychannel -n mycc

    2019-03-18 16:14:27.258 UTC [chaincodeCmd] ClientWait -> INFO 001 txid [b6f657a14689b27d69a50f39590b3949906b5a426f9d7f0dcee557f775e17882] committed with status (VALID) at peer0.org2.example.com:9051
    2019-03-18 16:14:27.321 UTC [chaincodeCmd] ClientWait -> INFO 002 txid [b6f657a14689b27d69a50f39590b3949906b5a426f9d7f0dcee557f775e17882] committed with status (VALID) at peer0.org1.example.com:7051
    ```

    Approved chaincode definition for chaincode 'mycc' on channel 'mychannel':
    sequence: 3, version: 3, init-required: false, package-id: mycc_1:d02f72000e7c0f715840f51cb8d72d70bc1ba230552f8445dded0ec8b6e0b830, endorsement plugin: escc, validation plugin: vscc
    ```

### peer lifecycle chaincode querycommitted示例

  * You can also use the `--output` flag to have the CLI format the output as
    JSON.

你可以使用`peer lifecycle chaincode querycommitted`命令查询通道上已经提交的链码定义。在升级链码之前，你可以用该命令查询当前链码定义的序列号。

    - When querying an approved chaincode definition for which package is specified

  * 你需要提供链码名称和通道名称来查询特定的链码定义以及批准它的组织。

      ```
      peer lifecycle chaincode queryapproved -C mychannel -n mycc --sequence 1 --output json
      ```

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

      If successful, the command will return a JSON that has the approved chaincode definition for chaincode `mycc` at sequence number `1` on channel `mychannel`.

    peer lifecycle chaincode querycommitted -o orderer.example.com:7050 --channelID mychannel --name mycc --tls --cafile $ORDERER_CA --peerAddresses peer0.org1.example.com:7051

      ```
      {
        "sequence": 1,
        "version": "1",
        "endorsement_plugin": "escc",
        "validation_plugin": "vscc",
        "validation_parameter": "EiAvQ2hhbm5lbC9BcHBsaWNhdGlvbi9FbmRvcnNlbWVudA==",
        "collections": {},
        "init_required": true,
        "source": {
          "Type": {
            "LocalPackage": {
              "package_id": "mycc_1:d02f72000e7c0f715840f51cb8d72d70bc1ba230552f8445dded0ec8b6e0b830"
            }
          }
        }
      }
      ```

    Committed chaincode definition for chaincode 'mycc' on channel 'mychannel':
    Version: 1, Sequence: 1, Endorsement Plugin: escc, Validation Plugin: vscc
    Approvals: [Org1MSP: true, Org2MSP: true]
    ```

    - When querying an approved chaincode definition for which package is NOT specified

  * 你也可以只指定通道名称来查询该通道上所有的链码定义。

      ```
      peer lifecycle chaincode queryapproved -C mychannel -n mycc --sequence 2 --output json
      ```

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

      If successful, the command will return a JSON that has the approved chaincode definition for chaincode `mycc` at sequence number `2` on channel `mychannel`.

    peer lifecycle chaincode querycommitted -o orderer.example.com:7050 --channelID mychannel --tls --cafile $ORDERER_CA --peerAddresses peer0.org1.example.com:7051

      ```
      {
        "sequence": 2,
        "version": "2",
        "endorsement_plugin": "escc",
        "validation_plugin": "vscc",
        "validation_parameter": "EiAvQ2hhbm5lbC9BcHBsaWNhdGlvbi9FbmRvcnNlbWVudA==",
        "collections": {},
        "source": {
          "Type": {
            "Unavailable": {}
          }
        }
      }
      ```

    Committed chaincode definitions on channel 'mychannel':
    Name: mycc, Version: 1, Sequence: 1, Endorsement Plugin: escc, Validation Plugin: vscc
    Name: yourcc, Version: 2, Sequence: 3, Endorsement Plugin: escc, Validation Plugin: vscc
    ```

### peer lifecycle chaincode checkcommitreadiness example

You can check whether a chaincode definition is ready to be committed using the
`peer lifecycle chaincode checkcommitreadiness` command, which will return
successfully if a subsequent commit of the definition is expected to succeed. It
also outputs which organizations have approved the chaincode definition. If an
organization has approved the chaincode definition specified in the command, the
command will return a value of true. You can use this command to learn whether enough
channel members have approved a chaincode definition to meet the
`Application/Channel/Endorsement` policy (a majority by default) before the
definition can be committed to a channel.

  * Here is an example of the `peer lifecycle chaincode checkcommitreadiness` command,
    which checks a chaincode named `mycc` at version `1.0` on channel `mychannel`.

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    peer lifecycle chaincode checkcommitreadiness -o orderer.example.com:7050 --channelID mychannel --tls --cafile $ORDERER_CA --name mycc --version 1.0 --init-required --sequence 1
    ```

    If successful, the command will return the organizations that have approved
    the chaincode definition.

    ```
    Chaincode definition for chaincode 'mycc', version '1.0', sequence '1' on channel
    'mychannel' approval status by org:
    Org1MSP: true
    Org2MSP: true
    ```

  * You can also use the `--output` flag to have the CLI format the output as
    JSON.

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    peer lifecycle chaincode checkcommitreadiness -o orderer.example.com:7050 --channelID mychannel --tls --cafile $ORDERER_CA --name mycc --version 1.0 --init-required --sequence 1 --output json
    ```

    If successful, the command will return a JSON map that shows if an organization
    has approved the chaincode definition.

    ```
    {
       "Approvals": {
          "Org1MSP": true,
          "Org2MSP": true
       }
    }
    ```

### peer lifecycle chaincode commit example

Once a sufficient number of organizations approve a chaincode definition for
their organizations (a majority by default), one organization can commit the
definition the channel using the `peer lifecycle chaincode commit` command:

  * This command needs to target the peers of other organizations on the channel
    to collect their organization endorsement for the definition.

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID mychannel --name mycc --version 1.0 --sequence 1 --init-required --tls --cafile $ORDERER_CA --peerAddresses peer0.org1.example.com:7051 --peerAddresses peer0.org2.example.com:9051

    2019-03-18 16:14:27.258 UTC [chaincodeCmd] ClientWait -> INFO 001 txid [b6f657a14689b27d69a50f39590b3949906b5a426f9d7f0dcee557f775e17882] committed with status (VALID) at peer0.org2.example.com:9051
    2019-03-18 16:14:27.321 UTC [chaincodeCmd] ClientWait -> INFO 002 txid [b6f657a14689b27d69a50f39590b3949906b5a426f9d7f0dcee557f775e17882] committed with status (VALID) at peer0.org1.example.com:7051
    ```

### peer lifecycle chaincode querycommitted example

You can query the chaincode definitions that have been committed to a channel by
using the `peer lifecycle chaincode querycommitted` command. You can use this
command to query the current definition sequence number before upgrading a
chaincode.

  * You need to supply the chaincode name and channel name in order to query a
    specific chaincode definition and the organizations that have approved it.

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    peer lifecycle chaincode querycommitted -o orderer.example.com:7050 --channelID mychannel --name mycc --tls --cafile $ORDERER_CA --peerAddresses peer0.org1.example.com:7051

    Committed chaincode definition for chaincode 'mycc' on channel 'mychannel':
    Version: 1, Sequence: 1, Endorsement Plugin: escc, Validation Plugin: vscc
    Approvals: [Org1MSP: true, Org2MSP: true]
    ```

  * You can also specify just the channel name in order to query all chaincode
  definitions on that channel.

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    peer lifecycle chaincode querycommitted -o orderer.example.com:7050 --channelID mychannel --tls --cafile $ORDERER_CA --peerAddresses peer0.org1.example.com:7051

    Committed chaincode definitions on channel 'mychannel':
    Name: mycc, Version: 1, Sequence: 1, Endorsement Plugin: escc, Validation Plugin: vscc
    Name: yourcc, Version: 2, Sequence: 3, Endorsement Plugin: escc, Validation Plugin: vscc
    ```

  * You can also use the `--output` flag to have the CLI format the output as
    JSON.

    - For querying a specific chaincode definition

      ```
      export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

      peer lifecycle chaincode querycommitted -o orderer.example.com:7050 --channelID mychannel --name mycc --tls --cafile $ORDERER_CA --peerAddresses peer0.org1.example.com:7051 --output json
      ```

      If successful, the command will return a JSON that has committed chaincode definition for chaincode 'mycc' on channel 'mychannel'.

      ```
      {
        "sequence": 1,
        "version": "1",
        "endorsement_plugin": "escc",
        "validation_plugin": "vscc",
        "validation_parameter": "EiAvQ2hhbm5lbC9BcHBsaWNhdGlvbi9FbmRvcnNlbWVudA==",
        "collections": {},
        "init_required": true,
        "approvals": {
          "Org1MSP": true,
          "Org2MSP": true
        }
      }
      ```

      The `validation_parameter` is base64 encoded. An example of the command to decode it is as follows.

      ```
      echo EiAvQ2hhbm5lbC9BcHBsaWNhdGlvbi9FbmRvcnNlbWVudA== | base64 -d

       /Channel/Application/Endorsement
      ```

    - For querying all chaincode definitions on that channel

      ```
      export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

      peer lifecycle chaincode querycommitted -o orderer.example.com:7050 --channelID mychannel --tls --cafile $ORDERER_CA --peerAddresses peer0.org1.example.com:7051 --output json
      ```

      If successful, the command will return a JSON that has committed chaincode definitions on channel 'mychannel'.

      ```
      {
        "chaincode_definitions": [
          {
            "name": "mycc",
            "sequence": 1,
            "version": "1",
            "endorsement_plugin": "escc",
            "validation_plugin": "vscc",
            "validation_parameter": "EiAvQ2hhbm5lbC9BcHBsaWNhdGlvbi9FbmRvcnNlbWVudA==",
            "collections": {},
            "init_required": true
          },
          {
            "name": "yourcc",
            "sequence": 3,
            "version": "2",
            "endorsement_plugin": "escc",
            "validation_plugin": "vscc",
            "validation_parameter": "EiAvQ2hhbm5lbC9BcHBsaWNhdGlvbi9FbmRvcnNlbWVudA==",
            "collections": {}
          }
        ]
      }
      ```

