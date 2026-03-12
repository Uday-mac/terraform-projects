variable "REGION" {
  default = "us-east-1"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "2-tier-project"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "az" {
  description = "availability zone"
  type        = string
  default     = "us-east-1a"
}

variable "db-az" {
  description = "db availability zone"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "cidr_block" {
  description = "Ip range for vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tags" {
  description = "tags for 2-tier project"
  type        = map(string)
  default = {
    "Project"     = "2-tier-project"
    "Environment" = "Dev"
  }
}

variable "pubsub_cidr" {
  description = "Enter the subnet block"
  type        = list(string)
  default     = ["10.0.10.0/24"]
}

variable "privatesub_cidr" {
  description = "Enter the subnet block"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

#Database user
variable "username" {
  description = "user for mysql"
  type        = string
  default     = "admin"
}