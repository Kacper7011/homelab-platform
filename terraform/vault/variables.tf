# Vault configuration variables
variable "vault_address" {
    description = "The address of the Vault server."
    type = string
    default = "http://10.10.10.216:8200"
} 

variable "root_token" {
    description = "The token to authenticate with the Vault server."
    type = string
    sensitive = true
}

# Ansible user credentials
variable "sys_user_username" {
    description = "Username for the ansible system user"
    type = string
}

variable "sys_user_password" {
    description = "Password for the ansible system user"
    type = string
    sensitive = true
}

# Ansible SSH key pair
variable "ansible_ssh_private_key" {
    description = "Private SSH key for Ansible to access remote hosts"
    type = string
    sensitive = true
}

variable "ansible_ssh_public_key" {
    description = "Public SSH key for Ansible to access remote hosts"
    type = string
}

# Application secrets
variable "homepage_env" {
    description = "JSON-encoded string containing environment variables for the homepage application"
    type = map(string)
    sensitive = true
}

variable "seafile_env" {
    description = "JSON-encoded string containing environment variables for the seafile application"
    type = map(string)
    sensitive = true
}

variable "cloudflared_env" {
    description = "JSON-encoded string containing environment variables for the cloudflared application"
    type = map(string)
    sensitive = true
}

variable "adguard_home_sync_env" {
    description = "JSON-encoded string containing environment variables for the AdGuard Home sync application"
    type = map(string)
    sensitive = true
}

variable "grafana_env" {
    description = "JSON-encoded string containing environment variables for the Grafana application"
    type = map(string)
    sensitive = true
}

