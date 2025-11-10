#!/bin/bash

# Source environment variables
source airflow-helm/.env

# Set image name and tag
IMAGE_NAME="airflow-custom"
IMAGE_TAG=$(date +%Y.%m.%d)-3.1.2 # Set tag with date and Airflow version
FULL_IMAGE_NAME="${ACR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"

echo "Building Docker image: ${FULL_IMAGE_NAME}"

# Build the Docker image
docker build -t ${FULL_IMAGE_NAME} .

if [ $? -eq 0 ]; then
    echo "✅ Docker build successful"
    
    # Login to ACR
    echo "Logging into ACR: ${ACR_REGISTRY}"
    az acr login --name ${ACR_REGISTRY%%.azurecr.io}
    
    if [ $? -eq 0 ]; then
        echo "✅ ACR login successful"
        
        # Push the image
        echo "Pushing image to ACR: ${FULL_IMAGE_NAME}"
        docker push ${FULL_IMAGE_NAME}
        
        if [ $? -eq 0 ]; then
            echo "✅ Image pushed successfully to ACR"
            echo "Image available at: ${FULL_IMAGE_NAME}"
        else
            echo "❌ Failed to push image to ACR"
            exit 1
        fi
    else
        echo "❌ Failed to login to ACR"
        exit 1
    fi
else
    echo "❌ Docker build failed"
    exit 1
fi