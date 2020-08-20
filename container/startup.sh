#!/usr/bin/env bash
set -e
source ./functions.sh

if [[ $1 == "--config" ]] ; then
  cat <<EOF
configVersion: v1
onStartup: 10
EOF
else
  echo "STARTING UP"
  for namespace in $(kubectl get namespaces --output=jsonpath={.items..metadata.name})
    do
    echo "discovered namespace: ${namespace}"
    namespace_handler ${namespace}
  done
fi


