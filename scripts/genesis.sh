#!/bin/sh

genesis='{
  "l1Config": {
    "chainId": 0,
    "polygonZkEVMAddress": "{{polygon_zkevm_address}}",
    "polygonZkEVMGlobalExitRootAddress": "{{polygon_zkevm_global_exit_root_address}}",
    "polygonRollupManagerAddress": "{{polygon_rollup_manger_address}}",
    "polTokenAddress": "{{matic_token_address}}"
  },
  "rollupCreationBlockNumber": 0,
  "rollupManagerCreationBlockNumber": 0,
  "root": "{{genesisroot}}"
}'

generate_genesis() {
  tmp=$(echo "$genesis" | jq --arg chain_id "$1" '.l1Config.chainId = $chain_id')
  tmp=$(echo "$tmp" | jq --arg polygon_zkevm_address "$2" '.l1Config.polygonZkEVMAddress = $polygon_zkevm_address')
  tmp=$(echo "$tmp" | jq --arg polygon_zkevm_global_exit_root_address "$3" '.l1Config.polygonZkEVMGlobalExitRootAddress = $polygon_zkevm_global_exit_root_address')
  tmp=$(echo "$tmp" | jq --arg polygon_rollup_manger_address "$4" '.l1Config.polygonRollupManagerAddress = $polygon_rollup_manger_address')
  tmp=$(echo "$tmp" | jq --arg matic_token_address "$5" '.l1Config.polTokenAddress = $matic_token_address')
  tmp=$(echo "$tmp" | jq --arg rollup_createion_block_number "$6" '.rollupCreationBlockNumber = $rollup_createion_block_number')
  tmp=$(echo "$tmp" | jq --arg rollup_manager_creation_block_number "$7" '.rollupManagerCreationBlockNumber = $rollup_manager_creation_block_number')
  tmp=$(echo "$tmp" | jq --arg root "$8" '.root = $root')
  tmp=$(echo "$tmp" | jq --argjson genesis "$9" '. + {"genesis": $genesis}')
  echo "$tmp" | jq .
}
