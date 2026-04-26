resource "vault_kubernetes_auth_backend_config" "kubernetes" {
    backend = vault_auth_backend.kubernetes.path
    kubernetes_host = "https://10.10.10.106:6443"
    kubernetes_ca_cert = var.kubernetes_cert
    token_reviewer_jwt = var.vault_k8s_rewiever_token
}