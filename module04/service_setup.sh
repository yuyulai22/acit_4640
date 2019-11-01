#!/bin/bash
#Yuyu Lai A00964030 ACIT 4640
#this script sets up the network and the pxe server

vbmg () { VBoxManage.exe "$@"; }
export PATH=/mnt/c/Program\ Files/Oracle/VirtualBox:$PATH

NETNAME="net_4640"
VM_NAME="VM_ACIT4640"
PXE_NAME="PXE_4640"

clean_all(){
	vbmg natnetwork remove --netname "$NETNAME"
	vbmg unregistervm "$VM_NAME" --delete
}

#setting up network
create_network(){
  vbmg natnetwork add --netname "$NETNAME" --network "192.168.250.0/24" --enable
  vbmg natnetwork modify --netname "$NETNAME" --ipv6 off --dhcp off
  vbmg natnetwork start --netname "$NETNAME"
  vbmg natnetwork modify \
    --netname "$NETNAME" --port-forward-4 "ssh:tcp:[]:50022:[192.168.250.10]:22"
  vbmg natnetwork modify \
    --netname "$NETNAME" --port-forward-4 "http:tcp:[]:50080:[192.168.250.10]:80"
  vbmg natnetwork modify \
    --netname "$NETNAME" --port-forward-4 "https:tcp:[]:50443:[192.168.250.10]:443"
}

#create vm
create_vm(){
  vbmg createvm --name "$VM_NAME" --ostype RedHat_64 --register
  SED_PROGRAM="/^Config file:/ { s/^.*:\s\+\(\S\+\)/\1/; s|\\\\|/|gp }"
  VBOX_FILE=$(vbmg showvminfo "$VM_NAME" | sed -ne "$SED_PROGRAM")
  VM_DIR=$(dirname "$VBOX_FILE")
  vbmg modifyvm "$VM_NAME" --cpus 1 --memory 1600 --nic1 natnetwork --nat-network1 "$NETNAME" \
   --audio none --boot1 disk --boot2 net --boot3 none --boot4 none
  vbmg createmedium disk --filename "${VM_DIR}/VM_ACIT4640.vdi" --size 10000 --format VDI
  vbmg storagectl "$VM_NAME" --name SATA --add sata --portcount 2 --bootable on
  vbmg storageattach "$VM_NAME" --storagectl SATA --device 0 --port 0  --type hdd --medium "${VM_DIR}/VM_ACIT4640.vdi"
  vbmg storagectl "$VM_NAME" --name IDE --add ide
  vbmg storageattach "$VM_NAME" --storagectl IDE --device 0 --port 0  --type hdd --medium emptydrive
}

#setup pxe
setup_pxe(){
  vbmg natnetwork modify \
    --netname "$NETNAME" --port-forward-4 "ssh2:tcp:[]:50222:[192.168.250.200]:22"
  vbmg startvm "$PXE_NAME"
  while /bin/true; do
        ssh -i ~/.ssh/acit_admin_id_rsa -p 50222 \
            -o ConnectTimeout=2 -o StrictHostKeyChecking=no \
            -q admin@localhost exit
        if [ $? -ne 0 ]; then
                echo "PXE server is not up, sleeping..."
                sleep 2
        else
                break
        fi
  done
  echo "START COPYING"
  scp -i ~/.ssh/acit_admin_id_rsa -P 50222 -o ConnectTimeout=4 -o StrictHostKeyChecking=no ks.cfg admin@localhost:/home/admin/
  scp -i ~/.ssh/acit_admin_id_rsa -P 50222 -o ConnectTimeout=4 -o StrictHostKeyChecking=no sudoers admin@localhost:/home/admin/
  ssh -i ~/.ssh/acit_admin_id_rsa -p 50222 -o ConnectTimeout=4 -o StrictHostKeyChecking=no admin@localhost "sudo mv /home/admin/ks.cfg /var/www/lighttpd/ks.cfg"
  ssh -i ~/.ssh/acit_admin_id_rsa -p 50222 -o ConnectTimeout=4 -o StrictHostKeyChecking=no admin@localhost "sudo mv /home/admin/sudoers /var/www/lighttpd/"
  echo "COPYING APP_SETUP FILES"
  scp -i ~/.ssh/acit_admin_id_rsa -P 50222 -o ConnectTimeout=4 -o StrictHostKeyChecking=no -r setup admin@localhost:/home/admin/
  scp -i ~/.ssh/acit_admin_id_rsa -P 50222 -o ConnectTimeout=4 -o StrictHostKeyChecking=no app_setup.sh admin@localhost:/home/admin/
  ssh -i ~/.ssh/acit_admin_id_rsa -p 50222 -o ConnectTimeout=4 -o StrictHostKeyChecking=no admin@localhost "sudo mv /home/admin/app_setup.sh /var/www/lighttpd/"
  ssh -i ~/.ssh/acit_admin_id_rsa -p 50222 -o ConnectTimeout=4 -o StrictHostKeyChecking=no admin@localhost "sudo mv /home/admin/setup/database.js /var/www/lighttpd/"
  ssh -i ~/.ssh/acit_admin_id_rsa -p 50222 -o ConnectTimeout=4 -o StrictHostKeyChecking=no admin@localhost "sudo mv /home/admin/setup/nginx.conf /var/www/lighttpd/"
  ssh -i ~/.ssh/acit_admin_id_rsa -p 50222 -o ConnectTimeout=4 -o StrictHostKeyChecking=no admin@localhost "sudo mv /home/admin/setup/todoapp.service /var/www/lighttpd/"
  ssh -i ~/.ssh/acit_admin_id_rsa -p 50222 -o ConnectTimeout=4 -o StrictHostKeyChecking=no admin@localhost "sudo mv /home/admin/setup/acit_admin_id_rsa.pub /var/www/lighttpd/"
  echo "DONE COPYING"
}


start_vm(){
  echo "STARTING ACIT 4640 VM";
  vbmg startvm "$VM_NAME";
}

clean_all
create_network
create_vm
setup_pxe
start_vm