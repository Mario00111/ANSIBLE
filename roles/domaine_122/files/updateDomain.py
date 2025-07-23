# coding: utf8
'''

updateDomain.py

2ème partie de la création d'un domaine 

Auteur : Emmanuel Collin / Easyteam pour CPRP SNCF

'''

import sys
import string
import os
import ConfigParser

def createUsers():
	print "\tCréation des utilisateurs"
	cd('/')
	atnr=cmo.getSecurityConfiguration().getDefaultRealm().lookupAuthenticationProvider("DefaultAuthenticator")
	if atnr != None:
	  try:
		nb=0
		stop=false
		while stop==false:
		  nb=nb+1
		  try:
			username=configFile.get("Users", "user"+str(nb)+".username")
			password=configFile.get("Users", "user"+str(nb)+".password")
			print "\t\tCréation de l'utilisateur "+username
			atnr.createUser(username,password,'')
		  except ConfigParser.NoOptionError:
			stop=true
		  except Exception:
			print "Unexpected error:", sys.exc_info()[0]
			stop=true
		print "\n\t > " + str(nb-1) +" utilisateurs crées dans le domaine.\n\n"
	  except:
		print "Unexpected error:", sys.exc_info()[0]
		print "Impossible de créer les utilisateurs"

def createJmsServer(jmsServerName,jmsTargetName):
	print "\tCréation du serveur JMS ",jmsServerName
	root=getMBean('/')
	serverTarget=getMBean('/Servers/'+jmsTargetName)
	if serverTarget==None:
		print "ERREUR - Impossible de trouver le mbean de type cluster ",jmsTargetName
		return

	jmsServer = getMBean('/JMSServers/'+jmsServerName)
	if jmsServer == None:
		jmsServer = root.createJMSServer(jmsServerName)
		jmsServer.setName(jmsServerName)
		
		jmsServer.addTarget(serverTarget)
	else:
		print "Le serveur JMS ",jmsServerName," existe déjà"
	return jmsServer


# Deploiment des librairies partagees specifiques projet
def deployProjectLibraries():
	print "\nDéploiement des librairies partagées spécifiques au projet..."

	appId=1
	stop=false
	while stop==false:
		
		try:			
			appName=configFile.get('SHAREDLIBS','sl'+str(appId)+'.name')
			appPath=configFile.get('SHAREDLIBS','sl'+str(appId)+'.path')
			targets=configFile.get('SHAREDLIBS','sl'+str(appId)+'.targets')
			if (os.path.exists(appPath)):
				deployProjectLibrary(appName, appPath, targets)
			else:
				print "\n\nERREUR\nLa librairie "+appPath+" est introuvable, elle ne sera pas déployée."
		except:
			dumpStack()
			stop=true
		
		appId=appId+1
 

# Déploiement d'une librairie partagee projet
def deployProjectLibrary(name, path, _targets):
  print "Déploiement de la librairie " + name+" "+path+" sur "+_targets
		
   
  # Deploiement (avec objet progess, appel apparement bloquant sur l'execution : pas besoin d'attendre sa terminaison explicitement)
  redirect("./Step2.log", "false")
  # _progress = deploy(psLibraryName, psLibrarySourceDir + "/" + _libSourceFile, targets="AdminServer", stageMode="nostage", libraryModule="true")
  _progress = deploy(name, path, targets=_targets, stageMode="nostage", libraryModule="true")
  _progress = None
  stopRedirect()
# Deploiement de l'application

def deployApplications():
	
	print "\nDéploiement des applications..."
	appId=1
	stop=false
	while stop==false:
		
		try:

			appName=configFile.get('APPLICATIONS','app'+str(appId)+'.name')
			appPath=configFile.get('APPLICATIONS','app'+str(appId)+'.path')
			targets=configFile.get('APPLICATIONS','app'+str(appId)+'.targets')
			if (os.path.exists(appPath)):
				deployApplication(appName, appPath, targets)
			else:
				print "\n\nERREUR\nLa librairie "+appPath+" est introuvable, elle ne sera pas déployée."
		except:
			dumpStack()
			stop=true
		
		appId=appId+1
		
	

def deployApplication(app_name, app_path, _targets):
	print "Déploiement de l'application "+app_name+" "+app_path+" sur "+_targets
	try:
		deploy(app_name,app_path,targets=_targets,stageMode='nostage',timeout=600000)
	except Exception, e:
		print "==> Erreur : "
		print e
		print sys.exc_info()[0]

# Suppression de RDBMS Store
def removeRDBMSSecurityStore():
	print " > Suppression du RDBMSSecurityStore"

	cd('/SecurityConfiguration/'+domainName+'/Realms/myrealm')
	cmo.destroyRDBMSSecurityStore()


# Suppression des ressources JMS liees au SecurityStore
def removeRDBMSSecurityStoreJMSResources():
  # Reference sur le MBean domaine pour destruction des ressources
  _domainBean = getMBean("/")
  
  print " > Suppression du module JMS p13n-security-jms"
  _jmsModule = getMBean("/JMSSystemResources/p13n-security-jms")
  _domainBean.destroyJMSSystemResource(_jmsModule)
  
  print " > Suppression du serveur JMS p13nJMSServer"
  _jmsServer = getMBean("/JMSServers/p13nJMSServer")
  _domainBean.destroyJMSServer(_jmsServer)
  
  print " > Suppression du store JMS p13nJMSPersistenceStore"
  _jmsStore = getMBean("/JDBCStores/p13nJMSPersistenceStore")
  _domainBean.destroyJDBCStore(_jmsStore)
 
### Main

configFile = ConfigParser.ConfigParser()

print "*"*80
print "*"," "*76,"*"
print "*"," "*76,"*"

s = "CPRP SNCF"
s = s.center(76)
print "*",s,"*"
print "*"," "*76,"*"

s = "Création d'un domaine Oracle Service Bus 12c (12.2.1.3)"
s = s.center(76)
print "*",s,"*"

print "*"," "*76,"*"
s = "2ème partie, mise à jour du domaine."
s = s.center(76)
print "*",s,"*"
print "*"," "*76,"*"
print "*"," "*76,"*"
print "*"*80

 
print 'Démarrage du script ....'
 
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
 		_adminAddr = "localhost"

	
	AdminUrl='t3://'+_adminAddr+':'+configFile.get('DOMAIN','adminServerPort')	
	
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
		print "Impossible de se connecter au serveur d'administration. Création du domaine interrompue."
		exit('',100)
	
	# Type de domaine : WLS 
	_domainType = configFile.get('DOMAIN','type')
	
	# Initialisation d'une session de configuration
	stopRedirect()

	### Ouverture d'une session edit
	### domainConfig()
	
	#Creation des utilisateur
	createUsers()
	print "Generation des fichiers boot.properties et startup.properties pour les serveurs manages"
	serverId=1
        stop=false
        while stop==false:
		try:
			serverName=configFile.get('SERVERS','server'+str(serverId)+'.name')
			print "Generation boot.properties et startup.properties pour le serveur "+serverName
			nmGenBootStartupProps(serverName)
			serverId=serverId+1
		except:
			stop=true
      
	edit()
	startEdit()
	
	print "Création des serveurs JMS"
	jmsServerNames=[]
	id=1
	stop=false
	while stop==false:
		try:
			jmsServerName=configFile.get('JMS','jmsserver'+str(id)+'.name')
			jmsTargetName=configFile.get('JMS','jmsserver'+str(id)+'.target')
			
			jmsServerNames.append(jmsServerName)
			
			createJmsServer(jmsServerName,jmsTargetName)
		except:
			#print "Erreur lors de la crꢴion du serveur..."
			dumpStack()
			stop=true
		id=id+1	


	edit()
	startEdit()

	print "Création des modules JMS"
	id=1
	stop=false
	while stop==false:
		try:	
			moduleName=configFile.get('JMS','module'+str(id)+'.name')
			targetName=configFile.get('JMS','module'+str(id)+'.target')
			print "\tCreation du module JMS "+moduleName
			cd('/')
			

			try:
				target=lookup(targetName,'Server')
			except:
				target=lookup(targetName,'Cluster')

			cmo.createJMSSystemResource(moduleName)
			
			cd('/SystemResources/'+moduleName)
			
			set('Targets',jarray.array([ObjectName('com.bea:Name='+target.getName()+',Type='+target.getType())], ObjectName))

			subModuleName=configFile.get('JMS','module'+str(id)+'.subdeployment.name')
			#subModuleTarget=configFile.get('JMS','module'+str(id)+'.subdeployment.target')
			
			print "\tCréation du sous-module JMS "+subModuleName
			cd('/SystemResources/'+moduleName)
			cmo.createSubDeployment(subModuleName)

			cd('/SystemResources/'+moduleName+'/SubDeployments/'+subModuleName)
			#set('Targets',jarray.array([ObjectName('com.bea:Name='+subModuleTarget+',Type=Cluster')], ObjectName))
						
			for jmsServerName in jmsServerNames:
				cmo.addTarget(getMBean('/JMSServers/'+jmsServerName))
			
			print "Création des connection factories"
			cfId=1
			stopCF=false
			while stopCF==false:
				try:	
					cfName = configFile.get('JMS','module'+str(id)+'.connectionFactory'+str(cfId)+'.name')
					cfJndi = configFile.get('JMS','module'+str(id)+'.connectionFactory'+str(cfId)+'.jndiName')
					cfXA = configFile.get('JMS','module'+str(id)+'.connectionFactory'+str(cfId)+'.xa')
					print "\tCréation de la connection factory ",cfName
					cd('/JMSSystemResources/'+moduleName+'/JMSResource/'+moduleName)
					cmo.createConnectionFactory(cfName)

					cd('/JMSSystemResources/'+moduleName+'/JMSResource/'+moduleName+'/ConnectionFactories/'+cfName)
					cmo.setJNDIName(cfJndi)

					cd('/JMSSystemResources/'+moduleName+'/JMSResource/'+moduleName+'/ConnectionFactories/'+cfName+'/SecurityParams/'+cfName)
					cmo.setAttachJMSXUserId(false)

					cd('/JMSSystemResources/'+moduleName+'/JMSResource/'+moduleName+'/ConnectionFactories/'+cfName+'/ClientParams/'+cfName)
					cmo.setClientIdPolicy('Restricted')
					cmo.setSubscriptionSharingPolicy('Exclusive')
					cmo.setMessagesMaximum(10)

					cd('/JMSSystemResources/'+moduleName+'/JMSResource/'+moduleName+'/ConnectionFactories/'+cfName+'/TransactionParams/'+cfName)
					if cfXA.upper()=="FALSE":
						cmo.setXAConnectionFactoryEnabled(false)
					else:
						cmo.setXAConnectionFactoryEnabled(true)

					cd('/JMSSystemResources/'+moduleName+'/JMSResource/'+moduleName+'/ConnectionFactories/'+cfName)
					cmo.setDefaultTargetingEnabled(true)
				except:
					#print "Erreur lors de la crꢴion du serveur..."
					dumpStack()
					stopCF=true
				cfId=cfId+1	


			print "Création des distributed Topics"
			topicId=1
			stopTopic=false
			while stopTopic==false:
				try:
					topicName = configFile.get('JMS','module'+str(id)+'.distributedtopic'+str(topicId)+'.name')
					topicJndi = configFile.get('JMS','module'+str(id)+'.distributedtopic'+str(topicId)+'.jndiName')
					topicTarget = configFile.get('JMS','module'+str(id)+'.distributedtopic'+str(topicId)+'.target')
					print "\tCréation du topic ",topicName

					cd('/JMSSystemResources/'+moduleName+'/JMSResource/'+moduleName)
					cmo.createUniformDistributedTopic(topicName)
					cd('/JMSSystemResources/'+moduleName+'/JMSResource/'+moduleName+'/UniformDistributedTopics/'+topicName)

					cmo.setForwardingPolicy('Replicated')
					cmo.setJNDIName(topicJndi)
					cmo.setSubDeploymentName(subModuleName)
					
				except:
					#print('unable to create TOPIC ' + topicName)
					dumpStack()
					stopTopic=true
					
				topicId=topicId+1	
				
			print "Création des Topics"
			topicId=1
			stopTopic=false
			while stopTopic==false:
				try:
					topicName = configFile.get('JMS','module'+str(id)+'.topic'+str(topicId)+'.name')
					topicJndi = configFile.get('JMS','module'+str(id)+'.topic'+str(topicId)+'.jndiName')
					topicTarget = configFile.get('JMS','module'+str(id)+'.topic'+str(topicId)+'.target')
					print "\tCréation du topic ",topicName

					cd('/JMSSystemResources/'+moduleName+'/JMSResource/'+moduleName)
					cmo.createTopic(topicName)
					cd('/JMSSystemResources/'+moduleName+'/JMSResource/'+moduleName+'/Topics/'+topicName)

					#cmo.setForwardingPolicy('Replicated')
					cmo.setJNDIName(topicJndi)
					cmo.setSubDeploymentName(subModuleName)
					
				except:
					#print('unable to create TOPIC ' + topicName)
					dumpStack()
					stopTopic=true
					
				topicId=topicId+1					
		except:
			#print "Erreur lors de la crꢴion du serveur..."
			dumpStack()
			stopTopic=true
			stop=true
		id=id+1	

	### Sauvegarde des modifications
	save()
	activate(block="true")

	edit()
	startEdit()
	
	deployProjectLibraries()
	
	### Sauvegarde des modifications
	save()
	activate(block="true")

	
	edit()
	startEdit()
	
	deployApplications()
	
	### Sauvegarde des modifications
	save()
	activate(block="true")	

	print "Arrêt du serveur d'administration."
	shutdown(force='true', block='true')
	
	if (os.path.exists('Step2.log')):
		os.remove('Step2.log')
	if (os.path.exists('updateDomain.log')):
		os.remove('updateDomain.log')

	#disconnect()
 
except Exception, e:
	print "==> Erreur : "
	print e
	print sys.exc_info()[0]
	exit("",100)
exit("",0)
