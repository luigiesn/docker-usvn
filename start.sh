#!/bin/sh

cd /

# if there is no CONFIG directory for usvn, create it 
if [ ! -e "/var/lib/svn/config" ]; then
	mkdir /var/lib/svn/config
	chown www-data:www-data /var/lib/svn/config
fi
# remove config folder and link it to a persistent CONFIG directory
rm -rf /usr/local/src/usvn-1.0.10/src/config
ln -s /var/lib/svn/config /usr/local/src/usvn-1.0.10/src/config

# if there is no FILES directory for usvn, create it 
if [ ! -e "/var/lib/svn/files" ]; then
	mkdir /var/lib/svn/files
	mkdir /var/lib/svn/files/svn

	chown www-data:www-data /var/lib/svn/files
	chown www-data:www-data /var/lib/svn/files/svn
fi
# remove config folder and link it to a persistent FILES directory
rm -rf /usr/local/src/usvn-1.0.10/src/files
ln -s /var/lib/svn/files /usr/local/src/usvn-1.0.10/src/files

# create a softlink to the USVN public folder  
if [ "x${USVN_SUBDIR}" = "x" ]; then
	rm -rf /var/www/html
	ln -s /usr/local/src/usvn-1.0.10/src/public /var/www/html
else
	mkdir -p /var/www/html${USVN_SUBDIR}
	chown www-data:www-data /var/www/html${USVN_SUBDIR}
	cd /var/www/html${USVN_SUBDIR}
	cd ../
	rmdir ./*
	ln -s /usr/local/src/usvn-1.0.10/src/public /var/www/html${USVN_SUBDIR}
fi

cd /

# Change apache settings 
cat << EOF > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
        <Directory /var/www/html>
                AllowOverride all
                Options -MultiViews 
                Order Deny,Allow
                Allow from all
                Require all granted
        </Directory>
        ErrorLog /var/log/apache2/error.log
        CustomLog /var/log/apache2/access.log combined
</VirtualHost>
EOF

cat << EOF > /etc/apache2/mods-enabled/dav_svn.conf
<Location ${USVN_SUBDIR}/svn/>
	ErrorDocument 404 default
	DAV svn
	Require valid-user
	SVNParentPath /usr/local/src/usvn-1.0.10/src/files/svn
	SVNListParentPath off
	AuthType Basic
	AuthName "USVN"
	AuthUserFile /usr/local/src/usvn-1.0.10/src/files/htpasswd
	AuthzSVNAccessFile /usr/local/src/usvn-1.0.10/src/files/authz
</Location>
EOF

cat << EOF > /usr/local/src/usvn-1.0.10/src/public/.htaccess
<Files *.ini>
Order Allow,Deny
Deny from all
</Files>

php_flag short_open_tag on
php_flag magic_quotes_gpc off

RewriteEngine on
#RewriteCond
RewriteBase "//"
RewriteCond %{REQUEST_FILENAME} -f [OR]
RewriteCond %{REQUEST_FILENAME} -l [OR]
RewriteCond %{REQUEST_FILENAME} -d
RewriteRule ^.*$ - [NC,L]
RewriteRule ^.*$ index.php [NC,L]
EOF

chown www-data:www-data /usr/local/src/usvn-1.0.10/src/public/.htaccess

a2enmod rewrite
/etc/init.d/apache2 restart

# show apache error log.
exec tail -f /var/log/apache2/error.log
