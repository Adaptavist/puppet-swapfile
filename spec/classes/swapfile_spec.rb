require 'spec_helper'

  swapon = 'true'
  swapfile_path = '/mnt/swap.1'
  swapfile_size = '1024'

  cust_swapfile_path = '/mnt/swap.2'
  cust_swapfile_size = '2048'

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

      should contain_exec('Attach swap file').with(
            'command' => "/sbin/mkswap #{cust_swapfile_path} && /sbin/swapon #{cust_swapfile_path}",
            'require' => 'Exec[Create swap file]',
            'unless'  => "/sbin/swapon -s | grep #{cust_swapfile_path}",
      )
    end
  end
end
