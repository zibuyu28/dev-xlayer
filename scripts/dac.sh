#!/bin/sh


dac_config='
PrivateKey = {Path = "/pk/test-member.keystore", Password = ""}
PermitApiAddress = "{{dac_permit_api_address}}"

[L1]
WsURL = "{{l1_ws_url}}"
RpcURL = "{{l1_rpc_url}}"
PolygonValidiumAddress = "{{l1_validium_address}}"
DataCommitteeAddress = "{{data_committee_address}}"
Timeout = "3m"
RetryPeriod = "5s"

[Log]
Environment = "development" # "production" or "development"
Level = "info"
Outputs = ["stderr"]

[DB]
User = "{{dac_db_user}}"
Password = "{{dac_db_password}}"
Name = "{{dac_db_name}}"
Host = "{{dac_db_host}}"
Port = "{{dac_db_port}}"
EnableLog = false
MaxConns = 200

[RPC]
Host = "0.0.0.0"
Port = 8444
ReadTimeout = "60s"
WriteTimeout = "60s"
MaxRequestsPerIPAndSecond = 500
SequencerNodeURI = ""
EnableL2SuggestedGasPricePolling = false
[RPC.WebSockets]
Enabled = false'


sedi () {
    case $(uname -s) in
        *[Dd]arwin* | *BSD* ) sed "$@";;
        *) sed "$@";;
    esac
}

generate_dac() {
  tmp=$(echo "$dac_config" | sedi "s#{{dac_permit_api_address}}#${dac_permit_api_address}#g")
  tmp=$(echo "$tmp" | sedi "s#{{l1_ws_url}}#${l1_ws_url}#g")
  tmp=$(echo "$tmp" | sedi "s#{{l1_rpc_url}}#${l1_rpc_url}#g")
  tmp=$(echo "$tmp" | sedi "s#{{l1_validium_address}}#${l1_validium_address}#g")
  tmp=$(echo "$tmp" | sedi "s#{{data_committee_address}}#${data_committee_address}#g")
  tmp=$(echo "$tmp" | sedi "s#{{dac_db_user}}#${dac_db_user}#g")
  tmp=$(echo "$tmp" | sedi "s#{{dac_db_password}}#${dac_db_password}#g")
  tmp=$(echo "$tmp" | sedi "s#{{dac_db_name}}#${dac_db_name}#g")
  tmp=$(echo "$tmp" | sedi "s#{{dac_db_host}}#${dac_db_host}#g")
  tmp=$(echo "$tmp" | sedi "s#{{dac_db_port}}#${dac_db_port}#g")
  echo "$tmp"
}
