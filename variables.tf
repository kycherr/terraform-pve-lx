variable "proxmox_url" {
  description = "Proxmox API URL"
  type        = string
  default     = null
}

variable "proxmox_user" {
  description = "Proxmox user for authentication"
  type        = string
  default     = null
}

variable "proxmox_password" {
  description = "Password for Proxmox root user"
  type        = string
  sensitive   = true
}

variable "vm_template" {
  description = "Template name for cloning the VMs"
  type        = string
  default     = null
}

variable "vm_storage" {
  description = "Storage location for VM disks"
  type        = string
  default     = null
}

variable "vm_bridge" {
  description = "Network bridge for VMs"
  type        = string
  default     = null
}

variable "vm_gateway" {
  description = "Gateway for VMs"
  type        = string
  default     = null
}

variable "vm_dns" {
  description = "DNS for VMs"
  type        = string
  default     = null
}

variable "vm_ips" {
  description = "Map of VM names to IPs"
  type        = map(string)
  default     = null
}

variable "lx_password" {
  description = "Password for lx root user"
  type        = string
}

variable "ip_ansible" {
  description = "ip_ansible"
  type        = string
  default     = null
}


variable "ip_db" {
  description = "ip_ansible"
  type        = string
  default     = null
}

variable "ip_web" {
  description = "ip_ansible"
  type        = string
  default     = null
}