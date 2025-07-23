'''

startAD.py

Demarrage AdminServer

CPRP SNCF

'''

host=sys.argv[1]

arg='Arguments="-Djava.security.egd=file:/dev/./urandom -Dweblogic.security.SSL.ignoreHostnameVerification=true -Djava.endorsed.dirs=/SOFT/oracle/java_current/jre/lib/endorsed:/SOFT/oracle/wls_121300/oracle_common/modules/endorsed"'
prps=makePropertiesObject(arg)

# Connexion au Node Manager
nmConnect('weblogic','weblogic1',host,'5556',host+'_domain','/u01/domains/'+host+'_domain','ssl')

dumpStack()


# Demarrage du serveur ManagedServer_1
nmStart('AdminServer',props=prps)

# Deconnexion du Node Manager
nmDisconnect()

exit()
