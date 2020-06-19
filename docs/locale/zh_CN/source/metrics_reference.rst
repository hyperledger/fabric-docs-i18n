Metrics Reference
=================

Prometheus Metrics
------------------

The following metrics are currently exported for consumption by Prometheus.

+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| Name                                                | Type      | Description                                                | Labels             |
+=====================================================+===========+============================================================+====================+
| blockcutter_block_fill_duration                     | histogram | The time from first transaction enqueing to the block      | channel            |
|                                                     |           | being cut in seconds.                                      |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| broadcast_enqueue_duration                          | histogram | The time to enqueue a transaction in seconds.              | channel            |
|                                                     |           |                                                            | type               |
|                                                     |           |                                                            | status             |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| broadcast_processed_count                           | counter   | The number of transactions processed.                      | channel            |
|                                                     |           |                                                            | type               |
|                                                     |           |                                                            | status             |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| broadcast_validate_duration                         | histogram | The time to validate a transaction in seconds.             | channel            |
|                                                     |           |                                                            | type               |
|                                                     |           |                                                            | status             |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| chaincode_execute_timeouts                          | counter   | The number of chaincode executions (Init or Invoke) that   | chaincode          |
|                                                     |           | have timed out.                                            |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| chaincode_launch_duration                           | histogram | The time to launch a chaincode.                            | chaincode          |
|                                                     |           |                                                            | success            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| chaincode_launch_failures                           | counter   | The number of chaincode launches that have failed.         | chaincode          |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| chaincode_launch_timeouts                           | counter   | The number of chaincode launches that have timed out.      | chaincode          |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| chaincode_shim_request_duration                     | histogram | The time to complete chaincode shim requests.              | type               |
|                                                     |           |                                                            | channel            |
|                                                     |           |                                                            | chaincode          |
|                                                     |           |                                                            | success            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| chaincode_shim_requests_completed                   | counter   | The number of chaincode shim requests completed.           | type               |
|                                                     |           |                                                            | channel            |
|                                                     |           |                                                            | chaincode          |
|                                                     |           |                                                            | success            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| chaincode_shim_requests_received                    | counter   | The number of chaincode shim requests received.            | type               |
|                                                     |           |                                                            | channel            |
|                                                     |           |                                                            | chaincode          |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| cluster_comm_egress_queue_capacity                  | gauge     | Capacity of the egress queue.                              | host               |
|                                                     |           |                                                            | msg_type           |
|                                                     |           |                                                            | channel            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| cluster_comm_egress_queue_length                    | gauge     | Length of the egress queue.                                | host               |
|                                                     |           |                                                            | msg_type           |
|                                                     |           |                                                            | channel            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| cluster_comm_egress_queue_workers                   | gauge     | Count of egress queue workers.                             | channel            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| cluster_comm_egress_stream_count                    | gauge     | Count of streams to other nodes.                           | channel            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| cluster_comm_egress_tls_connection_count            | gauge     | Count of TLS connections to other nodes.                   |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| cluster_comm_ingress_stream_count                   | gauge     | Count of streams from other nodes.                         |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| cluster_comm_msg_dropped_count                      | counter   | Count of messages dropped.                                 | host               |
|                                                     |           |                                                            | channel            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| cluster_comm_msg_send_time                          | histogram | The time it takes to send a message in seconds.            | host               |
|                                                     |           |                                                            | channel            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| consensus_etcdraft_cluster_size                     | gauge     | Number of nodes in this channel.                           | channel            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| consensus_etcdraft_committed_block_number           | gauge     | The block number of the latest block committed.            | channel            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| consensus_etcdraft_config_proposals_received        | counter   | The total number of proposals received for config type     | channel            |
|                                                     |           | transactions.                                              |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| consensus_etcdraft_data_persist_duration            | histogram | The time taken for etcd/raft data to be persisted in       | channel            |
|                                                     |           | storage (in seconds).                                      |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| consensus_etcdraft_is_leader                        | gauge     | The leadership status of the current node: 1 if it is the  | channel            |
|                                                     |           | leader else 0.                                             |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| consensus_etcdraft_leader_changes                   | counter   | The number of leader changes since process start.          | channel            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| consensus_etcdraft_normal_proposals_received        | counter   | The total number of proposals received for normal type     | channel            |
|                                                     |           | transactions.                                              |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| consensus_etcdraft_proposal_failures                | counter   | The number of proposal failures.                           | channel            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| consensus_etcdraft_snapshot_block_number            | gauge     | The block number of the latest snapshot.                   | channel            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| consensus_kafka_batch_size                          | gauge     | The mean batch size in bytes sent to topics.               | topic              |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| consensus_kafka_compression_ratio                   | gauge     | The mean compression ratio (as percentage) for topics.     | topic              |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| consensus_kafka_incoming_byte_rate                  | gauge     | Bytes/second read off brokers.                             | broker_id          |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| consensus_kafka_last_offset_persisted               | gauge     | The offset specified in the block metadata of the most     | channel            |
|                                                     |           | recently committed block.                                  |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| consensus_kafka_outgoing_byte_rate                  | gauge     | Bytes/second written to brokers.                           | broker_id          |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| consensus_kafka_record_send_rate                    | gauge     | The number of records per second sent to topics.           | topic              |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| consensus_kafka_records_per_request                 | gauge     | The mean number of records sent per request to topics.     | topic              |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| consensus_kafka_request_latency                     | gauge     | The mean request latency in ms to brokers.                 | broker_id          |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| consensus_kafka_request_rate                        | gauge     | Requests/second sent to brokers.                           | broker_id          |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| consensus_kafka_request_size                        | gauge     | The mean request size in bytes to brokers.                 | broker_id          |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| consensus_kafka_response_rate                       | gauge     | Requests/second sent to brokers.                           | broker_id          |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| consensus_kafka_response_size                       | gauge     | The mean response size in bytes from brokers.              | broker_id          |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| couchdb_processing_time                             | histogram | Time taken in seconds for the function to complete request | database           |
|                                                     |           | to CouchDB                                                 | function_name      |
|                                                     |           |                                                            | result             |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| deliver_blocks_sent                                 | counter   | The number of blocks sent by the deliver service.          | channel            |
|                                                     |           |                                                            | filtered           |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| deliver_requests_completed                          | counter   | The number of deliver requests that have been completed.   | channel            |
|                                                     |           |                                                            | filtered           |
|                                                     |           |                                                            | success            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| deliver_requests_received                           | counter   | The number of deliver requests that have been received.    | channel            |
|                                                     |           |                                                            | filtered           |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| deliver_streams_closed                              | counter   | The number of GRPC streams that have been closed for the   |                    |
|                                                     |           | deliver service.                                           |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| deliver_streams_opened                              | counter   | The number of GRPC streams that have been opened for the   |                    |
|                                                     |           | deliver service.                                           |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| dockercontroller_chaincode_container_build_duration | histogram | The time to build a chaincode image in seconds.            | chaincode          |
|                                                     |           |                                                            | success            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| endorser_chaincode_instantiation_failures           | counter   | The number of chaincode instantiations or upgrade that     | channel            |
|                                                     |           | have failed.                                               | chaincode          |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| endorser_duplicate_transaction_failures             | counter   | The number of failed proposals due to duplicate            | channel            |
|                                                     |           | transaction ID.                                            | chaincode          |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| endorser_endorsement_failures                       | counter   | The number of failed endorsements.                         | channel            |
|                                                     |           |                                                            | chaincode          |
|                                                     |           |                                                            | chaincodeerror     |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| endorser_proposal_acl_failures                      | counter   | The number of proposals that failed ACL checks.            | channel            |
|                                                     |           |                                                            | chaincode          |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| endorser_proposal_validation_failures               | counter   | The number of proposals that have failed initial           |                    |
|                                                     |           | validation.                                                |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| endorser_proposals_received                         | counter   | The number of proposals received.                          |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| endorser_propsal_duration                           | histogram | The time to complete a proposal.                           | channel            |
|                                                     |           |                                                            | chaincode          |
|                                                     |           |                                                            | success            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| endorser_successful_proposals                       | counter   | The number of successful proposals.                        |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| fabric_version                                      | gauge     | The active version of Fabric.                              | version            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| gossip_comm_messages_received                       | counter   | Number of messages received                                |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| gossip_comm_messages_sent                           | counter   | Number of messages sent                                    |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| gossip_comm_overflow_count                          | counter   | Number of outgoing queue buffer overflows                  |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| gossip_leader_election_leader                       | gauge     | Peer is leader (1) or follower (0)                         | channel            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| gossip_membership_total_peers_known                 | gauge     | Total known peers                                          | channel            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| gossip_payload_buffer_size                          | gauge     | Size of the payload buffer                                 | channel            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| gossip_privdata_commit_block_duration               | histogram | Time it takes to commit private data and the corresponding | channel            |
|                                                     |           | block (in seconds)                                         |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| gossip_privdata_fetch_duration                      | histogram | Time it takes to fetch missing private data from peers (in | channel            |
|                                                     |           | seconds)                                                   |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| gossip_privdata_list_missing_duration               | histogram | Time it takes to list the missing private data (in         | channel            |
|                                                     |           | seconds)                                                   |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| gossip_privdata_pull_duration                       | histogram | Time it takes to pull a missing private data element (in   | channel            |
|                                                     |           | seconds)                                                   |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| gossip_privdata_purge_duration                      | histogram | Time it takes to purge private data (in seconds)           | channel            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| gossip_privdata_reconciliation_duration             | histogram | Time it takes for reconciliation to complete (in seconds)  | channel            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| gossip_privdata_retrieve_duration                   | histogram | Time it takes to retrieve missing private data elements    | channel            |
|                                                     |           | from the ledger (in seconds)                               |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| gossip_privdata_send_duration                       | histogram | Time it takes to send a missing private data element (in   | channel            |
|                                                     |           | seconds)                                                   |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| gossip_privdata_validation_duration                 | histogram | Time it takes to validate a block (in seconds)             | channel            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| gossip_state_commit_duration                        | histogram | Time it takes to commit a block in seconds                 | channel            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| gossip_state_height                                 | gauge     | Current ledger height                                      | channel            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| grpc_comm_conn_closed                               | counter   | gRPC connections closed. Open minus closed is the active   |                    |
|                                                     |           | number of connections.                                     |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| grpc_comm_conn_opened                               | counter   | gRPC connections opened. Open minus closed is the active   |                    |
|                                                     |           | number of connections.                                     |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| grpc_server_stream_messages_received                | counter   | The number of stream messages received.                    | service            |
|                                                     |           |                                                            | method             |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| grpc_server_stream_messages_sent                    | counter   | The number of stream messages sent.                        | service            |
|                                                     |           |                                                            | method             |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| grpc_server_stream_request_duration                 | histogram | The time to complete a stream request.                     | service            |
|                                                     |           |                                                            | method             |
|                                                     |           |                                                            | code               |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| grpc_server_stream_requests_completed               | counter   | The number of stream requests completed.                   | service            |
|                                                     |           |                                                            | method             |
|                                                     |           |                                                            | code               |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| grpc_server_stream_requests_received                | counter   | The number of stream requests received.                    | service            |
|                                                     |           |                                                            | method             |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| grpc_server_unary_request_duration                  | histogram | The time to complete a unary request.                      | service            |
|                                                     |           |                                                            | method             |
|                                                     |           |                                                            | code               |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| grpc_server_unary_requests_completed                | counter   | The number of unary requests completed.                    | service            |
|                                                     |           |                                                            | method             |
|                                                     |           |                                                            | code               |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| grpc_server_unary_requests_received                 | counter   | The number of unary requests received.                     | service            |
|                                                     |           |                                                            | method             |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| ledger_block_processing_time                        | histogram | Time taken in seconds for ledger block processing.         | channel            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| ledger_blockchain_height                            | gauge     | Height of the chain in blocks.                             | channel            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| ledger_blockstorage_and_pvtdata_commit_time         | histogram | Time taken in seconds for committing the block and private | channel            |
|                                                     |           | data to storage.                                           |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| ledger_blockstorage_commit_time                     | histogram | Time taken in seconds for committing the block to storage. | channel            |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| ledger_statedb_commit_time                          | histogram | Time taken in seconds for committing block changes to      | channel            |
|                                                     |           | state db.                                                  |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| ledger_transaction_count                            | counter   | Number of transactions processed.                          | channel            |
|                                                     |           |                                                            | transaction_type   |
|                                                     |           |                                                            | chaincode          |
|                                                     |           |                                                            | validation_code    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| logging_entries_checked                             | counter   | Number of log entries checked against the active logging   | level              |
|                                                     |           | level                                                      |                    |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+
| logging_entries_written                             | counter   | Number of log entries that are written                     | level              |
+-----------------------------------------------------+-----------+------------------------------------------------------------+--------------------+


StatsD Metrics
--------------

The following metrics are currently emitted for consumption by StatsD. The
``%{variable_name}`` nomenclature represents segments that vary based on
context.

For example, ``%{channel}`` will be replaced with the name of the channel
associated with the metric.

+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| Bucket                                                                                  | Type      | Description                                                |
+=========================================================================================+===========+============================================================+
| blockcutter.block_fill_duration.%{channel}                                              | histogram | The time from first transaction enqueing to the block      |
|                                                                                         |           | being cut in seconds.                                      |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| broadcast.enqueue_duration.%{channel}.%{type}.%{status}                                 | histogram | The time to enqueue a transaction in seconds.              |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| broadcast.processed_count.%{channel}.%{type}.%{status}                                  | counter   | The number of transactions processed.                      |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| broadcast.validate_duration.%{channel}.%{type}.%{status}                                | histogram | The time to validate a transaction in seconds.             |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| chaincode.execute_timeouts.%{chaincode}                                                 | counter   | The number of chaincode executions (Init or Invoke) that   |
|                                                                                         |           | have timed out.                                            |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| chaincode.launch_duration.%{chaincode}.%{success}                                       | histogram | The time to launch a chaincode.                            |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| chaincode.launch_failures.%{chaincode}                                                  | counter   | The number of chaincode launches that have failed.         |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| chaincode.launch_timeouts.%{chaincode}                                                  | counter   | The number of chaincode launches that have timed out.      |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| chaincode.shim_request_duration.%{type}.%{channel}.%{chaincode}.%{success}              | histogram | The time to complete chaincode shim requests.              |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| chaincode.shim_requests_completed.%{type}.%{channel}.%{chaincode}.%{success}            | counter   | The number of chaincode shim requests completed.           |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| chaincode.shim_requests_received.%{type}.%{channel}.%{chaincode}                        | counter   | The number of chaincode shim requests received.            |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| cluster.comm.egress_queue_capacity.%{host}.%{msg_type}.%{channel}                       | gauge     | Capacity of the egress queue.                              |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| cluster.comm.egress_queue_length.%{host}.%{msg_type}.%{channel}                         | gauge     | Length of the egress queue.                                |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| cluster.comm.egress_queue_workers.%{channel}                                            | gauge     | Count of egress queue workers.                             |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| cluster.comm.egress_stream_count.%{channel}                                             | gauge     | Count of streams to other nodes.                           |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| cluster.comm.egress_tls_connection_count                                                | gauge     | Count of TLS connections to other nodes.                   |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| cluster.comm.ingress_stream_count                                                       | gauge     | Count of streams from other nodes.                         |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| cluster.comm.msg_dropped_count.%{host}.%{channel}                                       | counter   | Count of messages dropped.                                 |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| cluster.comm.msg_send_time.%{host}.%{channel}                                           | histogram | The time it takes to send a message in seconds.            |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| consensus.etcdraft.cluster_size.%{channel}                                              | gauge     | Number of nodes in this channel.                           |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| consensus.etcdraft.committed_block_number.%{channel}                                    | gauge     | The block number of the latest block committed.            |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| consensus.etcdraft.config_proposals_received.%{channel}                                 | counter   | The total number of proposals received for config type     |
|                                                                                         |           | transactions.                                              |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| consensus.etcdraft.data_persist_duration.%{channel}                                     | histogram | The time taken for etcd/raft data to be persisted in       |
|                                                                                         |           | storage (in seconds).                                      |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| consensus.etcdraft.is_leader.%{channel}                                                 | gauge     | The leadership status of the current node: 1 if it is the  |
|                                                                                         |           | leader else 0.                                             |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| consensus.etcdraft.leader_changes.%{channel}                                            | counter   | The number of leader changes since process start.          |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| consensus.etcdraft.normal_proposals_received.%{channel}                                 | counter   | The total number of proposals received for normal type     |
|                                                                                         |           | transactions.                                              |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| consensus.etcdraft.proposal_failures.%{channel}                                         | counter   | The number of proposal failures.                           |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| consensus.etcdraft.snapshot_block_number.%{channel}                                     | gauge     | The block number of the latest snapshot.                   |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| consensus.kafka.batch_size.%{topic}                                                     | gauge     | The mean batch size in bytes sent to topics.               |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| consensus.kafka.compression_ratio.%{topic}                                              | gauge     | The mean compression ratio (as percentage) for topics.     |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| consensus.kafka.incoming_byte_rate.%{broker_id}                                         | gauge     | Bytes/second read off brokers.                             |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| consensus.kafka.last_offset_persisted.%{channel}                                        | gauge     | The offset specified in the block metadata of the most     |
|                                                                                         |           | recently committed block.                                  |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| consensus.kafka.outgoing_byte_rate.%{broker_id}                                         | gauge     | Bytes/second written to brokers.                           |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| consensus.kafka.record_send_rate.%{topic}                                               | gauge     | The number of records per second sent to topics.           |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| consensus.kafka.records_per_request.%{topic}                                            | gauge     | The mean number of records sent per request to topics.     |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| consensus.kafka.request_latency.%{broker_id}                                            | gauge     | The mean request latency in ms to brokers.                 |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| consensus.kafka.request_rate.%{broker_id}                                               | gauge     | Requests/second sent to brokers.                           |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| consensus.kafka.request_size.%{broker_id}                                               | gauge     | The mean request size in bytes to brokers.                 |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| consensus.kafka.response_rate.%{broker_id}                                              | gauge     | Requests/second sent to brokers.                           |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| consensus.kafka.response_size.%{broker_id}                                              | gauge     | The mean response size in bytes from brokers.              |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| couchdb.processing_time.%{database}.%{function_name}.%{result}                          | histogram | Time taken in seconds for the function to complete request |
|                                                                                         |           | to CouchDB                                                 |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| deliver.blocks_sent.%{channel}.%{filtered}                                              | counter   | The number of blocks sent by the deliver service.          |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| deliver.requests_completed.%{channel}.%{filtered}.%{success}                            | counter   | The number of deliver requests that have been completed.   |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| deliver.requests_received.%{channel}.%{filtered}                                        | counter   | The number of deliver requests that have been received.    |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| deliver.streams_closed                                                                  | counter   | The number of GRPC streams that have been closed for the   |
|                                                                                         |           | deliver service.                                           |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| deliver.streams_opened                                                                  | counter   | The number of GRPC streams that have been opened for the   |
|                                                                                         |           | deliver service.                                           |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| dockercontroller.chaincode_container_build_duration.%{chaincode}.%{success}             | histogram | The time to build a chaincode image in seconds.            |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| endorser.chaincode_instantiation_failures.%{channel}.%{chaincode}                       | counter   | The number of chaincode instantiations or upgrade that     |
|                                                                                         |           | have failed.                                               |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| endorser.duplicate_transaction_failures.%{channel}.%{chaincode}                         | counter   | The number of failed proposals due to duplicate            |
|                                                                                         |           | transaction ID.                                            |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| endorser.endorsement_failures.%{channel}.%{chaincode}.%{chaincodeerror}                 | counter   | The number of failed endorsements.                         |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| endorser.proposal_acl_failures.%{channel}.%{chaincode}                                  | counter   | The number of proposals that failed ACL checks.            |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| endorser.proposal_validation_failures                                                   | counter   | The number of proposals that have failed initial           |
|                                                                                         |           | validation.                                                |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| endorser.proposals_received                                                             | counter   | The number of proposals received.                          |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| endorser.propsal_duration.%{channel}.%{chaincode}.%{success}                            | histogram | The time to complete a proposal.                           |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| endorser.successful_proposals                                                           | counter   | The number of successful proposals.                        |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| fabric_version.%{version}                                                               | gauge     | The active version of Fabric.                              |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| gossip.comm.messages_received                                                           | counter   | Number of messages received                                |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| gossip.comm.messages_sent                                                               | counter   | Number of messages sent                                    |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| gossip.comm.overflow_count                                                              | counter   | Number of outgoing queue buffer overflows                  |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| gossip.leader_election.leader.%{channel}                                                | gauge     | Peer is leader (1) or follower (0)                         |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| gossip.membership.total_peers_known.%{channel}                                          | gauge     | Total known peers                                          |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| gossip.payload_buffer.size.%{channel}                                                   | gauge     | Size of the payload buffer                                 |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| gossip.privdata.commit_block_duration.%{channel}                                        | histogram | Time it takes to commit private data and the corresponding |
|                                                                                         |           | block (in seconds)                                         |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| gossip.privdata.fetch_duration.%{channel}                                               | histogram | Time it takes to fetch missing private data from peers (in |
|                                                                                         |           | seconds)                                                   |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| gossip.privdata.list_missing_duration.%{channel}                                        | histogram | Time it takes to list the missing private data (in         |
|                                                                                         |           | seconds)                                                   |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| gossip.privdata.pull_duration.%{channel}                                                | histogram | Time it takes to pull a missing private data element (in   |
|                                                                                         |           | seconds)                                                   |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| gossip.privdata.purge_duration.%{channel}                                               | histogram | Time it takes to purge private data (in seconds)           |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| gossip.privdata.reconciliation_duration.%{channel}                                      | histogram | Time it takes for reconciliation to complete (in seconds)  |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| gossip.privdata.retrieve_duration.%{channel}                                            | histogram | Time it takes to retrieve missing private data elements    |
|                                                                                         |           | from the ledger (in seconds)                               |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| gossip.privdata.send_duration.%{channel}                                                | histogram | Time it takes to send a missing private data element (in   |
|                                                                                         |           | seconds)                                                   |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| gossip.privdata.validation_duration.%{channel}                                          | histogram | Time it takes to validate a block (in seconds)             |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| gossip.state.commit_duration.%{channel}                                                 | histogram | Time it takes to commit a block in seconds                 |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| gossip.state.height.%{channel}                                                          | gauge     | Current ledger height                                      |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| grpc.comm.conn_closed                                                                   | counter   | gRPC connections closed. Open minus closed is the active   |
|                                                                                         |           | number of connections.                                     |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| grpc.comm.conn_opened                                                                   | counter   | gRPC connections opened. Open minus closed is the active   |
|                                                                                         |           | number of connections.                                     |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| grpc.server.stream_messages_received.%{service}.%{method}                               | counter   | The number of stream messages received.                    |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| grpc.server.stream_messages_sent.%{service}.%{method}                                   | counter   | The number of stream messages sent.                        |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| grpc.server.stream_request_duration.%{service}.%{method}.%{code}                        | histogram | The time to complete a stream request.                     |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| grpc.server.stream_requests_completed.%{service}.%{method}.%{code}                      | counter   | The number of stream requests completed.                   |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| grpc.server.stream_requests_received.%{service}.%{method}                               | counter   | The number of stream requests received.                    |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| grpc.server.unary_request_duration.%{service}.%{method}.%{code}                         | histogram | The time to complete a unary request.                      |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| grpc.server.unary_requests_completed.%{service}.%{method}.%{code}                       | counter   | The number of unary requests completed.                    |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| grpc.server.unary_requests_received.%{service}.%{method}                                | counter   | The number of unary requests received.                     |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| ledger.block_processing_time.%{channel}                                                 | histogram | Time taken in seconds for ledger block processing.         |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| ledger.blockchain_height.%{channel}                                                     | gauge     | Height of the chain in blocks.                             |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| ledger.blockstorage_and_pvtdata_commit_time.%{channel}                                  | histogram | Time taken in seconds for committing the block and private |
|                                                                                         |           | data to storage.                                           |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| ledger.blockstorage_commit_time.%{channel}                                              | histogram | Time taken in seconds for committing the block to storage. |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| ledger.statedb_commit_time.%{channel}                                                   | histogram | Time taken in seconds for committing block changes to      |
|                                                                                         |           | state db.                                                  |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| ledger.transaction_count.%{channel}.%{transaction_type}.%{chaincode}.%{validation_code} | counter   | Number of transactions processed.                          |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| logging.entries_checked.%{level}                                                        | counter   | Number of log entries checked against the active logging   |
|                                                                                         |           | level                                                      |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+
| logging.entries_written.%{level}                                                        | counter   | Number of log entries that are written                     |
+-----------------------------------------------------------------------------------------+-----------+------------------------------------------------------------+


.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
