#!/bin/bash
#
#-------------------------------------------------------------------------------
#	Shell Transfert_EDMS.sh appel� par KSL serveur 
#
#
#	 Droit d'auteur : Fabrice Devin
#  Attention: param�tres positionnels (@ si vide)
#  variables re�ues: $1= Repertoire en attente de transfert vers EDMS
#                    $2= Repertoire de transfert   
#                    $3= Serveur EDMS 
#-------------------------------------------------------------------------------
echo "$(date '+%d/%m/%Y %X');$(basename $0);$@" >> /editique/logtmp/audit_$(date '+%Y%m').log 
#D�claration des variables d'environnement
#Dans FTPREP tu mets le chemin complet o� tu souhaites d�poser les fichiers sur edms
FIC=${1}
FTPSERV=${3}
FTPUSER="andromede"
FTPPASS="andro13"
FTPREP=${2}
LOG="/logtmp/log/m13/redms/transfert_EDMS.log"
Horodateur=$(date '+%d/%m/%Y %X')
PID=$(echo $$)
debug="n"

echo "${Horodateur} ($PID) : ************Lancement du Shell Transfert_EDMS.sh avec les param�tres : $@" >> ${LOG}
#Lancement traitement :
cd ${FIC}
nbfic=$(ls | wc -l)
echo "${Horodateur} ($PID) : Nombre de fichier � transf�rer : ${nbfic}" >>${LOG}
ftp -n -v <<FIN 2>&1 >/logtmp/log/m13/redms/ftp_edmscpr_${PID}.log
open ${FTPSERV}
user ${FTPUSER} ${FTPPASS}
#V�rouillage du dossier de r�ception pour �viter le parall�lisme et s�curis� le transfert
rename ${FTPREP} ${FTPREP}"_LOCK"
cd ${FTPREP}"_LOCK"
prompt off
type binary
mput *
quit
FIN

nombre=`grep "226 Transfer OK" /logtmp/log/m13/redms/ftp_edmscpr_${PID}.log |wc -l`
echo "${Horodateur} ($PID) : Nombre de fichier transf�r�s : ${nombre}" >>${LOG}
#Controle si tous les fichiers ont bien �t� transf�r�s
if (($nombre != $nbfic ))
then
  echo "Erreur sur le transfert du fichier vers EDMS, au moins un fichier n a pas �t� transf�r�" >>${LOG}
  exit 1
else

#On renomme le dossier de r�ception si tous les fichiers ont bien �t� transf�r�s pour int�gration dans EDMS
ftp -n -v <<FINAL 2>&1 >/logtmp/log/m13/redms/ftp_edmscpr_${PID}.log
open ${FTPSERV}
user ${FTPUSER} ${FTPPASS}
#V�rouillage du dossier de r�ception pour �viter le parall�lisme et s�curis� le transfert
rename ${FTPREP}"_LOCK" ${FTPREP}
quit
FINAL

echo "${Horodateur} ($PID) : Transfert du fichier vers EDMS : OK" >>${LOG}
echo "${Horodateur} ($PID) : Suppression des fichiers du dossier  : ${FIC}" >>${LOG}        
echo "${Horodateur} ($PID) : Suppression des fichiers transf�r�s" >>${LOG}
rm ${FIC}*
      if [ "$debug" != "y" ]
          then
            rm /logtmp/log/m13/redms/ftp_edmscpr_${PID}.log
            echo "${Horodateur} ($PID) : Suppression du fichier  /editique/logtmp/logs/ftp_edmscpr_${PID}.log" >>${LOG}
      fi
fi

exit $?
