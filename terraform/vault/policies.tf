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

resource "vault_policy" "kopia" {

    name = "kopia"

    policy = <<-EOT
        path "secret/data/kopia/*" {
            capabilities = ["read"]
        }
    EOT
}

