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

# We are going to replace the flannel network pods.
cat > flannel.sh <<EOF
#!/bin/sh
export KUBECONFIG=\$(pwd)/admin.conf
# deploy flannel
curl -sL https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml |awk '1;/kube-subnet-mgr/{ print "        - --iface=enp0s8";}' | kubectl apply -f -
EOF
chmod +x flannel.sh
# make it available from host OS
cp -f flannel.sh /vagrant
