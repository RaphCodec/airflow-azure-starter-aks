#!/usr/bin/env bash
set -euo pipefail

# Uninstall Airflow from AKS namespace
# Usage: source ./01-set-env-vars.sh then run this script

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# source envs if available
if [ -f "$DIR/01-set-env-vars.sh" ]; then
  # shellcheck disable=SC1090
  source "$DIR/01-set-env-vars.sh"
fi

NAMESPACE="${AKS_AIRFLOW_NAMESPACE:-airflow}"
RELEASE_NAME="airflow"

echo "Uninstalling Airflow from namespace: $NAMESPACE"
echo "Release name: $RELEASE_NAME"
echo ""
read -p "Are you sure you want to uninstall Airflow? (yes/no): " -r
echo

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
  echo "Uninstall cancelled."
  exit 0
fi

# Check if Helm release exists
if helm list -n "$NAMESPACE" | grep -q "$RELEASE_NAME"; then
  echo "Uninstalling Helm release '$RELEASE_NAME' from namespace '$NAMESPACE'..."
  helm uninstall "$RELEASE_NAME" -n "$NAMESPACE"
  echo "✓ Helm release uninstalled"
else
  echo "⚠ Helm release '$RELEASE_NAME' not found in namespace '$NAMESPACE'"
fi

# Optional: Clean up persistent volume claims (commented out by default)
# Uncomment if you want to delete PVCs as well
echo ""
echo "Checking for Persistent Volume Claims..."
PVCS=$(kubectl get pvc -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l)
if [ "$PVCS" -gt 0 ]; then
  echo "Found $PVCS PVC(s) in namespace '$NAMESPACE'"
  echo "To keep logs and data, PVCs are NOT deleted by default."
  echo ""
  read -p "Do you want to delete PVCs as well? (yes/no): " -r
  echo
  if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Deleting PVCs..."
    kubectl delete pvc --all -n "$NAMESPACE"
    echo "✓ PVCs deleted"
  else
    echo "PVCs preserved. List with: kubectl get pvc -n $NAMESPACE"
  fi
else
  echo "No PVCs found in namespace '$NAMESPACE'"
fi

# Optional: Delete namespace (commented out by default)
# Uncomment if you want to delete the entire namespace
echo ""
read -p "Do you want to delete the entire namespace '$NAMESPACE'? (yes/no): " -r
echo
if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
  echo "Deleting namespace '$NAMESPACE'..."
  kubectl delete namespace "$NAMESPACE" --wait=true
  echo "✓ Namespace deleted"
else
  echo "Namespace preserved."
fi

echo ""
echo "✓ Airflow uninstall complete."
echo ""
echo "To reinstall Airflow, run:"
echo "  ./25-install-airflow.sh"
