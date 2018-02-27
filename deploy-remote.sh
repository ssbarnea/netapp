#!/bin/bash
set -euxo pipefail

REMOTE_HOST=rhos-slave-04
REMOTE_PATH=/root/netapp/
IMG=DataONTAPv

echo "INFO:	Converting ..."
qemu-img convert -O qcow2 ${IMG}.vmdk ${IMG}.qcow2

echo "INFO:	Rsync to remote ..."
rsync -ahv . --exclude '*.gz' --exclude '*.vmdk' --exclude '*.ova' ${REMOTE_HOST}:${REMOTE_PATH}

echo "INFO:	Upload image to openstack cloud ..."
ssh -t $REMOTE_HOST "cd ${REMOTE_PATH} && OS_CLOUD=core-ci-tools openstack image create --file ${IMG}.qcow2 ${IMG}"
