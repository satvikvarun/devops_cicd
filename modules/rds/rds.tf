variable "subnets" {}
variable "sg_id" {}
variable "db_username" {}
variable "db_password" {}

resource "aws_db_subnet_group" "db_subnets" {
  name       = "threetier-db-subnet-group"
  subnet_ids = var.subnets
}

resource "aws_db_instance" "postgres" {
  identifier = "threetier-postgres"
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = "db.t4g.medium"
  allocated_storage      = 20
  username               = var.db_username
  password               = var.db_password
  db_name                = "postgres"
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [var.sg_id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  multi_az               = false
  storage_encrypted      = true
}

output "endpoint" {
  value = aws_db_instance.postgres.endpoint
}
