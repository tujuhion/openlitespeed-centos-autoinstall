# Openlitespeed Auto install in Centos7

Tested and work with 2GB RAM VM in [Digitalocean](https://m.do.co/c/c0809edd09b1) and [Vultr](https://www.vultr.com/?ref=7083611)
## Usage
Copy and Paste this line in your fresh install Centos7
```
bash <( curl -k https://raw.githubusercontent.com/tujuhion/openlitespeed-centos-autoinstall/master/install.sh )
```

This scripts will install 
- Openlitespeed web server
- ProFTPD
- MariaDB 10.2
- PHP 7.2
- PHPMyAdmin 4.8.2
- Simple Scripts to start|stop|restart|reload openlitespeed web server
- Simple Scripts to create vhost

### Access Openlitespeed web server
```
https://yourhostorip:7080
```
before access, create your username and password with this command
```
/usr/local/lsws/admin/misc/admpass.sh
```
or
```
lsws admin
```

### Access PHPMyadmin
```
https://yourhostorip:8090
```
Your MariaDB root password is auto generated and stored in /root/.MariaDB

#### To Start Stop Web Server
This only symlink to /usr/local/lsws/bin/lswsctrl
```
lsws start
```
type 'lsws help' to list command
#### To create Vhosts
```
/scripts/lscreate
```
and fill your domain name, ftp username and ftp password.
#### To Install Let's Encrypt Certificate
```
/scripts/certbot
```
Enter your domain, and certificate is auto installed to your domain. Please make sure vhost create by /scripts/lscreate

Please refer this [link](https://www.indowebsite.co.id/kb/install-webserver-openlitespeed-pada-centos/) for installation in Bahasa Indonesia

Specialy Thank to [Web Hosting](https://www.indowebsite.co.id) Indonesia for support and donation.
