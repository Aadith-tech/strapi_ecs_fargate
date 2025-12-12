output "ec2_public_ip" {
  description = "Public IP of the Strapi EC2 instance"
  value       = aws_instance.strapi_server.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the Strapi EC2 instance"
  value       = aws_instance.strapi_server.public_dns
}

output "strapi_url" {
  description = "URL to access Strapi"
  value       = "http://${aws_instance.strapi_server.public_ip}:1337"
}

output "rds_hostname" {
  description = "RDS PostgreSQL hostname"
  value       = aws_db_instance.aadith_strapi_postgres.address
}


output "ssh_command" {
  description = "SSH command to connect to EC2"
  value       = "ssh -i /Users/aaditharasu/downloads/aadithkey.pem ec2-user@${aws_instance.strapi_server.public_ip}"
}
