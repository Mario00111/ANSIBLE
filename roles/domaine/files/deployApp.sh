#!/bin/bash
# Script de deploiement automatique d une application
####################################################
clear
if [ "$1" == "" ] ; then
	echo "."
	echo "."
	echo Usage : deployApp.sh nom_du_fichier_properties
	echo Exemple : deployApp.sh domain_dev.properties
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

echo " - Mise a jour du domaine ${DOMAIN_NAME}"

${WL_HOME}/common/bin/wlst.sh deployApp.py ${FILE_PROP}
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
