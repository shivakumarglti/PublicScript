#!/bin/bash
echo 
# read -p "username: " user_name
# read -sp "password: " password
sudo hostnamectl set-hostname $hostname
sudo sed -i 's/.*VM_IP.*/VM_IP $hostname.endurancebermuda.net $hostname/' /etc/hosts
sudo sed -i '/^search.*/a nameserver 10.0.0.15' /etc/resolv.conf
sudo sed -i 's/search/search endurancebermuda.net/g' /etc/resolv.conf
sudo yum install realmd sssd sssd-tools samba packagekit adcli chrony krb5-workstation -y
sudo -- sh -c "echo 'server endurancebermuda.net' >> /etc/chrony.conf"
sudo systemctl restart chronyd.service
sudo timedatectl
sudo chronyc sources
echo $domainadmin_password | kinit -V admin.skg@endurancebermuda.net
echo $domainadmin_password | sudo realm join --verbose --user=admin.skg endurancebermuda.net
sudo sed -i 's/use_fully_qualified_names = True/use_fully_qualified_names = False/g' /etc/sssd/sssd.conf
sudo sed -i 's/.*fallback_homedir.*/fallback_homedir = \/home\/%u/g' /etc/sssd/sssd.conf
sudo sh -c "echo 'entry_cache_timeout = 900' >> /etc/sssd/sssd.conf"
sudo systemctl start sssd.service
sudo realm permit -g AccAdminSecOpsServers@endurancebermuda.net
sudo realm permit -g domain\ admins@endurancebermuda.net
sudo sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd.service
sudo systemctl restart sssd.service
sudo sh -c "echo '%AccAdminSecOpsServers@endurancebermuda.net ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"
sudo sh -c "echo '%domain\ admins@endurancebermuda.net ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"