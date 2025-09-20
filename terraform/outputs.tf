output "cluster_id" {
  description = "EKS cluster name / id"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded CA cert for the cluster (useful for kubeconfig)"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

