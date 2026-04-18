variable rustfs_access_key {
    description = "Access key for RustFS"
    type = string
}

variable rustfs_secret_key {
    description = "Secret key for RustFS"
    type = string
    sensitive = true
}

variable rustfs_address {
    description = "Address of the RustFS server (full URL, e.g. http://host:port)"
    type = string
}

variable rustfs_host {
    description = "Host:port of the RustFS server (no scheme, for minio provider)"
    type = string
}

variable kopia_agent_secret {
    description = "Secret key for Kopia agent"
    type = string
    sensitive = true
}