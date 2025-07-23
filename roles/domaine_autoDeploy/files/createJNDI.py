'''

createJNDI.py

Auteur : CPRP SNCF ORACLE

'''

### Main
### createJNDI.py
import sys
import string

import os
import ConfigParser
import shutil

def create_ForeignJNDIProvider():
	jndiProviderId=1
	stop=false
	while stop==false:
		try:
			cd('/')
      			providerName=configFile.get('JNDIPROVIDERS','jndiProvider'+str(jndiProviderId)+'.name')
      			providerUrl=configFile.get('JNDIPROVIDERS','jndiProvider'+str(jndiProviderId)+'.url')
			providerTarget=configFile.get('JNDIPROVIDERS','jndiProvider'+str(jndiProviderId)+'.target')
			print 'creating ForeignJNDIProvider ... '+providerName
      			theproviderName = cmo.lookupForeignJNDIProvider(providerName)
      			if theproviderName == None:
				cmo.createForeignJNDIProvider(providerName)
				setAttributesFor_JNDIProvider(providerName,providerUrl,providerTarget)
    		except java.lang.UnsupportedOperationException, usoe:
			pass
    		except weblogic.descriptor.BeanAlreadyExistsException,bae:
      			pass
    		except java.lang.reflect.UndeclaredThrowableException,udt:
      			pass
		except:
			dumpStack()
			stop=true
		jndiProviderId=jndiProviderId+1

def create_ForeignJNDILink():
        jndiLinkId=1
        stop=false
        while stop==false:
                try:	
			cd('/')
		        providerName=configFile.get('JNDILINKS','jndiLink'+str(jndiLinkId)+'.providername')
			linkName=configFile.get('JNDILINKS','jndiLink'+str(jndiLinkId)+'.linkname')
                        linkRemoteName=configFile.get('JNDILINKS','jndiLink'+str(jndiLinkId)+'.linkremotename')
                        linkLocalName=configFile.get('JNDILINKS','jndiLink'+str(jndiLinkId)+'.linklocalname')
  			cd('/ForeignJNDIProviders/'+providerName)
    			print "creating mbean of type ForeignJNDILink ... "
    			thelinkName = cmo.lookupForeignJNDILink(linkName)
    			if thelinkName == None:
      				cmo.createForeignJNDILink(linkName)
				setAttributesFor_JNDILink(providerName,linkName,linkRemoteName,linkLocalName)
  		except java.lang.UnsupportedOperationException, usoe:
    			pass
  		except weblogic.descriptor.BeanAlreadyExistsException,bae:
    			pass
  		except java.lang.reflect.UndeclaredThrowableException,udt:
    			pass
		except:
                        dumpStack()
                        stop=true
                jndiLinkId=jndiLinkId+1 
   
def setAttributesFor_JNDIProvider(providerName,providerUrl,providerTarget):
  cd('/ForeignJNDIProviders/'+providerName)
  print "setting attributes for mbean type ForeignJNDIProvider"
  set("User", "weblogic")
  setEncrypted("Password", "Password_1412251362291", "/u01/scripts/Script1412251361194Config", "/u01/scripts/Script1412251361194Secret")
  set("ProviderURL", providerUrl)
  refBean0 = getMBean('/Servers/'+providerTarget)
  theValue = jarray.array([refBean0], Class.forName("weblogic.management.configuration.TargetMBean"))
  cmo.setTargets(theValue)

def setAttributesFor_JNDILink(providerName,linkName,linkRemoteName,linkLocalName):
  cd('/ForeignJNDIProviders/'+providerName+'/ForeignJNDILinks/'+linkName)
  print "setting attributes for mbean type ForeignJNDILink"
  set("RemoteJNDIName", linkRemoteName)
  set("LocalJNDIName", linkLocalName)


def editing():
	edit()
	startEdit()
 
def activating():
	save()
	activate()

### Main

configFile = ConfigParser.ConfigParser()

print "*"*80
print "*"," "*76,"*"
print "*"," "*76,"*"

s = "CPRP SNCF"
s = s.center(76)
print "*",s,"*"
print "*"," "*76,"*"

s = "Deploiement JNDI Weblogic Server 12c"
s = s.center(76)
print "*",s,"*"

print "*"," "*76,"*"
s = "Undeploy/Deploy"
s = s.center(76)
print "*",s,"*"
print "*"," "*76,"*"
print "*"," "*76,"*"
print "*"*80

 
print 'Demarrage du script ....'
 
### Chargement du fichier de proprietes
#ServerProperties=sys.argv[1]

fileProperties = sys.argv[1]  
 
### Lecture du fichier de proprietes propre a l'application
print('Lecture du fichier de proprietes : \"' + fileProperties + '\"' )  
try:
	loadProperties(fileProperties)

	configFile.read(fileProperties)
	_adminAddr = configFile.get('DOMAIN','adminServerAddress')
	if 0 == len(_adminAddr.strip()):
		# Si ecoute sur toutes les cartes, acces par localhost
 		_adminAddr = "prodriw"

	
	AdminUrl='t3://'+_adminAddr+':'+configFile.get('DOMAIN','adminServerPort')	
	print AdminUrl
	user=configFile.get('DOMAIN','adminUser')
	pwd=configFile.get('DOMAIN','adminPassword')
	# Boucle d'essai de connexion
	redirect("./updateDomain.log", "false")
	print "Connexion au serveur d'Administration"
	maxTry = 60
	delay=5

	ok=false
	timeout=false
	tryCount=1
	while ok==false and timeout==false:
		
		print '\n\n>> Tentative de connexion %s / %s' % (tryCount,maxTry)

		
		try:
			### Connexion au serveur d'administration
			connect(adminUser,adminPassword,AdminUrl)
			ok=true
		except WLSTException,e:
			print ">>> Connexion au serveur impossible."

		if tryCount < maxTry and ok==false:
			print '>>> Attente de la prochaine tentative dans %s secondes' % delay
			java.lang.Thread.sleep(delay * 1000)

		tryCount = tryCount + 1
		print '-'*60

		if tryCount > maxTry:
			timeout=true
			
	if ok==false:
		print "Impossible de se connecter au serveur d'administration. Creation du domaine interrompue."
		exit('',100)
	
	# Type de domaine : WLS / WLP
	_domainType = configFile.get('DOMAIN','type')
	
	# Initialisation d'une session de configuration
	stopRedirect()

	
	edit()
	startEdit()

	### Creation des Providers JNDI
	create_ForeignJNDIProvider()	
	
	### Sauvegarde des modifications
	save()
	activate(block="true")

	edit()
        startEdit()

        ### Creation des Links JNDI
        create_ForeignJNDILink()
        
	### Sauvegarde des modifications
        save()
        activate(block="true")




	print '\n\n'
		
	
	if (os.path.exists('Step2.log')):
		os.remove('Step2.log')
	if (os.path.exists('updateDomain.log')):
		os.remove('updateDomain.log')

	#disconnect()
 
except Exception, e:
	print "==> Erreur Fin: "
	print e
	print sys.exc_info()[0]
	exit("",100)
exit("",0)
 
 
 
 
