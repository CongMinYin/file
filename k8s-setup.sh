#! /bin/bash

#Prepare
swapoff -a
systemctl status apparmor.service
systemctl disable apparmor.service

#-------------------------------------------------------------#
#Docker Installation

##Remove old version
apt-get remove docker docker-engine docker.io containerd runc

##setup apt environments
apt-get update
apt-get install \
    apt-transport-https\
    ca-certificates \
    gnupg-agent \
    software-properties-common -y

##add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  apt-key add -

##set up the stable repository
 add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

##Installation
 apt-get update
 apt-get install docker-ce docker-ce-cli containerd.io

#-------------------------------------------------------------#
#Kubernetes Installation

##installing kubeadm, kubelet and kubectl
apt-get install -y apt-transport-https 
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get install -y kubelet=1.15.3-00 kubeadm=1.15.3-00 kubectl=1.15.3-00
apt-mark hold kubelet kubeadm kubectl

##restart kubelet
systemctl daemon-reload
systemctl restart kubelet

##create master node
kubeadm reset
kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address 10.239.48.145 --node-name master --ignore-preflight-errors=all

##configure env
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config -y
chown $(id -u):$(id -g) $HOME/.kube/config

export KUBECONFIG=/etc/kubernetes/admin.conf

##pod network add-on
wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f kube-flannel.yml

##control plane node isolation
kubectl taint nodes --all node-role.kubernetes.io/master-
