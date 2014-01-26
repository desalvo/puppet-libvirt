class libvirt::params {

  case $::osfamily {
    'RedHat': {
      $libvirt_packages = ['libvirt', 'libvirt-client', 'libvirt-python', 'virt-manager', 'virt-viewer']
      $libvirt_service  = 'libvirtd'
      $qemu_tools       = 'qemu-img'
      $kvm_package      = 'qemu-kvm'
      $qemu_conf        = '/etc/libvirt/qemu.conf'
    }
    default:   {
    }
  }

}
