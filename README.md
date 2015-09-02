puppet-libvirt
======

Puppet module for managing libvirt configurations.

#### Table of Contents
1. [Overview - What is the libvirt module?](#overview)
2. [Usage](#usage)

Overview
--------

This module is used to install and configure libvirt.

Usage
-----

Parameters:
* **virt_type**: the virtualization type, currently only 'kvm' is supported
* **vnc_listen**: set this to '0.0.0.0' to enable public VNC access
* **vnc_password**: set the VNC password
* **live_migration**: set this to true to enable the live migration
* **qemu_user**: user for qemu images
* **qemu_group**: group for qemu images
* **rhev**: Use the ovirt rhev binaries for KVM
* **sanlock**: Set this to true if you want to use sanlock
* **sanlock_wd**: Set this to false if you do not want to use the sanlock watchdoghdog
* **sanlock_host_id**: Unique host id, must be set
* **sanlock_auto_disk_leases**: The default sanlock configuration requires the management application to manually define <lease> elements in the guest configuration, typically one lease per disk. An alternative is to enable "auto disk lease" mode. In this usage, libvirt will automatically create a lockspace and lease for each fully qualified disk path. This works if you are able to ensure stable, unique disk paths across all hosts in a network
* **sanlock_require_lease_for_disks**: Flag to determine whether we allow starting of guests which do not have any <lease> elements defined in their configuration. If 'sanlock_auto_disk_leases' is false, this setting defaults to true, otherwise it defaults to false
* **sanlock_disk_lease_dir**: Custom sanlock lease dir, defaults to /var/lib/libvirt/sanlock
* **sanlock_user**: Custom sanlock user, defaults to root
* **sanlock_group**: Custom sanlock group, defaults to root


**Configuring libvirt**

```libvirt
class {'libvirt':
    virt_type    => 'kvm',
    vnc_listen   => "0.0.0.0",
    vnc_password => "mysafepass",
}
```

Contributors
------------

* https://github.com/desalvo/puppet-libvirt/graphs/contributors

Release Notes
-------------

**0.1.5**

* Add sanlock support

**0.1.4**

* Fix qemu-img package when RHEV is enabled

**0.1.3**

* Support for oVirt RHEV binaries

**0.1.2**

* Fix missing option to allow listening to incoming connection

**0.1.1**

* New options for live migration and ownership of qemu images

**0.1.0**

* Initial version
