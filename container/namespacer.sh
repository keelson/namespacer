#!/usr/bin/env bash
set -e  -x
source /shell_lib.sh

function __config__() {
  cat <<EOF
    configVersion: v1
    kubernetes:
    - name: OnCreateDeleteNamespace
      apiVersion: v1
      kind: Namespace
      executeHookOnEvent:
      - Added
EOF
}



function __main__() {
  namespace=$(jq -r .[0].object.metadata.name ${BINDING_CONTEXT_PATH})
  echo "HUUUURZ namespace ${namespace} added"
  #kubectl label ns ${namespace} ivebeenwatchingyou=alalalalong
}

hook::run "$@"

