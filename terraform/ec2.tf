resource "aws_instance" "strapi_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.private_key_config.key_name
  vpc_security_group_ids      = [aws_security_group.strapi_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  user_data = templatefile("${path.module}/user_data.sh", {
    docker_image     = var.docker_image
    aws_region       = var.aws_region
    db_host          = aws_db_instance.aadith_strapi_postgres.address
    db_port          = aws_db_instance.aadith_strapi_postgres.port
    db_name          = var.db_name
    db_username      = var.db_username
    db_password      = var.db_password
    app_keys         = var.app_keys
    api_token_salt   = var.api_token_salt
    admin_jwt_secret = var.admin_jwt_secret
    jwt_secret       = var.jwt_secret
  })

  tags = {
    Name = "aadith-strapi-server"
  }

  depends_on = [aws_db_instance.aadith_strapi_postgres]
}