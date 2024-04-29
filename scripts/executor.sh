#!/bin/sh

executor_config='{
   "runExecutorServer": true,
   "runExecutorClient": false,
   "runExecutorClientMultithread": false,

   "runHashDBServer": true,
   "runHashDBTest": false,

   "runAggregatorServer": false,
   "runAggregatorClient": false,
   "runAggregatorClientMock": false,

   "runFileGenBatchProof": false,
   "runFileGenAggregatedProof": false,
   "runFileGenFinalProof": false,
   "runFileProcessBatch": false,
   "runFileProcessBatchMultithread": false,
   "runFileExecutor": false,

   "runKeccakScriptGenerator": false,
   "runKeccakTest": false,
   "runStorageSMTest": false,
   "runBinarySMTest": false,
   "runMemAlignSMTest": false,
   "runSHA256Test": false,
   "runBlakeTest": false,

   "executeInParallel": true,
   "useMainExecGenerated": true,
   "useProcessBatchCache": false,

   "saveRequestToFile": false,
   "saveInputToFile": false,
   "saveDbReadsToFile": false,
   "saveDbReadsToFileOnChange": false,
   "saveOutputToFile": false,
   "saveProofToFile": false,
   "saveResponseToFile": false,
   "saveFilesInSubfolders": false,

   "loadDBToMemCache": false,
   "loadDBToMemCacheInParallel": false,
   "loadDBToMemTimeout": 30000000,
   "dbMTCacheSize": 1024,
   "dbProgramCacheSize": 1024,

   "opcodeTracer": false,
   "logRemoteDbReads": false,
   "logExecutorServerInput": false,
   "logExecutorServerInputGasThreshold": 1048576,
   "logExecutorServerResponses": false,
   "logExecutorServerTxs": false,

   "executorServerPort": 50071,
   "executorROMLineTraces": false,
   "executorTimeStatistics": false,
   "executorClientPort": 50071,
   "executorClientHost": "127.0.0.1",
   "executorClientLoops": 1,

   "hashDBServerPort": 50061,
   "hashDBURL": "local",

   "aggregatorServerPort": 50081,
   "aggregatorClientPort": 50081,
   "aggregatorClientHost": "127.0.0.1",
   "aggregatorClientMockTimeout": 10000000,
   "aggregatorClientWatchdogTimeout": 60000000,

   "mapConstPolsFile": false,
   "mapConstantsTreeFile": false,

   "inputFile": "testvectors/performance/121_tx_input.json",
   "inputFile2": "testvectors/aggregatedProof/recursive1.zkin.proof_1.json",

   "outputPath": "runtime/output",
   "configPath": "config",

   "zkevmCmPols_disabled": "runtime/zkevm.commit",
   "zkevmCmPolsAfterExecutor_disabled": "runtime/zkevm.commit",
   "c12aCmPols": "runtime/c12a.commit",
   "recursive1CmPols_disabled": "runtime/recursive1.commit",
   "recursive2CmPols_disabled": "runtime/recursive2.commit",
   "recursivefCmPols_disabled": "runtime/recursivef.commit",
   "finalCmPols_disabled": "runtime/final.commit",

   "publicsOutput": "public.json",
   "proofFile": "proof.json",

   "databaseURL": "{{databaseURL}}",
   "dbNodesTableName": "state.nodes",
   "dbProgramTableName": "state.program",
   "dbMultiWrite": true,
   "dbFlushInParallel": false,
   "dbConnectionsPool": true,
   "dbNumberOfPoolConnections": 506,
   "dbMetrics": false,
   "dbClearCache": false,
   "dbGetTree": true,
   "dbReadRetryDelay": 100000,
   "cleanerPollingPeriod": 600,
   "requestsPersistence": 3600,
   "maxExecutorThreads": 100,
   "maxProverThreads": 100,
   "maxHashDBThreads": 200
}
'

generate_executor() {
  runAggregatorClientMock=false
  runExecutorClient=true
  runHashDBServer=true
  databaseURL="postgresql://$hash_db_user:$hash_db_password@$hash_db_host:$hash_db_port/$hash_db_name"
  if [ "$1" = "prover" ]; then
    runAggregatorClientMock=true
    runExecutorClient=false
    runHashDBServer=false
  fi
  tmp=$(echo "$executor_config" | jq --argjson runAggregatorClientMock "$runAggregatorClientMock" '.runAggregatorClientMock = $runAggregatorClientMock')
  tmp=$(echo "$tmp" | jq --argjson runExecutorClient "$runExecutorClient" '.runExecutorClient = $runExecutorClient')
  tmp=$(echo "$tmp" | jq --argjson runHashDBServer "$runHashDBServer" '.runHashDBServer = $runHashDBServer')
  tmp=$(echo "$tmp" | jq --arg databaseURL "$databaseURL" '.databaseURL = $databaseURL')
  echo "$tmp"
}
