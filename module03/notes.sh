#!/bin/bash
vbmg () { VBoxManage.exe "$@"; }
export PATH=/mnt/c/Program\ Files/Oracle/VirtualBox:$PATH


VM_NAME="VM_ACIT4640"
#vbmg modifyvm --name "$VM_NAME"
echo "vmname is" "$VM_NAME"


setup_system () { echo "Configuring system"; }
install_packages () { echo "Installing packages"; }
install_app () { echo "Installing app"; }
setup_app () { echo "Configuring app"; }

setup_system
install_packages
install_app
setup_app

echo "DONE!"



check_function() {
#echo "$1" "$2" "$3" "$@";
	if [ "$1" == "$VM_NAME" ]; then
		echo "called with vm name"
	else
		echo "not called with vm name: $1"
	fi
}

check_function "$VM_NAME"
check_function "wrong"


if [ -f "/mnt/c/Program\ Files/Oracle/VirtualBox/VBoxManage.exe" ]; then
	echo "VBoxManage exists"
#fi


#function() {
#	echo "1"
#	echo $VM_DIR
#}

#function() {
#	echo "2"
#	VM_DIR $(ls -l);
#}


#set -u
#VAR1=$(ls)

grep app_setup.sh <<< "VAR1"
echo "$VAR1" | grep app_setup.sh








echo "admin:password" :ichpasswd
openssl passwd


