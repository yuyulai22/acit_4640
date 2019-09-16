#!/bin/bash -x
vbmg () { VBoxManage.exe "$@"; }
export PATH=/mnt/c/Program\ Files/Oracle/VirtualBox:$PATH

#setting up network
vbmg natnetwork add --netname net_4640 --network "192.168.250.0/24" --enable
vbmg natnetwork modify --netname net_4640 --ipv6 off
vbmg natnetwork modify --netname net_4640 --dhcp off
vbmg natnetwork start --netname net_4640
vbmg natnetwork modify \
  --netname net_4640 --port-forward-4 "ssh:tcp:[]:50022:[192.168.250.10]:22"
vbmg natnetwork modify \
  --netname net_4640 --port-forward-4 "http:tcp:[]:50080:[192.168.250.10]:80"
vbmg natnetwork modify \
  --netname net_4640 --port-forward-4 "https:tcp:[]:50443:[192.168.250.10]:443"

#create vm
vbmg createvm --name "VM_ACIT4640_mod2" --ostype RedHat_64 --register
VM_NAME="VM_ACIT4640_mod2"
SED_PROGRAM="/^Config file:/ { s/^.*:\s\+\(\S\+\)/\1/; s|\\\\|/|gp }"
VBOX_FILE=$(vbmg showvminfo "$VM_NAME" | sed -ne "$SED_PROGRAM")
VM_DIR=$(dirname "$VBOX_FILE")

#vm specifications
vbmg modifyvm "VM_ACIT4640_mod2" --cpus 1 --memory 1024 --nic1 natnetwork --nat-network1 net_4640 --audio none
vbmg createmedium disk --filename "${VM_DIR}/VM_ACIT4640_mod2.vdi" --size 10000 --format VDI
vbmg storagectl "VM_ACIT4640_mod2" --name SATA --add sata --portcount 2 --bootable on
vbmg storageattach "VM_ACIT4640_mod2" --storagectl SATA --device 0 --port 0  --type hdd --medium "${VM_DIR}/VM_ACIT4640_mod2.vdi"
vbmg storagectl "VM_ACIT4640_mod2" --name IDE --add ide
vbmg storageattach "VM_ACIT4640_mod2" --storagectl IDE --device 0 --port 0  --type hdd --medium emptydrive
