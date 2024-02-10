locals {
  vpc_name         = "vpc-${var.project_name}"
  elasticache_name = "elasticache-${var.project_name}"
  db_name          = "db${var.project_name}"
}