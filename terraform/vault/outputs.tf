output "ansible_role_id" {
    description = "Ansible role id"
    value = data.vault_approle_auth_backend_role_id.ansible.role_id
}

output "ansible_secret_id" {
    description = "Ansible secret id"
    value = vault_approle_auth_backend_role_secret_id.ansible.secret_id
    sensitive = true
}

output "kopia_role_id" {
    description = "Kopia role id"
    value = vault_approle_auth_backend_role.kopia.role_id
}

output "kopia_secret_id" {
    description = "kopia secret id"
    value = vault_approle_auth_backend_role_secret_id.kopia.secret_id
    sensitive = true
}