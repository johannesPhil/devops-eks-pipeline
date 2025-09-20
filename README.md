# Project Bedrock - EKS Infrastructure Setup

## Overview

This repository contains the Infrastructure as Code (IaC) for deploying an Amazon EKS cluster as part of "Project Bedrock." The setup includes a Virtual Private Cloud (VPC) with public and private subnets, an EKS cluster with a managed node group, and IAM access configuration for a read-only user. A GitHub Actions workflow automates deployment using a submodule (`retail-app`) with Helmfile for the retail-store-sample-app.

## Architecture

- **VPC**:
  - Name: `innovatemart-vpc`
  - CIDR: `10.0.0.0/16`
  - Public Subnets: `10.0.101.0/24` (us-east-1a), `10.0.102.0/24` (us-east-1b)
  - Private Subnets: `10.0.1.0/24` (us-east-1a), `10.0.2.0/24` (us-east-1b)
  - NAT Gateways: Enabled (one per AZ) for private subnet internet access
- **EKS Cluster**:
  - Name: `innovatemart-cluster`
  - Kubernetes Version: 1.33
  - Node Group: `default` with `desired_size = 1`, `min_size = 1`, `max_size = 2`
  - Instance Types: `t2.micro` (Free Tier), `m1.medium` (available in us-east-1)
  - Subnets: Private subnets with NAT support

## Access Configuration

- **IAM User**: `innovatemart-dev-readonly`
  - ARN: `arn:aws:iam::491085392395:user/innovatemart-dev-readonly`
  - Access Policy: `AmazonEKSViewPolicy` (read-only access)
  - Credentials: See `access_credentials.md` for Access Key ID and Secret Access Key
- **Kubeconfig Setup**:
  - Run: `aws eks update-kubeconfig --name innovatemart-cluster --region us-east-1 --role-arn arn:aws:iam::491085392395:user/innovatemart-dev-readonly`
  - Set environment variables with credentials from `access_credentials.md` for `kubectl` access.

## CI/CD Automation

- **Workflow**: A GitHub Actions workflow (`deploy.yml`) automates Terraform apply and app deployment using the `retail-app` submodule.
- **App Deployment**: The submodule contains a Helmfile-based deployment script (`kubernetes-dist.sh`) that generates and applies `kubernetes.yaml` for the retail-store-sample-app.

## Setup Instructions

1. Initialize Terraform: `terraform init` in the `terraform/` directory.
2. Apply Configuration: `terraform apply` (confirm with `yes`) to provision the cluster.
3. Verify Cluster: Follow kubeconfig steps above and run `kubectl get nodes`.
4. Deploy App: The `deploy.yml` workflow triggers on push to `master`, deploying from the `retail-app` submodule.
