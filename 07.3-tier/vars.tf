#General variables
variable "region" {
  default = "us-east-1"
}

variable "project" {
  default = "3-tier"
}

variable "env" {
  default = "dev"
}

variable "availability_zone" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}


#Vpc variables
variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "az" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "app-tier-subnet" {
  type    = list(string)
  default = ["10.0.17.0/24", "10.0.18.0/24"]
}

variable "app-frontend-subnet" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "app-backend-subnet" {
  type    = list(string)
  default = ["10.0.13.0/24", "10.0.14.0/24"]
}

variable "app-db-subnet" {
  type    = list(string)
  default = ["10.0.15.0/24", "10.0.16.0/24"]
}

#secrets and db variables
variable "db-name" {
  type    = string
  default = "test-db"
}

variable "db-username" {
  type    = string
  default = "postgres"
}

variable "db-port" {
  type    = number
  default = 5342
}

variable "db-engine" {
  type    = string
  default = "postgres"
}