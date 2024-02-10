resource "aws_elasticache_cluster" "elasticache_cluster" {
  cluster_id         = local.elasticache_name
  engine             = "redis"
  node_type          = "cache.t3.micro"
  num_cache_nodes    = 1
  port               = 6379
  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = [aws_security_group.cache.id]
  depends_on         = [module.vpc]
}


resource "aws_elasticache_subnet_group" "this" {
  name       = "my-cache-subnet-group"
  subnet_ids = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
}


## security groups
resource "aws_security_group" "cache" {
  name        = "allow_redis"
  description = "Allow redis inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_redis"
  }
}

## Auth
resource "aws_elasticache_user" "test" {
  user_id       = var.credential_elasticache.user_name
  user_name     = var.credential_elasticache.user_name
  access_string = var.credential_elasticache.access_string
  engine        = var.credential_elasticache.engine

  authentication_mode {
    type      = "password"
    passwords = var.credential_elasticache.passwords
  }
}