variable "project_name" {
  description = "Project name used for tagging and naming AWS resources"
  type        = string
  default     = "taskapp-tsa-terra"
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-3"
}