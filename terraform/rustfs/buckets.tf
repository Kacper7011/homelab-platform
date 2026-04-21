locals {
    bucket_names = [
        "docker",
        "kubernetes",
        "terraform",
        "vault",
        "seafile",
        "misc"
    ]
}

resource "aws_s3_bucket" "rustfs_buckets" {
    for_each = toset(local.bucket_names)
    bucket = each.value
}