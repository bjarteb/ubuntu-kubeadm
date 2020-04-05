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

  # create load balancer node
  config.vm.define :lb do |node|
    node.vm.hostname = "lb"
    node.vm.network :private_network, ip: "10.0.19.10"
    node.vm.network "forwarded_port", guest: 80, host: 21987
    node.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", 512]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    end
    node.vm.provision "ansible" do |ansible|
      ansible.extra_vars = { ansible_python_interpreter:"/usr/bin/python3" }
      ansible.become = true
      ansible.playbook = "provisioning/install_loadbalancer.yml"
    end
  end

  # create k8s control plane(s)
  (1..3).each do |i|
    config.vm.define "m#{i}" do |node|
      node.vm.hostname = "m#{i}"
      node.vm.network :private_network, ip: "10.0.19.1#{i}"
      node.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", 1024]
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      end
      node.vm.provision "ansible" do |ansible|
        ansible.extra_vars = { ansible_python_interpreter:"/usr/bin/python3" }
        ansible.become = true
        ansible.playbook = "provisioning/install_controlplane.yml"
      end
      #node.vm.provision :shell, path: "provisioning/bootstrap-master.sh"
      #node.vm.provision :shell, path: "provisioning/configure-vagrant-user.sh", privileged: false
    end
  end

  # create k8s worker nodes
  (1..1).each do |i|
    config.vm.define "w#{i}" do |node|
      node.vm.hostname = "w#{i}"
      node.vm.network :private_network, ip: "10.0.19.2#{i}"
      node.vm.network "forwarded_port", guest: 80, host: "918#{i}"
      node.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", 1024]
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      end
      node.vm.provision "ansible" do |ansible|
        ansible.extra_vars = { ansible_python_interpreter:"/usr/bin/python3" }
        ansible.become = true
        ansible.playbook = "provisioning/install_controlplane.yml"
      end
    end
  end
  #config.vm.post_up_message = post_up_msg

  config.vm.define :a do |node|
    node.vm.hostname = "a"
    node.vm.network "private_network", ip: "10.0.19.9"
    node.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", 512]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
    end
    node.vm.provision "ansible" do |ansible|
      ansible.playbook = 'provisioning/controller.yml'
      ansible.extra_vars = { ansible_python_interpreter:"/usr/bin/python3" }
      ansible.become = true
    end
  end

end
