#!/bin/bash

## CONFIG LOCAL ENV
echo "[*] Config local environment..."
alias vault='docker-compose exec vault vault "$@"'
export VAULT_ADDR=http://127.0.0.1:8200

## INIT VAULT
echo "[*] Init vault..."
vault operator init -address=${VAULT_ADDR} 2>&1 >| _data/keys.txt
export VAULT_TOKEN=$(grep 'Initial Root Token:'    _data/keys.txt |awk '{print $NF}')

## UNSEAL VAULT
echo "[*] Unseal vault..."
vault operator unseal -address=${VAULT_ADDR} $(grep 'Key 1:' _data/keys.txt |awk '{print $NF}')
vault operator unseal -address=${VAULT_ADDR} $(grep 'Key 2:' _data/keys.txt |awk '{print $NF}')
vault operator unseal -address=${VAULT_ADDR} $(grep 'Key 3:' _data/keys.txt |awk '{print $NF}')

## AUTH
echo "[*] Auth..."
vault login -address=${VAULT_ADDR} ${VAULT_TOKEN}

## CREATE USER
echo "[*] Create user... Remember to change the defaults!!"
vault auth enable  -address=${VAULT_ADDR} userpass
vault policy write -address=${VAULT_ADDR} admin config/admin.hcl
vault write        -address=${VAULT_ADDR} auth/userpass/users/webui password=webui policies=admin

## CREATE BACKUP TOKEN
echo "[*] Create backup token..."
vault token create -address=${VAULT_ADDR} -display-name="backup_token" |awk '/token/{i++}i==2' |awk '{print "backup_token: " $2}' 2>&1 >> _data/keys.txt

## NEEDS TO BE FIXED, MOUNTS NO LONGER WORKS

## MOUNTS
echo "[*] Creating new mount point..."
vault secrets list    -address=${VAULT_ADDR}
vault secrets enable  -address=${VAULT_ADDR} -path=assessment -description="Secrets used in the assessment" generic
vault write           -address=${VAULT_ADDR} assessment/server1_ad value1=name value2=pwd
