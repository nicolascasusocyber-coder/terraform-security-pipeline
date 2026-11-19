variable "aws_region" {
  type        = string
  default     = "eu-west-1"
  description = "AWS deployment region"
}

variable "bucket_name" {
  type        = string
  description = "Globally unique name of the empty demo bucket"
}

variable "offline_plan" {
  type        = bool
  default     = false
  description = "Skip provider identity checks for the credential-free CI plan"
}
