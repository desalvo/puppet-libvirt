# == Class: libvirt
#
# Class to install and configure libvirt
#
# === Parameters
#
# Document parameters here.
#
# [*virt_type*]
#   The virtualization type, currently only 'kvm' is supported
#
# [*vnc_listen*]
#   Set this to '0.0.0.0' to enable public VNC access
#
# [*vnc_password*]
#   Set the VNC password
#
# [*live_migration*]
#   Set this to true to enable live migration
#
# [*rhev*]
#   Use the ovirt rhev binaries for KVM
#
# === Examples
#
#  class {'libvirt':
#    virt_type      => 'kvm',
#    vnc_listen     => "0.0.0.0",
#    vnc_password   => "mysafepass",
#    live_migration => true,
#  }
#
# === Authors
#
# Alessandro De Salvo <Alessandro.DeSalvo@roma1.infn.it>
#
# === Copyright
#
# Copyright 2014 Alessandro De Salvo.
#
class libvirt (
  $virt_type = 'kvm',
  $vnc_listen = undef,
  $vnc_password = undef,
  $live_migration = false,
  $qemu_user = false,
  $qemu_group = false,
  $rhev = false,
) inherits params {

  package { $libvirt::params::libvirt_packages: ensure => latest }
  if ($rhev) {
      package { $libvirt::params::qemu_tools_rhev: ensure => latest }
  } else {
      package { $libvirt::params::qemu_tools: ensure => latest }
  }
  case $virt_type {
     'kvm': {
          if ($rhev) {
              class {'::libvirt::repo': }
              package { $libvirt::params::kvm_package_rhev:
                  ensure  => latest,
                  notify  => Service[$libvirt::params::libvirt_service],
                  require => Yumrepo[$libvirt::params::kvm_repo_rhev]
              }
          } else {
              package { $libvirt::params::kvm_package:
                  ensure => latest,
                  notify => Service[$libvirt::params::libvirt_service]
              }
          }
      }
      default: {}
  }

  if ($live_migration) {
      augeas{ "libvirtd live migration" :
         context => "/files${libvirt::params::libvirtd_conf}",
         changes => [
             "set listen_tls 0",
             "set listen_tcp 1",
             "set auth_tcp none",
         ],
         notify => Service[$libvirt::params::libvirt_service]
      }
      augeas{ "libvirtd listen" :
         context => "/files${libvirt::params::libvirtd_sysconf}",
         changes => [
             "set LIBVIRTD_ARGS '\"--listen\"'",
         ],
         notify => Service[$libvirt::params::libvirt_service]
      }
  }

  file { $libvirt::params::qemu_conf:
      ensure  => file,
      owner   => "root",
      group   => "root",
      mode    => 0644,
      content => template("libvirt/qemu.conf.erb"),
      require => Package[$libvirt::params::libvirt_packages],
      notify  => Service[$libvirt::params::libvirt_service]
  }

  service { $libvirt::params::libvirt_service:
     ensure     => running,
     hasrestart => true,
     require    => File[$libvirt::params::qemu_conf]
  }
}
