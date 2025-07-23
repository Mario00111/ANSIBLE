# coding: utf8
'''

createDomain.py

Script WLST de création d'un domaine 12.2.1.3

Auteur : Emmanuel Collin / Easyteam pour CPRP SNCF

Release Notes :
---------------
27/03/2019 - Version 1.0 du script

TODO
----


'''

VERSION = "1.0"

# Change DataSource to XA
def changeDatasourceToXA(datasource):
	print 'Modification de la datasource '+datasource
	cd('/')
	cd('/JDBCSystemResource/'+datasource+'/JdbcResource/'+datasource+'/JDBCDriverParams/NO_NAME_0')
	set('DriverName','oracle.jdbc.xa.client.OracleXADataSource')
	print '. Set UseXADataSourceInterface='+'True'
	set('UseXADataSourceInterface','True') 
	cd('/JDBCSystemResource/'+datasource+'/JdbcResource/'+datasource+'/JDBCDataSourceParams/NO_NAME_0')
	print '. Set GlobalTransactionsProtocol='+'TwoPhaseCommit'
	set('GlobalTransactionsProtocol','TwoPhaseCommit')
	cd('/')

def targetLib(libName,targets):
	print '\tCiblage de la librairie '+libName+' sur '+targets
	try:
		cd('/Library/'+libName)
		set('Target',targets)
	except:
		dumpStack()
		
def targetApp(appName,targets):
	print "\tCiblage de l'application "+appName+" sur "+targets
	try:
		cd('/AppDeployment/'+appName)
		set('Target',targets)
	except:
		dumpStack()
		
def createCustomSetEnvScript(domainPath):
	filename="setUserOverrides.sh"

	print "Création du script bin/"+filename
	scriptPath = domainPath + "/bin/"+filename
	
	newFile = open(scriptPath, "w")
	newFile.write("PRODUCTION_MODE=true\n")
	newFile.write("export PRODUCTION_MODE\n\n")
	newFile.write("DERBY_FLAG=false\n")
	newFile.write("export DERBY_FLAG\n\n")
	newFile.write("JAVA_OPTIONS=\"${JAVA_OPTIONS} -Djava.security.egd=file:/dev/./urandom\"\n\n")
	newFile.write("export JAVA_OPTIONS\n\n")

	newFile.flush()
	
def updateDomainStartScript(domainPath):
	osname=System.getProperty("os.name")
	p=osname.find("Windows")
	if p >=0:
		filename="startWebLogic.cmd"
	else:
		filename="startWebLogic.sh"


	print "Mise a jour du script "+filename

	# Path du fichier
	scriptPath = domainPath + "/"+filename
	curScriptPath = scriptPath
	newScriptPath = scriptPath + ".new"
  
	# Lecture du courant vers nouveau avec filtre sur la ligne set DOMAIN_HOME=
	curFile = open(curScriptPath, "r")
	newFile = open(newScriptPath, "w")
	curLine = curFile.readline()
	while ("" != curLine):
		if 0 < curLine.find(filename):
			newFile.write(curLine.rstrip()+' production\n')
		else:
			newFile.write(curLine)
		# Ligne suivante
		curLine = curFile.readline()
  
	# Terminaison
	curFile.close()
	newFile.flush()
	newFile.close()

	# Remplacement du fichier
	os.remove(curScriptPath)
	os.rename(newScriptPath, scriptPath)



		
def updateNodeManagerConfigFile(domainPath,nodeManagerType, nodeManagerListenAddress, nodeManagerPort, nodeManagerStartScript):
        filename="nodemanager.properties"

        print "Mise a jour du fichier de configuration du node manager "+filename

        # Path du fichier
        scriptPath = domainPath + "/nodemanager/"+filename
        curScriptPath = scriptPath
        newScriptPath = scriptPath + ".new"

        # Lecture du courant vers nouveau avec filtre sur les lignes
        curFile = open(curScriptPath, "r")
        newFile = open(newScriptPath, "w")
        curLine = curFile.readline()
        while ("" != curLine):
                if 0 <= curLine.find("ListenAddress"):
                        newFile.write('ListenAddress='+nodeManagerListenAddress+'\n')
		elif 0 <= curLine.find("ListenPort"):
			newFile.write('ListenPort='+nodeManagerPort+'\n')
		elif 0 <= curLine.find("StartScriptEnabled"):
                        newFile.write('StartScriptEnabled='+nodeManagerStartScript+'\n')
                else:
                        newFile.write(curLine)
                # Ligne suivante
                curLine = curFile.readline()
        # Terminaison
        curFile.close()
        newFile.flush()
        newFile.close()

        # Remplacement du fichier
        os.remove(curScriptPath)
        os.rename(newScriptPath, scriptPath)


def createServerStopScript(domainPath,serverName):
	print "Création du script d'arret du serveur "+serverName+"..."
	osname=System.getProperty("os.name")
	p=osname.find("Windows")
	if p >=0:
	
		# VERSION WINDOWS
		filename="stop"+serverName+".cmd"

		file = open (domainPath+'/'+filename, 'w')

		file.write('call .\\bin\\stopManagedWebLogic.cmd '+serverName+' '+_adminAddr+':'+configFile.get('DOMAIN','adminServerPort')+'\n')
		file.flush()
		file.close()	
	else:
		# VERSION UNIX
		filename="stop"+serverName+".sh"
		file = open (domainPath+'/'+filename, 'w')

		file.write('./bin/stopManagedWebLogic.sh '+serverName+' '+_adminAddr+':'+configFile.get('DOMAIN','adminServerPort')+'\n')
		file.flush()
		file.close()	
	print "Script cree avec succès."

def createServerStartScript(domainPath,serverName):
	print "Creation du script de demarrage du serveur "+serverName+"..."
	osname=System.getProperty("os.name")
	p=osname.find("Windows")
	if p >=0:

		# VERSION WINDOWS
		filename="start"+serverName+".cmd"
		file = open (domainPath+'/'+filename, 'w')

		file.write('@echo off\n')

		file.write('SETLOCAL\n')
		file.write('TITLE '+serverName+'\n')
		file.write('echo Demarrage du serveur '+serverName+'...\n')

		file.write('SET JAVA_VENDOR=Oracle\n')
		file.write('set PRODUCTION_MODE=true\n')
		file.write('SET USER_MEM_ARGS=-Xms1024m -Xmx1024m\n')
		file.write('SET PRE_CLASSPATH=.\n')

		file.write('call .\\bin\\startManagedWeblogic.cmd '+serverName+' '+_adminAddr+':'+configFile.get('DOMAIN','adminServerPort')+' production\n')
		file.write('ENDLOCAL\n')
		file.flush()
		file.close()	
	else:
		# VERSION UNIX
		print "Script cree avec succès."
		filename="start"+serverName+".sh"
		file = open (domainPath+'/'+filename, 'w')

		file.write('echo Demarrage du serveur '+serverName+'...\n')
		file.write('export JAVA_VENDOR=Oracle\n')
		file.write('export PRODUCTION_MODE=true\n')
		file.write('export USER_MEM_ARGS="-Xms1024m -Xmx1024m"\n')
		file.write('export PRE_CLASSPATH=.\n')
		file.write('./bin/startManagedWebLogic.sh '+serverName+' '+_adminAddr+':'+configFile.get('DOMAIN','adminServerPort')+' production\n')
		file.flush()
		file.close()
	print "Script cree avec succs."

	
def createDataSource(name, JNDINames, host, port, dbName, username, password, targets):
	print '\tCréation de la datasource '+name
	cd('/')
	datasource = create(name,'JDBCSystemResource')
	
	cd('/JDBCSystemResources/'+name+'/JdbcResource/'+name)
	set('Name',name)
	
	print '\tMise à jour de son nom JNDI'
	create('jdbcDataSourceParams','JDBCDataSourceParams')
	cd('JDBCDataSourceParams/NO_NAME_0')
	set("JNDIName", JNDINames)
	set('GlobalTransactionsProtocol','None') #OnePhaseCommit
	
	
	print '\tconfiguration du pool de connexions'
	cd('/JDBCSystemResources/'+name+'/JdbcResource/'+name)
	dbParam = create('dbParams','JDBCDriverParams')
	cd('JDBCDriverParams/NO_NAME_0')
	dbParam.setDriverName('oracle.jdbc.OracleDriver')
	set('URL', 'jdbc:oracle:thin:@'+host+':'+port+':'+dbName)
	dbParam.setPasswordEncrypted(password)
	
	
	dbProps = create('props','Properties')
	cd('Properties/NO_NAME_0')
	dbUser = create('user', 'Property')
	dbUser.setValue(username)
	
	'''
	dll = create('dll', 'Property')
	dll.setValue('ocijdbc9')
	protocol = create('protocol', 'Property')
	protocol.setValue('thin')
	'''
	cd('/JDBCSystemResources/'+name+'/JdbcResource/'+name)
	create('jdbcConnectionPoolParams','JDBCConnectionPoolParams')
	cd('JDBCConnectionPoolParams/NO_NAME_0')
	set('TestTableName','SQL SELECT 1 FROM DUAL')
	set('ShrinkFrequencySeconds',60)
	set('InitialCapacity',0)
	set('MaxCapacity',5)
			
	print '\tDéploiement sur la/les cible(s) suivante(s) : '+targets
	assign('JDBCSystemResource', name, 'Target', targets)	

def buildDomain():  
	print "Configuration du domaine."
	### Lecture du template de base
	#print "Lecture du template ", fileTemplate
	#readTemplate(fileTemplate)  
	selectTemplate('Basic WebLogic Server Domain','12.2.1.3.0')
	loadTemplates()
	#readTemplate(BEA_HOME+"/wlserver/common/templates/wls/wls.jar")
	#adminServerName="AdminServer"
	### Modify Domain Name
	
	set ('Name',domainName)
	set('AdminServerName',adminServerName)

	### Modification des proprietes du serveur d'Admin 
	print "Configuration du serveur d'administration."
	#cd('Servers/xxxyAdmin') 
	
	cd('Servers/AdminServer') 
	set ('Name',adminServerName) 
	set('ListenAddress', adminServerAddress)  
	set('ListenPort', int(adminServerPort))  

	create(adminServerName,'SSL')
	cd('SSL/'+adminServerName)
	set('Enabled','true')
	set('ListenPort',int(configFile.get('DOMAIN','adminServerSSLPort')))
	
	### Creation du user Admin  
	print "Configuration de l'utilisateur 'weblogic'."
	
	'''
	cd('/Security/'+domainName+'/User/weblogic')
	set('UserPassword','welcome1')
	'''
	
	cd('/Security/'+domainName+'/User')  
	delete('weblogic','User')  
	create(adminUser,'User')  
	cd(adminUser)  
	set('Password',adminPassword)  
	set('IsDefaultAdmin',1)  
	
	# Forcer le mode PRODUCTION sur le domaine
	cd('/')
	set('ProductionModeEnabled','true')

	# Forcer la creation d un cookie avec le domainName
	create(domainName,'AdminConsole')
	cd('AdminConsole/'+domainName)
	set('CookieName','ADMINCONSOLESESSION_'+domainName)

	# Emplacement des applications Fusion MiddleWare (EM par exemple)
	setOption('AppDir',appLocation)
	
	
	#setOption('OverwriteDomain', 'true')  
	print "Ecriture du domaine "+domainLocation+'/'+domainName
	writeDomain(domainLocation+'/'+domainName)  
	
	print "Fermeture des templates"
	closeTemplate()
	
	# Configuration 
	print "Lecture du domaine."
	readDomain(domainLocation+'/'+domainName)
	
	### Configuration de la partie Log du serveur d'administration
	print "Configuration des logs du serveur AdminServer..."
	cd ('/Servers/AdminServer')
	create('AdminServer','Log')
	cd ('/Servers/AdminServer/Log/AdminServer')
	set ('FileName','logs/AdminServer.log')
	set ('FileCount',5)
	set ('FileMinSize',5000)
	set ('FileTimeSpan',24)
	set ('RotationType','bySize')
	set ('RotateLogOnStartup','true')
	set ('NumberOfFilesLimited',7)
	set ('DomainLogBroadcastSeverity','Off')
	print "Configuration des logs du serveur AdminServer terminee avec succès."
	
	print "Configuration des logs HTTP du serveur AdminServer..."
	cd ('/Servers/AdminServer')
	create('AdminServer','WebServer')
	cd('WebServer/AdminServer')
	create('AdminServer','WebServerLog')
	cd ('WebServerLog/AdminServer')
	set ('LoggingEnabled','true')			
	set('RotationType','bySize')
	set('RotateLogOnStartup','true')
	set('FileCount',5)
	set('NumberOfFilesLimited',7)
	set('LogTimeInGMT','false')
	set('FileName','logs/access_AdminServer.log')
	set('FileMinSize',5000)
	set('LogFileFormat','extended')
	
	#set('ELFFields','date time cs-method cs-uri sc-status time-taken bytes')
	set('ELFFields','date time cs-method ctx-ecid ctx-rid cs-uri cs-uri-query sc-status bytes time-taken')
	
	print "Configuration des logs HTTP du serveur AdminServer terminee avec succès."
			
	
	### Création des machines
	print "\nCreation des machines..."
	nodeManagerPort=""
	nodeManagerType=""
	nodeManagerListenAddress=""
	machineId=1
	stop=false
	while stop==false:
		
		try:
			machineName=configFile.get('MACHINES','machine'+str(machineId)+'.name')
			print "Creation de la machine '"+machineName+"'"

			cd("/")
			create(machineName,'UnixMachine')
			print "Machine "+machineName+" creee avec succès."
			print "nodemanager.type:"+configFile.get('MACHINES','machine'+str(machineId)+'.nodemanager.type')
			if "" != configFile.get('MACHINES','machine'+str(machineId)+'.nodemanager.type'):
				# configuration nodemanager
				print "  Configuration du Node Manager"
				cd('/Machines/'+machineName)
				create(machineName,'NodeManager')
				cd('NodeManager/'+machineName)

				nodeManagerType=configFile.get('MACHINES','machine'+str(machineId)+'.nodemanager.type')
				nodeManagerListenAddress=configFile.get('MACHINES','machine'+str(machineId)+'.nodemanager.listenAddress')
				nodeManagerPort=configFile.get('MACHINES','machine'+str(machineId)+'.nodemanager.listenPort')
				#Utile pour le nodemanager properties
				nodeManagerStartScript=configFile.get('MACHINES','machine'+str(machineId)+'.nodemanager.startscriptenabled')

				set('NMType',nodeManagerType)
				set('listenAddress',nodeManagerListenAddress)
				set('listenPort',int(nodeManagerPort))

			'''
			cd("/Machines/" + machineName)
			print "setting attributes for UnixMachine" + machineName
			set("PostBindUID", PostBindUID)
			set("PostBindGIDEnabled", "true")
			set("PostBindUIDEnabled", "true")
			set("PostBindGID", PostBindGID)	
			'''
		except:
			dumpStack()
			stop=true
		
		machineId=machineId+1
	
	
	### Création des CLUSTERS

	print "\nCréation des clusters..."
	clusters=[]
	
	clusterId=1
	stop=false
	while stop==false:
		
		try:
			clusterName=configFile.get('CLUSTERS','cluster'+str(clusterId)+'.name')
			# unicast ou multicast
			mode=configFile.get('CLUSTERS','cluster'+str(clusterId)+'.messagingMode') 
			addr=configFile.get('CLUSTERS','cluster'+str(clusterId)+'.clusterAddress') 
			
			print "Creation du cluster '"+clusterName+"'"
			
			clusters.append(clusterName)
			
			cd('/')
			cluster=create(clusterName,"Cluster")
			cd('/Cluster/'+clusterName)
			set('ClusterMessagingMode',mode)
			set('ClusterAddress',addr)
			if mode=='multicast':
				set('MulticastAddress',configFile.get('CLUSTERS','cluster'+str(clusterId)+'.multicast.address') )
				set('MulticastPort',int(configFile.get('CLUSTERS','cluster'+str(clusterId)+'.multicast.port') ))
		except:
			dumpStack()
			stop=true
		
		clusterId=clusterId+1

	clusterTargets=''
	if len(clusters)>0:
		print str(len(clusters))+" cluster(s) cree(s)."
		for cluster in clusters:
			if clusterTargets != '':
				clusterTargets=clusterTargets+","+cluster
			else:
				clusterTargets=cluster

	### Création/Modification des serveurs managés
	managedServers=[]
	print "\nCreation des autres serveurs..."
	serverId=1
	stop=false
	while stop==false:
		
		try:
			serverName=configFile.get('SERVERS','server'+str(serverId)+'.name')
			cd('/')
			try:
				managedServer=cd('/Servers/'+serverName)
				print "\nModification du serveur '"+serverName+"'"
			except:
				print "\nCreation du serveur '"+serverName+"'"
				managedServer = create(serverName,'Server')				
			
			managedServers.append(managedServer)
			
			managedServer.setListenAddress(configFile.get('SERVERS','server'+str(serverId)+'.listenAddress'))
			managedServer.setListenPort(int(configFile.get('SERVERS','server'+str(serverId)+'.listenPort')))
			
			### Configuration de la partie Log des serveurs manages
			print "Configuration des logs du serveur '"+serverName+"'..."
			cd ('/Servers/'+serverName)
			create(serverName,'Log')
			cd ('/Servers/'+serverName+'/Log/'+serverName)
			set ('FileName',configFile.get('SERVERS','server'+str(serverId)+'.log.fileName'))
			set ('FileCount',int(configFile.get('SERVERS','server'+str(serverId)+'.log.fileCount')))
			set ('FileMinSize',int(configFile.get('SERVERS','server'+str(serverId)+'.log.fileMinSize')))
			set ('FileTimeSpan',int(configFile.get('SERVERS','server'+str(serverId)+'.log.fileTimeSpan')))
			set ('RotationType',configFile.get('SERVERS','server'+str(serverId)+'.log.rotationType'))
			set ('RotateLogOnStartup',configFile.get('SERVERS','server'+str(serverId)+'.log.rotateLogOnStartup'))
			set ('NumberOfFilesLimited',int(configFile.get('SERVERS','server'+str(serverId)+'.log.numberOfFilesLimited')))
			set ('DomainLogBroadcastSeverity','Off')
			print "Configuration des logs du serveur '"+serverName+"' terminee avec succès."
			
			print "Configuration des logs HTTP du serveur '"+serverName+"'..."
			cd ('/Servers/'+serverName)
			create(serverName,'WebServer')
			cd('WebServer/'+serverName)
			create(serverName,'WebServerLog')
			cd ('WebServerLog/'+serverName)
			set ('LoggingEnabled','true')			
			set('RotationType',configFile.get('SERVERS','server'+str(serverId)+'.log.http.rotationType'))
			set('RotateLogOnStartup',configFile.get('SERVERS','server'+str(serverId)+'.log.http.rotateLogOnStartup'))
			set('FileCount',int(configFile.get('SERVERS','server'+str(serverId)+'.log.http.fileCount')))
			set('NumberOfFilesLimited',int(configFile.get('SERVERS','server'+str(serverId)+'.log.http.numberOfFilesLimited')))
			set('LogTimeInGMT','false')
			set('FileName',configFile.get('SERVERS','server'+str(serverId)+'.log.http.fileName'))
			set('FileMinSize',int(configFile.get('SERVERS','server'+str(serverId)+'.log.http.fileMinSize')))
			set('LogFileFormat','extended')
			
			#set('ELFFields','date time cs-method cs-uri sc-status time-taken bytes')
			set('ELFFields','date time cs-method ctx-ecid ctx-rid cs-uri cs-uri-query sc-status bytes time-taken')
			
			print "Configuration des logs HTTP du serveur '"+serverName+"' terminee avec succès."

			
			print "Configuration de demarrage du serveur '"+serverName+"'..."
			cd ('/Servers/'+serverName)
			create(serverName,'ServerStart')
			cd('ServerStart/'+serverName)
			set('JavaHome',configFile.get('SERVERS','server'+str(serverId)+'.serverstart.javaHome'))
			set('BeaHome',configFile.get('SERVERS','server'+str(serverId)+'.serverstart.beaHome'))
			set('Arguments',configFile.get('SERVERS','server'+str(serverId)+'.serverstart.arguments'))
			set('Username',adminUser)
			set('PasswordEncrypted',adminPassword)
			set('JavaVendor',configFile.get('SERVERS','server'+str(serverId)+'.serverstart.javaVendor'))
			set('SecurityPolicyFile',configFile.get('SERVERS','server'+str(serverId)+'.serverstart.securityPolicyFile'))
			set('RootDirectory',configFile.get('SERVERS','server'+str(serverId)+'.serverstart.rootDirectory'))
			set('ClassPath',configFile.get('SERVERS','server'+str(serverId)+'.serverstart.classPath')) 

			
			print "Configuration SSL du serveur "+serverName
			cd('/Servers/'+serverName)
			create(serverName,'SSL')
			cd('SSL/'+serverName)
			set('Enabled','true')
			set('ListenPort',int(configFile.get('SERVERS','server'+str(serverId)+'.listenSSLPort')))

			
			print "Affectation du serveur a une machine..."
			try:
				machine=configFile.get('SERVERS','server'+str(serverId)+'.machine')
				if machine != None and machine != '': 
					print "Affectation du serveur "+serverName+" a la machine '"+machine+"'"
					cd('/Servers/'+serverName)
					set('Machine',machine)
					print "Affectation realisee avec succès."
				else:
					print "Le serveur "+serverName+" n'est pas affecte a une machine."
			except:
				dummy=""
				
			print "Affectation du serveur a un cluster..."
			try:
				cluster=configFile.get('SERVERS','server'+str(serverId)+'.cluster')
				if cluster != None and cluster != '': 
					print "Affectation du serveur "+serverName+" au cluster '"+cluster+"'..."
					cd('/Servers/'+serverName)
					set('Cluster',cluster)
					print "Affectation realisee avec succès."
				else:
					print "Le serveur "+serverName+" n'est pas affecte a un cluster."
			except:
				dummy=""
				
			createServerStartScript(domainLocation+'/'+domainName,serverName)
			createServerStopScript(domainLocation+'/'+domainName,serverName)
			
			
			# copie du boot.properties pour chaque serveur
			src=domainLocation+'/'+domainName+'/servers/'+configFile.get('DOMAIN','adminServerName')+'/security/boot.properties'
			dest=domainLocation+'/'+domainName+'/servers/'+serverName
			try:
				print "\tCreation du repertoire "+dest
				os.mkdir(dest)
				dest=domainLocation+'/'+domainName+'/servers/'+serverName+'/security'
				print "\tCreation du repertoire "+dest
				os.mkdir(dest)
				repDest=os.path.abspath(dest)
				repSrc=os.path.abspath(src)
				
				print 'Copie de '+repSrc+' vers '+repDest
				shutil.copy(repSrc,repDest)
				'''
				osname=System.getProperty("os.name")
				p=osname.find("Windows")
				if p >=0:
					print "Copie Windows"
					print "copy %s %s" % (repSrc, repDest)
					os.system ("copy %s %s" % (repSrc, repDest))
				else:
					print "Copie Unix/Linux"
					print "cp %s %s" % (repSrc,repDest)
					os.system ("cp %s %s" % (repSrc, repDest))
				'''
				print "Copie terminee avec succès."
		
			except:
				print "Erreur lors de la copie du fichier boot.properties"
				dumpStack()
				stop=true
		except:
			#print "Erreur lors de la création du serveur..."
			#dumpStack()
			stop=true
		
		serverId=serverId+1	

	print "Ecriture du domaine."
	updateDomain() 

	print "Fermeture du domaine."
	closeDomain()
	#closeTemplate()	

	print "Lecture du domaine."
	readDomain(domainLocation+'/'+domainName)
	
	### Création des datasources à partir du .properties
	print "\nCreation des datasources JDBC..."
	
	workDone=False
	dsId=1
	stop=false
	while stop==false:
		
		try:
			dsName=configFile.get('DOMAIN','datasource'+str(dsId)+'.name')
			print "Creation de la datasource JDBC '"+dsName+"'"
			jndiStr=configFile.get('DOMAIN','datasource'+str(dsId)+'.jndi')
			jndi = jndiStr.split(',')
			host=configFile.get('DOMAIN','datasource'+str(dsId)+'.host')
			port=configFile.get('DOMAIN','datasource'+str(dsId)+'.port')
			dbName=configFile.get('DOMAIN','datasource'+str(dsId)+'.dbname')
			username=configFile.get('DOMAIN','datasource'+str(dsId)+'.username')
			password=configFile.get('DOMAIN','datasource'+str(dsId)+'.password')
			tgs=configFile.get('DOMAIN','datasource'+str(dsId)+'.targets')
			
			createDataSource(dsName,jndi,host,port,dbName,username,password,tgs)

			print "Datasource JDBC "+dsName+" creee avec succès.\n"
			workDone=True
		except:
			stop=true
			pass
		
		dsId=dsId+1	
	
	if workDone==True:
		print "Datasources JDBC creees avec succès."
	
		print "Ecriture du domaine."
		updateDomain() 

	print "Fermeture du domaine."
	closeDomain()
	
	updateDomainStartScript(domainLocation+'/'+domainName)
	#createCustomSetEnvScript(domainLocation+'/'+domainName)
	
	print "Lecture du domaine."
	readDomain(domainLocation+'/'+domainName)
	workDone=False
	
	try:
		mailSessionName = configFile.get('DOMAIN','mailsession.name')
		if (len(mailSessionName)>0):
			print "Création du mail session '"+mailSessionName+"'..."
			cd('/')
			create(mailSessionName,'MailSession')
			cd('/MailSession/'+mailSessionName)
			set('JNDIName',configFile.get('DOMAIN','mailsession.jndi'))
			set('Properties',configFile.get('DOMAIN','mailsession.properties'))
			set('Targets',configFile.get('DOMAIN','mailsession.targets'))
			
			print "Création du mail session '"+mailSessionName+"' terminée avec succès."
			workDone=True
	except:
		print "Aucun composant mail session a créer."
   
	if workDone==True:
		print "Ecriture du domaine."
		updateDomain() 

	print "Fermeture du domaine."
	closeDomain()

	print "Lecture du domaine."
	readDomain(domainLocation+'/'+domainName)
	
	### Creation du mdp/login NodeManager  
	print "Configuration du login/mdp nodemanager '."
	cd('/')
	cd('/SecurityConfiguration/'+domainName)
	set('NodeManagerUsername',adminUser)
	set('NodeManagerPasswordEncrypted',adminPassword)
	
	print "Ecriture du domaine."
	updateDomain() 

	print "Fermeture du domaine."
	closeDomain()

	if "" != nodeManagerType:
		print "Mise à jour du fichier de configuration du Node Manager"

		updateNodeManagerConfigFile(domainLocation+'/'+domainName,nodeManagerType,nodeManagerListenAddress,nodeManagerPort,nodeManagerStartScript)
		print "Mise à jour terminée avec succès"

	
	# Copie des fichiers de conf. dans le répertoire conf du domaine
	'''
	print "\n\nCopie des fichiers de configuration..."
	try:
		logDir=domainLocation+'/'+domainName+'/logs'
		print "\tCreation du repertoire "+logDir
		os.mkdir(logDir)
		osname=System.getProperty("os.name")
		p=osname.find("Windows")
		if p >=0:
			filename1='./conf'
			filename2=domainLocation+'/'+domainName+'/conf'

			print "\tCreation du repertoire "+filename2
			os.mkdir(filename2)

			#os.system ("md %s " % (filename2))
			# conversion automatique du chemin en fonction de l'OS
			rep=os.path.abspath(filename2)
			src=os.path.abspath(filename1)

			print 'Copie de '+src+' vers '+rep

			print "Copie Windows"
			print "copy %s %s" % (src, rep)
			# xcopy /S conf F:\Missions\SNECMA\CWC\domains\test\conf
			os.system ("xcopy /S %s %s" % (src, rep))
		else:
			filename1='./conf'
			filename2=domainLocation+'/'+domainName+'/'

			# conversion automatique du chemin en fonction de l'OS
			rep=os.path.abspath(filename2)
			src=os.path.abspath(filename1)

			print 'Copie de '+src+' vers '+rep

			print "Copie Unix/Linux"
			print "cp -R %s %s" % (src, rep)
			os.system ("cp -R %s %s" % (src, rep))
		print "Copie terminee avec succes."
	except:
		print "Une erreur s'est produite lors de la copie !"
		dumpStack()
	'''

def printConfirmation():  
	### Print Confirmation  
	print "##################################################################"  
	print "Création d'un Domaine avec les valeurs suivantes :" 
	print "Nom du Domaine =				%s " % domainName  
	print "Type de domaine =				%s " % _domainType  
	print "Path de configuration du Domaine =	%s " % domainLocation  
	print "User admin =				%s " % adminUser  
	print "Password du user admin =			%s " % adminPassword  
	print "Nom du serveur d'administration =	%s " % adminServerName
	print "Host du serveur d'administration =	%s " % adminServerAddress  
	print "Port du serveur d'administration =	%s " % adminServerPort  
	print "##################################################################"

### Main  
import sys  
import string

import os
import ConfigParser
import shutil

global configFile
configFile = ConfigParser.ConfigParser()

BEA_HOME=os.environ.get("BEA_HOME")
if BEA_HOME=='':
	print "La variable d'environnement BEA_HOME doit etre renseignée pour que ce script fonctionne."
	exit("",100)

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
s = "Version "+VERSION
s = s.center(76)
print "*",s,"*"
print "*"," "*76,"*"
print "*"," "*76,"*"
print "*"*80
	

### Lecture des arguments 
fileProperties = sys.argv[1]  
#fileTemplate = sys.argv[2]

### Lecture du fichier de proprietes propre a l'application  
print('Lecture du fichier de propriétés : \"' + fileProperties + '\"' )  
try:  
	loadProperties(fileProperties)
	print "Domain Location : ",domainLocation
	print "Domain Name : ",domainName
	
	configFile.read(fileProperties)
	_domainType=configFile.get('DOMAIN','type')

	_adminAddr = configFile.get('DOMAIN','adminServerAddress')
	if 0 == len(_adminAddr.strip()):
		# Si ecoute sur toutes les cartes, acces par localhost
 		_adminAddr = "localhost"
	
	### Appel de buildDomain  
	buildDomain()  
	### Defintion printConfirmation  
	printConfirmation()  

except Exception, e:  
	print "==> Erreur : " 
	print e  
	exit("",100)
exit("",0) 

