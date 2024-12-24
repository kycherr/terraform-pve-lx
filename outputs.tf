output "ansible_vm_ip" {
  description = "The IP address of the Ansible VM"
  value       = var.ip_ansible
}

output "web_vm_ip" {
  description = "The IP address of the Web Server VM"
  value       = var.ip_web
}

output "db_vm_ip" {
  description = "The IP address of the Database VM"
  value       = var.ip_db
}
