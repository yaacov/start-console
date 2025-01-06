#!/bin/bash

set -ex

export NFS_IP_ADDRESS=$(ip route get 8.8.8.8 | awk '{ print $7 }' | head -1)
export NFS_SHARE="/home/nfsshare"

nfs_server_ip=NFS_IP_ADDRESS
nfs_share=NFS_SHARE

# Install latest csi-driver-nfs
curl -skSL https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/v4.2.0/deploy/install-driver.sh | bash -s v4.2.0 --


cat << EOF | kubectl apply -f -
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    storageclass.kubernetes.io/is-default-class: 'true'
  name: nfs-csi
provisioner: nfs.csi.k8s.io
parameters:
  server: ${nfs_server_ip}
  share: ${nfs_share}
  subDir: nfs-csi/\${pvc.metadata.namespace}/\${pvc.metadata.name}
  mountPermissions: "0777"
  # csi.storage.k8s.io/provisioner-secret is only needed for providing mountOptions in DeleteVolume
  csi.storage.k8s.io/provisioner-secret-name: "mount-options"
  csi.storage.k8s.io/provisioner-secret-namespace: "default"
reclaimPolicy: Delete
volumeBindingMode: Immediate
mountOptions:
---
kind: Secret
apiVersion: v1
metadata:
  name: mount-options
  namespace: default
data:
  mountOptions: bmZzdmVycz00LjE=
type: Opaque
EOF


