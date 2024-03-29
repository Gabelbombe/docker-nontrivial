#!/bin/bash

## CONFIG LOCAL ENV
echo -e "[*] Config local environment..."
alias vault='docker-compose exec vault vault "$@"'
export VAULT_ADDR=http://127.0.0.1:8200

## UNSEAL VAULT
echo -e "[*] Unseal vault..."
vault operator unseal -address=${VAULT_ADDR} $(grep 'Key 1:' _data/keys.txt |awk '{print $NF}')
vault operator unseal -address=${VAULT_ADDR} $(grep 'Key 2:' _data/keys.txt |awk '{print $NF}')
vault operator unseal -address=${VAULT_ADDR} $(grep 'Key 3:' _data/keys.txt |awk '{print $NF}')
