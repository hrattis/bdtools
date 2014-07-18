# -*- coding: iso8859-1 -*-
import os
import sys

# Global
DIRIT = os.getcwd()
PRO_NAME = os.path.basename(os.path.dirname(DIRIT))
WAMP_PROJECT = "C:/wamp/proyectos/"

def getPROHOST():
	return os.environ['USERNAME']+".dev"

def getPRO_URL(subdomain):
	if subdomain == '':
		return PRO_NAME+"."+getPROHOST()
	else:
		return subdomain+"."+PRO_NAME+"."+getPROHOST()

def getPRO_ROOT():
	if os.name == 'posix':
		return os.path.dirname(DIRIT)+os.sep+'Domains'+os.sep
	else:
		return WAMP_PROJECT+PRO_NAME+"/Domains/"

def getAPACHE_ENABLED():
	if os.name == 'posix':
		return os.path.dirname(os.path.dirname(os.path.dirname(DIRIT)))+os.sep+'vhosts'
	else:
		return "C:/wamp/vhosts"

def mk_vhost(subdomain, droot):
	import re
	import shutil
	reemplazo = { 'DR' : droot, 'URL': getPRO_URL(subdomain), 'IP' : getIPADDRESS(),'LOG' : PRO_NAME }
	template =  open (DIRIT+os.sep+'template-'+os.name,"r")
	vhost_file = open (DIRIT+os.sep+getPRO_URL(subdomain), "wt")
	regex = re.compile('(%s)' % '|'.join(map(re.escape, reemplazo.keys())))
	for line in template:
		nueva_cadena = regex.sub(lambda x: str(reemplazo[x.string[x.start() :x.end()]]), line)
		vhost_file.write(nueva_cadena)
	template.close()
	vhost_file.close()
	# Copiamos al directorio de sites-enabled de wamp
	if os.name == 'posix':
                os.system('ln -s '+DIRIT+os.sep+getPRO_URL(subdomain)+' '+getAPACHE_ENABLED()+os.sep+getPRO_URL(subdomain))
        else:
		shutil.copy(DIRIT+os.sep+getPRO_URL(subdomain),getAPACHE_ENABLED()+os.sep+getPRO_URL(subdomain))

def restart_apache():
	if os.name == 'posix':
		os.system('sudo /etc/init.d/apache2 reload')		
	else:
		from subprocess import call
		call(['net','stop', 'wampapache'], shell=True)
		call(['net','start', 'wampapache'], shell=True)

def getIPADDRESS():
        import socket
	s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	s.connect(('google.com', 0))
	return s.getsockname()[0]

def update_dns(subdomain):
	import shutil
       	if os.name == 'nt':
		ifile = open('C:\windows\system32\drivers\etc\hosts','a');
        else:
		ifile = open ('/etc/hosts','a');	

        ifile.write("\n"+getIPADDRESS()+"\t"+getPRO_URL(subdomain));
        ifile.close
		
def main():	
	#creamos los archivos de configuracion
	mk_vhost('' , getPRO_ROOT()+'site/public') 
	update_dns('')
	mk_vhost('static' , getPRO_ROOT()+'static')
	update_dns('static')
	#mk_vhost('previews' , getPRO_ROOT()+'previews')
	#update_dns('previews')
	mk_vhost('service' , getPRO_ROOT()+'service/public')
	update_dns('service')
	
	# reiniciamos el apache
	restart_apache()
            
if __name__ == "__main__":
        main()

