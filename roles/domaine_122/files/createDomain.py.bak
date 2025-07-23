'''

createDomain.py

Script WLST de création d'un domaine

Auteur : Emmanuel Collin / Oracle pour CPRP SNCF

Release Notes :
---------------
	   		
26/09/2013 - Version 1.0 du script
10/10/2013 - Version 1.1
				Ajout du déploiement des applications
				Ajout du déploiement des Shared Libs
				Ajout d'une propriété "type" dans le fichier .properties pour indiquer s'il faut créer un domaine WLS ou WLP

'''

VERSION = "1.1"

def targetLib(libName,targets):
	print '\tCiblage de la librairie '+libName+' sur '+targets
	cd('/Library/'+libName)
	set('Target',targets)
	
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

def updateDomainWlsStartWebLogicScript(domainPath):
	filename="startWebLogic.sh"

        print "Mise a jour du script "+filename

        # Path du fichier
        scriptPath = domainPath + "/bin/"+filename
        curScriptPath = scriptPath
        newScriptPath = scriptPath + ".new"

        # Lecture du courant vers nouveau avec filtre sur la ligne set DOMAIN_HOME=
        curFile = open(curScriptPath, "r")
        newFile = open(newScriptPath, "w")
        curLine = curFile.readline()
        while ("" != curLine):
                if 0 <= curLine.find(". ${DOMAIN_HOME}/bin/setDomainEnv.sh $*"):
                        newFile.write(". ${DOMAIN_HOME}/bin/setDomainEnv.sh $*\n\n")
			newFile.write("PRODUCTION_MODE=true\n")
			newFile.write("export PRODUCTION_MODE\n\n")
			newFile.write("DERBY_FLAG=false\n")
			newFile.write("export DERBY_FLAG\n\n")
			newFile.write("JAVA_OPTIONS=\"${JAVA_OPTIONS} -Djava.security.egd=file:/dev/./urandom \"\n\n")
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
	print "Creation du script d'arret du serveur "+serverName+"..."
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
	print "Script cree avec succes."

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
		print "Script cree avec succes."
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
        print "Script cree avec succes."

	
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
	
	### Lecture du template de base
	#print "Lecture du template ", fileTemplate
	#readTemplate(fileTemplate)  
	readTemplate(BEA_HOME+"/wlserver/common/templates/wls/wls.jar")
	#adminServerName="AdminServer"
	### Modify Domain Name
	print "Configuration du domaine."
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
	set('UserPassword','weblogic0')
	'''
	
	cd('/Security/'+domainName+'/User')  
	delete('weblogic','User')  
	create(adminUser,'User')  
	cd(adminUser)  
	set('Password',adminPassword)  
	set('IsDefaultAdmin',1)  

	# Forcer le mode PRODUCTION sur le domaine
	cd('/')
	set('ProductionModeEnabled','false')


	# Forcer la creation d un cookie avec le domainName
        create(domainName,'AdminConsole')
	cd('AdminConsole/'+domainName)
        set('CookieName','ADMINCONSOLESESSION_'+domainName)

	### Ecriture du Domaine  
	setOption('OverwriteDomain', 'true')  
	print "Ecriture du domaine."
	writeDomain(domainLocation+'/'+domainName)  
	
	print "Fermeture du template."

	closeTemplate()

	### Application des Templates requis pour WLP
	print "Lecture du domaine."
	readDomain(domainLocation+'/'+domainName)
	
	if ("WLP"==_domainType):
		print "Application des templates requis pour un domaine Weblogic Portal."
		addTemplate(BEA_HOME+"/wlserver/common/templates/applications/wls_webservice.jar")
		addTemplate(BEA_HOME+"/wlportal/workshop/common/templates/applications/workshop_wl.jar")
		addTemplate(BEA_HOME+"/wlportal/common/templates/applications/p13n.jar")
		addTemplate(BEA_HOME+"/wlportal/common/templates/applications/content.jar")
		addTemplate(BEA_HOME+"/wlportal/common/templates/applications/wlp.jar")
		#addTemplate(BEA_HOME+"/wlportal/common/templates/applications/wsrp-simple-producer.jar")

		print "Creation de la base de donnees..."
		print "mise a jour de la datasource p13nDataSource"
		cd('/JDBCSystemResource/p13nDataSource/JdbcResource/p13nDataSource/JDBCDriverParams/NO_NAME_0')
		set("DriverName",wlpDatabaseDriver)
		set("PasswordEncrypted",wlpDatabasePassword)
		set("URL",wlpDatabaseURL)
		cd('/JDBCSystemResource/p13nDataSource/JdbcResource/p13nDataSource/JDBCDriverParams/NO_NAME_0/Properties/NO_NAME_0/Property/user')
		set('Value',wlpDatabaseUser)
		cd('/JDBCSystemResource/p13nDataSource/JdbcResource/p13nDataSource/JDBCConnectionPoolParams/NO_NAME_0')
		set('TestTableName',wlpDatabaseTestTableName)
		print "Chargement du schema sql WLP + donnees..."
		
		loadDB(configFile.get('DOMAIN','wlp.database.version'), 'p13nDataSource')
		
		print "Creation de la base de donnees terminee."

	
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
	print "Configuration des logs du serveur AdminServer terminee avec succes."
	
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
	set('ELFFields','date time cs-method cs-uri cs-uri-query sc-status bytes time-taken')
	print "Configuration des logs HTTP du serveur AdminServer terminee avec succes."
			
	
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
			print "Machine "+machineName+" creee avec succes."
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

	print "\nCreation des clusters..."
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
				print "Mise a jour des Datasources JDBC."
				
	### Création des serveurs managés
	print "\nCreation des serveurs..."
	serverId=1
	stop=false
	while stop==false:
		
		try:
			serverName=configFile.get('SERVERS','server'+str(serverId)+'.name')
			print "\nCreation du serveur '"+serverName+"'"

			cd('/')
			managedServer = create(serverName,'Server')
			managedServer.setListenAddress(configFile.get('SERVERS','server'+str(serverId)+'.listenAddress'))
			managedServer.setListenPort(int(configFile.get('SERVERS','server'+str(serverId)+'.listenPort')))
			print serverName+' cree avec succes.'
			
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
			print "Configuration des logs du serveur '"+serverName+"' terminee avec succes."
			
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
                        set('ELFFields','date time cs-method cs-uri cs-uri-query sc-status bytes time-taken')
                        print "Configuration des logs HTTP du serveur '"+serverName+"' terminee avec succes."

			
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
					print "Affectation realisee avec succes."
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
					print "Affectation realisee avec succes."
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
				print "Copie terminee avec succes."
		
			except:
				print "Erreur lors de la copie du fichier boot.properties"
				dumpStack()
				stop=true
			

		except:
			#print "Erreur lors de la création du serveur..."
			dumpStack()
			stop=true
		
		serverId=serverId+1	


	if ("WLP"==_domainType):
		### Mise a jour des DATASOURCES JDBC utilisees par WLP
		# Mise à jour de la datasource cgDataSource
		#=======================================================================================	
		print "\nMise a jour des datasources JDBC specifiques a Weblogic Portal..."
		cd('/JDBCSystemResource/cgDataSource/JdbcResource/cgDataSource/JDBCDriverParams/NO_NAME_0')
		set("DriverName",wlpDatabaseDriver)
		set("PasswordEncrypted",wlpDatabasePassword)
		set("URL",wlpDatabaseURL)
		cd('/JDBCSystemResource/cgDataSource/JdbcResource/cgDataSource/JDBCDriverParams/NO_NAME_0/Properties/NO_NAME_0/Property/user')
		set('Value',wlpDatabaseUser)
		cd('/JDBCSystemResource/cgDataSource/JdbcResource/cgDataSource/JDBCConnectionPoolParams/NO_NAME_0')
		set('TestTableName',wlpDatabaseTestTableName)
		set('ShrinkFrequencySeconds',60)
		set('InitialCapacity',0)
		set('MaxCapacity',5)
		cd('/JDBCSystemResources/cgDataSource')
		set('Target',wlpDatabaseTargets)

		# Mise à jour de la datasource cgDataSource-nonXA
		#=======================================================================================	
		cd('/JDBCSystemResource/cgDataSource-nonXA/JdbcResource/cgDataSource-nonXA/JDBCDriverParams/NO_NAME_0')
		set("DriverName",wlpDatabaseDriver)
		set("PasswordEncrypted",wlpDatabasePassword)
		set("URL",wlpDatabaseURL)
		cd('/JDBCSystemResource/cgDataSource-nonXA/JdbcResource/cgDataSource-nonXA/JDBCDriverParams/NO_NAME_0/Properties/NO_NAME_0/Property/user')
		set('Value',wlpDatabaseUser)
		cd('/JDBCSystemResource/cgDataSource-nonXA/JdbcResource/cgDataSource-nonXA/JDBCConnectionPoolParams/NO_NAME_0')
		set('TestTableName',wlpDatabaseTestTableName)
		set('ShrinkFrequencySeconds',60)
		set('InitialCapacity',0)
		set('MaxCapacity',5)
		cd('/JDBCSystemResources/cgDataSource-nonXA')
		set('Target',wlpDatabaseTargets)

		# Mise à jour de la datasource p13nDataSource
		#=======================================================================================	
		cd('/JDBCSystemResource/p13nDataSource/JdbcResource/p13nDataSource/JDBCDriverParams/NO_NAME_0')
		set("DriverName",wlpDatabaseDriver)
		set("PasswordEncrypted",wlpDatabasePassword)
		set("URL",wlpDatabaseURL)
		cd('/JDBCSystemResource/p13nDataSource/JdbcResource/p13nDataSource/JDBCDriverParams/NO_NAME_0/Properties/NO_NAME_0/Property/user')
		set('Value',wlpDatabaseUser)
		cd('/JDBCSystemResource/p13nDataSource/JdbcResource/p13nDataSource/JDBCConnectionPoolParams/NO_NAME_0')
		set('TestTableName',wlpDatabaseTestTableName)
		set('ShrinkFrequencySeconds',60)
		set('InitialCapacity',0)
		set('MaxCapacity',5)
		cd('/JDBCSystemResources/p13nDataSource')
		set('Target',adminServerName+","+wlpDatabaseTargets)

		# Mise à jour de la datasource portalDataSource
		#=======================================================================================	
		cd('/JDBCSystemResource/portalDataSource/JdbcResource/portalDataSource/JDBCDriverParams/NO_NAME_0')
		set("DriverName",wlpDatabaseDriver)
		set("PasswordEncrypted",wlpDatabasePassword)
		set("URL",wlpDatabaseURL)
		cd('/JDBCSystemResource/portalDataSource/JdbcResource/portalDataSource/JDBCDriverParams/NO_NAME_0/Properties/NO_NAME_0/Property/user')
		set('Value',wlpDatabaseUser)
		cd('/JDBCSystemResource/portalDataSource/JdbcResource/portalDataSource/JDBCConnectionPoolParams/NO_NAME_0')
		set('TestTableName',wlpDatabaseTestTableName)
		set('ShrinkFrequencySeconds',60)
		set('InitialCapacity',0)
		set('MaxCapacity',5)
		cd('/JDBCSystemResources/portalDataSource')
		set('Target',wlpDatabaseTargets)

		# Mise à jour de la datasource portalDataSourceAlwaysXA
		#=======================================================================================	
		cd('/JDBCSystemResource/portalDataSourceAlwaysXA/JdbcResource/portalDataSourceAlwaysXA/JDBCDriverParams/NO_NAME_0')
		set("DriverName",wlpDatabaseDriver)
		set("PasswordEncrypted",wlpDatabasePassword)
		set("URL",wlpDatabaseURL)
		cd('/JDBCSystemResource/portalDataSourceAlwaysXA/JdbcResource/portalDataSourceAlwaysXA/JDBCDriverParams/NO_NAME_0/Properties/NO_NAME_0/Property/user')
		set('Value',wlpDatabaseUser)
		cd('/JDBCSystemResource/portalDataSourceAlwaysXA/JdbcResource/portalDataSourceAlwaysXA/JDBCConnectionPoolParams/NO_NAME_0')
		set('TestTableName',wlpDatabaseTestTableName)
		set('ShrinkFrequencySeconds',60)
		set('InitialCapacity',0)
		set('MaxCapacity',5)
		cd('/JDBCSystemResources/portalDataSourceAlwaysXA')
		set('Target',wlpDatabaseTargets)
		
		# Mise à jour de la datasource portalDataSourceNeverXA
		#=======================================================================================	
		cd('/JDBCSystemResource/portalDataSourceNeverXA/JdbcResource/portalDataSourceNeverXA/JDBCDriverParams/NO_NAME_0')
		set("DriverName",wlpDatabaseDriver)
		set("PasswordEncrypted",wlpDatabasePassword)
		set("URL",wlpDatabaseURL)
		cd('/JDBCSystemResource/portalDataSourceNeverXA/JdbcResource/portalDataSourceNeverXA/JDBCDriverParams/NO_NAME_0/Properties/NO_NAME_0/Property/user')
		set('Value',wlpDatabaseUser)
		cd('/JDBCSystemResource/portalDataSourceNeverXA/JdbcResource/portalDataSourceNeverXA/JDBCConnectionPoolParams/NO_NAME_0')
		set('TestTableName',wlpDatabaseTestTableName)
		set('ShrinkFrequencySeconds',60)
		set('InitialCapacity',0)
		set('MaxCapacity',5)
		cd('/JDBCSystemResources/portalDataSourceNeverXA')
		set('Target',adminServerName+","+wlpDatabaseTargets)
		
	print "Ecriture du domaine."
	updateDomain() 

	print "Fermeture du domaine."
	closeDomain()
	closeTemplate()	

	print "Lecture du domaine."
	readDomain(domainLocation+'/'+domainName)
	
	### Création des datasources à partir du .properties
	print "\nCreation des datasources JDBC..."
	
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

			print "Datasource JDBC "+dsName+" creee avec succes.\n"

		except:
			dumpStack()
			stop=true
		
		dsId=dsId+1	
	
	print "Datasources JDBC creees avec succes."
	
	print "Ecriture du domaine."
	updateDomain() 

	print "Fermeture du domaine."
	closeDomain()
	
	updateDomainStartScript(domainLocation+'/'+domainName)
	updateDomainWlsStartWebLogicScript(domainLocation+'/'+domainName)
	
	print "Lecture du domaine."
	readDomain(domainLocation+'/'+domainName)
	
	try:
		mailSessionName = configFile.get('DOMAIN','mailsession.name')
		if (len(mailSessionName)>0):
			print "Creation du mail session '"+mailSessionName+"'..."
			cd('/')
			create(mailSessionName,'MailSession')
			cd('/MailSession/'+mailSessionName)
			set('JNDIName',configFile.get('DOMAIN','mailsession.jndi'))
			set('Properties',configFile.get('DOMAIN','mailsession.properties'))
			set('Targets',configFile.get('DOMAIN','mailsession.targets'))
			
			print "Creation du mail session '"+mailSessionName+"' terminee avec succes."
	except:
		print "Aucun composant mail session a créer."

	if ("WLP"==_domainType):
		print "\nModification de la configuration du Security Store..."
		# Security Store
		cd('/SecurityConfiguration/'+domainName+'/Realm/myrealm/RDBMSSecurityStore/p13nRDBMSSecurityStore')
		set('ConnectionProperties','user='+wlpDatabaseUser)
		set('ConnectionURL',wlpDatabaseURL)
		set('DriverName',wlpDatabaseDriver)
		set('PasswordEncrypted',wlpDatabasePassword)
		set('Username',wlpDatabaseUser)
		print "Modification de la configuration du Security Store terminée avec succes."
	
	# TARGET DES SHARED LIB
	if clusterTargets != '':
		print "\nDeploiement des Shared Libs..."
		
		cd('/')
		libs = cmo.getLibraries()
		for lib in libs:
			targetLib(lib.getName(),clusterTargets)
	print "Ecriture du domaine."
	updateDomain() 

	print "Fermeture du domaine."
	closeDomain()

	if "" != nodeManagerType:
		print "Mise àour du fichier de configuration du Node Manager"

		updateNodeManagerConfigFile(domainLocation+'/'+domainName,nodeManagerType,nodeManagerListenAddress,nodeManagerPort,nodeManagerStartScript)
		print "Mise àour terminéavec succes"

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

	# Copie de l'identity Asserter dans le répertoire lib/mbeantypes du domaine créé
	if ("WLP"==_domainType):
		print "\n\nCopie de l'identity asserter dans le repertoire lib/mbeantypes du domaine "+domainName
		try:
			filename1='./lib/mbeantypes/*.*'
			filename2=domainLocation+'/'+domainName+'/lib/mbeantypes'
			
			print "\tCreation du repertoire "+filename2
			os.mkdir(filename2)
			
			#os.system ("md %s " % (filename2))
			# conversion automatique du chemin en fonction de l'OS
			rep=os.path.abspath(filename2)
			src=os.path.abspath(filename1)
			
			print 'Copie de '+src+' vers '+rep
			osname=System.getProperty("os.name")
			p=osname.find("Windows")
			if p >=0:
				print "Copie Windows"
				print "copy %s %s" % (src, rep)
				os.system ("copy %s %s" % (src, rep))
			else:
				print "Copie Unix/Linux"
				print "cp %s %s" % (src, rep)
				os.system ("cp %s %s" % (src, rep))
			print "Copie terminee avec succes."
		except:
			print "Une erreur s'est produite lors de la copie !"
			dumpStack()

def printConfirmation():  
	### Print Confirmation  
	print "##################################################################"  
	print "Creation d'un Domaine avec les valeurs suivantes :" 
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
### CreateDomain.py  
import sys  
import string

import os
import ConfigParser
import shutil

global configFile
configFile = ConfigParser.ConfigParser()

BEA_HOME=os.environ.get("BEA_HOME")
if BEA_HOME=='':
	print "La variable d'environnement BEA_HOME doit etre renseignee pour que ce script fonctionne."
	exit("",100)

'''
global wlpDatabaseURL
global wlpDatabaseDriver
global wlpDatabaseUser
global wlpDatabasePassword
global wlpDatabaseTestTableName
'''
print "*"*80
print "*"," "*76,"*"
print "*"," "*76,"*"

s = "CPRP SNCF"
s = s.center(76)
print "*",s,"*"
print "*"," "*76,"*"

s = "Creation d'un domaine Weblogic Server 12c"
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
print('Lecture du fichier de proprietes : \"' + fileProperties + '\"' )  
try:  
	loadProperties(fileProperties)
	
	configFile.read(fileProperties)
	_domainType=configFile.get('DOMAIN','type')

	if "WLP"==_domainType:
		wlpDatabaseURL=configFile.get('DOMAIN','wlp.database.url')
		wlpDatabaseDriver=configFile.get('DOMAIN','wlp.database.driver')
		wlpDatabaseUser=configFile.get('DOMAIN','wlp.database.user')
		wlpDatabasePassword=configFile.get('DOMAIN','wlp.database.password')
		wlpDatabaseTestTableName=configFile.get('DOMAIN','wlp.database.testTableName')
		wlpDatabaseTargets=configFile.get('DOMAIN','wlp.database.targets')

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

