
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

#yum install -y yum-utils
#yum-config-manager --enable ol7_addons
#yum-config-manager --enable ol7_preview
#
#/usr/sbin/setenforce 0
#yum install -y docker-engine
#systemctl enable docker
#systemctl start docker
#yum install -y kubeadm
#iptables -P FORWARD ACCEPT
#/sbin/sysctl -p /etc/sysctl.d/k8s.conf
#
#cat /vagrant/my_password.txt | docker login --username bjarte.brandt@gmail.com --password-stdin container-registry.oracle.com
## join cluster
#TOKEN=$(cat /vagrant/token)
#CA_CERT_HASH=$(cat /vagrant/ca-cert-hash)
#export KUBE_REPO_PREFIX=container-registry.oracle.com/kubernetes& kubeadm-setup.sh join --token $TOKEN 10.0.18.10:6443 --discovery-token-ca-cert-hash sha256:${CA_CERT_HASH}
