#!/bin/bash

# Aplicar el configmap.yaml
kubectl apply -f k8s/configmap.yaml

# Aplicar los archivos de deployment y service para cada microservicio

# Configserver
kubectl apply -f k8s/configserver/deployment.yaml
kubectl apply -f k8s/configserver/service.yaml

# Eurekaserver
kubectl apply -f k8s/eurekaserver/deployment.yaml
kubectl apply -f k8s/eurekaserver/service.yaml

# Gatewayserver
kubectl apply -f k8s/gatewayserver/deployment.yaml
kubectl apply -f k8s/gatewayserver/service.yaml

# Accounts
kubectl apply -f k8s/accounts/deployment.yaml
kubectl apply -f k8s/accounts/service.yaml

# Loans
kubectl apply -f k8s/loans/deployment.yaml
kubectl apply -f k8s/loans/service.yaml

# Cards
kubectl apply -f k8s/cards/deployment.yaml
kubectl apply -f k8s/cards/service.yaml
