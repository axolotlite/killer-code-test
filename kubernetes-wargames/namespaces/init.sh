#!/bin/bash

mkdir /var/lib/k8s-manifest-backup

cp -r /etc/kubernetes/manifests/* /var/lib/k8s-manifest-backup/

# kubectl apply -f /tmp/init/