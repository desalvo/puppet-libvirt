class libvirt::repo (
  $ovirt_version = '3.5',
  $ovirt_repo = 'http://resources.ovirt.org/pub'
) {
  case $osfamily {
    'RedHat': {
      yumrepo {$libvirt::params::kvm_repo_rhev:
        descr               => "oVirt rebuilds of qemu-kvm-rhev",
        baseurl             => "${ovirt_repo}/ovirt-${ovirt_version}/rpm/el${operatingsystemmajrelease}Server/",
        mirrorlist          => "${ovirt_repo}/yum-repo/mirrorlist-ovirt-i${ovirt_version}-el${operatingsystemmajrelease}Server",
        enabled             => 1,
        skip_if_unavailable => 1,
        gpgcheck            => 0
      }
    }
  }
}
