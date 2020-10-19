require 'spec_helper'

  swapon = 'true'
  swapfile_path = '/mnt/swap.1'
  swapfile_size = '1024'

  cust_swapfile_path = '/mnt/swap.2'
  cust_swapfile_size = '2048'

  mount_options = 'defaults'

describe 'swapfile', :type => 'class' do
    
  context "Should create and attach swap file by default" do
    it do
      should contain_exec('Create swap file').with(
            'command'     => "/bin/dd if=/dev/zero of=#{swapfile_path} bs=1M count=#{swapfile_size}",
            'creates'     => swapfile_path,
      )

      should contain_exec('Attach swap file').with(
            'command' => "/sbin/mkswap #{swapfile_path} && /sbin/swapon #{swapfile_path}",
            'require' => 'Exec[Create swap file]',
            'unless'  => "/sbin/swapon -s | grep #{swapfile_path}",
      )

      should contain_file(swapfile_path).with(
            'mode'  => '0600',
            'owner' => 'root',
            'group' => 'root',
      )
    end
  end

  context "Should detach swap file with swapon set to false" do
    let(:params){{ :swapon => false }}
    it do
      should contain_exec('Detach swap file').with(
            'command' => "/sbin/swapoff #{swapfile_path}",
            'onlyif'  => "/sbin/swapon -s | grep #{swapfile_path}",
      )

      should contain_file(swapfile_path).with(
            'ensure'  => 'absent',
            'backup'  => false,
            'require' => 'Exec[Detach swap file]',
      )
    end
  end

  context "Should create and attach swap file with custom params" do
    let(:params){{ 
      :swapon => swapon,
      :swapfile_path => cust_swapfile_path,
      :swapfile_size => cust_swapfile_size,
       }}
    it do
      should contain_exec('Create swap file').with(
            'command'     => "/bin/dd if=/dev/zero of=#{cust_swapfile_path} bs=1M count=#{cust_swapfile_size}",
            'creates'     => cust_swapfile_path,
      )

      should contain_file(cust_swapfile_path).with(
            'mode'  => '0600',
            'owner' => 'root',
            'group' => 'root',
      )

      should contain_exec('Attach swap file').with(
            'command' => "/sbin/mkswap #{cust_swapfile_path} && /sbin/swapon #{cust_swapfile_path}",
            'require' => 'Exec[Create swap file]',
            'unless'  => "/sbin/swapon -s | grep #{cust_swapfile_path}",
      )
    end
  end

  context "Should ensure swapfile is present in fstab when swapped on" do
    let(:params){{ 
      :swapon => swapon,
      :swapfile_path => cust_swapfile_path,
      :swapfile_size => cust_swapfile_size,
      :perm_mount => true,
      :mount_options => mount_options,
       }}
    it do
      should contain_mount(cust_swapfile_path).with(
            'ensure'  => 'present',
            'fstype'  => 'swap',
            'device'  => cust_swapfile_path,
            'options' => mount_options,
            'dump'    => '0',
            'pass'    => '0',
            'require' => 'Exec[Attach swap file]',
      )
    end
  end

  context "Should ensure swapfile is not present in fstab when swapped on" do
    let(:params){{ 
      :swapon => swapon,
      :swapfile_path => cust_swapfile_path,
      :swapfile_size => cust_swapfile_size,
      :perm_mount => false,
      :mount_options => mount_options,
       }}
    it do
      should contain_mount(cust_swapfile_path).with(
            'ensure'  => 'absent',
            'fstype'  => 'swap',
            'device'  => cust_swapfile_path,
            'options' => mount_options,
            'dump'    => '0',
            'pass'    => '0',
            'require' => 'Exec[Attach swap file]',
      )
    end
  end

  context "Should ensure swapfile is not present in fstab when swapped off" do
    let(:params){{ 
      :swapon => false,
      :swapfile_path => cust_swapfile_path,
      :swapfile_size => cust_swapfile_size,
      :perm_mount => true,
      :mount_options => mount_options,
       }}
    it do
      should contain_mount(cust_swapfile_path).with(
            'ensure'  => 'absent',
            'fstype'  => 'swap',
            'device'  => cust_swapfile_path,
            'options' => mount_options,
            'dump'    => '0',
            'pass'    => '0',
            'require' => 'Exec[Detach swap file]',
      )
    end
  end

end
