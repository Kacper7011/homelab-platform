resource "vault_policy" "restic" {

    name = "restic"

    policy = <<-EOT
        path "secret/data/services/restic/credentials" {
            capabilities = ["read"]
        }
    EOT
}

resource "vault_approle_auth_backend_role" "restic" {
    backend = vault_auth_backend.approle.path
    role_name = "restic"
    token_policies = [vault_policy.restic.name]
    token_ttl = 3600
    token_max_ttl = 7200
}

resource "vault_approle_auth_backend_role_secret_id" "restic" {
    backend = vault_auth_backend.approle.path
    role_name = vault_approle_auth_backend_role.restic.role_name
}

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

output "restic_role_id" {
    description = "Restic role id"
    value = vault_approle_auth_backend_role.restic.role_id
}

output "restic_secret_id" {
    description = "Restic secret id"
    value = vault_approle_auth_backend_role_secret_id.restic.secret_id
    sensitive = true
}
