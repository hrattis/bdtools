###############################################cabeza
cabeza='<VirtualHost 192.168.4.50:443>\n
\t        ServerName apps-fb.cba.brandigital.com\n
\t         ServerAdmin it@brandigital.com\n
\t #        ServerAlias www.priceless.com.mx mc-priceless.live.ec2us.brandigital.com
\n
\t         DocumentRoot /var/www/test/\n
\n
\t         <Directory />\n
\t \t                 DirectoryIndex index.htm index.php\n
\t \t                 AllowOverride None\n
\t \t \t                 Options -Indexes\n
\t         </Directory>\n
\n
\t         SSLEngine on\n
\n
\t         SSLCertificateFile /var/lamp/security/certs/apps-fb.cba.brandigital.com/apps-fb.cba.brandigital.com.crt\n
\t         SSLCertificateKeyFile /var/lamp/security/certs/apps-fb.cba.brandigital.com/apps-fb.cba.brandigital.com_npp.key\n
\t         SSLCertificateChainFile /var/lamp/security/certs/apps-fb.cba.brandigital.com/gd_bundle.crt\n
\n
\t         <Proxy *>\n
\t \t                 AddDefaultCharset off\n
\t \t                 Order deny,allow\n
\t \t                 Deny from all\n
\t \t                 Allow from all\n
\t \t                 #Allow from  ssl.test.brandigital.com
\n
\t         </Proxy>\n
\t         ProxyRequests Off\n';






#####################pie#######################################

pie='\n \t       ErrorLog /var/log/apache2/error_fb_ssl.log\n
\n
\t        # Possible values include: debug, info, notice, warn, error, crit,
\n
\t        # alert, emerg.
\n
\t        LogLevel warn\n
\n
\t        CustomLog /var/log/apache2/access_fb_ssl.log combined\n
\t        ServerSignature On\n
</VirtualHost>\n
';

#####################################armado del config

echo -e $cabeza > /etc/apache2/sites-enabled/apps-fb.cba.brandigital.com-ssl

cat  /etc/apache2/sites-enabled/resources/* >> /etc/apache2/sites-enabled/apps-fb.cba.brandigital.com-ssl

echo -e $pie >> /etc/apache2/sites-enabled/apps-fb.cba.brandigital.com-ssl



/etc/init.d/apache2 reload




