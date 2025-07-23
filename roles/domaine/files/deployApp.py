'''

deployApp.py

Auteur : CPRP SNCF ORACLE

'''

### Main
### deployApp.py
import sys
import string

import os
import ConfigParser
import shutil

# Deploiment des librairies partagees specifiques projet
def deployProjectLibraries():
	print "\nDeploiement des librairies partagees specifiques au projet..."

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
				print "\n\nERREUR\nLa librairie "+appPath+" est introuvable, elle ne sera pas déployee."
		except:
			dumpStack()
			stop=true
		
		appId=appId+1
 

# Deploiement d'une librairie partagee projet
def deployProjectLibrary(name, path, _targets):
  print "Deploiement de la librairie " + name+" "+path+" sur "+_targets
		
   
  # Deploiement (avec objet progess, appel apparement bloquant sur l'execution : pas besoin d'attendre sa terminaison explicitement)
  redirect("./Step2.log", "false")
  # _progress = deploy(psLibraryName, psLibrarySourceDir + "/" + _libSourceFile, targets="AdminServer", stageMode="nostage", libraryModule="true")
  _progress = deploy(name, path, targets=_targets, stageMode="nostage", libraryModule="true")
  _progress = None
  stopRedirect()
# Deploiement de l'application

def checkApp_todeploy():

        print "\n\n"
        print "*"*48
        s = "Liste des applications a deployer"
        s = s.center(44)
        print "*",s,"*"
        print "*"*48
	listApp_todeploy = []
	Apps=ls('serverConfig:/AppDeployments',returnMap='true')
	appId=1
	stop=false
	while stop==false:

		try:
			appName=configFile.get('APPLICATIONS','app'+str(appId)+'.name')
			appPath=configFile.get('APPLICATIONS','app'+str(appId)+'.path')
			appDestPath=configFile.get('APPLICATIONS','app'+str(appId)+'.destpath')
			targets=configFile.get('APPLICATIONS','app'+str(appId)+'.targets')
			propPath=configFile.get('APPLICATIONS','app'+str(appId)+'.pathproperties')
			propDestPath=configFile.get('APPLICATIONS','app'+str(appId)+'.destpathproperties')
			appNameNoVersion=nameApp(appName)
			if(os.path.exists(appPath)):
				print ("\n* Application" + str(appId) + " : " + appName )
                                #        print "\n\t-> L application existe deja :"
				AppExist=false
				deployedAppName=''
				for deployedApp in Apps:
					deployedAppNoVersion=nameApp(deployedApp)
					# deployedAppNoVersion est le nom hors num de version et prefixe (ex:EP-TS)
					if(appNameNoVersion==deployedAppNoVersion):
						AppExist=true
						deployedAppName=deployedApp
				if(AppExist==true):	
					print "\n\t-> L application existe deja :"
					print "\n\t*Application en cours d execution :"+deployedAppName
                                        print "\t*Application disponible             : "+appName
                                        returnList = questionFunc(appName,appId)
                                        if ( returnList != 'nodeploy' ):
                                       		listApp_todeploy.append(returnList)
				else:
					print "\n\t-> L application n existe pas "
					print "\t*    Application a deployer : "+appName
					returnList = questionFunc(appName,appId)
					if ( returnList != 'nodeploy' ):
						listApp_todeploy.append(returnList)
		except:
			dumpStack()
			stop=true

		appId=appId+1
	if ( listApp_todeploy != []):
		deployApplications(listApp_todeploy)
	

def deployApplications(listapptodeploy):
	
	print "\nDeploiement des applications..."
	stop=false
	for appId in listapptodeploy:
		
		try:
			appName=configFile.get('APPLICATIONS','app'+str(appId)+'.name')
			appPath=configFile.get('APPLICATIONS','app'+str(appId)+'.path')
			appDestPath=configFile.get('APPLICATIONS','app'+str(appId)+'.destpath')
			targets=configFile.get('APPLICATIONS','app'+str(appId)+'.targets')
			propPath=configFile.get('APPLICATIONS','app'+str(appId)+'.pathproperties');
			propDestPath=configFile.get('APPLICATIONS','app'+str(appId)+'.destpathproperties');
			if (appName != ""):
				print "*"*24
                        	s = "app"+str(appId)
                        	s = s.center(20)
                        	print "*",s,"*"
                        	print "*"*24
			# Existence d une application a deployer dans
			if (os.path.exists(appPath)):
				dest=domainLocation+'/'+domainName+'/'+appDestPath
				repDest=os.path.abspath(dest)
				repSrc=os.path.abspath(appPath)
				appNameOffLine=appPath.split("/")
				appDestNameNew=dest+'/'+appNameOffLine[-1]
				if (os.path.exists(dest)):
					try:
                                        	# Recherche du nom physique de l 'appli ex: test.ear
						cd('serverConfig:/AppDeployments/'+appName)
                                        	appNameOnLine=cmo.getSourcePath().split("/")
                                        	appDestNameOld=dest+'/'+appNameOnLine[-1]
						# Existence de l'appli -> undeploy
                                        	if (os.path.exists(appDestNameOld)):
							stoppingApplication(appName)
							print "\t\n"
                                                	undeployApplication(appName, targets)
                                	except Exception, e:
                                        	print "Pas d application existante :"+appName
                                        	print e
                                        	print sys.exc_info()[0]
					# Copie de la nouvelle version de l'appli
					fileCopy(repSrc,repDest)
				else:
					try:
						print "\tCreation du repertoire de l application "+dest
						os.mkdir(dest)
						fileCopy(repSrc,repDest)
					except:
						print "\tErreur lors de la copie de l application"
						dumpStack()
						stop=true			
				deployApplication(appName, appDestNameNew, targets)
				print "\t\n"
				startingApplication(appName)
			else:
				print "\n\nPas d'application a deployer\nVerifier votre fichier domain_hostname.properties."
			# Exitence d un fichier properties
			if (os.path.exists(propPath)):
				#dest=domainLocation+'/'+domainName+'/config/'+propDestPath
				dest=propDestPath
				repDest=os.path.abspath(dest)
				repSrc=os.path.abspath(propPath)
				if (os.path.exists(dest)):
					fileCopy(repSrc,repDest)
				else:	
					try:
						print "\tCreation du repertoire properties "+dest
						os.mkdir(dest)
						fileCopy(repSrc,repDest)
					except:
						print "\tErreur lors de la copie du fichier properties"
						dumpStack()
						stop=true				
		except:
			dumpStack()
			stop=true
		
		appId=appId+1


def nameApp(app):
	appTrunc=app.rfind('-')
        if(appTrunc == -1):
		appNameTrunc=app
        else:
		appNameTrunc=app[appTrunc+1:]
	return appNameTrunc


def questionFunc(app_name,app_id):
	reponse=raw_input("\n\t-> Souhaitez-vous deployer le nouveau livrable dispo (oui/non) ? ")
	if (reponse == "oui"):
		print "\t <<===  L'application "+app_name+" va etre deployee ===>>"
		return app_id
	else:
		print "\t <<===  L application "+app_name+" ne sera pas deployee ===>>"
		return 'nodeploy'

def stoppingApplication(app_name):
	print "\tARRET DE L APPLICATION "+app_name
	try:
            editing()
            progress=stopApplication(app_name,timeout=360000)
            progress.printStatus()
            activating()
	except:
            print '\tFAILED TO STOP THE APPLICATION'
            print dumpStack()
   
	print '\tAPPLICATION ARRETEE'			
	
def startingApplication(app_name):
	print "\tDEMARRAGE DE L APPLICATION "+app_name
        try:
            editing()
            progress=startApplication(app_name,timeout=360000)
            progress.printStatus()
            activating()
        except:
            print '\tFAILED TO START THE APPLICATION'
            print dumpStack()

        print '\tAPPLICATION DEMARREE'


def deployApplication(app_name, app_path, _targets):
	print "\tDEPLOIEMENT APPLICATION : "+app_name+" "+app_path+" sur "+_targets
	try:
		# Retour to edit tree
		editing()
		progress=deploy(app_name,app_path,targets=_targets,stageMode='nostage',timeout=600000)
		print "\tEtat du deploy:" + progress.getState()
		progress.printStatus()
		activating()
	except Exception, e:
		print "==> Erreur deploy : "
		print e
		print sys.exc_info()[0]
	print "\tAPPLICATION DEPLOYE"

def undeployApplication(app_name,  _targets):
        print "\tUNDEPLOIEMENT APPLICATION "+app_name+" sur "+_targets
        try:
                editing()
		progress=undeploy(app_name,targets=_targets,timeout=600000)
		print "\tEtat du undeploy:" + progress.getState()
		progress.printStatus()
		activating()
        except Exception, e:
                print "==> Erreur Undeploy : "
                print e
                print sys.exc_info()[0]
	print "\tAPPLICATION UNDEPLOYEE"


def fileCopy(repSrc, repDest):
	print '\n\tCopie de '+repSrc+' vers '+repDest
	try:
		shutil.copy(repSrc,repDest)
        	print "\tCopie terminee avec succes.\n"
	except:
                print "\tErreur lors de la copie du fichier properties\n"
                dumpStack()
                stop=true

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

s = "Deploiement application Weblogic Server 12c"
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
 		_adminAddr = "localhost"

	
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
	
	deployProjectLibraries()
	
	### Sauvegarde des modifications
	save()
	activate(block="true")

	checkApp_todeploy()
	### Deploiement des applications
	#deployApplications()
	
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
 
 
 
 
