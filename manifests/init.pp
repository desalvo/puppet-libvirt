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
# === Examples
#
#  class {'libvirt':
#    virt_type    => 'kvm',
#    vnc_listen   => "0.0.0.0",
#    vnc_password => "mysafepass",
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
  $vnc_password = undef
) inherits params {

  package { $libvirt::params::libvirt_packages: ensure => latest }
  package { $libvirt::params::qemu_tools: ensure => latest }
  case $virt_type {
     'kvm': {
          package { $libvirt::params::kvm_package: ensure => latest, notify => Service[$libvirt::params::libvirt_service] }
      }
      default: {}
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
