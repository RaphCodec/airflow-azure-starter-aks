kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-airflow-logs
  labels:
    type: local
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain # If set as "Delete" container would be removed after pvc deletion
  storageClassName: azureblob-fuse-premium
  mountOptions:
    - -o allow_other
    - --file-cache-timeout-in-seconds=120
  csi:
    driver: blob.csi.azure.com
    readOnly: false
    volumeHandle: airflow-logs-1
    volumeAttributes:
      resourceGroup: ${MY_RESOURCE_GROUP_NAME}
      storageAccount: ${AKS_AIRFLOW_LOGS_STORAGE_ACCOUNT_NAME}
      containerName: ${AKS_AIRFLOW_LOGS_STORAGE_CONTAINER_NAME}
    nodeStageSecretRef:
      name: ${AKS_AIRFLOW_LOGS_STORAGE_SECRET_NAME}
      namespace: ${AKS_AIRFLOW_NAMESPACE}
EOF