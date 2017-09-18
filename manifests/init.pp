# This is modified from https://gist.github.com/Yggdrasil/3918632
# Class: swapfile
#
# This class manages swapspace on a node.
#
# == Parameters:
#
# [*swapon*]
#  Set to false to disable swap. Default is on (true)
# [*swapfile_path*]
#  Defaults to /mnt which is a fast ephemeral filesystem on EC2 instances.
#  This keeps performance reasonable while avoiding I/O charges on EBS.
# [*swapfile_size*]
#  Size of the swapfile in MB. Defaults to 1024MB
# [*perm_mount*]
#  Set to false to disable perm mount. Default is on (true)
# [*mount_options*]
#  Mount options. Defaults to 'defaults'
#
# Actions:
#   Creates and mounts a swapfile.
#   Umounts and removes a swapfile.
#
# Sample Usage:
#   class { 'swapfile':
#     ensure => present,
#   }
#
#   class { 'swapfile':
#     ensure => absent,
#   }
#
#   If you have the swapsizeinbytes fact (see Requires), you could also do:
#     if $::swapsizeinbytes == 0 {
#         include swapfile
#     }
#
class swapfile(
    $swapon           = $swapfile::params::swapon,
    $swapfile_path    = $swapfile::params::swapfile_path,
    $swapfile_size    = $swapfile::params::swapfile_size,
    $perm_mount       = $swapfile::params::perm_mount,
    $mount_options    = $swapfile::params::mount_options,
) inherits swapfile::params {

    if str2bool($swapon) {
        exec { 'Create swap file':
            command => "/bin/dd if=/dev/zero of=${swapfile_path} bs=1M count=${swapfile_size}",
            creates => $swapfile_path,
        }

        exec { 'Attach swap file':
            command => "/sbin/mkswap ${swapfile_path} && /sbin/swapon ${swapfile_path}",
            require => Exec['Create swap file'],
            unless  => "/sbin/swapon -s | grep ${swapfile_path}",
        }

        if str2bool($perm_mount) {
            mount { $swapfile_path:
                ensure  => present,
                fstype  => swap,
                device  => $swapfile_path,
                options => $mount_options,
                dump    => 0,
                pass    => 0,
                require => Exec['Attach swap file'],
            }
        } 
        else {
            mount { $swapfile_path:
                ensure  => absent,
                fstype  => swap,
                device  => $swapfile_path,
                options => $mount_options,
                dump    => 0,
                pass    => 0,
            }            
        }
    }
    else {
        exec { 'Detach swap file':
            command => "/sbin/swapoff ${swapfile_path}",
            onlyif  => "/sbin/swapon -s | grep ${swapfile_path}",
        }

        file { $swapfile_path:
            ensure  => absent,
            require => Exec['Detach swap file'],
        }
        
        mount { $swapfile_path:
            ensure  => absent,
            fstype  => swap,
            device  => $swapfile_path,
            options => $mount_options,
            dump    => 0,
            pass    => 0,
        }
    }
}
