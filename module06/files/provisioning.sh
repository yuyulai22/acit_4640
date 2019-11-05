#configure firewall settings
configure_firewall(){
    firewall-cmd --zone=public --add-service=http;
	firewall-cmd --zone=public --add-service=https;
	firewall-cmd --zone=public --add-service=ssh;
	firewall-cmd --runtime-to-permanent;
}

#create todoapp user, install and configure app
app_setup(){
    useradd -d /home/todoapp -m todoapp;
    cd /home/todoapp/;
    rm -rf  *;
    mkdir app;
    git clone https://github.com/timoguic/ACIT4640-todo-app.git /home/todoapp/app;
    chown -R todoapp:todoapp /home/todoapp/app;
    chmod a+rx /home/todoapp;
    cd /home/todoapp/app && npm install;
    sed -r -i 's/CHANGEME/acit4640/g' /home/todoapp/app/config/database.js
    cp /home/admin/database.js /home/todoapp/app/config/database.js;
    cp /home/admin/todoapp.service /lib/systemd/system;
    cp /home/admin/nginx.conf /etc/nginx/nginx.conf;
}

#enable and start services
production_setup() {
    systemctl enable mongod;
    systemctl start mongod;
    systemctl enable nginx;
    systemctl start nginx;
    systemctl daemon-reload;
    systemctl enable todoapp;
    systemctl start todoapp;
    systemctl restart nginx;
    systemctl restart todoapp;
}

setenforce  0
sed -r -i 's/SELINUX=(enforcing|disabled)/SELINUX=permissive/' /etc/selinux/config;
configure_firewall
app_setup
production_setup