#!/bin/bash
read -p "username: " user_name
read -sp "password: " password
sudo hostnamectl set-hostname centos7new1
sudo sed -i 's/.*10.0.0.95.*/10.0.0.95 centos7new1.personallab.local centos7new1/' /etc/hosts
sudo sed -i '/^search.*/a nameserver 10.0.0.15' /etc/resolv.conf
sudo sed -i 's/search/search personallab.local/g' /etc/resolv.conf
sudo yum install krb5-workstation -y
sudo yum install chrony -y
sudo yum install adcli -y
sudo yum install packagekit -y
sudo yum install samba -y
sudo yum install sssd-tools -y
sudo yum install sssd -y
sudo yum install realmd -y
sudo -- sh -c "echo 'server personallab.local' >> /etc/chrony.conf"
sudo systemctl restart chronyd.service
sudo timedatectl
sudo chronyc sources
echo $password | kinit -V $user_name@PERSONALLAB.LOCAL
echo $password | sudo realm join --verbose --user=$user_name PERSONALLAB.LOCAL
sudo sed -i 's/use_fully_qualified_names = True/use_fully_qualified_names = False/g' /etc/sssd/sssd.conf
sudo sed -i 's/.*fallback_homedir.*/fallback_homedir = \/home\/%u/g' /etc/sssd/sssd.conf
sudo sh -c "echo 'entry_cache_timeout = 900' >> /etc/sssd/sssd.conf"
sudo systemctl start sssd.service
sudo realm permit -g AccAdminSecOpsServers@PERSONALLAB.LOCAL
sudo realm permit -g domain\ admins@PERSONALLAB.LOCAL
sudo sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd.service
sudo systemctl restart sssd.service
sudo sh -c "echo '%AccAdminSecOpsServers@PERSONALLAB.LOCAL ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"
sudo sh -c "echo '%domain\ admins@PERSONALLAB.LOCAL ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"