#!/bin/sh


newaccount() {
  cast wallet new -j --unsafe-password password .
}

newaccount_mnemonic() {
  cast wallet new-mnemonic
}

checkbalance() {
  cast balance "$1" -r "$ETH_RPC_URL"
}





