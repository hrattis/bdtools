#!/bin/bash

DATE=$(date +%Y%m%d%H%M)
echo "El ID es "$DATE
ssh -i hrattis-web-staging_07_05_2014.pem hrattis@54.232.95.160 "/home/hrattis/make_upload_pack.sh $DATE"

#echo -n "Ingrese el nombre del archivo generado: ";read ANS
scp -i hrattis-web-staging_07_05_2014.pem hrattis@54.232.95.160:subir-$DATE.tar.gz .

ssh -i hrattis-web-staging_07_05_2014.pem hrattis@54.232.95.160 "rm subir-$DATE.tar.gz"
scp -i hrattis-web-live.pem subir-$DATE.tar.gz 10.0.1.247:.

rm subir-$DATE.tar.gz

echo "tar cvzf back-$DATE"".tar.gz"
