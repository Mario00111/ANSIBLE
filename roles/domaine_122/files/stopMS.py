'''

stopMS.py

Arret ManagedServer

CPRP SNCF

'''

host=sys.argv[1]
MS=sys.argv[2]

# Connexion au Node Manager
nmConnect('weblogic','weblogic1',host,'5556',host+'_domain','/u01/domains/'+host+'_domain','ssl')

if (MS == "ALL"):
# Arret des ManagedServer
        nmKill('ManagedServer_1')
	nmKill('ManagedServer_2')


else:
# Arret d un ManagedServer
        nmKill('ManagedServer_'+MS[-1])

# Deconnexion du Node Manager
nmDisconnect()

exit()
 
 
