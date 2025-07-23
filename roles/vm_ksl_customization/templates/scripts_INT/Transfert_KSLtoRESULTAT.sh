#!/bin/bash
#
#-------------------------------------------------------------------------------
#	Shell Transfert_KSLtoRESULTAT.sh appele KSL serveur 
# variables reçues: $1= Fichier
#                   $2= Repertoire de dépôt  
#                   $3= Log
#
#
#-------------------------------------------------------------------------------
echo "$(date '+%d/%m/%Y %X');$(basename $0);$@" >> /editique/logtmp/audit_$(date '+%Y%m').log 

#Variables d'environnement
Horodateur=$(date '+%d/%m/%Y %X')
FIC=${1}
DEST=${2}
LOG="${3}Transfert_KSLtoRESULTAT.log"
echo "${Horodateur} : Paramètres : ${1}|${2}|${3}" >> ${LOG}
echo "${Horodateur} : Initialisation SAMBA" >> ${LOG}
SAMBA="/usr/bin/smbclient //edition.cpr.sncf.fr/Resultats_Editique -U edit%12345"
echo "${Horodateur} : Transfert vers Resultat_Editique" >> ${LOG}
${SAMBA} -c "put ${FIC} ${DEST}" 
echo "${Horodateur} : Suppression du fichier" >> ${LOG}
rm ${FIC}
