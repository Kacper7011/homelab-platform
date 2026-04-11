resource "vault_auth_backend" "approle" {
    type = "approle"
}

# Create an AppRole role for Ansible with read-only access to secrets
resource "vault_approle_auth_backend_role" "ansible" {
    backend = vault_auth_backend.approle.path
    role_name = "ansible"

    token_policies = [vault_policy.ansible.name]
    token_ttl = 3600
    token_max_ttl = 7200
    secret_id_ttl = 604800
    secret_id_num_uses = 0
}

data "vault_approle_auth_backend_role_id" "ansible" {
    backend   = vault_auth_backend.approle.path
    role_name = vault_approle_auth_backend_role.ansible.role_name
}

resource "vault_approle_auth_backend_role_secret_id" "ansible" {
    backend   = vault_auth_backend.approle.path
    role_name = vault_approle_auth_backend_role.ansible.role_name

    lifecycle {
        ignore_changes = all
    }
}