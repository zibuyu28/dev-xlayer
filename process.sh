#!/bin/sh

set -e

debug=${DEBUG:-0}
if [ "$debug" -eq 1 ]; then
  set -v
fi

. scripts/require.sh
. scripts/account.sh
. scripts/genesis.sh
. scripts/node.sh
. scripts/executor.sh
. scripts/dac.sh


OUTPUT_DIR="output"
mkdir -p "$OUTPUT_DIR"

process=1
if [ -f "$OUTPUT_DIR"/process ]; then
  process=$(cat "$OUTPUT_DIR"/process)
else
  echo 1 > "$OUTPUT_DIR"/process
fi

force_renew=${FORCE_RENEW:-0}
if [ "$force_renew" -gt 0 ]; then
  echo "$force_renew" > "$OUTPUT_DIR"/process
  process=$(cat "$OUTPUT_DIR"/process)
fi

echo "$process" > "$OUTPUT_DIR"/process



handle_account() {
  acc_address=""
  if [ "$process" -le 1 ]; then
    acc=$(newaccount)
    acc_address=$(echo "$acc" | jq -r '.[0].address')
    acc_path=$(echo "$acc" | jq -r '.[0].path')
    mv "$acc_path" "$OUTPUT_DIR"/"$1".keystore
    echo "{\"address\": \"$acc_address\"}" > "$OUTPUT_DIR"/"$1".json
    echo 2 > "$OUTPUT_DIR"/process
  else
    if [ -f "$OUTPUT_DIR"/"$1".json ]; then
      acc_address=$(jq -r '.address' "$OUTPUT_DIR"/"$1".json)
    else
      echo "Please provide $OUTPUT_DIR/$1.json" >&2
      exit 1
    fi
  fi
  printf %s "$acc_address"
}

sequencer_address=$(handle_account "sequencer")

aggregator_address=$(handle_account "aggregator")

dac_signer_address=$(handle_account "dac_signer")

dac1_address=$(handle_account "dac1")

dac2_address=$(handle_account "dac2")


admin_address=""
admin_mnemonic=""
admin_private_key=""
if [ "$process" -le 2 ]; then
  admin_info=$(newaccount_mnemonic)
  admin_mnemonic=$(echo "$admin_info" | grep -A 1 "Phrase:" | tail -n 1)
  admin_address=$(echo "$admin_info" | grep "Address:" | awk '{print $2}')
  admin_private_key=$(echo "$admin_info" | grep "Private key:" | awk '{print $3}')
  admin="{
  \"address\": \"$admin_address\",
  \"mnemonic\": \"$admin_mnemonic\",
  \"private_key\": \"$admin_private_key\"
}"
  echo "$admin" > "$OUTPUT_DIR"/admin.json
  echo 3 > "$OUTPUT_DIR"/process
else
  if [ -f "$OUTPUT_DIR"/admin.json ]; then
    admin_address=$(jq -r '.address' "$OUTPUT_DIR"/admin.json)
    admin_mnemonic=$(jq -r '.mnemonic' "$OUTPUT_DIR"/admin.json)
    admin_private_key=$(jq -r '.private_key' "$OUTPUT_DIR"/admin.json)
  else
    echo "Please provide $OUTPUT_DIR/admin.json"
    exit 1
  fi
fi

echo "Admin address: $admin_address"
echo "Sequencer address: $sequencer_address"
echo "Aggregator address: $aggregator_address"
echo "DAC Signer address: $dac_signer_address"
echo "DAC1 address: $dac1_address"
echo "DAC2 address: $dac2_address"


if [ "$process" -le 3 ]; then
  rm -rf "$OUTPUT_DIR"/xlayer-contracts
  cd "$OUTPUT_DIR"/ || exit 1
  git clone -b release/v0.3.1 https://github.com/okx/xlayer-contracts.git
  cd xlayer-contracts || exit 1
  npm install
  echo 4 > ../process
else
  if [ ! -d "$OUTPUT_DIR"/xlayer-contracts ]; then
    echo "Please provide $OUTPUT_DIR/xlayer-contracts directory" >&2
    exit 1
  fi
  cd "$OUTPUT_DIR"/xlayer-contracts || exit 1
  git checkout release/v0.3.1
  git pull origin release/v0.3.1
fi


cp deployment/v2/deploy_parameters.json.example deployment/v2/deploy_parameters.json
deploy_parameters_tmp=$(jq --arg admin_address "$admin_address" '.timelockAdminAddress = $admin_address' deployment/v2/deploy_parameters.json)
deploy_parameters_tmp=$(echo "$deploy_parameters_tmp" | jq --arg admin_address "$admin_address" '.admin = $admin_address' )
deploy_parameters_tmp=$(echo "$deploy_parameters_tmp" | jq --arg admin_address "$admin_address" '.initialZkEVMDeployerOwner = $admin_address' )
deploy_parameters_tmp=$(echo "$deploy_parameters_tmp" | jq --arg admin_address "$admin_address" '.emergencyCouncilAddress = $admin_address')
deploy_parameters_tmp=$(echo "$deploy_parameters_tmp" | jq --arg aggregator "$aggregator_address" '.trustedAggregator = $aggregator')
deploy_parameters_tmp=$(echo "$deploy_parameters_tmp" | jq --arg pol_token "$POL_TOKEN_ADDRESS" '.polTokenAddress = $pol_token')
echo "$deploy_parameters_tmp" > deployment/v2/deploy_parameters.json


cp deployment/v2/create_rollup_parameters.json.example deployment/v2/create_rollup_parameters.json
create_rollup_parameters_tmp=$(jq '.networkName = "xlayer"' deployment/v2/create_rollup_parameters.json)
create_rollup_parameters_tmp=$(echo "$create_rollup_parameters_tmp" | jq '.forkID = 9')
create_rollup_parameters_tmp=$(echo "$create_rollup_parameters_tmp" | jq '.consensusContract = "PolygonValidiumEtrog"')
create_rollup_parameters_tmp=$(echo "$create_rollup_parameters_tmp" | jq --arg trust_sequencer "$sequencer_address" '.trustedSequencer = $trust_sequencer')
create_rollup_parameters_tmp=$(echo "$create_rollup_parameters_tmp" | jq --arg admin "$admin_address" '.adminZkEVM = $admin')
create_rollup_parameters_tmp=$(echo "$create_rollup_parameters_tmp" | jq --arg gas_token "$POL_TOKEN_ADDRESS" '.gasTokenAddress = $gas_token')
echo "$create_rollup_parameters_tmp" > deployment/v2/create_rollup_parameters.json

cp .env.example .env
echo "MNEMONIC=\"$admin_mnemonic\"" > .env
echo "INFURA_PROJECT_ID=\"$INFURA_PROJECT_ID\"" >> .env
echo "ETHERSCAN_API_KEY=\"$ETHERSCAN_API_KEY\"" >> .env

echo "check balance"

while true; do
  balance=$(checkbalance "$admin_address" "$ETH_RPC_URL")
  if [ "$balance" -eq 0 ]; then
    sleep 1
    echo "[$(date)] Waiting for balance address [$admin_address], private [$admin_private_key], Current balance: $balance"
    continue
  fi
  break
done

if [ "$process" -le 4 ]; then
  npm run deploy:v2:sepolia
  npm run verify:v2:sepolia
  echo 5 > ../process
fi




dir=$(ls -d deployments/sepolia_*/ 2>/dev/null | head -n 1)

genesis=$(cat "$dir/genesis.json")
deploy_output=$(cat "$dir/deploy_output.json")
create_rollup_output=$(cat "$dir/create_rollup_output.json")

cd ../../ || exit 1

generate_genesis "$L1_CHAIN_ID" \
  "$(echo "$create_rollup_output" | jq -r '.rollupAddress' )" \
  "$(echo "$deploy_output" | jq -r '.polygonZkEVMGlobalExitRootAddress')" \
  "$(echo "$deploy_output" | jq -r '.polygonRollupManagerAddress')" \
  "$POL_TOKEN_ADDRESS" \
  "$(echo "$create_rollup_output" | jq -r '.createRollupBlockNumber')" \
  "$(echo "$deploy_output" | jq -r '.deploymentRollupManagerBlockNumber')" \
  "$(echo "$genesis" | jq -r '.root')" \
  "$(echo "$genesis" | jq '.genesis')" > "$OUTPUT_DIR"/genesis.json


state_db_user="admin"
state_db_password="test123"
state_db_name="xlayer_state_db"
state_db_host="postgres-xlayer-okx"
state_db_port="5432"

free_gas_address="\"$sequencer_address\""

pool_db_user="admin"
pool_db_password="test123"
pool_db_name="xlayer_pool_db"
pool_db_host="postgres-xlayer-okx"
pool_db_port="5432"

etherman_url="$ETH_RPC_URL"
pack_batch_spacial_list="\"$sequencer_address\""
l2_chain_id="1001"
sequencer_address="$sequencer_address"
aggregator_address="$aggregator_address"

event_db_user="admin"
event_db_password="test123"
event_db_name="xlayer_event_db"
event_db_host="postgres-xlayer-okx"
event_db_port="5432"

hash_db_user="admin"
hash_db_password="test123"
hash_db_name="xlayer_hash_db"
hash_db_host="postgres-xlayer-okx"
hash_db_port="5432"

generate_node > "$OUTPUT_DIR"/node.toml

generate_executor "executor" > "$OUTPUT_DIR"/executor.json

generate_executor "prover" > "$OUTPUT_DIR"/prover.json


dac_permit_api_address="$dac_signer_address"
l1_ws_url="$ETH_WS_URL"
l1_rpc_url="$ETH_RPC_URL"
l1_validium_address="$(echo "$create_rollup_output" | jq -r '.rollupAddress' )"
data_committee_address="$(echo "$create_rollup_output" | jq -r '.polygonDataCommitteeAddress')"
dac_db_user="admin"
dac_db_password="test123"
dac_db_name="xlayer_dac1_db"
dac_db_host="postgres-xlayer-okx"
dac_db_port="5432"

generate_dac > "$OUTPUT_DIR"/dac1.toml

dac_db_name="xlayer_dac2_db"

generate_dac > "$OUTPUT_DIR"/dac2.toml







