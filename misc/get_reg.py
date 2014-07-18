#!/usr/bin/python

import time

RUF = 'RUF4'+time.strftime("%Y%m%d%H%M")
salida = open(RUF,'w+')

# Lee archivos y guarda en listas
fd = open('pe_registrados_'+time.strftime("%d%m%Y")+'.txt')
peru = ['\t'.join(x.split()) for x in fd]
fd.close()
fd = open('cl_registrados_'+time.strftime("%d%m%Y")+'.txt') 
chile = ['\t'.join(x.split()) for x in fd] 
fd.close()

# Limpia los cabezera, pie y los 3 registros invalidos de chile
body = peru[4:-1] + chile[1:-1]

# Crea la cabezera y el pie
head = ['0\t'+time.strftime("%Y%m%d")+'\t'+time.strftime("%H%M%S")+'\t'+'BRANDIGITAL']
bottom = ['9\t'+str(len(body))]

# Escribe el archivo RUF
salida.write("\n".join(head+body+bottom))
salida.close()
