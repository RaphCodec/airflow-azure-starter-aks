#!/bin/bash
# Get total pod count in all namespaces
kubectl get pods --all-namespaces --no-headers | wc -l