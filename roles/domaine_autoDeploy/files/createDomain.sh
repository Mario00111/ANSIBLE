#!/bin/bash
# Script de creation automatique de Domaine Weblogic
####################################################

clear
if [ "$1" == "" ] ; then
	echo "."
	echo "."
	echo Usage : createDomain.cmd nom_du_fichier_properties
	echo Exemple : createDomain.cmd domain_ass.properties
	exit
fi

PROPERTY_FILE=$1

if [ ! -f "${PROPERTY_FILE}" ] ; then 
	echo "."
	echo "."
	echo Le fichier ${PROPERTY_FILE} est introuvable.
	exit
fi

export BEA_HOME=/SOFT/oracle/wls_121300
export WL_HOME=${BEA_HOME}/wlserver
export JAVA_HOME=/SOFT/oracle/java_current
 
. ${WL_HOME}/server/bin/setWLSEnv.sh $*


##### Recuperation du fichier de proprietes donne en input
FILE_PROP=${PROPERTY_FILE}

echo "."
echo "."
echo "Utilisation du fichier de configuration ${FILE_PROP}"


DOMAIN_NAME=`grep "domainName" ${FILE_PROP} | cut -d'=' -f 2`
if [ "${DOMAIN_NAME}" = "" ] ; then
	echo "."
	echo "."
	echo "Impossible d'extraire le nom du domaine du fichier ${FILE_PROP}"
	exit
fi

echo "Nom du domaine : ${DOMAIN_NAME}"

DOMAIN_PATH=`grep "domainLocation" ${FILE_PROP} | cut -d'=' -f 2`
if [ "${DOMAIN_PATH}" = "" ] ; then
	echo "."
	echo "."
	echo "Impossible d'extraire l'emplacement du domaine depuis le fichier ${FILE_PROP}"
	exit
fi

echo "Emplacement du domaine : ${DOMAIN_PATH}"

echo "."
echo "."
echo " - Creation du domaine ${DOMAIN_PATH}/${DOMAIN_NAME}"

${WL_HOME}/common/bin/wlst.sh createDomain.py ${FILE_PROP} > /u01/domains/create_domain.log

if [ ! -f "${DOMAIN_PATH}/${DOMAIN_NAME}/startWebLogic.sh" ] ; then
	echo "."
	echo "."
	echo "Le domaine n'a pas ete cree correctement. Procedure interrompue."
	exit
fi

echo "."
echo "."
echo " - Demarrage du serveur d'administration avant d'achever la creation du domaine"


nohup ${DOMAIN_PATH}/${DOMAIN_NAME}/startWebLogic.sh &

echo " - Enrichissement du classpath avec les librairies du repertoire ./lib/mbeantypes"

CLASSPATH=${CLASSPATH}:${WL_HOME}/server/lib/jms-notran-adp.rar
export CLASSPATH
#for i in `ls ${DOMAIN_PATH}/${DOMAIN_NAME}/lib/mbeantypes/*.jar`
#do
#        CLASSPATH=${CLASSPATH}:$i
#done
#export CLASSPATH

echo " - Mise a jour du domaine ${DOMAIN_NAME}"

${WL_HOME}/common/bin/wlst.sh updateDomain.py ${FILE_PROP}
if [ "$?" -ne "0" ]; then
	echo "."
	echo "."
	echo "Une erreur s'est produite lors de la mise a jour du domaine. Procedure interrompue."
	exit
fi

echo "."
echo "."
echo "Procedure terminee."

exit
