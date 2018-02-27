#!/bin/bash
set -euxo pipefail

REMOTE_HOST=leno
REMOTE_PATH=/root/netapp/
IMG=DataONTAPv

echo "INFO:	Converting ..."
qemu-img convert -O qcow2 ${IMG}.vmdk ${IMG}.qcow2

echo "INFO:	Rsync to remote ..."
rsync -ahv . --exclude '*.gz' --exclude '*.vmdk' --exclude '*.ova' ${REMOTE_HOST}:${REMOTE_PATH}

echo "INFO:	Start netapp using virsh ..."

ssh -t $REMOTE_HOST << EOF
set -x
virsh destroy netapp
virsh undefine netapp
BRIDGE=`brctl show | grep -v 'bridge name' | cut -f1`
virt-install --connect qemu:///system --ram 16384 -n netapp --os-type=linux --os-variant=generic  \
    --network=bridge:${BRIDGE},model=e1000 \
    --disk path=/root/netapp/DataONTAPv.qcow2,device=disk,format=qcow2 --vcpus=4 --graphics vnc,listen=0.0.0.0,password=rhos --noautoconsole --import
virsh vncdisplay netapp
echo "Connect to vnc://`hostname -I | cut -d' ' -f1`:5900"
EOF
