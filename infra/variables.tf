variable "region" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "subnets" { type = list(string) }
variable "frontend_image" { type = string }
variable "endpoint_image" { type = string }
variable "default_sg_id" { type = string }