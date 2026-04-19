resource "vault_kv_secret_v2" "kopia_credentials" {
    mount = vault_mount.kv.path
    name = "kopia/credentials"
    delete_all_versions = true

    data_json = jsonencode({
        "kopia" = {
            access_key = var.kopia_access_key
            secret_access_key = var.kopia_secret_access_key
        }
    })
}