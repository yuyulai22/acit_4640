#!/bin/bash -x
vbmg () { VBoxManage.exe "$@"; }
export PATH=/mnt/c/Program\ Files/Oracle/VirtualBox:$PATH
setup_system () { 
	echo "Configuring system";
	vbmg modifyvm --ostype RedHat_64 --cpus 1 --memory 1024 --nic1 natnetwork --cableconnected on --nat-network1 "net_4640" --audio none;
	vbmg storagectl --add sata;
	vbmg storageattach "VM_ACIT4640_scripts"
	useradd admin;
	passwd P@ssw0rd;

 }
install_packages () { 
	echo "Installing packages";
	yum install epel-release vim git tcpdump curl net-tools bzip2;
	yum update;
 }
install_app () { echo "Installing app"; }
setup_app () { 
echo "Configuring app";

 }

setup_system
install_packages
install_app
setup_app

echo "DONE!"
