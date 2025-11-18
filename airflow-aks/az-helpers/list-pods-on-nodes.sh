#!/bin/bash
# List pods and the nodes they are running on (all namespaces)
kubectl get pods -o wide --all-namespaces