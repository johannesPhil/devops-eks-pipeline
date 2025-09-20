resource "aws_iam_user" "dev_readonly" {
  name          = "innovatemart-dev-readonly"
  force_destroy = true
}

resource "aws_iam_access_key" "dev_readonly" {
  user = aws_iam_user.dev_readonly.name
}

# Inline policy for read-only EKS + EC2 + RDS + DynamoDB
resource "aws_iam_user_policy" "dev_readonly_policy" {
  name = "DevReadOnlyPolicy"
  user = aws_iam_user.dev_readonly.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:Describe*",
          "eks:List*",
          "ec2:Describe*",
          "rds:Describe*",
          "dynamodb:Describe*",
          "dynamodb:List*",
          "logs:GetLogEvents",
          "logs:Describe*",
          "logs:List*"
        ]
        Resource = "*"
      }
    ]
  })
}

output "dev_readonly_access_key_id" {
  value     = aws_iam_access_key.dev_readonly.id
  sensitive = true
}

output "dev_readonly_secret_access_key" {
  value     = aws_iam_access_key.dev_readonly.secret
  sensitive = true
}
