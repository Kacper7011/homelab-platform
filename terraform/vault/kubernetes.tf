resource "vault_kubernetes_auth_backend_config" "kubernetes" {
    backend = vault_auth_backend.kubernetes.path
    kubernetes_host = "https://10.10.10.106:6443"
    kubernetes_ca_cert = var.kubernetes_cert
    token_reviewer_jwt = var.vault_k8s_rewiever_token
}

resource "vault_policy" "cloudflared" {
    name = "cloudflared"
    policy = <<-EOT
        path "secret/data/services/cloudflared" {
            capabilities = ["read"]
        }
    EOT
}

resource "vault_kubernetes_auth_backend_role" "cloudflared" {
    backend = vault_auth_backend.kubernetes.path
    role_name = "cloudflared"
    bound_service_account_names = ["cloudflared-sa"]
    bound_service_account_namespaces = ["cloudflared"]
    token_policies = [vault_policy.cloudflared.name]
    token_ttl = 3600
}