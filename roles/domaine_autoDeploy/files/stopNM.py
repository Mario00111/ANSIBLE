'''

stopNM.py

Arret NodeManager

CPRP SNCF

'''

host=sys.argv[1]

# Connexion au Node Manager
nmConnect('weblogic','weblogic1',host,'5556',host+'_domain','/u01/domains/'+host+'_domain','ssl')

# Arret NodeManager
stopNodeManager()

# Deconnexion du Node Manager
nmDisconnect()

exit()
 
 
