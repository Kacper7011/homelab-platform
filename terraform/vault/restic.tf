resource "vault_kv_secret_v2" "restic_credentials" {
    mount = vault_mount.kv.path
    name = "services/restic/credentials"
    delete_all_versions = true

    data_json = jsonencode({
        access_key = var.restic_access_key
        secret_key = var.restic_secret_access_key
        repo_password = var.restic_repo_password
    })
}