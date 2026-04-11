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