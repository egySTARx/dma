#!/bin/bash
clear
echo "$COL_GREEN Radius Manager installer script for CENTOS 6.x 32bit"
echo "Copyright 2004-2013, DMA Softlab LLC"
echo "All right reserved.. $COL_RESET"
echo "$COL_GREEN Script modified by Syed Jahanzaib for CENTOS and MaGeek egySTARx"

# Colors Config  . . . [[ JZ . . . ]]
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"

# Variables & Paths [jz]
wwwpath="/var/www/html"
radhost="localhost"
myusr_rad="radius"
mypsw_radius="radius123"
ctshost="localhost"
myusr_cts="conntrack"
mypsw_cts="conn123"
radusr="root"
httpusr="apache"

# MySQL ROOT Password , Change this variable according to your own setup if required. . . [[ JZ . . . ]]
sqlpass="meem"
# Update centos repos
curl https://www.getpagespeed.com/files/centos6-eol.repo --output /etc/yum.repos.d/CentOS-Base.repo
yum -y update
yum -y install epel-release
yum -y update

# RM Installation Package Download URL , Change this variable according to your own setup , if required. . . [[ JZ . . . ]]
#rmurl="http://wifismartzone.com/files/rm_related"
#Google Drive link is more reliable
#rmurl="http://talhaali.byethost13.com/files/rm_related/”"

# Temporary Folder where all software will be downloaded . . . [[ JZ . . . ]]
temp="temp"

# Packages which will be installed as pre requisite and to make your life easier
PKG="nano wget git unzip curl net-tools lsof mc make gcc libtool-ltdl curl httpd mysql-server mysql-devel net-snmp net-snmp-utils php php-mysql php-gd php-snmp php-process sendmail mailutils mailx sendmail-bin sendmail-cf cyrus-sasl-plain perl perl-Net-SSLeay openssl perl-IO-Tty perl-Encode-Detect phpmyadmin pptpd system-config-network-tui sntp ntpdate"

# Turn off iptables and disabled
echo -e "$COL_GREEN Disabling iptables service, $COL_RESET"
service iptables stop
chkconfig iptables off

echo -e "$COL_GREEN Disabling IPv6 to avoid slow link issue $COL_RESET"
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf

# Turn off SELINUX andd disable it on boot
echo -e "$COL_GREEN Disabling SELINUX & setting it disabled on boot ... $COL_RESET"
echo 0 > /selinux/enforce
sed -i "s/=enforcing/=disabled/g" /etc/selinux/config

# Installing WGET which is not in default installation of CENTOS 6.5 Minimal [jz]
sleep 3
echo -e "$COL_GREEN Installing WGET to fetch required tools later ... $COL_RESET"
yum install -y wget
cd /
wget https://f34b-50-61-238-139.in.ngrok.io/meemradius//temp.tar.gz
tar zxvf temp.tar.gz
# Checking if /temp folder is previously present or not . . .
{
if [ ! -d "/temp" ]; then
echo
echo -e "$COL_RED /temp folder not found, Creating it so all downloads will be placed here  . . . $COL_RESET"
mkdir /$temp
else
echo
echo -e "$COL_GREEN /temp folder is already present , so no need to create it, Proceeding further . . . $COL_RESET"
echo
fi
}

cd /temp/
wget https://f34b-50-61-238-139.in.ngrok.io/meemradius//freeradius-server-2.2.0-dma-patch-2.tar.gz
wget https://f34b-50-61-238-139.in.ngrok.io/meemradius//ioncube_loaders_lin_x86.tar.gz
wget https://f34b-50-61-238-139.in.ngrok.io/meemradius//libmcrypt-2.5.8-9.el6.i686.rpm
wget https://f34b-50-61-238-139.in.ngrok.io/meemradius//php-mcrypt-5.3.2-3.el6.i686.rpm
wget https://f34b-50-61-238-139.in.ngrok.io/meemradius//webmin-2.001-1.noarch.rpm
wget https://f34b-50-61-238-139.in.ngrok.io/meemradius//radiusmanager-4.1.6.tgz
# Clearing Old downloads in /temp to avoid DUPLICATIONS . . .
#echo -e "$COL_RED Clearing Old downloads in /temp to avoid DUPLICATIONS . . . $COL_RESET"

#rm -fr /$temp/radiusmanager*.*
#rm -fr /$temp/freeradius*.*
#rm -fr /$temp/libltd*.*
#rm -fr /$temp/ioncube*.*
#rm -fr /$temp/php-my*
#rm -fr /$temp/libmy*
#rm -fr /$temp/rm4.txt

# Checking IF $rmurl is accessible m if YES then continue further , otherwise EXIT the script with ERROR ! [[ JZ .. . .]]
#echo -e "$COL_GREEN Checking if zaib Google Drive or other URL to download requires  packages is accessible in order to proceed further. . .!! $COL_RESET"
#sleep 3
cd /$temp
#wget -q $rmurl/rm4.txt
#{
#if [ ! -f /$temp/rm4.txt ]; then
#echo
#echo -e "$COL_RED ERROR: Unable to contact $rmurl, or possibly internet is not working or your IP is in black list at destination server  !! $COL_RESET"
#echo -e "$COL_RED ERROR: Please check manual if $rmurl is accessible or not or if it have required files, JZ  !! $COL_RESET"
#exit 0
#fi
#}

######################

#echo -e "$COL_GREEN $url accessible $COL_RESET ......OK......"
#echo -e "$COL_GREEN Downloading RADIUS MANAGER 4.1.6 package from INTERNET  .  (Press CTRL+C to stop any time) $COL_RESET"
#wget $rmurl/radiusmanager-4.1.6.tgz
# Checking if RM installation file have been downloaded. if YES continue further , otherwise EXIT the script with ERRO ! [[ JZ .. . .]]
{
if [ ! -f /$temp/radiusmanager-4.1.6.tgz ]; then
echo .
echo -e "$COL_RED ERROR: RM Installation File could not be download or found in /$temp ! $COL_RESET"
exit 0
fi
}

echo -e "$COL_GREEN Installing some tools and other rpe requisite for the application ... ! $COL_RESET"
yum install -y $PKG
echo -e "$COL_GREEN YUM install/update Done.! $COL_RESET"

echo -e "$COL_GREEN Installing LIBMYCRYPT and PHPMCRYPT ... ! $COL_RESET"
#wget $rmurl/libmcrypt-2.5.8-9.el6.i686.rpm
#wget $rmurl/php-mcrypt-5.3.2-3.el6.i686.rpm
rpm -i libmcrypt-2.5.8-9.el6.i686.rpm
rpm -i php-mcrypt-5.3.2-3.el6.i686.rpm
sleep 3

# IONCUBE Installation:
# Now Download ioncube library and add it to php  . . . [[ JZ . . . ]]
echo .
echo -e "$COL_GREEN Installing IONCUBE  .  (Press CTRL+C to stop any time) $COL_RESET"
#wget http://www.dmasoftlab.com/cont/download/ioncube_loaders_lin_x86.tar.gz

# Checking if IONCUBE installation file have been downloaded. if YEs continue further , otherwise EXIT the script with ERROR ! [[ JZ .. . .]]
{
if [ ! -f /$temp/ioncube_loaders_lin_x86.tar.gz ]; then
echo .
echo -e "$COL_RED ERROR: COULD NOT DOWNLOAD IONCUBE !!! EXITING . . .  $COL_RESET"
exit 0
fi
}

tar zxvf ioncube_loaders_lin_x86.tar.gz
mkdir /usr/local/ioncube
cp -fr /$temp/ioncube/* /usr/local/ioncube/

# Now Add the appropriate ionCube loader to your php.ini . . . [JZ]
echo .
echo -e "$COL_GREEN Adding iONCUBE extension in PHP config file  .  (Press CTRL+C to stop any time) $COL_RESET"
echo "zend_extension=/usr/local/ioncube/ioncube_loader_lin_5.3.so" >> /etc/php.ini
echo .
echo -e "$COL_GREEN Downloading FREERADiUS 2.2.20-dma-patch-2 package  .  (Press CTRL+C to stop any time) $COL_RESET"
#wget http://dmasoftlab.com/cont/download/freeradius-server-2.2.0-dma-patch-2.tar.gz

# Checking if FREERADIUS is downloaded, just to make sure internet is working ,IF NOT, EXIT the script with ERROR ! [[ JZ .. . .]]
{
if [ ! -f /$temp/freeradius-server-2.2.0-dma-patch-2.tar.gz ]; then
echo .
echo -e "$COL_RED ERROR: COULD NOT DOWNLOAD FREERADIUS 2.2.20-dma-patch-2, possible INTERNET is not Working !!! EXITING . . .  $COL_RESET"
exit 0
fi
}

echo .
echo -e "$COL_GREEN Starting to Compile FREERADIUS  ...  (Press CTRL+C to stop any time) $COL_RESET"
sleep 3

cd /$temp
tar zxvf freeradius-server-2.2.0-dma-patch-2.tar.gz
cd /$temp/freeradius-server-2.2.0/

### Now proceed with the compilation of FREERAIDUS , applicable for all
./configure
make
make install
ldconfig
echo -e "$COL_GREEN Starting FREERADIUS by radiusd -xx coommand & start radius service.  (Press CTRL+C to stop any time) $COL_RESET"
radiusd -xx
radiusd -X
service radiusd start
sleep 3

# ================================================================
# Creating MySQL databases with MySQL command line tool . . . [JZ]
# ================================================================
# ** FROM CLI ** . . . [JZ]
echo -e "$COL_GREEN Starting MYSQLD servuce to create Radius Manager Database.  (Press CTRL+C to stop any time) $COL_RESET"
echo -e "$COL_GREEN MYSQL password is set to   'meem'  $COL_RESET"
service mysqld start
mysqladmin -u root password 'meem'
echo .
echo -e "$COL_GREEN adding RADIUS user & DB in MYSQL  .  (Press CTRL+C to stop any time) $COL_RESET"
mysql -u root -p$sqlpass -e "create database radius";
mysql -u root -p$sqlpass -e "create database conntrack";
mysql -u root -p$sqlpass -e "CREATE USER '$myusr_rad'@'$radhost' IDENTIFIED BY '$mypsw_radius';"
mysql -u root -p$sqlpass -e "CREATE USER '$myusr_cts'@'$radhost' IDENTIFIED BY '$mypsw_cts';"
mysql -u root -p$sqlpass -e "GRANT ALL ON radius.* TO radius@$radhost;"
mysql -u root -p$sqlpass -e "GRANT ALL ON conntrack.* TO conntrack@$radhost;"

# UNTAR Copy WEB content

echo "$COL_GREEN Copying Radius Manager WEB content to $wwwpath/radiusmanager $COL_RESET"
cd /$temp
tar zxvf radiusmanager-4.1.6.tgz
mkdir $wwwpath/radiusmanager
cp -fr /$temp/radiusmanager-4.1.6/www/radiusmanager $wwwpath
sleep 3

# rename .dist files

mv $wwwpath/radiusmanager/config/paypal_cfg.php.dist $wwwpath/radiusmanager/config/paypal_cfg.php
mv $wwwpath/radiusmanager/config/netcash_cfg.php.dist $wwwpath/radiusmanager/config/netcash_cfg.php
mv $wwwpath/radiusmanager/config/authorizenet_cfg.php.dist $wwwpath/radiusmanager/config/authorizenet_cfg.php
mv $wwwpath/radiusmanager/config/dps_cfg.php.dist $wwwpath/radiusmanager/config/dps_cfg.php
mv $wwwpath/radiusmanager/config/2co_cfg.php.dist $wwwpath/radiusmanager/config/2co_cfg.php
mv $wwwpath/radiusmanager/config/payfast_cfg.php.dist $wwwpath/radiusmanager/config/payfast_cfg.php

# set ownership and permissions

chown $httpusr $wwwpath/radiusmanager/config
chown $httpusr $wwwpath/radiusmanager/config/system_cfg.php
chown $httpusr $wwwpath/radiusmanager/config/paypal_cfg.php
chown $httpusr $wwwpath/radiusmanager/config/netcash_cfg.php
chown $httpusr $wwwpath/radiusmanager/config/authorizenet_cfg.php
chown $httpusr $wwwpath/radiusmanager/config/dps_cfg.php
chown $httpusr $wwwpath/radiusmanager/config/2co_cfg.php
chown $httpusr $wwwpath/radiusmanager/config/payfast_cfg.php
mkdir -p $wwwpath/radiusmanager/tmpimages
chown $httpusr $wwwpath/radiusmanager/tmpimages
chown $httpusr $wwwpath/radiusmanager/tftpboot
chmod 600 $wwwpath/radiusmanager/config/system_cfg.php
chmod 600 $wwwpath/radiusmanager/config/paypal_cfg.php
chmod 600 $wwwpath/radiusmanager/config/netcash_cfg.php
chmod 600 $wwwpath/radiusmanager/config/authorizenet_cfg.php
chmod 600 $wwwpath/radiusmanager/config/dps_cfg.php
chmod 600 $wwwpath/radiusmanager/config/2co_cfg.php
chmod 600 $wwwpath/radiusmanager/config/payfast_cfg.php
chmod 644 $wwwpath/radiusmanager/config/docsis_keyfile
chmod 644 $wwwpath/radiusmanager/config/docsis_template

# chmod and copy binaries
cd /$temp/radiusmanager-4.1.6/
echo "Copying binaries to /usr/local/bin"
chmod 755 bin/rm*
cp bin/rm* /usr/local/bin

echo "Copying rootexec to /usr/local/sbin"
cp bin/rootexec /usr/local/sbin
chmod 4755 /usr/local/sbin/rootexec

# chmod and copy radiusmanager.cfg

echo "Copying radiusmanager.cfg to /etc"
cp etc/radiusmanager.cfg /etc
chown $radusr /etc/radiusmanager.cfg
chmod 600 /etc/radiusmanager.cfg

# create Tables

echo -e "$COL_GREEN Creating MYSQL Table $COL_RESET"
mysql -h $radhost -u $myusr_rad -p$mypsw_radius radius < sql/radius.sql
mysql -h $radhost -u $myusr_cts -p$mypsw_cts conntrack < sql/conntrack.sql

# create rmpoller service
echo "Enabling rmpoller service at boot time"
cp rc.d/rmpoller /etc/init.d
chown root.root /etc/init.d/rmpoller
chmod 755 /etc/init.d/rmpoller
chkconfig --add rmpoller

# create rmconntrack service
echo "Enabling rmconntrack service at boot time"
cp rc.d/rmconntrack /etc/init.d
chown root.root /etc/init.d/rmconntrack
chmod 755 /etc/init.d/rmconntrack
chkconfig --add rmconntrack

# copy radiusd init script

echo "$COL_GREEN Enabling radiusd service at boot time $COL_RESET"
chmod 755 rc.d/redhat/radiusd
cp rc.d/redhat/radiusd /etc/init.d
chkconfig --add radiusd

# copy logrotate script
echo "Copying logrotate script"
cp etc/logrotate.d/radiusd /etc/logrotate.d/radiusd

# copy cron job script
echo "$COL_GREEN Copying cronjob script $COL_RESET"
cp etc/cron/radiusmanager /etc/cron.d/radiusmanager
chmod 644 /etc/cron.d/radiusmanager

# comment out the old style cron job
sed -i 's/02\ 0\ \*\ \*\ \*\ root\ \/usr\/bin\/php/#2\ 0\ \*\ \*\ \*\ root\ \/usr\/bin\/php/g' /etc/crontab

# set permission on raddb files
echo "$COL_GREEN Setting permission on raddb files $COL_RESET"
chown $httpusr /usr/local/etc/raddb
chown $httpusr /usr/local/etc/raddb/clients.conf
sleep 3

echo -e "$COL_GREEN Re-Starting Apache2, Radius Service & add them in startup... $COL_RESET"
service httpd restart
chkconfig --add mysqld
chkconfig --add httpd
chkconfig --add radiusd
chkconfig mysqld on
chkconfig httpd on
chkconfig radiusd on

#cp /temp/lic.txt $wwwpath/radiusmanager
#cp /temp/mod.txt $wwwpath/radiusmanager
cd /$temp
rpm -U webmin-2.001-1.noarch.rpm

mkdir /var/www/html/s/
git clone https://github.com/librespeed/speedtest.git
cd speedtest
sudo cp -R backend example-singleServer-gauges.html *js /var/www/html/s/
cd /var/www/html/s/
sudo mv example-singleServer-gauges.html index.html
sed -i "s/LibreSpeed Example/TechnoMeeM Speed Test/g" /var/www/html/s/index.html
sed -i "s/Source code/TechnoMeeM/g" /var/www/html/s/index.html
sed -i "s/github.com\/librespeed\/speedtest/technomeem.blogspot.com/g" /var/www/html/s/index.html
sudo -v ; curl https://rclone.org/install.sh | sudo bash
sleep 3
# Enable Backup Database
mkdir -P /var/meem/
cp -r /temp/backupcentos.sh /var/meem/
chmod +x /var/meem/backupcentos.sh

#write out current crontab
crontab -l > mycron
#echo new cron into cron file
echo "00 02 * * * /var/meem/backupcentos.sh  > /var/log/backup.log 2>&1" >> mycron
#install new cron file
crontab mycron
rm mycron


cd /temp/main/
cp -r assets images speed pdf meem.apk index.html /var/www/html/
#sed -i "s/كونكت/نور نت/g" /var/www/html/radiusmanager/hotspot/alarm.html
#sed -i "s/00000000000/012/g" /var/www/html/radiusmanager/hotspot/alarm.html
#sed -i "s/00000000000/012/g" /var/www/html/radiusmanager/hotspot/cut.html
#sed -i "s/كونكت/نور نت/g" /var/www/html/radiusmanager/hotspot/cut.html
# Enable ppptp server
wget https://raw.githubusercontent.com/egySTARx/dma/main/pptp.sh
sudo sh pptp.sh
sleep 3
service pptpd restart
chkconfig pptpd on
rm -rf /temp/
rm -rf /temp.tar.gz
history -c
echo .
echo .
echo .
echo .
echo .
echo -e "$COL_GREEN All Done. Kindly RESTART the system one time to maek sure everything is ok on reboot."
echo -e "Please access ADMIN panel via http://yourip/radiusmanager/admin.php $COL_RESET"
echo -e "Installation completed for CENTOS by $COL_RED SYED JAHANZAIB / MaGeek egySTARx TechnoMeeM $COL_RESET"
