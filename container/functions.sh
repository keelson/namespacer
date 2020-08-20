CONFIG_FILE="/etc/config/settings.json"
function namespace_handler {
  namespace=${1}
  echo "processing namespace ${namespace}"
# extract values from config
  for label in $(cat ${CONFIG_FILE} | jq -r  '.labels| join(" ")')
    do labels+=($label)
  done
  for annotation in $(cat ${CONFIG_FILE} | jq -r  '.annotations| join(" ")')
    do annotations+=($annotation)
  done
  for namespace_from_ignorelist in $(cat ${CONFIG_FILE} | jq -r  '.ignore_namespaces| join(" ")')
    do ignore_namespaces+=($namespace_from_ignorelist)
  done
  # check if namespace should be ignored
  listed=0
  for element in "${ignore_namespaces[@]}"
    do
    if [[ ${element} =~ ^${namespace}$ ]] ; then
      listed=1
    fi
  done
  if [[ ${listed} -ne 0 ]]; then 
    echo "Namespace ${namespace} is on the ignore list, skipping"
  else 
    for label in ${labels[@]}
      do 
        kubectl label namespace --overwrite=true  ${namespace} ${label} 
    done   
    for annotation in ${annotations[@]}
      do 
        kubectl annotate namespace --overwrite=true ${namespace} ${annotation} 
    done   
  fi
}