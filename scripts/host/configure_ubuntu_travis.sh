#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && devbox_dir=$PWD

cd "${devbox_dir}"
sudo ./scripts/host/configure_nfs_exports.sh
cp ./tests/include/configuration.sh.dist ./tests/include/configuration.sh
sed -i "s|git@github.com:|https://github.com/|g" ./etc/config.yaml.dist
sed -i "s|git@github.com:|https://github.com/|g" ./tests/_files/*
sed -i "s|php_executable=\"php\"|php_executable=\"/home/travis/.phpenv/shims/php\"|g" ./scripts/host/get_path_to_php.sh
# TODO: Make configurable and enable for specific tests
# sed -i "s|git clone|git clone --depth 1 |g" ./init_project.sh
sed -i "s|minikube start -v=0 --cpus=2 --memory=4096|sudo minikube start -v=0 --cpus=2 --memory=4096  --vm-driver=none --bootstrapper=kubeadm --kubernetes-version=v1.13.0|g" ./init_project.sh
sed -i "s|&& eval \$(minikube docker-env) ||g" ./scripts/host/k_rebuild_environment.sh
sed -i "s/use_nfs:\ 1/use_nfs:\ 0/g" ./etc/config.yaml.dist
sed -i "s/nfs_server_ip:\ \"0\.0\.0\.0\"/nfs_server_ip:\ \"$(ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+')\"/g" ./etc/config.yaml.dist
echo "${COMPOSER_AUTH}" > ./etc/composer/auth.json
