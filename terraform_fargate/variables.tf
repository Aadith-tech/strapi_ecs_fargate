variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}


variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "strapidb"
}

variable "db_username" {
  description = "PostgreSQL username"
  type        = string
  default     = "strapiuser"
}

variable "db_password" {
  description = "PostgreSQL master password"
  type        = string
  sensitive   = true
  default     = "password"
}

variable "docker_image" {
  description = "Docker image for Strapi (ECR)"
  type        = string
  default     = "aadith27/strapi-daily-logs"

}

variable "app_keys" {
  description = "Strapi APP_KEYS (comma-separated)"
  type        = string
  sensitive   = true
  default     = "aQrx8CqVWAT0k7ryEogiWg==,t3Lmky21wd/JMJ7WYw92qw==,MOl2ZER1hKfaJu1fLzBhdA==,4mIG873yvbrqN/KFZjtXaQ=="
}

variable "api_token_salt" {
  description = "Strapi API_TOKEN_SALT"
  type        = string
  sensitive   = true
  default     = "AJyNKy+cgMrvSJvSUFUPYg=="
}

variable "admin_jwt_secret" {
  description = "Strapi ADMIN_JWT_SECRET"
  type        = string
  sensitive   = true
  default     = "uAZKUe3ldI27YASKAAnY2g=="
}

variable "jwt_secret" {
  description = "Strapi JWT_SECRET"
  type        = string
  sensitive   = true
  default     = "fAiAjMekEOI4nDvdMViTng=="
}
