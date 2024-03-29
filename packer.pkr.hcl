variable "arch_iso_checksum" {
  type = string
}

variable "arch_version" {
  type = string
}

variable "outdir" {
  type    = string
  default = "."
}

variable "outputname" {
  type    = string
}

variable "virt_cpus" {
  type    = string
  default = "2"
}

variable "virt_disksize" {
  type    = number
  default = 32768
}

variable "virt_ramsize" {
  type    = number
  default = 2048
}

variable "virt_vramsize" {
  type    = number
  default = 16
}

variable "virt_vramsizebytes" {
  type    = number
  default = 16384
}

# "timestamp" template function replacement
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/from-1.5/blocks/source
# could not parse template for following block: "template: hcl2_upgrade:15:42: executing \"hcl2_upgrade\" at <.Name>: can't evaluate field Name in type struct { HTTPIP string; HTTPPort string }"

source "virtualbox-iso" "autogenerated_1" {
  boot_command         = ["<enter><wait10><wait10><wait10>", "curl {{.HTTPIP}}:{{.HTTPPort}}/vagrant-bootstrap.sh | bash<enter>"]
  disk_size            = var.virt_disksize
  guest_additions_mode = "disable"
  guest_os_type        = "ArchLinux_64"
  hard_drive_interface = "sata"
  headless             = true
  http_directory       = "install"
  iso_checksum         = "sha256:${var.arch_iso_checksum}"
  iso_url              = ".iso/archlinux-${var.arch_version}-x86_64.iso"
  output_directory     = "${var.outdir}/box/virtualbox"
  shutdown_command     = "sudo systemctl poweroff"
  ssh_username         = "root"
  vboxmanage           = [["modifyvm", "{{.Name}}", "--vram", "${var.virt_vramsize}"], ["modifyvm", "{{.Name}}", "--memory", "${var.virt_ramsize}"], ["modifyvm", "{{.Name}}", "--firmware", "efi", "--accelerate3d", "on", "--cpus", "${var.virt_cpus}"], ["modifyvm", "{{.Name}}", "--rtcuseutc", "on"]]
  vm_name              = "archlinux-${var.outputname}-${var.arch_version}"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/from-1.5/blocks/build
build {
  sources = ["source.virtualbox-iso.autogenerated_1"]

  provisioner "file" {
    source      = "install"
    destination = "/tmp/install"
  }

  provisioner "shell" {
    inline = ["cd /tmp ; ./install/install.sh"]
  }

  # could not parse template for following block: "template: hcl2_upgrade:3:59: executing \"hcl2_upgrade\" at <.Provider>: can't evaluate field Provider in type struct { HTTPIP string; HTTPPort string }"
  post-processor "vagrant" {
    keep_input_artifact = true
    output              = "${var.outdir}/box/archlinux-${var.outputname}-${var.arch_version}-{{.Provider}}.box"
  }
}
