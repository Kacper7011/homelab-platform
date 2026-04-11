output "ansible_role_id" {
    description = "Ansible role id"
    value = data.vault_approle_auth_backend_role_id.ansible.role_id
}

output "ansible_secret_id" {
    description = "Ansible secret id"
    value = vault_approle_auth_backend_role_secret_id.ansible.secret_id
    sensitive = true
}