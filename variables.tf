variable "aws_profile" {
  description = "[REQUIRED] The AWS Region to deploy the resources"
  type        = string
}

variable "aws_region" {
  description = "[REQUIRED] The AWS Region to deploy the resources"
  type        = string
}

variable "vpc_cidr" {
  description = "[REQUIRED] The VPC CIDR block, Required format: '0.0.0.0/0'"
  type        = string
}

variable "logs_retention" {
  description = "[REQUIRED] The number of days to retain log events in CloudWatch"
  type        = number
}

variable "name_prefix" {
  description = "[REQUIRED] is required for resource names"
  type        = string
}


variable "PublicSubnet" {
  description = "[REQUIRED] List of key value maps to build the CIDR using the cidrsubnets function, plus the value name and index number for the availability zone"
  type = list(object({
    name = string
    az   = string
    cidr = string
  }))
}

variable "PrivateSubnet" {
  description = "[REQUIRED] List of key value maps to build the CIDR using the cidrsubnets function, plus the value name and index number for the availability zone"
  type = list(object({
    name = string
    az   = string
    cidr = string
  }))
}

variable "project-tags" {
  type = map(string)
  default = {
  }
}



