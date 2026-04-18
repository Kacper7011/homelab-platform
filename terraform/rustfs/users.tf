resource "minio_iam_user" "kopia_agent" {
  name = "kopia-agent"
  secret = var.kopia_agent_secret
}

resource "minio_iam_policy" "kopia_readwrite" {
  name = "kopia-readwrite"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::./*",
          "arn:aws:s3:::./*/*"
        ]
      }
    ]
  })
}

resource "minio_iam_user_policy_attachment" "kopia_agent-attachment" {
  user_name = minio_iam_user.kopia_agent.name
  policy_name = minio_iam_policy.kopia_readwrite.name
}
