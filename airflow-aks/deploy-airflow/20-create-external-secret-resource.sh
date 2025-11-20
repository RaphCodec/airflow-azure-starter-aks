kubectl apply -f - <<EOF
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: airflow-aks-azure-logs-secrets
  namespace: ${AKS_AIRFLOW_NAMESPACE}
spec:
  refreshInterval: 1h
  secretStoreRef:
    kind: SecretStore
    name: azure-store

  target:
    name: ${AKS_AIRFLOW_LOGS_STORAGE_SECRET_NAME}
    creationPolicy: Owner

  data:
    # name of the SECRET in the Azure KV (no prefix is by default a SECRET)
    - secretKey: azurestorageaccountname
      remoteRef:
        key: AKS-AIRFLOW-LOGS-STORAGE-ACCOUNT-NAME
    - secretKey: azurestorageaccountkey
      remoteRef:
        key: AKS-AIRFLOW-LOGS-STORAGE-ACCOUNT-KEY
---
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: airflow-redis-secrets
  namespace: ${AKS_AIRFLOW_NAMESPACE}
spec:
  refreshInterval: 1h
  secretStoreRef:
    kind: SecretStore
    name: azure-store

  target:
    name: airflow-redis-connection
    creationPolicy: Owner
    template:
      engineVersion: v2
      data:
        # Create connection string from individual secrets
        # Note: rediss:// (with double 's') for SSL connections
        connection: 'rediss://:{{ .rediskey }}@{{ .redishost }}:6380/0?ssl_cert_reqs=required'

  data:
    - secretKey: redishost
      remoteRef:
        key: REDIS-HOST
    - secretKey: rediskey
      remoteRef:
        key: REDIS-PRIMARY-KEY
---
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: airflow-postgres-secrets
  namespace: ${AKS_AIRFLOW_NAMESPACE}
spec:
  refreshInterval: 1h
  secretStoreRef:
    kind: SecretStore
    name: azure-store

  target:
    name: airflow-postgres-connection
    creationPolicy: Owner
    template:
      engineVersion: v2
      data:
        # Create PostgreSQL connection string from individual secrets
        # Format: postgresql://user:password@host:5432/database?sslmode=require
        # URL-encode password to handle special characters like @ ! $ etc.
        connection: 'postgresql://{{ .pguser }}:{{ .pgpassword | urlquery }}@{{ .pghost }}:5432/{{ .pgdatabase }}?sslmode=require'

  data:
    - secretKey: pghost
      remoteRef:
        key: POSTGRES-HOST
    - secretKey: pguser
      remoteRef:
        key: POSTGRES-USER
    - secretKey: pgpassword
      remoteRef:
        key: POSTGRES-PASSWORD
    - secretKey: pgdatabase
      remoteRef:
        key: POSTGRES-DATABASE
---
# ExternalSecret for Airflow webserver SECRET_KEY
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: airflow-webserver-secret
  namespace: ${AKS_AIRFLOW_NAMESPACE}
spec:
  refreshInterval: 1h
  secretStoreRef:
    kind: SecretStore
    name: azure-store

  target:
    name: airflow-webserver-secret
    creationPolicy: Owner

  data:
    # maps the Key Vault secret named 'airflow-webserver-secret-key' into the
    # Kubernetes secret key 'webserver-secret-key'
    - secretKey: webserver-secret-key
      remoteRef:
        key: airflow-webserver-secret-key
EOF