#!/bin/bash

# configure the vagrant account for kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
# we want to run kubectl from VM host.
sudo cp -f /etc/kubernetes/admin.conf /vagrant/
