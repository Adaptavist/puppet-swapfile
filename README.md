# Swap File Module
[![Build Status](https://travis-ci.org/Adaptavist/puppet-swapfile.svg?branch=master)](https://travis-ci.org/Adaptavist/puppet-swapfile)

## Overview

The **swapfile** adds a swap file. The default size is 1024MB. For more configuration details see init.pp

## Parameters:

 * swapon - Set to false to disable swap. Default is on (true)
 * swapfile_path - Defaults to /mnt which is a fast ephemeral filesystem on EC2 instances. This keeps performance reasonable while avoiding I/O charges on EBS.
 * swapfile_size - Size of the swapfile in MB. Defaults to 1024MB
 * perm_mount - Set to false to disable perm mount. Default is on (true)
 * mount_options - Mount options. Defaults to 'defaults'


## Sample Usage:

```
    swapfile::swapon: true
    swapfile::swapfile_path: '/mnt/swap.1'
    swapfile::swapfile_size: 2048
    swapfile::perm_mount: true
    swapfile::mount_options: 'defaults'

```

## Dependencies

'puppetlabs/stdlib', '>= 2.4.0'

