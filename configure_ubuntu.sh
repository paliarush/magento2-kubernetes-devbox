#!/usr/bin/env bash

# Increase CPU to 2

## Install SSH
# sudo apt-get install -y openssh-server


## Install Docker
sudo apt-get update

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io
#sudo apt-get install -y docker-ce=18.06.3~ce~3-0~ubuntu docker-ce-cli=18.06.3~ce~3-0~ubuntu containerd.io

# Travis Yaml

sudo mount --make-rshared /

curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v1.13.0/bin/linux/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/

curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.30.0/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/

curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > get_helm.sh && chmod +x get_helm.sh && sudo ./get_helm.sh

sudo apt-get update && sudo apt-get install -y socat

sudo apt-get install -y nfs-kernel-server

sudo su
echo "export CHANGE_MINIKUBE_NONE_USER=true" >> /etc/profile

sudo swapoff -a

sudo apt-get install -y ebtables

# Defaults env_keep+="CHANGE_MINIKUBE_NONE_USER"
sudo visudo

#
#echo '{"dns": ["10.1.2.3", "8.8.8.8"]}' | sudo tee /etc/docker/daemon.json > /dev/null
#
## NFS configuration: "/home/travis/kube-travis" 192.0.0.0/8(rw,all_squash,no_subtree_check,anonuid=1000,anongid=1000)
## NFS configuration: "/home/travis/kube-travis" 172.17.0.0/16(rw,all_squash,no_subtree_check,anonuid=1000,anongid=1000)
## NFS configuration: "/home/travis/kube-travis" 172.17.0.9(rw,all_squash,no_subtree_check,anonuid=1000,anongid=1000)
## NFS configuration: "/home/travis/kube-travis" 172.0.0.0/255.0.0.0(rw)
## sudo mount -o vers=3,udp 172.17.0.1:"/home/travis/kube-travis" /var/mount
## sudo mount 172.17.0.1:/home/travis/kube /var/mount

## sudo mount -t nfs -o resvport 192.168.99.100:/home/travis/kube /Users/oleksandrpaliarush/m
#
## mount -t nfs 172.17.0.1:/home/travis/kube-travis /var/lib/kubelet/pods/fc487a10-4c3d-11e9-9d9d-0800271ab608/volumes/kubernetes.io~nfs/magento2-monolith-volume
## mount -t nfs 172.17.0.1:/home/travis/kube /var/mount
## docker run --rm -it --network bridge willfarrell/ping sh

## Optional: /etc/NetworkManager/NetworkManager.conf comment out # dns=dnsmasq
## Install rpcbind in the container

#mount -t nfs 172.17.0.1:/home/travis/kube /var/mount
# sudo docker run --rm -it --privileged d3fk/nfs-client sh

## mkdir /m && mount -t nfs 172.17.0.1:/home/travis/kube-travis /m
