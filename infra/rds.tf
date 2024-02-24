resource "aws_db_instance" "this" {
  allocated_storage      = 10
  db_name                = "dbawscache"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  username               = var.credential_rds_db.username
  password               = var.credential_rds_db.password
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  depends_on             = [module.vpc]
}


resource "aws_db_subnet_group" "this" {
  name       = "subnet-group-db-cache"
  subnet_ids = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]

}


# security groups
resource "aws_security_group" "db" {
  name        = "allow_mysql"
  description = "Allow mysq inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "mysql from VPC"
    from_port   = 3306
    to_port     = 3306
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
    Name = "allow_mysql"
  }
}