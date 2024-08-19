output "cluster_endpoint" {
  description = "Amazon Elastic Kubernetes Service Cluster Endpoint"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_ca_certificate" {
  description = "Amazon Elastic Kubernetes Service Cluster CA Certificate"
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "cluster_auth_token" {
  description = "Amazon Elastic Kubernetes Service Cluster Authentication Token"
  value       = data.aws_eks_cluster_auth.eks_cluster.token
}
