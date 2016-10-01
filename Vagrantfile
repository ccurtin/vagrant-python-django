# encoding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

# include YAML to parse the config file for user configurations.
require 'yaml'
config_file = YAML::load(File.open(File.expand_path(".././config.yml", __FILE__)))
vagrant_config = config_file['config'][config_file['config']['use']]

Vagrant.configure(2) do |config|

  # Install Vagrant Plugins
  required_plugins = %w(vagrant-hostsupdater vagrant-vbguest)
  plugin_installed = false
  required_plugins.each do |plugin|
    unless Vagrant.has_plugin?(plugin)
      system "vagrant plugin install #{plugin}"
      plugin_installed = true
    end
  end
  # If new plugins were installed, restart Vagrant process
  if plugin_installed === true
    exec "vagrant #{ARGV.join' '}"
  end

  # Vagrant base box
  config.vm.box = vagrant_config['base_box']

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. Not recommended.
  config.vm.box_check_update = true

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "http://localhost:{vagrant_config['access_port']}" will access port 80 on the guest machine
  config.vm.network "forwarded_port", guest: vagrant_config['guest_port'], host: vagrant_config['access_port'], :netmask => "255.255.0.0"

  config.vm.hostname = vagrant_config['hostname']
  # Create a private network, which allows host-only access to the machine using a specific IP.
  config.vm.network "private_network", ip: vagrant_config['ip'], auto_config: true
  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # 
  # config.vm.network "public_network", :bridge => "eth0", ip: "192.168.123.456", :netmask => "255.255.255.128", auto_config: false

  # Share an additional folder to the guest VM.
  # The first argument is the path on the host to the actual folder.
  # The second argument is the path on the guest to mount the folder.
  # And the optional third argument is a set of non-required options.
  config.vm.synced_folder './' + vagrant_config['synced_folder']['host'], vagrant_config['synced_folder']['guest'], create: true
 
  # This plugin adds an entry to your /etc/hosts file on the host system. This will remove on suspend.
  if Vagrant.has_plugin?('vagrant-hostsupdater')
    config.hostsupdater.remove_on_suspend = true
  end
  # Plugin keeps VM's guest additions in sync with virtualbox.
  if Vagrant.has_plugin?('vagrant-vbguest')
    config.vbguest.auto_update = false
  end

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose _provider-specific_ options.
  # 
  # VirtualBox Config:
  config.vm.provider :virtualbox do |vb|
    vb.name = vagrant_config['hostname']
    vb.memory = vagrant_config['memory'].to_i
    vb.cpus = vagrant_config['cpus'].to_i
    if 1 < vagrant_config['cpus'].to_i
      vb.customize ['modifyvm', :id, '--ioapic', 'on']
    end
    # max CPU execution on host.
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "65"]
    # DNS resolving.
    vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
    vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
  end
  #
  #
  # UNCOMMENT IF USING VMware instead of VirtualBox.
  # VMware FUSION Config (for MAC):
  # 
  #  config.vm.provider "vmware_fusion" do |v|
  #    v.vmx["memsize"] = vagrant_config['memory'].to_i
  #    v.vmx["numvcpus"] = vagrant_config['cpus'].to_i
  #  end
  #  # VMware WORKSTATION Config (for Windows):
  #  config.vm.provider "vmware_fusion" do |v|
  #    v.vmx["memsize"] = vagrant_config['memory'].to_i
  #    v.vmx["numvcpus"] = vagrant_config['cpus'].to_i
  #  end

  # Provision
  # remove notice `default: stdin: is not a tty` on vagrant up as not to confuse users of pseudo-error.
  config.vm.provision "shell", privileged: true, inline: <<-SHELL
    sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile
  SHELL
  
  # it is IMPORTANT that this is NOT run as root, but by the user "vagrant" with privileged commands.
  # Bootstrap folder is owned and accessible by "vagrant" user. Otherwise unable to copy bootstrap files over to VM bin.
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    # import Colors variables.
    sudo touch /bin/colors
    sudo chmod a+x /bin/colors
    sudo cp /vagrant/bootstrap/colors.sh /bin/colors
    sudo sed -i 's/\r//' /bin/colors
    
    # run script to improve PS1 prompt. Display virtualenv and current branch(*)
    sudo touch /bin/better_ps1
    sudo chmod a+x /bin/better_ps1
    sudo cp /vagrant/bootstrap/better_ps1.sh /bin/better_ps1
    sudo sed -i 's/\r//' /bin/better_ps1
    
    # run script to quickly add Python/Django environments
    sudo touch /bin/init_python_env
    sudo chmod a+x /bin/init_python_env
    sudo cp /vagrant/bootstrap/init_python_env.sh /bin/init_python_env
    sudo sed -i 's/\r//' /bin/init_python_env
    
    sudo touch /bin/manage_django_db
    sudo chmod a+x /bin/manage_django_db
    sudo cp /vagrant/bootstrap/manage_django_db.sh /bin/manage_django_db
    sudo sed -i 's/\r//' /bin/manage_django_db
    
    sudo touch /bin/manage_django_db_postgres
    sudo chmod a+x /bin/manage_django_db_postgres
    sudo cp /vagrant/bootstrap/manage_django_db_postgres.sh /bin/manage_django_db_postgres
    sudo sed -i 's/\r//' /bin/manage_django_db_postgres

  SHELL

  # run Shell commands, passing config variables to script.
  config.vm.provision :shell, :path => "./bootstrap/bootstrap.sh", :args => [
                                                                            vagrant_config['synced_folder']['host'],
                                                                            vagrant_config['guest_port'],
                                                                            vagrant_config['git_user_name'],
                                                                            vagrant_config['git_user_email']
                                                                          ]


end