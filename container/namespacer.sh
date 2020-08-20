#!/usr/bin/env bash
set -e 

if [[ $1 == "--config" ]] ; then
  cat <<EOF
configVersion: v1
kubernetes:
- apiVersion: v1
  kind: Namespace
  executeHookOnEvent: ["Added"]
EOF
else
  namespace=$(jq -r .[0].object.metadata.name $BINDING_CONTEXT_PATH)
  echo "namespace '${namespace}' added"
fi
