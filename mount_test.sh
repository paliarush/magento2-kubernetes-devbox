#!/usr/bin/env bash

mkdir -pv /var/test
chmod a+w /var/test
showmount -e 172.17.0.1
echo "Before Mount"
mount 172.17.0.1:/home/travis/build/paliarush/magento2-kubernetes-devbox/tests/tmp/test/magento2-vagrant /var/test
mount -l
echo "After Mount"
