#!/bin/bash
#
#-------------------------------------------------------------------------------
#	Shell Transfert_KSLtoPM_GCOS.sh appele KSL serveur 
#
#
#	 Droit d'auteur : Fabrice Devin
#  Attention: param?es positionnels (@ si vide)
#  variables re?s: $1= Chemin complet du fichier +  transferer
#                  $2= Repertoire de destination (distant)
#                  $3= Nom du h+Ýte distant  
#                  $4= login FTP du h+Ýte distant    
#                  $5= mot de passe FTP du h+Ýte distant
#                  $6= Chemin absolue vers le fichier de log
#                  $7= Mode debug (y ou n)
#                  $8= Emisged (0 ou 1)
#-------------------------------------------------------------------------------
echo "$(date '+%d/%m/%Y %X');$(basename $0);$@" >> /editique/logtmp/audit_$(date '+%Y%m').log 


#D?aration des variables d'environnement

Chemin_local_fic=${1}
Chemin_distant_fic=${2}
PM_Serveur_Host=${3}
Login_PM=${4}
Password_PM=${5}
FicLog=${6}
Debug=${7}
EmiseGed=${8}
Rep_Temp_Echange=$(dirname $Chemin_local_fic)
NomFic=$(basename $Chemin_local_fic)
NomFicSansExt=$(basename ${NomFic} '.afp')
Horodateur=$(date '+%d/%m/%Y %X')
NBARGS=6


echo "${Horodateur} : ************Lancement du shell avec les paramètres suivants ${1} ${2} ${3} ${4} ${5} ${6} ${7} ${8}" >> ${FicLog}
echo "${Horodateur} : Le répertoire du fichier à transferer --> ${Rep_Temp_Echange}" >> ${FicLog}
echo "${Horodateur} : Le nom du fichier à transferer        --> ${NomFic}" >> ${FicLog}


#Lancement traitement :
# =======================================================================
# Preparation de l'envoi des fichiers vers la machine Process Manager 
# ======================================================================
      echo "open ${PM_Serveur_Host}"            >  ${Rep_Temp_Echange}/connectftp_${NomFicSansExt}
      echo "user ${Login_PM} ${Password_PM}"   >> ${Rep_Temp_Echange}/connectftp_${NomFicSansExt}
      echo "lcd ${Rep_Temp_Echange}"           >> ${Rep_Temp_Echange}/connectftp_${NomFicSansExt}
      echo "bin"                               >> ${Rep_Temp_Echange}/connectftp_${NomFicSansExt}
      echo "cd ${Chemin_distant_fic}"          >> ${Rep_Temp_Echange}/connectftp_${NomFicSansExt}
      echo "put ${NomFic}"                     >> ${Rep_Temp_Echange}/connectftp_${NomFicSansExt}
      echo "close"                             >> ${Rep_Temp_Echange}/connectftp_${NomFicSansExt}
      echo "quit"                              >> ${Rep_Temp_Echange}/connectftp_${NomFicSansExt}
# --------------------------------------------------
# Ex?tion des commandes ftp de transfert
# --------------------------------------------------

FTPLOG=${Rep_Temp_Echange}/ftplogfile
ftp -i -n -v  < ${Rep_Temp_Echange}/connectftp_${NomFicSansExt} > $FTPLOG

FTP_SUCCESS_MSG="226 Transfer complete"
if fgrep "$FTP_SUCCESS_MSG" $FTPLOG ;then
   echo "ftp OK"
else
   echo "ftp Error: "$OUT
fi

echo "${Horodateur} : ${NomFic} transféré sur ${PM_Serveur_Host} dans ${Chemin_distant_fic} "  >> ${FicLog}
rm ${Rep_Temp_Echange}/connectftp_${NomFicSansExt}  
echo "${Horodateur} : EmiseGed = ${EmiseGed}" >> ${FicLog}    

if [ ${EmiseGed} = "0" ]; then
  echo "${Horodateur} : Suppression du fichier ${Rep_Temp_Echange}/${NomFic}  "  >> ${FicLog} 
  rm ${Rep_Temp_Echange}/${NomFic}   
fi
         
if [ ${Debug} = "n" ]; then
  echo "${Horodateur} : Mode debug = non suppression du fichier ${FTPLOG} " >> ${FicLog} 
  rm ${FTPLOG}
fi
exit 0
