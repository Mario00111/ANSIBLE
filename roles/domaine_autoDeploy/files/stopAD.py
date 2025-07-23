'''

stopAD.py

Arret AdminServer

CPRP SNCF

'''

host=sys.argv[1]

# Connexion au Node Manager
nmConnect('weblogic','weblogic1',host,'5556',host+'_domain','/u01/domains/'+host+'_domain','ssl')

# Arret AdminServer
nmKill('AdminServer')

# Deconnexion du Node Manager
nmDisconnect()

exit()
 
 
