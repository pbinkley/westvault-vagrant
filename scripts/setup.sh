!/bin/bash

apt-get -y update
apt-get -y upgrade

passwordless mysql root
debconf-set-selections <<< "mysql-server mysql-server/root_password password \"''\""
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password \"''\""

basics.
apt-get -y install git vim wget curl emacs24-nox 

LAMP
apt-get -y install apache2 php5 php5-dev php5-xsl php5-curl php5-cli php5-intl mysql-client mysql-server

staging server
apt-get -y install clamav clamav-daemon nodejs nodejs-dev npm php-pear

freshclam
/etc/init.d/clamav-daemon start

npm install --global --silent bower
pear install Archive_Tar > /dev/null

curl -Ss https://getcomposer.org/installer | php -- --quiet --install-dir=/usr/local/bin --filename=composer
