resource "minio_iam_user" "restic" {
  name = "restic"
  secret = var.restic_secret
}

resource "minio_iam_policy" "restic_readwrite" {
  name = "restic-readwrite"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*"
        ]
      }
    ]
  })
}

resource "minio_iam_user_policy_attachment" "restic-attachment" {
  user_name = minio_iam_user.restic.name
  policy_name = minio_iam_policy.restic_readwrite.name
}
