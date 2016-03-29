require './vagrant-provision-reboot-plugin'

Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/trusty64"

  config.vm.provision "ansible" do |bootstrap|
    bootstrap.verbose = "v"
    bootstrap.playbook = "bootstrap.yml"
  end

  config.vm.provision :reboot

  config.vm.provision "ansible" do |uptime|
    uptime.verbose = "v"
    uptime.playbook = "uptime.yml"
  end

end