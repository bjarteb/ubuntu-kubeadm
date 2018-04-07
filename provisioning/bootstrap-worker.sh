
apt-get update
apt-get install -y docker.io

apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl

# join cluster
TOKEN=$(cat /vagrant/token)
CA_CERT_HASH=$(cat /vagrant/ca-cert-hash)
kubeadm join --token $TOKEN 10.0.19.10:6443 --discovery-token-ca-cert-hash sha256:${CA_CERT_HASH}

/sbin/ip ro add 10.96.0.0/12 dev enp0s8
