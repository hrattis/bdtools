#!/bin/bash

VAR_DIR=/var/data/web2/sites/tray-eu
CON_DIR=/var/data/web2
PRO_NAME=$1
URL=".live.ec2eu.brandigital.com"
YEAR=($(date | awk '{print $6}'))
DATE=$(date +%d-%m-%Y)
PASS=`openssl rand -base64 12`

#Obteniendo nombre del cliente y la region
corte=`expr index $PRO_NAME -`
let "corte -= 1"
CLIENTE=`expr substr $PRO_NAME 1 $corte`
let "corte += 2"
REGION=`expr substr $PRO_NAME $corte 2`

while true; do
  if [ $# -lt 1 -o $# -gt 1 ]; then
        echo ""
        echo "faltan argumentos o hay demasiados."
        echo "Usage:"
        echo " newproject.sh [nombre_del_proyector] "
        echo ""
        break
  fi
  clear
  echo "El proyecto va ir en: $VAR_DIR/projects/$YEAR es correcto? (y)es, n(o) o (e)xit:"; read ANS

  case "$ANS" in
   y)   echo "Creando $PRO_NAME en $VAR_DIR"
        mkdir -p $VAR_DIR/projects/$YEAR/$PRO_NAME/Domains/static
        mkdir -p $VAR_DIR/projects/$YEAR/$PRO_NAME/Domains/site/public
        mkdir -p $VAR_DIR/projects/$YEAR/$PRO_NAME/Domains/service/public
        mkdir -p $VAR_DIR/projects/$YEAR/$PRO_NAME/Files
        chown ftp:www-data $VAR_DIR/projects/$YEAR/$PRO_NAME/Domains -R
        chown ftp:www-data $VAR_DIR/projects/$YEAR/$PRO_NAME/Files -R
        chmod g+s $VAR_DIR/projects/$YEAR/$PRO_NAME/Domains -R
        mkdir -p $VAR_DIR/projects/$YEAR/$PRO_NAME/_IT

        echo "Creando vhost"
        DR="$VAR_DIR/projects/$YEAR/$PRO_NAME"
        SEDPARAM1=" s|TEMPLATE|$PRO_NAME|g"
        SEDPARAM2=" s|DR|$DR|g"
        sed -e "$SEDPARAM1" -e "$SEDPARAM2" template.site > $VAR_DIR/projects/$YEAR/$PRO_NAME/_IT/$PRO_NAME

        echo "Creando $PRO_NAME en $VAR_DIR/logs/apache2"
        mkdir -p $VAR_DIR/logs/apache2/$PRO_NAME

        echo "Configurando apache"
        cp $VAR_DIR/projects/$YEAR/$PRO_NAME/_IT/$PRO_NAME $CON_DIR/configs/apache2/sites-available/tray-eu/$PRO_NAME
        ln -s $CON_DIR/configs/apache2/sites-available/tray-eu/$PRO_NAME $CON_DIR/configs/apache2/sites-enabled/tray-eu/$PRO_NAME

        echo "Creando cuenta de FTP"
        echo "local_root=$VAR_DIR/projects/$YEAR/$PRO_NAME" >> /etc/vsftpd/user_config/$PRO_NAME
        htpasswd -b /etc/vsftpd/passwd $PRO_NAME $PASS
        echo "Creando Ficha tecnica"
        FT=$VAR_DIR/projects/$YEAR/$PRO_NAME/_IT/"fichaT.txt"
        TEMPLATE="FichaTecnica_ec2eu.txt"
        SEDPARAM1=" s|{project}|$PRO_NAME|g"
        SEDPARAM2=" s|{cliente}|$CLIENTE|g"
        SEDPARAM3=" s|{pass}|$PASS|g"
        SEDPARAM4=" s|{year}|$YEAR|g"
        cat $TEMPLATE | sed -e "$SEDPARAM1" -e "$SEDPARAM2" -e "$SEDPARAM3" -e "$SEDPARAM4"> $FT
        break
        ;;
   n)   echo "Ingrese el PATH completo:"; read VAR_DIR
        ;;
   e)   break
        ;;
   *)   echo "Escriba (y)es, n(o) o bien (e)xit"
        clear
        ;;
  esac

done
