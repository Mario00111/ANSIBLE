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
FTPUSER="ST_EDITIQUE"
FTPPASS="cprp"
FTPREP=${2}
LOG="/datas/recette/m13/td/edms/KID/log/transfert_EDMS.log"
Horodateur=$(date '+%d/%m/%Y %X')
PID=$(echo $$)
debug="n"

echo "${Horodateur} ($PID) : ************Lancement du Shell Transfert_EDMS.sh avec les param�tres : $@" >> ${LOG}
#Lancement traitement :
cd ${FIC}
nbfic=$(ls *.pdf *.xml | wc -l)
echo "${Horodateur} ($PID) : Nombre de fichier � transf�rer : ${nbfic}" >>${LOG}
ftp -n -v <<FIN 2>&1 >/datas/recette/m13/td/edms/KID/log/ftp_edmscpr_${PID}.log
open ${FTPSERV}
user ${FTPUSER} ${FTPPASS}
cd ${FTPREP}"
prompt off
type binary
mput *.pdf
mput *.xml
quit
FIN


nombre=`grep "226 Transfer complete" /datas/recette/m13/td/edms/KID/log/ftp_edmscpr_${PID}.log |wc -l`
echo "${Horodateur} ($PID) : Nombre de fichier transf�r�s : ${nombre}" >>${LOG}
#Controle si tous les fichiers ont bien �t� transf�r�s
if (($nombre != $nbfic ))
then
  echo "Erreur sur le transfert du fichier vers EDMS, au moins un fichier n a pas �t� transf�r�" >>${LOG}
  exit 1
fi
echo "${Horodateur} ($PID) : Transfert du fichier vers EDMS : OK" >>${LOG}

#rm ${FIC}*
 #     if [ "$debug" != "y" ]
  #        then
   #         rm /datas/preprod/m13/td/edms/log/ftp_edmscpr_${PID}.log
    #        echo "${Horodateur} ($PID) : Suppression du fichier  /datas/preprod/m13/td/edms/log/ftp_edmscpr_${PID}.log" >>${LOG}
   #   fi
#fi


sleep 1



echo "${Horodateur} ($PID) : ************Lancement du Shell Transfert_EDMS.sh avec les param�tres : $@" >> ${LOG}
#Lancement traitement :
cd ${FIC}
nbfic=$(ls *.trigger | wc -l)
echo "${Horodateur} ($PID) : Nombre de fichier � transf�rer : ${nbfic}" >>${LOG}

ftp -n -v <<FIN 2>&1 >/datas/recette/m13/td/edms/KID/log/ftp_edmscpr_${PID}.log
open ${FTPSERV}
user ${FTPUSER} ${FTPPASS}
cd ${FTPREP}"
prompt off
type binary
mput *.trigger
quit
FIN


nombre=`grep "226 Transfer complete" /datas/recette/m13/td/edms/KID/log/ftp_edmscpr_${PID}.log |wc -l`
echo "${Horodateur} ($PID) : Nombre de fichier transf�r�s : ${nombre}" >>${LOG}
#Controle si tous les fichiers ont bien �t� transf�r�s
if (($nombre != $nbfic ))
then
  echo "Erreur sur le transfert du fichier vers EDMS, au moins un fichier n a pas �t� transf�r�" >>${LOG}
  exit 1
else

echo "${Horodateur} ($PID) : Transfert du fichier vers EDMS : OK" >>${LOG}

rm ${FIC}/*
      if [ "$debug" != "y" ]
          then
            rm /datas/recette/m13/td/edms/KID/log/ftp_edmscpr_${PID}.log
            echo "${Horodateur} ($PID) : Suppression du fichier  /datas/preprod/m13/td/edms/log/ftp_edmscpr_${PID}.log" >>${LOG}
      fi
fi

exit $?
