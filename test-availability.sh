#!/bin/bash

# Step 1: Get the NodePort for the frontend-service
FRONTEND_NODE_PORT=$(kubectl get svc frontend-service -o jsonpath='{.spec.ports[0].nodePort}')

# Step 2: Get the External IP of any node in the cluster
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}')

# If External IP is not available, try Internal IP (usually for local clusters like Minikube)
if [ -z "$NODE_IP" ]; then
  NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
fi

# Step 3: Form the URL and perform a simple curl check
URL="http://$NODE_IP:$FRONTEND_NODE_PORT"
response=$(curl --write-out "%{http_code}" --silent --output /dev/null "$URL")

# Step 4: Validate the response
if [ "$response" -eq 200 ]; then
  echo "Application is reachable at $URL and responded with status code 200."
  exit 0
else
  echo "Failed to reach the application at $URL. Status code: $response"
  exit 1
fi