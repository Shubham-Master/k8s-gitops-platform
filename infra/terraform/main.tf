terraform {
  required_version = ">= 1.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment and configure for remote state
  # backend "s3" {
  #   bucket         = "your-tfstate-bucket"
  #   key            = "k8s-gitops-platform/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.region
}

variable "region"       { default = "us-east-1" }
variable "cluster_name" { default = "gitops-platform" }

# Phase 1: networking (no dependencies)
module "vpc" {
  source       = "./vpc"
  region       = var.region
  cluster_name = var.cluster_name
}

# Phase 2: base IAM roles (no dependencies)
module "iam" {
  source       = "./iam"
  cluster_name = var.cluster_name
}

# Phase 3: EKS cluster — needs VPC subnets and IAM role ARNs
module "eks" {
  source           = "./eks"
  cluster_name     = var.cluster_name
  region           = var.region
  vpc_id           = module.vpc.vpc_id
  private_subnets  = module.vpc.private_subnets
  cluster_role_arn = module.iam.eks_cluster_role_arn
  node_role_arn    = module.iam.eks_node_role_arn
}

# Phase 4: IRSA roles — needs EKS OIDC provider (created after cluster)
module "irsa" {
  source            = "./irsa"
  cluster_name      = var.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
}
