output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  value       = module.eks.oidc_provider_arn
}

output "alb_controller_role_arn" {
  description = "IAM role ARN for the ALB controller"
  value       = module.irsa.alb_controller_role_arn
}

output "cluster_autoscaler_role_arn" {
  description = "IAM role ARN for the cluster autoscaler"
  value       = module.irsa.cluster_autoscaler_role_arn
}
