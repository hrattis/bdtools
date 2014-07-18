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
DATE=$(date +%d-%m-%Y)
EXITE='0'

# Const
DIRWP="/var/lamp/files/projects/2013"
#DIRWP="/mnt/nfs-stay_puft-cms/files/proyectos"
URL=".dev.cba.brandigital.com"
PLANTILLA="/root/script/plantilla"
DPASS="/var/lamp/files/security"
FPASS="passwd"
DA2ASITE="/etc/apache2/sites-available-lamp/devel"
DA2ESITE="/etc/apache2/sites-enabled/devel"
DIRIT=$DIRWP"/"$IPROYECT"/_IT"
DIRBAJA="/var/lamp/files/proyectos_baja"

#estructura
DIRES[0]='Domains/site/public'
DIRES[1]='Domains/previews'
DIRES[2]='Domains/static'
DIRES[3]='Domains/service/public'
DIRES[4]='Files'
DIRES[5]='Fuentes'

#gen pass
PASS=($(/root/script/randy -sldL10))

if [ -d "$DIRWP"/"$IPROYECT" ]
then
	EXITE='1'
else
	echo "No existe un proyecto con ese nombre. Revise su informción y vuelva a intentar"
        echo ""
	exit 0
fi

	# print datos
	echo ""
	echo "Datos del proyecto a remover"
	echo "Identificador del proyecto : " $IPROYECT
	echo "Directorio del proyecto : "$DIRWP"/"$IPROYECT
	printf "Los datos son correctos (y/n): " $DIRBAJA"/"$IPROYECT"_"$DATE $DIRWP"/"$IPROYECT"/" 

	read ENTRADA
	#ENTRADA="y"
	if [ $ENTRADA != "y" ]
	then
		echo "adio"
		exit 0
	fi

	#crear directorios
	echo "Comprimiendo estructura de directorio."
	zip -r -9 $DIRBAJA"/"$IPROYECT"_"$DATE $DIRWP"/"$IPROYECT"/"

	#Borrando archivos
	printf "Desea borrar los archivos (s)í, (n)o, nada(ENTER) : "
	read ENTRADA
	if [ "$ENTRADA" = "s" ]
	then
		#Removemos los archivos de configuración 
		echo "Removiendo archivos de configuración"
		rm $DA2ESITE"/"$IPROYECT 
		rm $DA2ESITE"/"$IPROYECT".service" 
		rm $DA2ESITE"/"$IPROYECT".static" 
		rm $DA2ESITE"/"$IPROYECT".previews" 

		rm $DA2ASITE"/"$IPROYECT 
		rm $DA2ASITE"/"$IPROYECT".service" 
		rm $DA2ASITE"/"$IPROYECT".static" 
		rm $DA2ASITE"/"$IPROYECT".previews"

		# Borramos el archivo htpasswd
		echo "Borramos htpasswd"
		echo ""
		if [ -f $DPASS/$IPROYECT/$FPASS ]
		then
			rm $DPASS/$IPROYECT -fr
		fi
		# Borrando archivos
        	rm -rf $DIRWP"/"$IPROYECT
	fi

	#reload apache
	printf "Apache restar(r), reload(rl), nada(ENTER) :"
	read ENTRADA
	#ENTRADA="y"
	if [ "$ENTRADA" = "r" ]
	then
		/etc/init.d/apache2 restart
	fi
	if [ "$ENTRADA" = "rl" ]
	then
		/etc/init.d/apache2 reload
	fi

	echo "En "$DIRBAJA"/"$IPROYECT"_"$DATE".zip contiene los datos de sitio y DB:"
	echo ""
