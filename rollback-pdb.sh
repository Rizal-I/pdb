namespaces=$(kubectl get namespaces -o=json | jq -r '.items[].metadata.name')
for namespace in $namespaces; do
    pdb_info=$(kubectl get poddisruptionbudget -n "$namespace" -o=json | jq -r '.items[0] | select(.status.currentHealthy > 5) | {name: .metadata.name, namespace: .metadata.namespace}')
    if [ -n "$pdb_info" ]; then
        pdb_name=$(echo "$pdb_info" | jq -r '.name')
        pdb_namespace=$(echo "$pdb_info" | jq -r '.namespace')
        # convert to minAvailable
        kubectl patch poddisruptionbudget $pdb_name -n $pdb_namespace --type='merge' -p '{"spec": {"minAvailable": 2, "maxUnavailable": null}}'
        echo "pdb $pdb_name in namespace $pdb_namespace rolled back" 
    fi
done
