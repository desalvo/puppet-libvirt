class libvirt::params {

  case $::osfamily {
    'RedHat': {
      $libvirt_packages  = ['libvirt', 'libvirt-client', 'libvirt-python', 'virt-manager', 'virt-viewer']
      $sanlock_packages  = ['libvirt-lock-sanlock']
      $libvirt_service   = 'libvirtd'
      $sanlock_service   = 'sanlock'
      $wdmd_service      = 'wdmd'
      $qemu_tools        = 'qemu-img'
      $qemu_tools_rhev   = 'qemu-img-rhev'
      $kvm_package       = 'qemu-kvm'
      $kvm_package_rhev  = 'qemu-kvm-rhev'
      $kvm_repo_rhev     = 'qemu-kvm-rhev'
      $qemu_conf         = '/etc/libvirt/qemu.conf'
      $libvirtd_conf     = '/etc/libvirt/libvirtd.conf'
      $libvirtd_sysconf  = '/etc/sysconfig/libvirtd'
      $qemu_sanlock_conf = '/etc/libvirt/libvirtd.conf'
      $sanlock_sysconf   = '/etc/sysconfig/sanlock'
    }
    default:   {
    }
  }

}
