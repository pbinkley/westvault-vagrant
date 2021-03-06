#!/bin/bash

pushd $HOME

	# OC Dev tool
	git clone https://github.com/owncloudarchive/ocdev.git
	pushd ocdev
		make -q install
	popd

	# configure apache
	cp /vagrant/configs/apache/apache.owncloud.conf /etc/apache2/sites-available/owncloud.conf
	ln -s /etc/apache2/sites-available/owncloud.conf /etc/apache2/sites-enabled/owncloud.conf
	service apache2 restart

	# get the OC code 
	wget --quiet https://download.owncloud.org/community/owncloud-9.1.7.tar.bz2
	tar -xjf owncloud-9.1.7.tar.bz2
	mv owncloud /var/www/owncloud
	chown -R vagrant:vagrant /var/www/owncloud

	# set up a database
	mysql -e "CREATE USER 'owncloud'@'localhost'"
	mysql -e "CREATE DATABASE owncloud"
	mysql -e "GRANT ALL ON owncloud.* TO 'owncloud'@'localhost'"
	mysql -e "SET PASSWORD FOR owncloud@localhost = PASSWORD('occ123')"
	mysql -e "FLUSH PRIVILEGES"

	# install owncloud
	
	pushd /var/www/owncloud
		
		chmod a+x occ
		./occ maintenance:install \
			--no-interaction \
			--database=mysql --database-name=owncloud \
			--database-user=owncloud --database-pass=occ123 \
			--admin-user=admin --admin-pass=admin

		./occ config:system:set debug --value=true
		./occ config:system:set pln_site_url --value=http://localhost:8181/westvaultpln/api/sword/2.0/sd-iri
		./occ config:system:set overwrite.cli.url --value=http://localhost:8181/owncloud
		
		# add the westvault app.
		git clone https://github.com/ubermichael/westvault.git apps/westvault
		chown -R vagrant:vagrant apps/westvault
		
		pushd apps/westvault
			/usr/local/bin/composer --no-progress install
		popd
		./occ app:enable westvault 
	
		
		OC_PASS=corey   ./occ user:add --password-from-env --group=uvic corey
		OC_PASS=mark    ./occ user:add --password-from-env --group=sfu mark
		OC_PASS=michael ./occ user:add --password-from-env --group=sfu michael
		
		chown -R www-data:www-data config data
		setfacl -R -m u:www-data:rwX -m u:vagrant:rwX config data
		setfacl -dR -m u:www-data:rwX -m u:vagrant:rwX config data

		# add some users.	
	popd

popd
