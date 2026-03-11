variable "REGION" {
  description = "Aws region"
  type        = string
  default     = "us-east-1"
}

variable "bucket" {
  description = "s3 Bucket name"
  type        = string
  default     = "badarak-website"
}

variable "domain" {
  description = "Domain name for hostedzone"
  type        = string
  default     = "static.devmac.xyz"
}

#Geting the ACM certificate
data "aws_acm_certificate" "cert" {
  domain      = "*.devmac.xyz"
  statuses    = ["ISSUED"]
  most_recent = true
}