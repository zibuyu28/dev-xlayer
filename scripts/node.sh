#!/bin/sh

node_config='IsTrustedSequencer = true
ForkUpgradeBatchNumber=0
ForkUpgradeNewForkId=0

[Log]
Environment = "production" # "production" or "development"
Level = "info"
Outputs = ["stderr"]

[State]
    [State.DB]
    User = "{{state_db_user}}"
    Password = "{{state_db_password}}"
    Name = "{{state_db_name}}"
    Host = "{{state_db_host}}"
    Port = "{{state_db_port}}"
    EnableLog = false
    MaxConns = 200
    [State.Batch]
        [State.Batch.Constraints]
        MaxTxsPerBatch = 300
        MaxBatchBytesSize = 108000
        MaxCumulativeGasUsed = 30000000
        MaxKeccakHashes = 1930
        MaxPoseidonHashes = 227121
        MaxPoseidonPaddings = 121671
        MaxMemAligns = 212926
        MaxArithmetics = 212926
        MaxBinaries = 425853
        MaxSteps = 6813484
        MaxSHA256Hashes = 1436

[Pool]
FreeClaimGasLimit = 1500000
IntervalToRefreshBlockedAddresses = "5m"
IntervalToRefreshGasPrices = "5s"
MaxTxBytesSize=100132
MaxTxDataBytesSize=100000
DefaultMinGasPriceAllowed = 5000000000
MinAllowedGasPriceInterval = "5m"
PollMinAllowedGasPriceInterval = "15s"
AccountQueue = 128
GlobalQueue = 0
FreeGasAddress = [{{free_gas_address}}]
    [Pool.EffectiveGasPrice]
        Enabled = false
        L1GasPriceFactor = 0.25
        ByteGasCost = 16
        ZeroByteGasCost = 4
        NetProfit = 1
        BreakEvenFactor = 1.1
        FinalDeviationPct = 10
        EthTransferGasPrice = 0
        EthTransferL1GasPriceFactor = 0
        L2GasPriceSuggesterFactor = 0.5
    [Pool.DB]
        User = "{{pool_db_user}}"
        Password = "{{pool_db_password}}"
        Name = "{{pool_db_name}}"
        Host = "{{pool_db_host}}"
        Port = "{{pool_db_port}}"
        EnableLog = false
        MaxConns = 200

[Etherman]
URL = "{{etherman_url}}"
ForkIDChunkSize = 20000
MultiGasProvider = false
    [Etherscan]
        ApiKey = ""

[RPC]
Host = "0.0.0.0"
Port = 8545
ReadTimeout = "60s"
WriteTimeout = "60s"
MaxRequestsPerIPAndSecond = 50000
SequencerNodeURI = ""
EnableL2SuggestedGasPricePolling = true
EnablePendingTransactionFilter = false
BatchRequestsEnabled = true
BatchRequestsLimit = 20
MaxLogsCount = 10000
MaxLogsBlockRange = 10000
MaxNativeBlockHashBlockRange = 60000
EnableHttpLog = true
GasLimitFactor = 1
DisableAPIs = []
    [RPC.WebSockets]
        Enabled = true
        Port = 10443
    [RPC.Nacos]
        URLs = ""
        NamespaceId = ""
        ApplicationName = ""
        ExternalListenAddr = ""
    [RPC.NacosWs]
        URLs = ""
        NamespaceId = ""
        ApplicationName = ""
        ExternalListenAddr = ""
    [RPC.RateLimit]
        Enabled = false
        RateLimitApis = ["eth_getLogs"]
        RateLimitCount = 100
        RateLimitDuration = 1
        SpecialApis = [
                {Api = "eth_newFilter", Count = 100, Duration = 1}
        ]
    [RPC.DynamicGP]
        Enabled = true
        CongestionTxThreshold = 100
        CheckBatches = 5
        SampleNumber = 3
        Percentile = 70
        MaxPrice = 20000000000
        MinPrice = 100000000

[Synchronizer]
SyncInterval = "1s"
SyncChunkSize = 100
TrustedSequencerURL = "" # If it is empty or not specified, then the value is read from the smc.

[Sequencer]
DeletePoolTxsL1BlockConfirmations = 100
DeletePoolTxsCheckInterval = "12h"
TxLifetimeCheckInterval = "10m"
TxLifetimeMax = "6h"
LoadPoolTxsCheckInterval = "500ms"
StateConsistencyCheckInterval = "5s"
PackBatchSpacialList = [{{pack_batch_spacial_list}}]
GasPriceMultiple = 5
  [Sequencer.Finalizer]
    NewTxsWaitInterval = "100ms"
    ForcedBatchesTimeout = "5s"
    ForcedBatchesL1BlockConfirmations = 0
    ForcedBatchesCheckInterval = "10s"
    L1InfoTreeL1BlockConfirmations = 64
    L1InfoTreeCheckInterval = "120s"
    BatchMaxDeltaTimestamp = "300s"
    L2BlockMaxDeltaTimestamp = "10s"
    ResourceExhaustedMarginPct = 10
    HaltOnBatchNumber = 0
    SequentialBatchSanityCheck = false
    SequentialProcessL2Block = true
    [Sequencer.Finalizer.Metrics]
      Interval = "60m"
      EnableLog = true
	[Sequencer.StreamServer]
		Port = 6900
		Filename = "/datastreamer/datastream.bin"
		Version = 2
		ChainId = {{l2_chain_id}}
		UpgradeEtrogBatchNumber = 0
		Enabled = true

[SequenceSender]
WaitPeriodSendSequence = "60s"
LastBatchVirtualizationTimeMaxWaitPeriod = "120s"
MaxTxSizeForL1 = 131072
MaxBatchesForL1 = 200
SenderAddress = "{{sequencer_address}}"
L2Coinbase= "{{sequencer_address}}"
PrivateKey = {Path = "/pk/sequencer.keystore", Password = "password"}
DAPermitApiPrivateKey = {Path = "/pk/da-signer.keystore", Password = "password"}

[Aggregator]
Host = "0.0.0.0"
Port = 8000
ForkId = 9
RetryTime = "5s"
VerifyProofInterval = "900s"
TxProfitabilityCheckerType = "acceptall"
TxProfitabilityMinReward = "1.1"
ProofStatePollingInterval = "5s"
SenderAddress = "{{aggregator_address}}"
CleanupLockedProofsInterval = "2m"
GeneratingProofCleanupThreshold = "10m"
GasOffset = 0
UpgradeEtrogBatchNumber = 0
BatchProofL1BlockConfirmations = 2

[EthTxManager]
ForcedGas = 0
FrequencyToMonitorTxs = "1s"
WaitTxToBeMined = "2m"
GasPriceMarginFactor = 2
MaxGasPriceLimit = 0
PrivateKeys = [
    {Path = "/pk/sequencer.keystore", Password = "password"},
    {Path = "/pk/aggregator.keystore", Password = "password"}
]
    [EthTxManager.CustodialAssets]
        Enable=false
        URL="https://assetonchain.coinall.ltd"
        Symbol=2882
        SequencerAddr="{{sequencer_address}}"
        AggregatorAddr="{{aggregator_address}}"
        WaitResultTimeout="2m"
        AccessKey="74w82q40cz"
        SecretKey="3v2c07o12j9760ag"

[L2GasPriceSuggester]
Type = "follower"
EnableFollowerAdjustByL2L1Price = true
UpdatePeriod = "10s"
Factor = 0.1
DefaultGasPriceWei = 1500000000
MaxGasPriceWei = 2000000000000
DefaultL1CoinPrice = 2000
DefaultL2CoinPrice = 50
KafkaURL= "10.1.6.182:9092,10.1.6.183:9092,10.1.6.184:9092"
Topic= "explorer_coinPrice_push"
GroupID= "web3_okbc_explorerchainprice"
Username= ""
Password= ""
RootCAPath= "/app/only-4096-ca-cert"
GasPriceUsdt = 0.000000476190476
CleanHistoryPeriod = "1h"
CleanHistoryTimeRetention = "5m"

[MTClient]
URI  = ""

[Executor]
URI = ""
MaxResourceExhaustedAttempts = 3
WaitOnResourceExhaustion = "1s"
MaxGRPCMessageSize = 1000000000

[Metrics]
Host = "0.0.0.0"
Port = 9091
Enabled = true
ProfilingHost = "0.0.0.0"
ProfilingPort = 6060
ProfilingEnabled = true

[EventLog]
    [EventLog.DB]
    User = "{{event_db_user}}"
    Password = "{{event_db_password}}"
    Name = "{{event_db_name}}"
    Host = "{{event_db_host}}"
    Port = "{{event_db_port}}"
    EnableLog = false
    MaxConns = 200
[Apollo]
    Enable=false
    IP="http://10.2.7.65:8080"
    AppID="defi-chain-x1-testnet"
    NamespaceName=""

[HashDB]
User = "{{hash_db_user}}"
Password = "{{hash_db_password}}"
Name = "{{hash_db_name}}"
Host = "{{hash_db_host}}"
Port = "{{hash_db_port}}"
EnableLog = false
MaxConns = 200
'

sedi () {
    case $(uname -s) in
        *[Dd]arwin* | *BSD* ) sed "$@";;
        *) sed "$@";;
    esac
}

generate_node() {
  tmp=$(echo "$node_config" | sedi "s#{{state_db_user}}#${state_db_user}#g")
  tmp=$(echo "$tmp" | sedi "s#{{state_db_password}}#${state_db_password}#g")
  tmp=$(echo "$tmp" | sedi "s#{{state_db_name}}#${state_db_name}#g")
  tmp=$(echo "$tmp" | sedi "s#{{state_db_host}}#${state_db_host}#g")
  tmp=$(echo "$tmp" | sedi "s#{{state_db_port}}#${state_db_port}#g")

  tmp=$(echo "$tmp" | sedi "s#{{free_gas_address}}#${free_gas_address}#g")

  tmp=$(echo "$tmp" | sedi "s#{{pool_db_user}}#${pool_db_user}#g")
  tmp=$(echo "$tmp" | sedi "s#{{pool_db_password}}#${pool_db_password}#g")
  tmp=$(echo "$tmp" | sedi "s#{{pool_db_name}}#${pool_db_name}#g")
  tmp=$(echo "$tmp" | sedi "s#{{pool_db_host}}#${pool_db_host}#g")
  tmp=$(echo "$tmp" | sedi "s#{{pool_db_port}}#${pool_db_port}#g")

  tmp=$(echo "$tmp" | sedi "s#{{etherman_url}}#${etherman_url}#g")
  tmp=$(echo "$tmp" | sedi "s#{{pack_batch_spacial_list}}#${pack_batch_spacial_list}#g")
  tmp=$(echo "$tmp" | sedi "s#{{l2_chain_id}}#${l2_chain_id}#g")
  tmp=$(echo "$tmp" | sedi "s#{{sequencer_address}}#${sequencer_address}#g")
  tmp=$(echo "$tmp" | sedi "s#{{aggregator_address}}#${aggregator_address}#g")

  tmp=$(echo "$tmp" | sedi "s#{{event_db_user}}#${event_db_user}#g")
  tmp=$(echo "$tmp" | sedi "s#{{event_db_password}}#${event_db_password}#g")
  tmp=$(echo "$tmp" | sedi "s#{{event_db_name}}#${event_db_name}#g")
  tmp=$(echo "$tmp" | sedi "s#{{event_db_host}}#${event_db_host}#g")
  tmp=$(echo "$tmp" | sedi "s#{{event_db_port}}#${event_db_port}#g")

  tmp=$(echo "$tmp" | sedi "s#{{hash_db_user}}#${hash_db_user}#g")
  tmp=$(echo "$tmp" | sedi "s#{{hash_db_password}}#${hash_db_password}#g")
  tmp=$(echo "$tmp" | sedi "s#{{hash_db_name}}#${hash_db_name}#g")
  tmp=$(echo "$tmp" | sedi "s#{{hash_db_host}}#${hash_db_host}#g")
  tmp=$(echo "$tmp" | sedi "s#{{hash_db_port}}#${hash_db_port}#g")

  echo "$tmp"
}
