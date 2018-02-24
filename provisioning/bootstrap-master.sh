#!/bin/bash
apt-get update
apt-get install -y docker.io

apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl

sysctl net.bridge.bridge-nf-call-iptables=1
kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address 10.0.19.10

kubeadm token list | awk 'NR==2 { print $1; }' > /vagrant/token
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //' > /vagrant/ca-cert-hash

export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
kubectl get pods --all-namespaces
