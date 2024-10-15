variable "proxmox" {
    description = "Proxmox server configuration"
    type        = object({
        endpoint  = string
        insecure  = bool

        ssh_username            = string
        ssh_private_key_file    = string
    })
}

###############################  API ##############################
variable "api_token_id" {
    type    = string
}

variable "api_token_secret" {
    type    = string
}

locals {
  api_token = "${var.api_token_id}=${var.api_token_secret}"
}
