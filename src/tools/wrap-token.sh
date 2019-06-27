#!/usr/bin/env bash -ue

if [ "$#" -ne 1 ]; then
  echo "usage: $0 [path to file to wrap/secure]"
  return 1
fi

: ${VAULT_ADDR?"env variable VAULT_ADDR needs to be set"}
: ${VAULT_TOKEN?"env variable VAULT_TOKEN needs to be set"}

data=$1

echo $(curl --silent                            \
            -H "X-Vault-Token: ${VAULT_TOKEN}"  \
            -H "X-Vault-Wrap-TTL: 60"           \
            -H "Content-Type: application/json" \
            -X POST                             \
            --data @$data                       \
            $VAULT_ADDR/v1/sys/wrapping/wrap    \
            |jq -r .wrap_info.token)
