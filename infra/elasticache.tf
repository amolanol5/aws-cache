resource "aws_elasticache_cluster" "elasticache_cluster" {
  cluster_id           = local.elasticache_name
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  port                 = 6379
  ## TODO subnet_group_name
}