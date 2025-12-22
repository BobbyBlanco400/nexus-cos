# NΞ3XUS·COS PF-MASTER v3.0
# Main Terraform Configuration

terraform {
  required_version = ">= 1.6"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
  
  backend "s3" {
    bucket         = "nexus-cos-terraform-state"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "nexus-cos-terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Platform    = "NΞ3XUS·COS"
      Version     = "3.0"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  environment        = var.environment
  
  private_subnets = [
    "10.50.1.0/24",
    "10.50.2.0/24",
    "10.50.3.0/24"
  ]
  
  public_subnets = [
    "10.50.101.0/24",
    "10.50.102.0/24",
    "10.50.103.0/24"
  ]
  
  enable_nat_gateway   = true
  enable_dns_hostnames = true
}

# EKS Cluster Module
module "eks" {
  source = "./modules/eks"
  
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  
  node_groups = {
    core = {
      name           = "nexus-core-nodes"
      instance_types = ["m6i.large"]
      min_size       = 3
      max_size       = 10
      desired_size   = 3
      labels = {
        workload = "core"
      }
    }
    
    streaming = {
      name           = "nexus-streaming-nodes"
      instance_types = ["c6i.xlarge"]
      min_size       = 2
      max_size       = 20
      desired_size   = 5
      labels = {
        workload = "streaming"
      }
      taints = [{
        key    = "streaming"
        value  = "true"
        effect = "NoSchedule"
      }]
    }
    
    gaming = {
      name           = "nexus-gaming-nodes"
      instance_types = ["c6i.2xlarge"]
      min_size       = 2
      max_size       = 15
      desired_size   = 3
      labels = {
        workload = "gaming"
      }
    }
  }
}

# Storage Module
module "storage" {
  source = "./modules/storage"
  
  environment = var.environment
  
  ebs_config = {
    encrypted         = true
    kms_key_id       = "alias/nexus-cos-ebs"
    retention_policy = "retain"
    volume_type      = "gp3"
    iops             = 3000
    throughput       = 125
  }
  
  s3_buckets = [
    {
      name       = "nexus-cos-backups-${var.environment}"
      versioning = true
      encryption = "AES256"
    },
    {
      name           = "nexus-cos-logs-${var.environment}"
      lifecycle_days = 90
    },
    {
      name        = "nexus-cos-media-${var.environment}"
      cdn_enabled = true
    }
  ]
}

# Ingress Module
module "ingress" {
  source = "./modules/ingress"
  
  cluster_name = module.eks.cluster_name
  vpc_id       = module.vpc.vpc_id
  
  nginx_config = {
    load_balancer_type = "public"
    ssl_policy         = "ELBSecurityPolicy-TLS-1-2-2017-01"
    certificate_arn    = var.acm_certificate_arn
  }
  
  annotations = {
    "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" = "true"
    "service.beta.kubernetes.io/aws-load-balancer-connection-draining-enabled"       = "true"
    "service.beta.kubernetes.io/aws-load-balancer-connection-draining-timeout"       = "300"
  }
}

# Configure Kubernetes provider
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name
    ]
  }
}

# Configure Helm provider
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_name
      ]
    }
  }
}

# Deploy Helm chart
resource "helm_release" "nexus_cos" {
  name       = "nexus-cos"
  chart      = "../../helm/nexus-cos"
  namespace  = "nexus-core"
  create_namespace = true
  
  # Use default values from helm chart
  # To customize, create a helm-values.yaml file in this directory
  # values = [
  #   file("${path.module}/helm-values.yaml")
  # ]
  
  depends_on = [
    module.eks
  ]
}

# Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "eks_cluster_name" {
  description = "EKS Cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "EKS Cluster security group ID"
  value       = module.eks.cluster_security_group_id
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}
