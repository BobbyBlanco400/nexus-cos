# NΞ3XUS·COS PF-MASTER v3.0
# Terraform Variables

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "nexus-cos-production"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.50.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for SSL"
  type        = string
  default     = ""
}

variable "platform_fee_percentage" {
  description = "Platform fee percentage"
  type        = number
  default     = 20
}

variable "soc2_compliance_enabled" {
  description = "Enable SOC-2 compliance features"
  type        = bool
  default     = true
}

variable "cost_governance_enabled" {
  description = "Enable cost governance"
  type        = bool
  default     = true
}

variable "tenant_count" {
  description = "Number of tenants"
  type        = number
  default     = 12
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default = {
    Platform = "NΞ3XUS·COS"
    Version  = "3.0"
  }
}
