#!/bin/bash

# Read PDB names from the file
PDB_NAMES_FILE="pdb_names.txt"
PDB_NAMES=($(cat $PDB_NAMES_FILE))

# Iterate over each PDB and delete it
for PDB_NAME in "${PDB_NAMES[@]}"; do
  # Extract the namespace and PDB name
  NAMESPACE=$(echo "$PDB_NAME" | cut -d'/' -f1)
  PDB=$(echo "$PDB_NAME" | cut -d'/' -f2)

  kubectl delete pdb -n $NAMESPACE $PDB
  echo "PodDisruptionBudget $PDB deleted in namespace $NAMESPACE"
done
rm pdb_names.txt
echo "pdb_names.txt" deleted.
