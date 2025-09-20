# devops-eks-pipeline

Infrastructure as Code setup with Terraform, Kubernetes manifests, and GitHub Actions workflows to provision AWS EKS and deploy a sample containerized application.

## Application Architecture

This deployment uses the official AWS retail-store-sample-app with:

- Pre-built container images from AWS ECR Public Gallery
- In-cluster databases (MySQL, PostgreSQL, DynamoDB Local, Redis, RabbitMQ)
- LoadBalancer exposure for the UI service

The approach demonstrates:

- Container orchestration skills
- Infrastructure as Code
- CI/CD pipeline automation
- Cost-optimized deployment strategies
