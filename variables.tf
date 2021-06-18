variable "profile" {
  default = ""
}

variable "region" {
  default = ""
}

variable "trusted_ecs_service" {
  description = "devops job role trusted ecs entities"
  type        = string
  default     = "ecs-tasks.amazonaws.com"
}

variable "trusted_lambda_service" {
  description = "devops job role trusted lambda entities"
  type        = string
  default     = "lambda.amazonaws.com"
}

variable "devops_iam_role_policy_arn" {
  description = "devops job role IAM policy arn list"
  type = list
  default = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/AWSBatchFullAccess",
  ]
}