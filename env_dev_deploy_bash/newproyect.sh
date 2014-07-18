#!/bin/bash

# un poco de ayuda, deben existir un argumento, si no manda ayuda
if [ $# -lt 1 ]
then

   echo "*** ERROR ***"
   echo "uso: ${0##*/} identificador_del_proyecto"
   echo "ejemplo: ./${0##*/} prominente"
   exit

fi

# Parametros
IPROYECT=$1 
ID_YEAR=($(date | awk '{print $6}'))
YEAR=$(date +%Y)

# Const
DIRWP="/var/lamp/files/projects/"$YEAR
URL=".dev.cba.brandigital.com"
PLANTILLA="/root/script/plantilla_ldap"
#PLANTILLA="/root/script/plantilla"
DPASS="/var/lamp/files/security"
FPASS="passwd"
DA2ASITE="/etc/apache2/sites-available/devel"
DA2ESITE="/etc/apache2/sites-enabled/devel"

#Obteniendo nombre del cliente y la region
corte=`expr index $IPROYECT -`
let "corte -= 1"
CLIENTE=`expr substr $IPROYECT 1 $corte`
let "corte += 2"
REGION=`expr substr $IPROYECT $corte 2`

#estructura
DIRES[0]='Domains/site/public'
DIRES[1]='Domains/previews'
DIRES[2]='Domains/static'
DIRES[3]='Domains/service/public'
DIRES[4]='Files'
DIRES[5]='Fuentes'

#gen pass 
#PASS=($(/root/script/randy -sldL10))
#PASS=$2
PASS=`openssl rand -base64 10`

#añadir proxys  apache#
####################################################################################################################

#echo > /etc/apache2/sites-enabled/resources/$IPROYECT
#echo "ProxyPass /$IPROYECT$URL/ http://$IPROYECT$URL/" >> /etc/apache2/sites-enabled/resources/$IPROYECT
#echo "ProxyPassReverse /$IPROYECT$URL/ http://$IPROYECT$URL/" >> /etc/apache2/sites-enabled/resources/$IPROYECT
#echo >> /etc/apache2/sites-enabled/resources/$IPROYECT

#anulado por encontrarse el HTTPS en el 4.50

###############################################cabeza
#cabeza='<VirtualHost 192.168.4.26:443>\n
#\t        ServerName apps-fb.cba.brandigital.com\n
#\t         ServerAdmin it@brandigital.com\n
#\t #        ServerAlias www.priceless.com.mx mc-priceless.live.ec2us.brandigital.com
#\n
#\t         DocumentRoot /var/www/test/\n
#\n
#\t         <Directory />\n
#\t \t                 DirectoryIndex index.htm index.php\n
#\t \t                 AllowOverride None\n
#\t \t \t                 Options -Indexes\n
#\t         </Directory>\n
#\n
#\t         SSLEngine on\n
#\n
#\t         SSLCertificateFile /var/lamp/security/certs/apps-fb.cba.brandigital.com/apps-fb.cba.brandigital.com.crt\n
#\t         SSLCertificateKeyFile /var/lamp/security/certs/apps-fb.cba.brandigital.com/apps-fb.cba.brandigital.com_npp.key\n
#\t         SSLCertificateChainFile /var/lamp/security/certs/apps-fb.cba.brandigital.com/gd_bundle.crt\n
#\n
#\t         <Proxy *>\n
#\t \t                 AddDefaultCharset off\n
#\t \t                 Order deny,allow\n
#\t \t                 Deny from all\n
#\t \t                 Allow from all\n
#\t \t                 #Allow from  ssl.test.brandigital.com
#\n
#\t         </Proxy>\n
#\t         ProxyRequests Off\n';

#####################pie#######################################

#pie='\n \t       ErrorLog /var/log/apache2/error_fb_ssl.log\n
#\n
#\t        # Possible values include: debug, info, notice, warn, error, crit,
#\n
#\t        # alert, emerg.
#\n
#\t        LogLevel warn\n
#\n
#\t        CustomLog /var/log/apache2/access_fb_ssl.log combined\n
#\t        ServerSignature On\n
#</VirtualHost>\n';

#####################################armado del config

#echo -e $cabeza > /etc/apache2/sites-enabled/apps-fb.cba.brandigital.com-ssl

#cat  /etc/apache2/sites-enabled/resources/* >> /etc/apache2/sites-enabled/apps-fb.cba.brandigital.com-ssl

#echo -e $pie >> /etc/apache2/sites-enabled/apps-fb.cba.brandigital.com-ssl

###################################################################################################################

echo "crear directorios"
echo "creando estructura de directorio."

for t in "${DIRES[@]}"
do
	mkdir -p  $DIRWP"/"$IPROYECT"/"$t
	chown root:www-data $DIRWP"/"$IPROYECT"/"$t
	chmod a=rx,g+ws,u+w $DIRWP"/"$IPROYECT"/"$t
echo $t
done

# carpeta IT
DIRIT=$DIRWP"/"$IPROYECT"/_IT"

mkdir -p $DIRIT
chmod o=,g=,u=rxw $DIRIT

#crear los archivos de configuración

#si los archivos existen los borramos
SEDPARAM1=" s|{url}|$IPROYECT$URL|g"
SEDPARAM2=" s|{DR}|$DIRWP/$IPROYECT/Domains/site/public|g"
SEDPARAM3=" s|{DP}|$DPASS/$IPROYECT/$FPASS|g"
SEDPARAM4=" s|{CLI}|$CLIENTE|g"
SEDPARAM5=" s|{proyecto}|$IPROYECT|g"

cat $PLANTILLA | sed -e "$SEDPARAM1" -e "$SEDPARAM2" -e "$SEDPARAM3" -e "$SEDPARAM4" -e "$SEDPARAM5" > $DIRIT"/"$IPROYECT

SEDPARAM1=" s|{url}|service.$IPROYECT$URL|g"
SEDPARAM2=" s|{DR}|$DIRWP/$IPROYECT/Domains/service/public|g"

cat $PLANTILLA | sed -e "$SEDPARAM1" -e "$SEDPARAM2" -e "$SEDPARAM3" -e "$SEDPARAM4" -e "$SEDPARAM5" > $DIRIT"/"$IPROYECT".service"

SEDPARAM1=" s|{url}|static.$IPROYECT$URL|g"
SEDPARAM2=" s|{DR}|$DIRWP/$IPROYECT/Domains/static|g"

cat $PLANTILLA | sed -e "$SEDPARAM1" -e "$SEDPARAM2" -e "$SEDPARAM3" -e "$SEDPARAM4" -e "$SEDPARAM5" > $DIRIT"/"$IPROYECT".static"

SEDPARAM1=" s|{url}|previews.$IPROYECT$URL|g"
SEDPARAM2=" s|{DR}|$DIRWP/$IPROYECT/Domains/previews|g"

cat $PLANTILLA | sed -e "$SEDPARAM1" -e "$SEDPARAM2" -e "$SEDPARAM3" -e "$SEDPARAM4" -e "$SEDPARAM5" > $DIRIT"/"$IPROYECT".previews"

SEDPARAM1=" s|{url}|static.$IPROYECT$URL|g"
SEDPARAM1=" s|{tex}|$IPROYECT|g"
FD="$DIRWP/$IPROYECT/Domains/site/public/index.php"
cp "/root/script/index.php" $FD
cat $FD | sed -e "$SEDPARAM1"  > $FD

SEDPARAM1=" s|{tex}|previews.$IPROYECT|g"
FD="$DIRWP/$IPROYECT/Domains/previews/index.php"
cp "/root/script/index.php" $FD
cat $FD | sed -e "$SEDPARAM1"  > $FD

SEDPARAM1=" s|{tex}|static.$IPROYECTL|g"
FD="$DIRWP/$IPROYECT/Domains/static/index.php"
cp "/root/script/index.php" $FD
cat $FD | sed -e "$SEDPARAM1"  > $FD

SEDPARAM1=" s|{tex}|service.$IPROYECT|g"
FD="$DIRWP/$IPROYECT/Domains/service/public/index.php"
cp "/root/script/index.php" $FD
cat $FD | sed -e "$SEDPARAM1"  > $FD



#copiar los archivos de configuración 

cp $DIRIT"/$IPROYECT" $DA2ASITE"/"
#cp $DIRIT"/$IPROYECT.service" $DA2ASITE"/"
#cp $DIRIT"/$IPROYECT.static" $DA2ASITE"/"
cp $DIRIT"/$IPROYECT.previews" $DA2ASITE"/"

ln -sf $DA2ASITE"/"$IPROYECT $DA2ESITE"/"$IPROYECT
#ln -sf $DA2ASITE"/"$IPROYECT".service" $DA2ESITE"/"$IPROYECT".service"
#ln -sf $DA2ASITE"/"$IPROYECT".static" $DA2ESITE"/"$IPROYECT".static"
ln -sf $DA2ASITE"/"$IPROYECT".previews" $DA2ESITE"/"$IPROYECT".previews"

# htpasswd
mkdir -p $DPASS/$IPROYECT
if [ -f $DPASS/$IPROYECT/$FPASS ]
then
	rm $DPASS/$IPROYECT/$FPASS
fi
htpasswd -b -c $DPASS/$IPROYECT/$FPASS $CLIENTE $PASS 

# Confección de la ficha tecnica
FT=$DIRIT"/fichaT.txt"
TEMPLATE="FichaTecnica_dev.txt"
SEDPARAM1=" s|{project}|$IPROYECT|g"
SEDPARAM2=" s|{cliente}|$CLIENTE|g"
SEDPARAM3=" s|{pass}|$PASS|g"
SEDPARAM4=" s|{year}|$YEAR|g"
cat $TEMPLATE | sed -e "$SEDPARAM1" -e "$SEDPARAM2" -e "$SEDPARAM3" -e "$SEDPARAM4"> $FT

# Reiniciar el servicio de Apache
/etc/init.d/apache2 reload

printf "ver Ficha tecnica (y/n):"
read ENTRADA
#ENTRADA="y"
if [ "$ENTRADA" = "y" ]
then
	clear
	cat $FT
fi

