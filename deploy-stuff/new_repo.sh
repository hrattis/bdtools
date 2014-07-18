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
ID_YEAR=$(date | awk '{print $6}')

# Const
DIRWP="/mnt/repos/hg"
URL=".dev"
PLANTILLA="/root/deploy-stuff/plantilla"

#estructura
DIRES[0]='Domains/site/public'
DIRES[1]='Domains/previews'
DIRES[2]='Domains/static'
DIRES[3]='Domains/service/public'
DIRES[4]='Fuentes'

# carpeta IT
DIRIT=$DIRWP"/"$IPROYECT"/_IT"

# print datos
echo ""
echo "Datos"
echo "Identificador del proyecto : " $IPROYECT
echo "Directorio del proyecto : "$DIRWP"/"$IPROYECT
echo "Urls del proyecto:"
echo ""
printf "Los datos son correctos (y/n): "

#read ENTRADA
ENTRADA="y"
if [ $ENTRADA != "y"  ]; then
	echo "adio"
	exit 0
fi

FT="/tmp/fichaT.txt"
echo "Ficha tecnica" > $FT
echo "" >> $FT
echo "Año: "$ID_YEAR >> $FT
echo "" >> $FT
echo "Datos del repositorio" >> $FT


#creamos el repositorio
HOME_JAVA=/opt/java
HOST="http://repo.dev.brandigital.com:8080/scm"
SCMPASS='SCM_Brandigital'

/opt/java/bin/java -jar /root/deploy-stuff/scm-client.jar --server $HOST -u admin -p $SCMPASS create-repository --name $IPROYECT --contact it@brandigital.com --type hg > /tmp/frepo

IDREPO=`cat /tmp/frepo | egrep "ID:*" | awk '{print$2}'`
/opt/java/bin/java -jar /root/deploy-stuff/scm-client.jar --server $HOST --user admin -p $SCMPASS add-permission $IDREPO --name produccion-team --group --type WRITE >> $FT

/opt/java/bin/java -jar /root/deploy-stuff/scm-client.jar --server $HOST --user admin -p $SCMPASS add-permission $IDREPO --name deployers --group --type READ >> $FT

#crear directorios
echo "\ncreando estructura de directorio."
for t in "${DIRES[@]}"
do
	mkdir -p  $DIRWP"/"$IPROYECT"/"$t
done
mkdir $DIRWP"/"$IPROYECT"/_IT"

#si los archivos existen los borramos
touch "$DIRWP/$IPROYECT/Fuentes/se_puede_borrar"

SEDPARAM1=" s|{tex}|$IPROYECT|g"
FD="$DIRWP/$IPROYECT/Domains/site/public/index.php"
cp "/root/deploy-stuff/index.php" $FD
cat $FD | sed -e "$SEDPARAM1"  > $FD

SEDPARAM1=" s|{tex}|previews.$IPROYECT|g"
FD="$DIRWP/$IPROYECT/Domains/previews/index.php"
cp "/root/deploy-stuff/index.php" $FD
cat $FD | sed -e "$SEDPARAM1"  > $FD

SEDPARAM1=" s|{tex}|static.$IPROYECTL|g"
FD="$DIRWP/$IPROYECT/Domains/static/index.php"
cp "/root/deploy-stuff/index.php" $FD
cat $FD | sed -e "$SEDPARAM1"  > $FD

SEDPARAM1=" s|{tex}|service.$IPROYECT|g"
FD="$DIRWP/$IPROYECT/Domains/service/public/index.php"
cp "/root/deploy-stuff/index.php" $FD
cat $FD | sed -e "$SEDPARAM1"  > $FD


# Copiar archivos de despliegue
cp $PWD/template-* $DIRWP"/"$IPROYECT"/_IT/"
#cp $PWD/rndc.key $DIRWP"/"$IPROYECT"/_IT/"
cp $PWD/deploy_dev.py $DIRWP"/"$IPROYECT"/_IT/"

# Commit de los cambios
echo "Guardando cambios en el repositorio"
echo ""
cd $DIRWP"/"$IPROYECT
/usr/local/bin/hg add . -S >> /dev/null
/usr/local/bin/hg commit --user admin@mercurial-repo -m "Creación de entorno"

# Limpiando
mv $FT $DIRIT"/."
rm /tmp/frepo

printf "ver Ficha tecnica (y/n):"
#read ENTRADA
ENTRADA="y"
if [ "$ENTRADA" = "y" ]
then
	cat $DIRIT"/fichaT.txt"
fi

