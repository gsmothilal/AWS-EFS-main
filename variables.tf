variable "region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for mount targets"
  type        = list(string)
}

variable "efs_name" {
  description = "Name for the EFS file system"
  type        = string
}

variable "efs_sg_name" {
  description = "Name for the EFS security group"
  type        = string
}
