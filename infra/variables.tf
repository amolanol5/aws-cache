variable "project_name" {
  default = "aws-cache"
}

variable "config_elasticache" {
  default = {
    cluster_size  = 1
    instance_type = "cache.t3.micro"
  }
}