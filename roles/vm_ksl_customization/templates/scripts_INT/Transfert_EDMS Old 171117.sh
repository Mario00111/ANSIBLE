#!/bin/bash
#
#-------------------------------------------------------------------------------
#	Shell Transfert_EDMS.sh appelé par KSL serveur 
#
#
#	 Droit d'auteur : Fabrice Devin
#  Attention: paramètres positionnels (@ si vide)
#  variables reçues: $1= Repertoire en attente de transfert vers EDMS
#                    $2= Repertoire de transfert   
#                    $3= Serveur EDMS 
#-------------------------------------------------------------------------------
echo "$(date '+%d/%m/%Y %X');$(basename $0);$@" >> /editique/logtmp/audit_$(date '+%Y%m').log 
#Déclaration des variables d'environnement
#Dans FTPREP tu mets le chemin complet où tu souhaites déposer les fichiers sur edms
FIC=${1}
FTPSERV=${3}
FTPUSER="andromede"
FTPPASS="andro13"
FTPREP=${2}
LOG="/logtmp/log/m13/redms/transfert_EDMS.log"
Horodateur=$(date '+%d/%m/%Y %X')
PID=$(echo $$)
debug="n"

echo "${Horodateur} ($PID) : ************Lancement du Shell Transfert_EDMS.sh avec les paramètres : $@" >> ${LOG}
#Lancement traitement :
cd ${FIC}
nbfic=$(ls | wc -l)
echo "${Horodateur} ($PID) : Nombre de fichier à transférer : ${nbfic}" >>${LOG}
ftp -n -v <<FIN 2>&1 >/logtmp/log/m13/redms/ftp_edmscpr_${PID}.log
open ${FTPSERV}
user ${FTPUSER} ${FTPPASS}
#Vérouillage du dossier de réception pour éviter le parallélisme et sécurisé le transfert
rename ${FTPREP} ${FTPREP}"_LOCK"
cd ${FTPREP}"_LOCK"
prompt off
type binary
mput *
quit
FIN

nombre=`grep "226 Transfer OK" /logtmp/log/m13/redms/ftp_edmscpr_${PID}.log |wc -l`
echo "${Horodateur} ($PID) : Nombre de fichier transférés : ${nombre}" >>${LOG}
#Controle si tous les fichiers ont bien été transférés
if (($nombre != $nbfic ))
then
  echo "Erreur sur le transfert du fichier vers EDMS, au moins un fichier n a pas été transféré" >>${LOG}
  exit 1
else

#On renomme le dossier de réception si tous les fichiers ont bien été transférés pour intégration dans EDMS
ftp -n -v <<FINAL 2>&1 >/logtmp/log/m13/redms/ftp_edmscpr_${PID}.log
open ${FTPSERV}
user ${FTPUSER} ${FTPPASS}
#Vérouillage du dossier de réception pour éviter le parallélisme et sécurisé le transfert
rename ${FTPREP}"_LOCK" ${FTPREP}
quit
FINAL

echo "${Horodateur} ($PID) : Transfert du fichier vers EDMS : OK" >>${LOG}
echo "${Horodateur} ($PID) : Suppression des fichiers du dossier  : ${FIC}" >>${LOG}        
echo "${Horodateur} ($PID) : Suppression des fichiers transférés" >>${LOG}
rm ${FIC}*
      if [ "$debug" != "y" ]
          then
            rm /logtmp/log/m13/redms/ftp_edmscpr_${PID}.log
            echo "${Horodateur} ($PID) : Suppression du fichier  /editique/logtmp/logs/ftp_edmscpr_${PID}.log" >>${LOG}
      fi
fi

exit $?
