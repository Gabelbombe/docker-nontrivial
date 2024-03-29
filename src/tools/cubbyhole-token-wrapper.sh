#!/usr/bin/env bash -ue

if [ "$#" -ne 1 ] ; then
  echo "usage: ${0} [vault path]"
  return 1
fi

: ${VAULT_ADDR?"env variable VAULT_ADDR needs to be set"}
: ${VAULT_TOKEN?"env variable VAULT_TOKEN needs to be set"}

path=$1

echo $(curl --silent                            \
            -H "X-Vault-Token: ${VAULT_TOKEN}"  \
            -H "X-Vault-Wrap-TTL: 120s"         \
            -H "Content-Type: application/json" \
            -X GET                              \
            $VAULT_ADDR/v1$path                 \
            |jq -r .wrap_info.token)
