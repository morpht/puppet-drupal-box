Vagrant.configure("2") do |config|
  config.vm.box = "trusty64"
  # for vagrant ver < 1.5 the 'ubuntu/trusty64' box form does not work, we need a box_url:
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
  #
  config.vm.hostname = "pdbox"
  config.vm.synced_folder ".", "/opt/puppet-drupal-box"

  # ====================================
  # NFS shared folder for /srv/www/vhost
  # On ubuntu, you need to install nfs support:
  # sudo apt-get install nfs-common nfs-kernel-server
  # Mac should have this by default.
  config.vm.synced_folder "./vhost", "/srv/www/vhost", type: "nfs"
  # ===

  config.vm.provision :shell, :path => "./provision.sh"

  config.vm.network :forwarded_port, host: 8822, guest: 22
  config.vm.network :private_network, ip: "10.8.8.99"

#  config.vm.provider "virtualbox" do |v|
#      v.memory = 1024
#  end

end
