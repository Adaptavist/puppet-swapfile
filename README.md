# Swap File Module

## Overview

The **swapfile** adds a swap file. The default size is 1024MB. For more configuration details see init.pp

## Parameters:

 * swapon - Set to false to disable swap. Default is on (true)
 * swapfile_path - Defaults to /mnt which is a fast ephemeral filesystem on EC2 instances. This keeps performance reasonable while avoiding I/O charges on EBS.
 * swapfile_size - Size of the swapfile in MB. Defaults to 1024MB


## Sample Usage:

```
    swapfile::swapon: true
    swapfile::swapfile_path: '/mnt/swap.1'
    swapfile::swapfile_size: 2048

```

## Dependencies

'puppetlabs/stdlib', '>= 2.4.0'

