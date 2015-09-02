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
# [*sanlock*]
#   Set this to true if you want to use sanlock
#
# [*sanlock_wd*]
#   Set this to false if you do not want to use the sanlock watchdog
#
# [*sanlock_auto_disk_leases*]
#   The default sanlock configuration requires the management
#   application to manually define <lease> elements in the
#   guest configuration, typically one lease per disk. An
#   alternative is to enable "auto disk lease" mode. In this
#   usage, libvirt will automatically create a lockspace and
#   lease for each fully qualified disk path. This works if
#   you are able to ensure stable, unique disk paths across
#   all hosts in a network.
#
# [*sanlock_require_lease_for_disks*]
#   Flag to determine whether we allow starting of guests
#   which do not have any <lease> elements defined in their
#   configuration. If 'sanlock_auto_disk_leases' is false,
#   this setting defaults to true, otherwise it defaults to false.
#
# [*sanlock_host_id*]
#   Unique host id, must be set
#
# [*sanlock_disk_lease_dir*]
#   Custom sanlock lease dir, defaults to /var/lib/libvirt/sanlock
#
# [*sanlock_user*]
#   Custom sanlock user
#
# [*sanlock_group*]
#   Custom sanlock group

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
  $sanlock = false,
  $sanlock_wd = true,
  $sanlock_host_id = undef,
  $sanlock_auto_disk_leases = false,
  $sanlock_require_lease_for_disks = false,
  $sanlock_disk_lease_dir = undef,
  $sanlock_user = undef,
  $sanlock_group = undef
) inherits params {

  package { $libvirt::params::libvirt_packages: ensure => latest }
  if ($rhev and $virt_type == 'kvm') {
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

  if ($sanlock) {
      if (!$sanlock_host_id) { fail ("Need to set sanlock_host_id when sanlock is enabled") }
      if (!$sanlock_wd) { $sanlockopts = "-U sanlock -G sanlock -w 0" }

      package {$libvirt::params::sanlock_packages: ensure => latest}

      file { $libvirt::params::qemu_sanlock_conf:
          ensure  => "file",
          owner   => "root",
          group   => "root",
          mode    => "0644",
          content => template("libvirt/qemu-sanlock.conf.erb"),
          require => Package[$libvirt::params::sanlock_packages],
          notify  => Service[$libvirt::params::sanlock_service]
      }

      file { $libvirt::params::sanlock_sysconf:
          ensure  => "file",
          owner   => "root",
          group   => "root",
          mode    => "0644",
          content => template("libvirt/sanlock.sysconf.erb"),
          require => Package[$libvirt::params::sanlock_packages],
          notify  => Service[$libvirt::params::sanlock_service]
      }

      service { $libvirt::params::wdmd_service:
         ensure     => running,
         hasrestart => true,
         require    => File[$libvirt::params::qemu_sanlock_conf]
      }
      service { $libvirt::params::sanlock_service:
         ensure     => running,
         hasrestart => true,
         require    => [File[$libvirt::params::qemu_sanlock_conf],Service[$libvirt::params::wdmd_service]]
      }
      $libvirt_service_reqs = [File[$libvirt::params::qemu_conf],Service[$libvirt::params::sanlock_service]]
  } else {
      $libvirt_service_reqs = File[$libvirt::params::qemu_conf]
  }

  file { $libvirt::params::qemu_conf:
      ensure  => "file",
      owner   => "root",
      group   => "root",
      mode    => "0644",
      content => template("libvirt/qemu.conf.erb"),
      require => Package[$libvirt::params::libvirt_packages],
      notify  => Service[$libvirt::params::libvirt_service]
  }

  service { $libvirt::params::libvirt_service:
     ensure     => running,
     hasrestart => true,
     require    => $libvirt_service_reqs
  }
}
