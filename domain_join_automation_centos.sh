#!/bin/bash
read -p "username: " user_name
read -sp "password: " password
sudo hostnamectl set-hostname shivsbxltst9001
sudo -- sh -c "echo '10.244.5.33 shivsbxltst9001.ENDURANCEBERMUDA.NET shivsbxltst9001' >> /etc/hosts"
sudo sed -i '/^search.*/a nameserver 10.125.3.60' /etc/resolv.conf
sudo sed -i '/^search.*/a nameserver 10.122.5.30' /etc/resolv.conf
sudo sed -i 's/search/search ENDURANCEBERMUDA.NET/g' /etc/resolv.conf
sudo yum install krb5-workstation -y
sudo yum install chrony -y
sudo yum install adcli -y
sudo yum install packagekit -y
sudo yum install samba -y
sudo yum install sssd-tools -y
sudo yum install sssd -y
sudo yum install realmd -y
sudo yum install oddjob -y
sudo yum install oddjob-mkhomedir -y
sudo yum install openldap-clients -y
sudo -- sh -c "echo 'server ENDURANCEBERMUDA.NET' >> /etc/chrony.conf"
sudo systemctl restart chronyd.service
sudo timedatectl
sudo chronyc sources
echo $password | kinit -V $user_name@ENDURANCEBERMUDA.NET
echo $password | sudo realm join --verbose ENDURANCEBERMUDA.NET
sudo sed -i 's/use_fully_qualified_names = True/use_fully_qualified_names = False/g' /etc/sssd/sssd.conf
sudo sed -i 's/.*fallback_homedir.*/fallback_homedir = \/home\/%u/g' /etc/sssd/sssd.conf
sudo sh -c "echo 'entry_cache_timeout = 900' >> /etc/sssd/sssd.conf"
sudo systemctl start sssd.service
sudo realm permit -g AccAdminSecOpsServers@ENDURANCEBERMUDA.NET
sudo realm permit -g domain\ admins@ENDURANCEBERMUDA.NET
sudo sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd.service
sudo systemctl restart sssd.service
sudo sh -c "echo '%AccAdminSecOpsServers@ENDURANCEBERMUDA.NET ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"
sudo sh -c "echo '%domain\ admins@ENDURANCEBERMUDA.NET ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"
