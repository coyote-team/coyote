# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "ubuntu/trusty64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network "forwarded_port", guest: 3000, host: 3000

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
   config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
     vb.memory = "2048"
     vb.cpus = "4"
   end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
   config.vm.provision "shell", inline: <<-SHELL
     apt-get update
     /usr/sbin/update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

     curl -sL https://deb.nodesource.com/setup | sudo bash -
     apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
     add-apt-repository 'deb http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.0/ubuntu trusty main'
     export DEBIAN_FRONTEND=noninteractive
     debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password password PASS'
     debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password_again password PASS'
     apt-get update
     apt-get install -y software-properties-common graphviz git libpq-dev gawk build-essential libreadline6-dev zlib1g-dev libssl-dev libyaml-dev autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev mariadb-server libmariadbclient-dev nodejs
     mysql -uroot -pPASS -e "SET PASSWORD = PASSWORD('');"
     apt-get upgrade -y

     sudo -i -u vagrant git clone git://github.com/sstephenson/rbenv.git ~vagrant/.rbenv
     sudo -i -u vagrant echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~vagrant/.bash_profile
     sudo -i -u vagrant echo 'eval "$(rbenv init -)"' >> ~vagrant/.bash_profile
     sudo -i -u vagrant exec $SHELL
     sudo -i -u vagrant git clone git://github.com/sstephenson/ruby-build.git ~vagrant/.rbenv/plugins/ruby-build
     sudo -i -u vagrant echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~vagrant/.bash_profile
     sudo -i -u vagrant exec $SHELL

     sudo -i -u vagrant rbenv install -v 2.2.2
     sudo -i -u vagrant rbenv global 2.2.2
     sudo -i -u vagrant echo "gem: --no-document" > ~vagrant/.gemrc

     sudo -i -u vagrant gem install bundler
     sudo -i -u vagrant gem install rails
     sudo -i -u vagrant rbenv rehash

     printf "Host *\nStrictHostKeyChecking no\n" >> ~vagrant/.ssh/config
     sudo -i -u vagrant BUNDLE_GEMFILE=/vagrant/Gemfile bundle install
     sudo -i -u vagrant BUNDLE_GEMFILE=/vagrant/Gemfile bundle update
sudo -i -u vagrant sh -c 'cd /vagrant && exec rake db:create db:migrate'
   SHELL
end
