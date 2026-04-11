resource "vault_mount" "kv" {
    path = "secret"
    type = "kv"

    options = {
      version = "2"
    }

    description = "Main homelab kv engine"
}