#!/bin/bash

# Array to store PDB names
PDB_NAMES=()

# Get a list of all namespaces
NAMESPACE_LIST=$(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}')

# Iterate over each namespace
for NAMESPACE in $NAMESPACE_LIST; do
  # Get a list of deployments in the current namespace
  DEPLOYMENT_LIST=$(kubectl get deployments -n $NAMESPACE -o jsonpath='{.items[*].metadata.name}')

  # Iterate over each deployment in the current namespace
  for DEPLOYMENT_NAME in $DEPLOYMENT_LIST; do
    # Get the number of replicas for the current deployment
    REPLICAS=$(kubectl get deployment -n $NAMESPACE $DEPLOYMENT_NAME -o=jsonpath='{.spec.replicas}')

    # Check if the number of replicas is greater than 1
    if [[ $REPLICAS -gt 2 ]]; then
      echo "Namespace: $NAMESPACE, Deployment: $DEPLOYMENT_NAME has more than 2 replica"

      # Check if a PDB already exists for the deployment
      PDB_NAME="${DEPLOYMENT_NAME}-pdb"
      if ! kubectl get pdb -n $NAMESPACE $PDB_NAME &> /dev/null; then
        # Get labels for the deployment
        LABELS=$(kubectl get deployment -n $NAMESPACE $DEPLOYMENT_NAME -o jsonpath='{.spec.template.metadata.labels}')

        # Create a PDB for the deployment with a custom label selector
        cat <<EOF | kubectl apply -n $NAMESPACE -f -
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: $PDB_NAME
  namespace: $NAMESPACE
spec:
  selector:
    matchLabels: $LABELS
  maxUnavailable: 1
EOF
        echo "$NAMESPACE/$PDB_NAME" >> pdb_names.txt
        echo "PodDisruptionBudget $PDB_NAME created"
      else
        echo "PodDisruptionBudget $PDB_NAME already exists"
      fi
    fi
  done
done
