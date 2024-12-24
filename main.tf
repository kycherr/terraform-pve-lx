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
    ip = "${var.ip_ansible}/24"
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
    "apt update && apt install -y openssh-server ansible sshpass",
    "echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config",
    "systemctl restart sshd",
    "mkdir -p /root/.ssh /etc/ansible",
    "ssh-keygen -t rsa -b 2048 -N '' -f /root/.ssh/id_rsa",
    "sshpass -p \"${var.lx_password}\" ssh-copy-id -i /root/.ssh/id_rsa.pub root@${var.ip_db}",
    "sshpass -p \"${var.lx_password}\" ssh-copy-id -i /root/.ssh/id_rsa.pub root@${var.ip_web}",
    "ssh-keyscan ${var.ip_db} >> /root/.ssh/known_hosts",
    "ssh-keyscan ${var.ip_web} >> /root/.ssh/known_hosts",
    "echo -e '[web]\\n${var.ip_web}\\n\\n[db]\\n${var.ip_db}' > /etc/ansible/hosts",
    "ansible all -m ping -i /etc/ansible/hosts"
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
    ip = "${var.ip_web}/24"
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
    ip = "${var.ip_db}/24"
    gw = var.vm_gateway
  }

  cores  = 2
  memory = 2048
  onboot = true
  start = true
}
