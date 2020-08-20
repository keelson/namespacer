#!/usr/bin/env bash
set -e
source ./functions.sh

ARRAY_COUNT=$(jq -r '. | length-1' ${BINDING_CONTEXT_PATH})

if [[ $1 == "--config" ]] ; then
  cat <<EOF
configVersion: v1
kubernetes:
- name: createnamespace
  apiVersion: v1
  kind: Namespace
  executeHookOnEvent:
  - Added
EOF
else
  # ignore Synchronization for simplicity
  type=$(jq -r '.[0].type' ${BINDING_CONTEXT_PATH})
  if [[ "${type}" == "Synchronization" ]] ; then
    echo Got Synchronization event
    exit 0
  fi

  for IND in $(seq 0 ${ARRAY_COUNT})
  do
    # extract namespace from binding context
    current_namespace=$(jq -r ".[${IND}].object.metadata.name" ${BINDING_CONTEXT_PATH})
    echo "namespace ${current_namespace} has been created"
    namespace_handler ${current_namespace}
  done
fi
