'''

startMS.py

Demarrage ManagedServer

CPRP SNCF

'''

host=sys.argv[1]
MS=sys.argv[2]

# Connexion au Node Manager
nmConnect('weblogic','weblogic1',host,'5556',host+'_domain','/u01/domains/'+host+'_domain','ssl')

if (MS == "ALL"):
# Demarrage des ManagedServer
        nmStart('ManagedServer_1','Server')
        nmServerStatus('ManagedServer_1')

        nmStart('ManagedServer_2','Server')
        nmServerStatus('ManagedServer_2')


else:
# Demarrage d un ManagedServer
        nmStart('ManagedServer_'+MS[-1],'Server')
        nmServerStatus('ManagedServer_'+MS[-1])

# Deconnexion du Node Manager
nmDisconnect()


exit()
 
 
