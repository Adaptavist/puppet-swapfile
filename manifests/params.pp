# Class: swapfile::params

class swapfile::params {
    $swapon = 'true'
    $swapfile_path = '/mnt/swap.1'
    $swapfile_size = '1024'
    $perm_mount = 'true'
    $mount_options = 'defaults'
}
