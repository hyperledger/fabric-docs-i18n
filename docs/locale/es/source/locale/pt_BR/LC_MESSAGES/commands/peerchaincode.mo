��    ;      �              �     �     �     �  %        ,     2     G  �   `    0  g   M     �     �  �   �  ;   \  8   �  �   �  U   �  �   	  F   �	  q   2
  m   �
  T        g  Q  n  N   �  U     �   e  9   $  +   ^  4   �  d   �  F   $  w   k  e   �  T   I  X   �     �     �                         .     E  #   `     �     �     �     �     �     �          3  �   N     �               %  �  -     �     �     �  %   �           &     ;  �   T    $  g   A     �     �  �   �  ;   P  8   �  �   �  U   �  �   �  F   �  q   &  m   �  T        [  Q  b  N   �  U     �   Y  9     +   R  4   ~  d   �  F      w   _   e   �   T   =!  X   �!     �!     �!     �!     "     "     "     ""     9"  #   T"     x"     �"     �"     �"     �"     �"     #     '#  �   B#     �#     $     $     $   --cafile <string> --certfile <string> --keyfile <string> --ordererTLSHostnameOverride <string> --tls --transient <string> -o or --orderer <string> A successful response indicates that the transaction was submitted for ordering successfully. The transaction will then be added to a block and, finally, validated or invalidated by each peer on the channel. Each peer chaincode subcommand has both a set of flags specific to an individual subcommand, as well as a set of global flags that relate to all peer chaincode subcommands. Not all subcommands would use these flags. For instance, the query subcommand does not need the --orderer flag. Each peer chaincode subcommand is described together with its options in its own section in this topic. Example Usage Flags Here are some examples of the peer chaincode instantiate command, which instantiates the chaincode named mycc at version 1.0 on channel mychannel: Here are some examples of the peer chaincode list  command: Here is an example of the peer chaincode invoke command: Here is an example of the peer chaincode package command, which packages the chaincode named mycc at version 1.1, creates the chaincode deployment spec, signs the package using the local MSP, and outputs it as ccpack.out: Here you can see that the invoke was submitted successfully based on the log message: Invoke the chaincode named mycc at version 1.0 on channel mychannel on peer0.org1.example.com:7051 and peer0.org2.example.com:9051 (the peers defined by --peerAddresses), requesting to move 10 units from variable a to variable b: Ordering service endpoint specified as <hostname or IP address>:<port> Path to file containing PEM-encoded X509 public key to use for mutual TLS communication with the orderer endpoint Path to file containing PEM-encoded private key to use for mutual TLS communication with the orderer endpoint Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint Syntax The different subcommand options (install, instantiate...) relate to the different chaincode operations that are relevant to a peer. For example, use the peer chaincode install subcommand option to install a chaincode on a peer, or the peer chaincode query subcommand option to query a chaincode for the current value on a peer's ledger. The hostname override to use when validating the TLS connection to the orderer The individual flags are described with the relevant subcommand. The global flags are The peer chaincode command allows administrators to perform chaincode related operations on a peer, such as installing, instantiating, invoking, packaging, querying, and upgrading chaincode. The peer chaincode command has the following subcommands: Transient map of arguments in JSON encoding Use TLS when communicating with the orderer endpoint Using only the command-specific options to instantiate the chaincode in a network with TLS disabled: Using the --installed flag to list the chaincodes installed on a peer. Using the --instantiated in combination with the -C (channel ID) flag to list the chaincodes instantiated on a channel. Using the --tls and --cafile global flags to instantiate the chaincode in a network with TLS enabled: You can see that chaincode mycc at version 1.0 is instantiated on channel mychannel. You can see that the peer has installed a chaincode called mycc which is at version 1.0. install instantiate invoke list package peer chaincode peer chaincode install peer chaincode instantiate peer chaincode instantiate examples peer chaincode invoke peer chaincode invoke example peer chaincode list peer chaincode list example peer chaincode package peer chaincode package example peer chaincode query peer chaincode signpackage peer chaincode signpackage ccwith1sig.pak ccwith2sig.pak Wrote signed package to ccwith2sig.pak successfully 2018-02-24 19:32:47.189 EST [main] main -> INFO 002 Exiting..... peer chaincode upgrade query signpackage upgrade Project-Id-Version: hyperledger-fabricdocs master
Report-Msgid-Bugs-To: 
POT-Creation-Date: 2020-05-24 19:11-0300
PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE
Last-Translator: FULL NAME <EMAIL@ADDRESS>
Language: pt_BR
Language-Team: pt_BR <LL@li.org>
Plural-Forms: nplurals=2; plural=(n > 1)
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Generated-By: Babel 2.6.0
 --cafile <string> --certfile <string> --keyfile <string> --ordererTLSHostnameOverride <string> --tls --transient <string> -o or --orderer <string> A successful response indicates that the transaction was submitted for ordering successfully. The transaction will then be added to a block and, finally, validated or invalidated by each peer on the channel. Each peer chaincode subcommand has both a set of flags specific to an individual subcommand, as well as a set of global flags that relate to all peer chaincode subcommands. Not all subcommands would use these flags. For instance, the query subcommand does not need the --orderer flag. Each peer chaincode subcommand is described together with its options in its own section in this topic. Example Usage Flags Here are some examples of the peer chaincode instantiate command, which instantiates the chaincode named mycc at version 1.0 on channel mychannel: Here are some examples of the peer chaincode list  command: Here is an example of the peer chaincode invoke command: Here is an example of the peer chaincode package command, which packages the chaincode named mycc at version 1.1, creates the chaincode deployment spec, signs the package using the local MSP, and outputs it as ccpack.out: Here you can see that the invoke was submitted successfully based on the log message: Invoke the chaincode named mycc at version 1.0 on channel mychannel on peer0.org1.example.com:7051 and peer0.org2.example.com:9051 (the peers defined by --peerAddresses), requesting to move 10 units from variable a to variable b: Ordering service endpoint specified as <hostname or IP address>:<port> Path to file containing PEM-encoded X509 public key to use for mutual TLS communication with the orderer endpoint Path to file containing PEM-encoded private key to use for mutual TLS communication with the orderer endpoint Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint Syntax The different subcommand options (install, instantiate...) relate to the different chaincode operations that are relevant to a peer. For example, use the peer chaincode install subcommand option to install a chaincode on a peer, or the peer chaincode query subcommand option to query a chaincode for the current value on a peer's ledger. The hostname override to use when validating the TLS connection to the orderer The individual flags are described with the relevant subcommand. The global flags are The peer chaincode command allows administrators to perform chaincode related operations on a peer, such as installing, instantiating, invoking, packaging, querying, and upgrading chaincode. The peer chaincode command has the following subcommands: Transient map of arguments in JSON encoding Use TLS when communicating with the orderer endpoint Using only the command-specific options to instantiate the chaincode in a network with TLS disabled: Using the --installed flag to list the chaincodes installed on a peer. Using the --instantiated in combination with the -C (channel ID) flag to list the chaincodes instantiated on a channel. Using the --tls and --cafile global flags to instantiate the chaincode in a network with TLS enabled: You can see that chaincode mycc at version 1.0 is instantiated on channel mychannel. You can see that the peer has installed a chaincode called mycc which is at version 1.0. install instantiate invoke list package peer chaincode peer chaincode install peer chaincode instantiate peer chaincode instantiate examples peer chaincode invoke peer chaincode invoke example peer chaincode list peer chaincode list example peer chaincode package peer chaincode package example peer chaincode query peer chaincode signpackage peer chaincode signpackage ccwith1sig.pak ccwith2sig.pak Wrote signed package to ccwith2sig.pak successfully 2018-02-24 19:32:47.189 EST [main] main -> INFO 002 Exiting..... peer chaincode upgrade query signpackage upgrade 