# IAM Role for EC2 to access ECR
resource "aws_iam_role" "ec2_ecr_role" {
  name = "aadith-strapi-ec2-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "aadith-strapi-ec2-ecr-role"
  }
}

# Policy to allow ECR access
resource "aws_iam_role_policy" "ecr_policy" {
  name = "aadith-strapi-ecr-policy"
  role = aws_iam_role.ec2_ecr_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:DescribeRepositories",
          "ecr:ListImages"
        ]
        Resource = "*"
      }
    ]
  })
}

# Instance profile to attach to EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "aadith-strapi-ec2-profile"
  role = aws_iam_role.ec2_ecr_role.name
}

