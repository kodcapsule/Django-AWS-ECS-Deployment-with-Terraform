variable "region" {
  description = "The AWS region to create resources in."
  default     = "us-east-1"
}

variable "profile" {
  description = "The AWS profile to use for authentication."
  default     = "wewoli"

}

variable "project_name" {
  description = "The name of the project."
  default     = "DjangoApp"

}


# ================= Networking variables =================

# VPC variables
variable "vpc_cidr" {
  description = "CIDR Block for the VPC"
  default     = "10.0.0.0/16"
}

# Public subnets variables
# Note: These subnets are used for load balancers and NAT gateways.
variable "public_subnet_1_cidr" {
  description = "CIDR Block for Public Subnet 1"
  default     = "10.0.1.0/24"
}
variable "public_subnet_2_cidr" {
  description = "CIDR Block for Public Subnet 2"
  default     = "10.0.2.0/24"
}

# Private subnets variables
# Note: These subnets are used for ECS tasks and RDS instances.
variable "private_subnet_1_cidr" {
  description = "CIDR Block for Private Subnet 1"
  default     = "10.0.3.0/24"
}
variable "private_subnet_2_cidr" {
  description = "CIDR Block for Private Subnet 2"
  default     = "10.0.4.0/24"
}

# Availability zones
# Note: Ensure that the availability zones match those available in your selected region.
variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}


# load balancer

variable "health_check_path" {
  description = "Health check path for the default target group"
  default     = "/ping/"
}


variable "log_retention_in_days" {
  default = 30
}




#================ ECS variables =================


variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type = string
  # Note: This is the name of the ECS cluster where the Django app will run.
  default     = "production"

  validation {
    condition     = length(var.ecs_cluster_name) > 0
    error_message = "ECS cluster name must not be empty."
  }
}

variable "docker_image_url_django" {
  description = "Docker image to run in the ECS cluster"
  type = string

  validation {
    condition     = length(var.docker_image_url_django) > 0
    error_message = "Docker image URL must not be empty."
  }
}

variable "app_count" {
  description = "Number of Docker containers to run"
  type = number
  default     = 2

  validation {
    condition     = var.app_count > 0
    error_message = "App count must be greater than 0."
  }
}

variable "fargate_cpu" {
  description = "Amount of CPU for Fargate task. E.g., '256' (.25 vCPU)"
  type = number
  default     = 256
  validation {
    condition     = var.fargate_cpu > 0
    error_message = "Fargate CPU must be greater than 0."
  }
}

variable "fargate_memory" {
  description = "Amount of memory for Fargate task. E.g., '512' (0.5GB)"
  type        = number
  default     = 512
  validation {
    condition     = var.fargate_memory > 0
    error_message = "Fargate memory must be greater than 0."
  }
}



# ECS service auto scaling

variable "autoscale_min" {
  description = "Minimum autoscale (number of tasks)"
  default     = "1"
}

variable "autoscale_max" {
  description = "Maximum autoscale (number of tasks)"
  default     = "10"
}

variable "autoscale_desired" {
  description = "Desired number of tasks to run initially"
  default     = "4"
}