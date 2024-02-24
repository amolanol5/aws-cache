data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}


resource "aws_instance" "this" {
  ami                                  = data.aws_ami.amzn-linux-2023-ami.id
  instance_type                        = "t3.large"
  subnet_id                            = module.vpc.public_subnets[0]
  instance_initiated_shutdown_behavior = "terminate"
  associate_public_ip_address          = true
  vpc_security_group_ids               = [aws_security_group.instance.id]


  user_data = templatefile("${path.module}/scripts/install_db.sh", {
    DB_HOST     = aws_db_instance.this.address
    DB_ADMIN    = var.credential_rds_db.username
    DB_PASSWORD = var.credential_rds_db.password
    DB_FILE     = templatefile("${path.module}/scripts/seed.sql", {})

  })

  tags = {
    Name = "build-database"
  }
}



resource "aws_security_group" "instance" {
  name        = "allow_instance"
  description = "Allow instance traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
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
    Name = "allow_traffic"
  }
}