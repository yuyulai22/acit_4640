#!/bin/bash
#Yuyu Lai A00964030 ACIT 4640
#this script configures the project and security for booting the todo app

VM_NAME="VM_ACIT4640"
setup_system() {
    echo "Configuring system";
	useradd admin;
    echo "admin:$6$9wb22kHYknGPuVcs$ur0kvmBAK7ig1sO1czmzFM7L9uAkqVs7DpBFWBJg7/Ql/jEePZf85TIeYEU4ISYlSKI5tnemzbK6VuQqrijaa1" | chpasswd -e;
    usermod -aG wheel admin;
	sed -r -i 's/^(%wheel\s+ALL=\(ALL\)\s+)(ALL)$/\1NOPASSWD: ALL/' /etc/sudoers;
	}

install_packages() {
	echo "Installing packages";
	#firewall config
	firewall-cmd --zone=public --add-service=http;
	firewall-cmd --zone=public --add-service=https;
	firewall-cmd --zone=public --add-service=ssh;
	firewall-cmd --runtime-to-permanent;
	#disable SELinux
	setenforce 0;
	sed -r -i 's/SELINUX=(enforcing|disabled)/SELINUX=permissive/' /etc/selinux/config;
	mkdir ~/.ssh;
	chown -R admin:admin ~/.ssh/;
	cp /tmp/acit_admin_id_rsa.pub ~/.ssh/;
	chown admin:admin ~/.ssh/acit_admin_id_rsa.pub;
	 }


install_app() {
	echo "Installing app";
	useradd -m -r todo-app && passwd -l todo-app;
	yum -y install epel-release vim git tcpdump curl net-tools bzip2;
	yum -y update;
	yum -y install nodejs npm;
	yum -y install mongodb-server;
	yum -y install nginx;
 }
setup_app() {
	echo "Configuring app";
	#mkdir -p /home/todo-app/app;
	cd /home/todo-app/;
	mkdir app;
	git clone https://github.com/timoguic/ACIT4640-todo-app.git /home/todo-app/app;
	chown -R todo-app:todo-app /home/todo-app/app;
	chmod a+rx /home/todo-app;
	cd /home/todo-app/app && npm install;
	cp /tmp/database.js /home/todo-app/app/config/database.js;
	cp /tmp/todoapp.service /lib/systemd/system;
	cp /tmp/nginx.conf /etc/nginx/nginx.conf;
	systemctl enable mongod;
	systemctl start mongod;
	systemctl enable nginx;
	systemctl start nginx;
	systemctl daemon-reload;
	systemctl enable todoapp;
	systemctl start todoapp;
	}

setup_system
install_packages
install_app
setup_app

echo "DONE!"
