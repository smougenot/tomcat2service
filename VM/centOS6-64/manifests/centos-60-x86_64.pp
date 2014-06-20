  
  # Time Zone
  file {
  '/etc/timezone':
    ensure => link,
    target => '/usr/share/zoneinfo/Europe/Paris';
  '/etc/localtime':
    ensure => link,
    target => '/usr/share/zoneinfo/Europe/Paris';
  }
  
  # Be welcomming as a VM
  file { '/etc/motd':
    content => "Welcome to your Vagrant-built virtual machine ${::hostname}!\n  With Puppet.\nA ${::operatingsystem} island in the sea of ${::domain}.\n"
  }
  
  # Be a fast learner (learn to install given packages at vm building)
  exec { 'yum_install_booster':
    command => 'yum localinstall -y /vagrant/*.rpm',
	path    => '/usr/bin',
	onlyif  => "find /vagrant -name '*.rpm'"
  }
