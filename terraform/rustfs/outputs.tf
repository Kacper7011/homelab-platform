output "restic_user" {
    value = minio_iam_user.restic.name
}

output "buckets" {
    value = aws_s3_bucket.rustfs_buckets[*]
}