#!/usr/bin/env python
#coding: utf8

import os.path
import sys
import commands

def print_help():
	print "recuerde que debe generar la lista de sitios activos.\nPuede hacerlo ejecutando:\n\
	grep \"DocumentRoot\" /etc/apache2/sites-enabled/*  -R | sed -e \"s|\/etc\/apache2\/sites-enabled\/\(.*\)DocumentRoot\(.*\)|\2|g\" -e \"s|\/Domains\(.*\)||g\" -e \"s|\/domains\(.*\)||g\" -e \"s|\/var\/www\(.*\)||g\" -e \"s|^ \(.*\)|\1|g\" | tee lista_sites-enabled.txt"
	exit()

def armar_tupla (nombre_cliente,project,size_project,size_hdd,aws_region,path_full):
	lista = nombre_cliente,project,size_project,size_hdd,aws_region,path_full
	tupla_list = ';'.join(str(x) for x in lista),'\n'
	tabla.writelines(tupla_list)
	pass

def armar_log(dir_env):
	name_env = dir_env.split('/')[-1]
	lista = name_env,get_size_project(dir_env)
	tupla_list = ';'.join(str(x) for x in lista),'\n'
	log.writelines(tupla_list)
	pass

def get_size_project(dir_env):
	if os.path.exists(dir_env):
		return commands.getoutput('du -sh '+dir_env).split()[0]
	else:
		return '0'
	pass

# Main
SIZE_HDD = "150GB"
AWS_RG = {'es': 'EU (Ireland) Region', 'rg' : 'US East (Northern Virginia) Region', 'ar' : 'US East (Northern Virginia) Region', 'co' : 'US East (Northern Virginia) Region','mx' : 'US East (Northern Virginia) Region' }
PATH='./lista_sites-enabled.txt'
if os.path.isfile(PATH) and os.access(PATH, os.R_OK):
	lista = open(PATH,'r').readlines()
	tabla = open('tabla_sites-enabled.txt','w')
	tabla.write('cliente;proyecto;espacio en disco;tamaño de disco;region AWS\n')
	log = open('log_sites-enabled.txt','w')

	for linea in lista:
		name_env = linea.split('/')[-1].rstrip()
		if len(name_env.split('-')) == 3:
			armar_tupla(name_env.split('-')[0],name_env.split('-')[2],get_size_project(linea.rstrip()),SIZE_HDD,AWS_RG.setdefault(name_env.split('-')[1], 'No entry dicionary'),linea.rstrip())
		else:
			armar_log(linea.rstrip())

	tabla.close()	
else:
	print_help
	exit()

#find /var/trays/tray02 -type d -maxdepth 2 | sed -e "s/^\/var\/trays\/tray02\/projects\/\(.*\)/#\1/g" | grep "#" | sed -e "s/\#//g" 
