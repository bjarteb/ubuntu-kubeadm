# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "ubuntu/bionic64"

MASTER_IP="10.0.19.10"
MASTER_PORT="8443"
NUM_NODES="1".to_i()

post_up_msg = <<-MSG
    ------------------------------------------------------
    Kubernetes cluster: master #{MASTER_IP}, #{NUM_NODES} nodes
    master (m): vagrant ssh m
    workers (w): vagrant ssh w1, vagrant ssh w2, etc... 

    Connect to cluster

    $ export KUBECONFIG=$(pwd)/admin.conf
    $ kubectl get nodes

    Replace flannel daemonset.
    $ ./flannel.sh
    ------------------------------------------------------
MSG

  config.hostmanager.enabled = true
  config.hostmanager.manage_guest = true

  # create k8s control plane(s)
  (1..3).each do |i|
    config.vm.define "m#{i}" do |node|
      node.vm.hostname = "m#{i}"
      node.vm.network :private_network, ip: "10.0.19.1#{i}"
      node.vm.network "forwarded_port", guest: 6443, host: "6443#{i}"
      node.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", 2048]
      end
      node.vm.provision "ansible" do |ansible|
        ansible.extra_vars = { ansible_python_interpreter:"/usr/bin/python3" }
        ansible.become = true
        ansible.playbook = "provisioning/install_controlplane.yml"
      end
    end
  end

 # create k8s worker nodes
  (1..3).each do |i|
    config.vm.define "w#{i}" do |node|
      node.vm.hostname = "w#{i}"
      node.vm.network :private_network, ip: "10.0.19.2#{i}"
      node.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", 2048]
      end
      node.vm.provision "ansible" do |ansible|
        ansible.extra_vars = { ansible_python_interpreter:"/usr/bin/python3" }
        ansible.become = true
        ansible.playbook = "provisioning/install_controlplane.yml"
      end
    end
  end
  #config.vm.post_up_message = post_up_msg

  config.vm.define "a" do |cntr|
    cntr.vm.hostname = "a"
    cntr.vm.network "private_network", ip: "10.0.19.9"
    cntr.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", 512]
    end
    cntr.vm.provision "ansible" do |ansible|
      ansible.playbook = 'provisioning/controller.yml'
      ansible.extra_vars = { ansible_python_interpreter:"/usr/bin/python3" }
      ansible.become = true
    end
  end

end
