#!/bin/bash
# Iterate over each generated PDB and delete it
for ns in "$(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}')"; do
  # Extract the namespace and PDB name
  kubectl config set-context --current --namespace=$ns
  NAMESPACE=$(kubectl get pdb -l generated=true -ojson | jq -r '.items[] | "\(.metadata.namespace)"')
  PDB=$(kubectl get pdb -l generated=fisclouds -ojson | jq -r '.items[] | "\(.metadata.name)"')

  kubectl delete pdb -n $NAMESPACE $PDB
  echo "PodDisruptionBudget $PDB deleted in namespace $NAMESPACE"
done
