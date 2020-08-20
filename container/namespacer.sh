#!/usr/bin/env bash
set -x 

CONFIG_FILE="/etc/config/settings.json"
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
    resourceName=$(jq -r ".[${IND}].object.metadata.name" ${BINDING_CONTEXT_PATH})

    # extract values from config
    for label in $(cat ${CONFIG_FILE} | jq -r  '.labels| join(" ")')
      do labels+=($label)
    done
    for annotation in $(cat ${CONFIG_FILE} | jq -r  '.annotations| join(" ")')
      do annotations+=($annotation)
    done
    for namespace in $(cat ${CONFIG_FILE} | jq -r  '.ignore_namespaces| join(" ")')
      do ignore_namespaces+=($namespace)
    done
    echo "Namespace ${resourceName} was created"
    # check if namespace should be ignored
    listed=0
    for element in "${ignore_namespaces[@]}"
      do
      echo "comparing $element: $resourceName"
      if [[ ${element} =~ ^${resourceName}$ ]] ; then
        listed=1
      fi
    done
    if [[ ${listed} -ne 0 ]]; then 
      echo "Namespace ${resourceName} is on the ignore list, skipping"
    else 
      for label in ${labels[@]}
        do 
          kubectl label namespace --overwrite=true  ${resourceName} ${label} 
      done   
      for annotation in ${annotations[@]}
        do 
          kubectl annotate namespace --overwrite=true ${resourceName} ${annotation} 
      done   
    fi
  done
fi
