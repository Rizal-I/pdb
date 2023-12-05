namespaces=$(kubectl get namespaces -o=json | jq -r '.items[].metadata.name')
for namespace in $namespaces; do
    pdb_info=$(kubectl get poddisruptionbudget -n "$namespace" -o=json | jq -r '.items[0] | select(.status.currentHealthy > 5) | {name: .metadata.name, namespace: .metadata.namespace}')
    if [ -n "$pdb_info" ]; then
        pdb_name=$(echo "$pdb_info" | jq -r '.name')
        pdb_namespace=$(echo "$pdb_info" | jq -r '.namespace')
        kubectl get pdb $pdb_name -n $pdb_namespace -oyaml >> $pdb_name-$pdb_namespace.yaml
        echo "pdb $pdb_name in namespace $pdb_namespace"
        # remove anotation
        #kubectl patch poddisruptionbudget $pdb_name -n $pdb_namespace --type merge -p '{"metadata":{"annotations":{"kubectl.kubernetes.io/last-applied-configuration":null}}}'

        # convert to maxUnavailable
        #kubectl patch poddisruptionbudget $pdb_name -n $pdb_namespace --type='json' -p='[{"op": "remove", "path": "/spec/minAvailable"}, {"op": "replace", "path": "/spec/maxUnavailable", "value": 1}]'
        kubectl patch poddisruptionbudget $pdb_name -n $pdb_namespace --type='merge' -p '{"spec": {"maxUnavailable": 1, "minAvailable": null}}'

        # convert to minAvailabe
        #kubectl patch poddisruptionbudget $pdb_name -n $pdb_namespace --type='json' -p='[{"op": "remove", "path": "/spec/maxUnavailable"}, {"op": "replace", "path": "/spec/minAvailable", "value": 2}]'
        #kubectl patch poddisruptionbudget $pdb_name -n $pdb_namespace --type='merge' -p '{"spec": {"minAvailable": 2, "maxUnavailable": null}}'

    fi
done

