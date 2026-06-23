resource "aws_db_subnet_group" "main" {
  name = "techstock-db-subnet-group"

  subnet_ids = var.private_subnets

  tags = {
    Name = "techstock-db-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier = "techstock-db"

  engine         = "postgres"
  engine_version = "15"

  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = "techstock"
  username = "techstock_user"
  password = var.db_password

  db_subnet_group_name = aws_db_subnet_group.main.name

  vpc_security_group_ids = [
    var.rds_sg_id
  ]

  publicly_accessible = false

  skip_final_snapshot = true
  multi_az            = false

  tags = {
    Name = "techstock-db"
  }
}
