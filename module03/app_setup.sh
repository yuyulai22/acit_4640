#!/bin/bash


VM_NAME="VM_ACIT4640"
setup_system () {
	echo "Configuring system";
	useradd admin;
	sed -r -i 's/^(%wheel\s+ALL=\(ALL\)\s+)(ALL)$/\1NOPASSWD: ALL/' /etc/sudoers;
	usermod -aG wheel admin;
	echo "admin:$6$9wb22kHYknGPuVcs$ur0kvmBAK7ig1sO1czmzFM7L9uAkqVs7DpBFWBJg7/Ql/jEePZf85TIeYEU4ISYlSKI5tnemzbK6VuQqrijaa1" | chpasswd -e;
	chown -R admin:admin .ssh;
	cat setup/acit_admin_id_rsa.pub >> ~admin/.ssh/authorized_keys
	ssh -copy_id -i "$VM_NAME" admin@localhost;
	 }

install_packages () {
	echo "Installing packages";
	yum install epel-release vim git tcpdump curl net-tools bzip2;
	yum update;
	#firewall config
	firewall-cmd --zone=public --add-service=http;
	firewall-cmd --zone=public --add-service=https;
	firewall-cmd --zone=public --add-service=ssh;
	firewall-cmd --runtime-to-permanent;
	#disable SELinux
	setenforce 0;
	sed -r -i 's/SELINUX=(enforcing|disabled)/SELINUX=permissive/' /etc/selinux/config;
	 }


install_app () {
	echo "Installing app";
	useradd -m -r todo-app && passwd -l todo-app;
	yum install nodejs npm;
	yum install mongodb-server;
	systemctl enable mongod && systemctl start mongod;
 }
setup_app () {
	echo "Configuring app";
	su - todo-app;
	mkdir app;
	cd app;
	git clone https://github.com/timoguic/ACIT4640-todo-app.git;
	npm install;
	cp -f setup/database.js config/database.js;
	curl -s localhost:8080/api/todos | jq;
	#production application setup
	yum install nginx;
	systemctl enable nginx;
	systemctl start nginx;
	#curl -s localhost/api/todos | jq;
	#curl -s localhost:50080/api/todos;
	cp setup/todoapp.service /lib/systemd/system;
	systemctl daemon-reload;
	systemctl enable todoapp;
	systemctl start todoapp;
	}

setup_system
install_packages
install_app
setup_app

echo "DONE!"
