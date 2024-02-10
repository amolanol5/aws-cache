locals {
  vpc_name         = "vpc-${var.project_name}"
  elasticache_name = "elasticache-${var.project_name}"
  lambda_function_name = "function-${var.project_name}"
}