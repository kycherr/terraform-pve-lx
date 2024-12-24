terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.11"
    }
  }

  required_version = ">= 1.0.0"
}

provider "proxmox" {
  pm_api_url      = var.proxmox_url
  pm_user         = var.proxmox_user
  pm_password     = var.proxmox_password
  pm_tls_insecure = true
}


resource "proxmox_lxc" "ansible" {
  target_node = "pveg5"
  hostname    = "ansible"
  ostemplate  = "PVE-G5-B34:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  password    =  var.lx_password

  rootfs {
    size    = "20G"
    storage = var.vm_storage
  }

  network {
    name = "eth0"
    bridge = var.vm_bridge
    ip = var.ip_ansible
    gw = var.vm_gateway
  }

provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "root"
      password = var.lx_password
      host     = regex("[^/]+", var.ip_ansible)
    }

    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "apt update && apt install -y openssh-server ansible",
      "echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config",
      "systemctl restart sshd",
      "ssh-keyscan ${var.ip_db} >> ~/.ssh/known_hosts",
      "ssh-keyscan ${var.ip_web} >> ~/.ssh/known_hosts",
      "cat > /etc/ansible/hosts <<EOL\n[web]\n${var.ip_web}\n\n[db]\n${var.ip_db}\nEOL"
    ]
  }

  cores  = 2
  memory = 2048
  onboot = true
  start = true
}

resource "proxmox_lxc" "web" {
  target_node = "pveg5"
  hostname    = "web-server"
  ostemplate  = "PVE-G5-B34:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  password    =  var.lx_password

  rootfs {
    size    = "20G"
    storage = var.vm_storage
  }

  network {
    name = "eth0"
    bridge = var.vm_bridge
    ip = var.ip_web
    gw = var.vm_gateway
  }

  cores  = 2
  memory = 2048
  onboot = true
  start = true
}

resource "proxmox_lxc" "db" {
  target_node = "pveg5"
  hostname    = "db-server"
  ostemplate  = "PVE-G5-B34:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  password    = var.lx_password

  rootfs {
    size    = "20G"
    storage = var.vm_storage
  }

  network {
    name = "eth0"
    bridge = var.vm_bridge
    ip = var.ip_db
    gw = var.vm_gateway
  }

  cores  = 2
  memory = 2048
  onboot = true
  start = true
}
