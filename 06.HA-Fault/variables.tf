#General variables
variable "region" {
  description = "aws region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "project name"
  type        = string
  default     = "HA-project"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "az" {
  description = "Availability zone"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "tags" {
  description = "tags for project"
  type        = map(string)
  default = {
    "Company"    = "Amazon"
    "Created-by" = "Terraform"
  }
}

#VPC variables
variable "cidr" {
  description = "cidr block for vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_cidr" {
  description = "cidr block for public subnet"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "private_cidr" {
  description = "cidr block for private subnet"
  type        = list(string)
  default     = ["10.0.12.0/24", "10.0.13.0/24"]
}

#Alb variables

