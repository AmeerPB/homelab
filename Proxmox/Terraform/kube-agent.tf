resource "proxmox_vm_qemu" "kube-agent" {
  count = 2
  name = "kube-agent-0${count.index + 1}"
  target_node = "prox-1u"
  vmid = "50${count.index + 1}"
  clone = "ubuntu-2004-cloudinit-template"
  agent = 1
  os_type = "cloud-init"
  cores = 2
  sockets = 1
  cpu = "host"
  memory = 4096
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"
  disk {
    slot = 0
    size = "10G"
    type = "scsi"
    storage = "local-zfs"
    #storage_type = "zfspool"
    iothread = 1
  }
  network {
    model = "virtio"
    bridge = "vmbr0"
  }
  
  network {
    model = "virtio"
    bridge = "vmbr17"
  }
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
  ipconfig0 = "ip=10.98.1.5${count.index + 1}/24,gw=10.98.1.1"
  ipconfig1 = "ip=10.17.0.5${count.index + 1}/24"
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}