��          �               �  _  �     =  {   N  |   �  g   G  J   �  A   �     <     E     N  	   W     a    h  9   v  |  �    -     9
     H
     V
     s
     �
     �
     �
     �
     �
     �
     �
  �  �
  _  �     �  {      |   |  g   �  J   a  A   �     �     �        	   	           9   (  |  b    �     �     �          %     @     [     o     �     �     �     �   <a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>. Additional Notes Alternatively, after starting the REST server, the following curl command performs the same operation through the REST API. Alternatively, after starting the REST server, the following curl commands perform the same operations through the REST API. Compute a config update from original_config.pb and modified_config.pb and decode it to JSON to stdout. Convert a JSON document for a policy from stdin to a file named policy.pb. Decode a block named fabric_block.pb to JSON and print to stdout. Decoding Encoding Examples Pipelines Syntax The configtxlator command allows users to translate between protobuf and JSON versions of fabric data structures and create config updates.  The command may either start a REST server to expose its functions over HTTP or may be utilized directly as a command line tool. The configtxlator tool has five sub-commands, as follows: The tool name is a portmanteau of configtx and translator and is intended to convey that the tool simply converts between different equivalent data representations. It does not generate configuration. It does not submit or retrieve configuration. It does not modify configuration itself, it simply provides some bijective operations between different views of the configtx format. There is no configuration file configtxlator nor any authentication or authorization facilities included for the REST server.  Because configtxlator does not have any access to data, key material, or other information which might be considered sensitive, there is no risk to the owner of the server in exposing it to other clients.  However, because the data sent by a user to the REST server might be confidential, the user should either trust the administrator of the server, run a local instance, or operate via the CLI. compute_update configtxlator configtxlator compute_update configtxlator proto_decode configtxlator proto_encode configtxlator start configtxlator version proto_decode proto_encode start version Project-Id-Version: hyperledger-fabricdocs master
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
 <a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>. Additional Notes Alternatively, after starting the REST server, the following curl command performs the same operation through the REST API. Alternatively, after starting the REST server, the following curl commands perform the same operations through the REST API. Compute a config update from original_config.pb and modified_config.pb and decode it to JSON to stdout. Convert a JSON document for a policy from stdin to a file named policy.pb. Decode a block named fabric_block.pb to JSON and print to stdout. Decoding Encoding Examples Pipelines Syntax The configtxlator command allows users to translate between protobuf and JSON versions of fabric data structures and create config updates.  The command may either start a REST server to expose its functions over HTTP or may be utilized directly as a command line tool. The configtxlator tool has five sub-commands, as follows: The tool name is a portmanteau of configtx and translator and is intended to convey that the tool simply converts between different equivalent data representations. It does not generate configuration. It does not submit or retrieve configuration. It does not modify configuration itself, it simply provides some bijective operations between different views of the configtx format. There is no configuration file configtxlator nor any authentication or authorization facilities included for the REST server.  Because configtxlator does not have any access to data, key material, or other information which might be considered sensitive, there is no risk to the owner of the server in exposing it to other clients.  However, because the data sent by a user to the REST server might be confidential, the user should either trust the administrator of the server, run a local instance, or operate via the CLI. compute_update configtxlator configtxlator compute_update configtxlator proto_decode configtxlator proto_encode configtxlator start configtxlator version proto_decode proto_encode start version 