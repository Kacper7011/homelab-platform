output "kopia_agent_user" {
    value = minio_iam_user.kopia_agent.name
}

output "buckets" {
    value = aws_s3_bucket.rustfs_buckets[*]
}