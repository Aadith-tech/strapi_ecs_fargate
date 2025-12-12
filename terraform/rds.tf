
resource "aws_db_subnet_group" "strapi_db_subnet" {
  name       = "aadith-strapi-db-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name = "aadith-strapi-db-subnet-group"
  }
}

resource "aws_db_instance" "aadith_strapi_postgres" {
  identifier             = "aadith-strapi-postgres"
  engine                 = "postgres"
  engine_version         = "17.6"
  instance_class         = var.db_instance_class
  allocated_storage      = 20
  storage_type           = "gp3"
  storage_encrypted      = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.strapi_db_subnet.name

  skip_final_snapshot    = true
  deletion_protection    = false
  backup_retention_period = 7

  tags = {
    Name = "aadith-strapi-postgres-rds"
  }
}