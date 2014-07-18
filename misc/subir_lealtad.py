#!/usr/bin/env python
#coding: utf8

import os.path
import sys
import commands
import time

LISTFILES = 'get_upload.txt'
LISTTAR = 'get_upload.subir'
LISTBACK = 'get_upload.back'

def generar_lista_comprimir():
	temp = open(LISTTAR,'w')
	if os.path.isfile(LISTFILES) and os.access(LISTFILES, os.R_OK):
		files_relative = open(LISTFILES,'r').readlines()
		for relative in files_relative:
			full = "/mnt/data/mastercard-rg-plataformalealtad/"+relative
			temp.writelines(full)
	else:
		print "La lista de archivos a subir no existe o esta vacia."

	temp.write('\n')
	temp.write(LISTBACK)
	temp.close()
	pass

def generar_lista_aux():
	temp_back = open(LISTBACK,'w')
	if os.path.isfile(LISTFILES) and os.access(LISTFILES, os.R_OK):
		files_relative = open(LISTFILES,'r').readlines()
		for relative in files_relative:
			full = "/mnt/nfs/data/mastercard-rg-plataformalealtad/"+relative
			temp_back.writelines(full)
	else:
		print "La lista de archivos a subir no existe o esta vacia."

	temp_back.close()
	pass

def generar_archivo_tar():
	if os.path.isfile(LISTTAR) and os.access(LISTTAR, os.R_OK):
		commands.getoutput('tar cfz subir-'+time.strftime("%Y%m%d%H%M").split()[0]+'.tar.gz --files-from='+LISTTAR)
	else:
		print "La lista de archivos a comprimir no existe o esta vacia."
	pass

def clean_all():
	os.remove(LISTTAR)
	os.remove(LISTBACK)
	pass

def main():
	print "Leyendo archivo de entrada "+LISTFILES
	generar_lista_comprimir()
	print "Generando archivo auxiliar en "+LISTBACK
	generar_lista_aux()
	print "Comprimiendo..."
	generar_archivo_tar()
	print "Limpiando..."
	clean_all()
	print "Si ha detectado un error revise la lista de archivos y ejecute nuevamente."
	pass

if __name__ == "__main__":
	main()
	