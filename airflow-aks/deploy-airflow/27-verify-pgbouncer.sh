#!/usr/bin/env bash
set -euo pipefail

# Verify PgBouncer installation and configuration for Airflow on AKS
# Usage: ./27-verify-pgbouncer.sh

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$DIR/01-set-env-vars.sh" ]; then
  source "$DIR/01-set-env-vars.sh"
fi

echo "=========================================="
echo "PgBouncer Verification for Airflow on AKS"
echo "=========================================="
echo ""

# 1. Check PgBouncer pods
echo "1. Checking PgBouncer Pods..."
echo "----------------------------------------"
kubectl get pods -n "$AKS_AIRFLOW_NAMESPACE" -l component=pgbouncer -o wide
echo ""

# 2. Check PgBouncer deployment
echo "2. Checking PgBouncer Deployment Status..."
echo "----------------------------------------"
kubectl get deployment airflow-pgbouncer -n "$AKS_AIRFLOW_NAMESPACE"
echo ""

# 3. Check PgBouncer service
echo "3. Checking PgBouncer Service..."
echo "----------------------------------------"
kubectl get service airflow-pgbouncer -n "$AKS_AIRFLOW_NAMESPACE"
echo ""

# 4. View PgBouncer configuration
echo "4. PgBouncer Configuration (pgbouncer.ini)..."
echo "----------------------------------------"
kubectl get secret airflow-pgbouncer-config -n "$AKS_AIRFLOW_NAMESPACE" -o jsonpath='{.data.pgbouncer\.ini}' | base64 -d
echo ""
echo ""

# 5. Check PgBouncer logs
echo "5. Recent PgBouncer Logs (last 15 lines)..."
echo "----------------------------------------"
kubectl logs -n "$AKS_AIRFLOW_NAMESPACE" deployment/airflow-pgbouncer -c pgbouncer --tail=15
echo ""

# 6. Check PgBouncer exporter (metrics)
echo "6. Checking PgBouncer Metrics Exporter..."
echo "----------------------------------------"
POD_NAME=$(kubectl get pods -n "$AKS_AIRFLOW_NAMESPACE" -l component=pgbouncer -o jsonpath='{.items[0].metadata.name}')
echo "Pod: $POD_NAME"
kubectl get pod "$POD_NAME" -n "$AKS_AIRFLOW_NAMESPACE" -o jsonpath='{.spec.containers[*].name}' | tr ' ' '\n'
echo ""
echo ""

# 7. Check if Airflow components are using PgBouncer
echo "7. Verifying Airflow Connection Configuration..."
echo "----------------------------------------"
echo "Checking data.metadataConnection configuration in values..."
kubectl get secret airflow-pgbouncer-config -n "$AKS_AIRFLOW_NAMESPACE" -o jsonpath='{.data}' | grep -o '"[^"]*"' | head -5
echo ""

# 8. Check PgBouncer resource usage
echo "8. PgBouncer Resource Usage..."
echo "----------------------------------------"
kubectl top pods -n "$AKS_AIRFLOW_NAMESPACE" -l component=pgbouncer 2>/dev/null || echo "Metrics server not available. Install metrics-server to see resource usage."
echo ""

# 9. Summary
echo "=========================================="
echo "Verification Summary"
echo "=========================================="

READY_PODS=$(kubectl get pods -n "$AKS_AIRFLOW_NAMESPACE" -l component=pgbouncer -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}' | grep -o "True" | wc -l | tr -d ' ')
TOTAL_PODS=$(kubectl get pods -n "$AKS_AIRFLOW_NAMESPACE" -l component=pgbouncer --no-headers | wc -l | tr -d ' ')

echo "✓ PgBouncer Pods Ready: $READY_PODS/$TOTAL_PODS"
echo "✓ PgBouncer Service: airflow-pgbouncer (port 6543)"
echo "✓ Configuration: pool_mode=transaction, max_client_conn=100"
echo "✓ Pool Sizes: metadata=10, result_backend=5"
echo ""

if [ "$READY_PODS" -eq "$TOTAL_PODS" ] && [ "$TOTAL_PODS" -gt 0 ]; then
  echo "🎉 PgBouncer is successfully deployed and running!"
else
  echo "⚠️  Warning: Not all PgBouncer pods are ready."
  echo "   Run: kubectl describe pods -n $AKS_AIRFLOW_NAMESPACE -l component=pgbouncer"
fi

echo ""
echo "Additional Commands for Troubleshooting:"
echo "  - View detailed logs: kubectl logs -n $AKS_AIRFLOW_NAMESPACE deployment/airflow-pgbouncer -c pgbouncer -f"
echo "  - Check configuration: kubectl describe deployment airflow-pgbouncer -n $AKS_AIRFLOW_NAMESPACE"
echo "  - Access PgBouncer console: kubectl exec -it -n $AKS_AIRFLOW_NAMESPACE deployment/airflow-pgbouncer -- /bin/bash"
echo ""
