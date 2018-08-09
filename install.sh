#!/bin/bash
# Random Password Generator
TEMPRANDSTR=
function getRandPassword
{
    dd if=/dev/urandom bs=8 count=1 of=/tmp/randpasswdtmpfile >/dev/null 2>&1
    TEMPRANDSTR=`cat /tmp/randpasswdtmpfile`
    rm /tmp/randpasswdtmpfile
    local DATE=`date`
    TEMPRANDSTR=`echo "$TEMPRANDSTR$RANDOM$DATE" |  md5sum | base64 | head -c 16`
}
getRandPassword
ROOTSQLPWD=$TEMPRANDSTR

# Update
wget -O /etc/yum.repos.d/MariaDB.repo https://raw.githubusercontent.com/tujuhion/docker-centos-openlitespeed-wordpress/master/repo/MariaDB.repo
yum -y install epel-release wget
yum -y update
rpm -ivh http://rpms.litespeedtech.com/centos/litespeed-repo-1.1-1.el7.noarch.rpm

# Install Proftpd
yum -y install proftpd
sed -i "s/ProFTPD server/$HOSTNAME/g" /etc/proftpd.conf

#Install Openlitespeed & MariaDB
mkdir /home/defdomain
mkdir /home/defdomain/html
mkdir /home/defdomain/logs
yum -y install openlitespeed
yum -y install MariaDB-server MariaDB-client

# Install PHP 72
yum -y install lsphp72 lsphp72-common lsphp72-mysqlnd lsphp72-process lsphp72-gd lsphp72-mbstring lsphp72-mcrypt lsphp72-opcache lsphp72-bcmath lsphp72-pdo lsphp72-xml lsphp72-json lsphp72-zip lsphp72-xmlrpc lsphp72-pecl-mcrypt

#Setting Up
mv -f /usr/local/lsws/conf/vhosts/Example/ /usr/local/lsws/conf/vhosts/defdomain/
rm -f /usr/local/lsws/conf/vhosts/defdomain/vhconf.conf
rm -f /usr/local/lsws/conf/httpd_config.conf
rm -f /usr/local/lsws/admin/conf/admin_config.conf
wget -O /usr/local/lsws/conf/vhosts/defdomain/vhconf.conf https://raw.githubusercontent.com/tujuhion/autoinstall/master/conf/vhconf.conf
wget -O /usr/local/lsws/conf/httpd_config.conf https://raw.githubusercontent.com/tujuhion/autoinstall/master/conf/httpd_config.conf
wget -O /usr/local/lsws/admin/conf/admin_config.conf https://raw.githubusercontent.com/tujuhion/autoinstall/master/conf/admin_config.conf
chown lsadm:lsadm /usr/local/lsws/conf/vhosts/defdomain/vhconf.conf
chown lsadm:lsadm /usr/local/lsws/conf/httpd_config.conf
chown lsadm:lsadm /usr/local/lsws/admin/conf/admin_config.conf
touch /home/defdomain/html/.htaccess
cat << EOT > /home/defdomain/html/index.php
echo "Domain name (Without www):"
read DOMAIN
echo FTP Username :
read USERNAME
echo Password :
read PASSWORD
HOMEDIR="/home/$DOMAIN"
SERVERROOT="/usr/local/lsws"
DOMAINCONF="$SERVERROOT/conf/templates/$DOMAIN.conf"
# Create directory
mkdir $HOMEDIR
mkdir $HOMEDIR/{html,logs}
mkdir $SERVERROOT/conf/vhosts/$DOMAIN
mkdir $SERVERROOT/conf/cert/$DOMAIN
# Create file
touch $HOMEDIR/html/.htaccess
cp $SERVERROOT/conf/templates/incl.conf $SERVERROOT/conf/templates/$DOMAIN.conf
cp $SERVERROOT/conf/templates/vhconf.conf $SERVERROOT/conf/vhosts/$DOMAIN/vhconf.conf
sed -i "s/##DOMAIN##/$DOMAIN/g" $SERVERROOT/conf/templates/$DOMAIN.conf
sed -i "s/##DOMAIN##/$DOMAIN/g" $SERVERROOT/conf/vhosts/$DOMAIN/vhconf.conf
#sed -i "s/defdomain[[:space:]][*]/$DOMAIN defdomain */g" $SERVERROOT/conf/httpd_config.conf
sed -i "s/##END_ALL_VHOST##/cat \/usr\/local\/lsws\/conf\/templates\/$DOMAIN.conf/e" $SERVERROOT/conf/httpd_config.conf
rm -f $DOMAINCONF
cat << EOT > $HOMEDIR/html/index.php
<?php
echo "Its Works!";
?>
EOT
chown -R nobody:nobody /home/defdomain/html/
firewall-cmd --zone=public --permanent --add-port=21/tcp
firewall-cmd --zone=public --permanent --add-port=80/tcp
firewall-cmd --zone=public --permanent --add-port=443/tcp
firewall-cmd --zone=public --permanent --add-port=7080/tcp
firewall-cmd --reload

#Setting MySQL
systemctl start mariadb && systemctl start proftpd && /usr/local/lsws/bin/lswsctrl start && 
mysql -uroot -v -e "use mysql;update user set Password=PASSWORD('$ROOTSQLPWD') where user='root'; flush privileges;"

# Save Password root MariaDB
cat << EOT > /root/.MariaDB
$ROOTSQLPWD
EOT

systemctl enable proftpd
systemctl enable mariadb
