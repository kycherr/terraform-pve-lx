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
  ostemplate  = "${var.vm_storage}:${var.vm_template}"
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
      host     = var.ip_ansible
    }

  inline = [
    "export DEBIAN_FRONTEND=noninteractive",
    # ansible-playbook main.yml --extra-vars "db_host=192.168.66.223 db_name=app_db db_user=app_user db_pass=app_pass" -i /etc/ansible/hosts
    "echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && systemctl restart sshd",
    "apt update && apt install -y openssh-server ansible sshpass",
    "mkdir -p /root/.ssh /etc/ansible",
    "echo ${var.lx_password} > 1.txt",
    "echo \"${var.lx_password}\" > 2.txt",
    "ssh-keyscan ${var.ip_db} >> /root/.ssh/known_hosts",
    "ssh-keyscan ${var.ip_web} >> /root/.ssh/known_hosts",
    "ssh-keygen -t rsa -b 2048 -N '' -f /root/.ssh/id_rsa",
    #${var.lx_password}
    "sshpass -p P@ssw0rd ssh-copy-id -i /root/.ssh/id_rsa.pub root@${var.ip_db}",
    "sshpass -p P@ssw0rd ssh-copy-id -i /root/.ssh/id_rsa.pub root@${var.ip_web}",
    "echo '[db]\\n${var.ip_db}\\n\\n[server]\\n${var.ip_web}' > /etc/ansible/hosts",
    "ansible all -m ping -i /etc/ansible/hosts",
  ]
  }

provisioner "local-exec" {
  command = <<EOL
    scp -r -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ansible/ root@${var.ip_ansible}:/root/ &&
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${var.ip_ansible} <<EOF
      cd /root/ansible &&
      ansible-playbook main.yml --extra-vars "db_host=${var.ip_db} db_name=app_db db_user=app_user db_pass=app_pass" -i /etc/ansible/hosts
    EOF
  EOL
}


  cores  = 2
  memory = 2048
  onboot = true
  start = true
}

resource "proxmox_lxc" "web" {
  target_node = "pveg5"
  hostname    = "web-server"
  ostemplate  = "${var.vm_storage}:${var.vm_template}"
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
  ostemplate  = "${var.vm_storage}:${var.vm_template}"
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
