variable "PM_API_TOKEN_ID" {
  description = "Proxmox API token ID"
  sensitive = true
}

variable "PM_API_TOKEN_SECRET" {
  description = "Proxmox API token secret"
  sensitive = true
}

variable "ssh_key" {
  description = "SSH public key for cloud-init"
}
