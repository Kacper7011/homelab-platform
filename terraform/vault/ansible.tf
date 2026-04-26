resource "vault_policy" "ansible" {

    name = "ansible_read_only"

    policy = <<-EOT
        path "secret/data/ansible/*" {
            capabilities = ["read", "list"]
        }
        path "secret/metadata/ansible/*" {
            capabilities = ["read", "list"]
        }
        path "secret/data/services/*" {
            capabilities = ["read", "list"]
        }
        path "secret/metadata/services/*" {
            capabilities = ["read", "list"]
        }
    EOT
}

resource "vault_approle_auth_backend_role" "ansible" {
    backend = vault_auth_backend.approle.path
    role_name = "ansible"

    token_policies = [vault_policy.ansible.name]
    token_ttl = 3600
    token_max_ttl = 7200
    secret_id_ttl = 864000
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

resource "vault_kv_secret_v2" "ansible_users" {
    mount = vault_mount.kv.path
    name = "ansible/users"
    delete_all_versions = true

    data_json = jsonencode({
        "sys_user" = {
            username = var.sys_user_username
            password = var.sys_user_password
        }
    })
}

resource "vault_kv_secret_v2" "ansible_ssh" {
    mount = vault_mount.kv.path
    name = "ansible/ssh"
    delete_all_versions = true

    data_json = jsonencode({
        "ssh_keys" = {
            private_key = var.ansible_ssh_private_key
            public_key = var.ansible_ssh_public_key
        }
    })
}

output "ansible_role_id" {
    description = "Ansible role id"
    value = data.vault_approle_auth_backend_role_id.ansible.role_id
}

output "ansible_secret_id" {
    description = "Ansible secret id"
    value = vault_approle_auth_backend_role_secret_id.ansible.secret_id
    sensitive = true
}
