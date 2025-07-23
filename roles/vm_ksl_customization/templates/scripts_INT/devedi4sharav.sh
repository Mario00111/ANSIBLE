#!/bin/bash
#
#-------------------------------------------------------------------------------
# Nom Shell:		Shell devedi4traverso.sh 
# Objet:		Transfert putftp de DEVEDI CPR vers TRAVERSO AGORA
# Paricularit�s:	Ce shell effectue un envoi de fichier via putftp (programme AGORA ?)
#			J'ai copi� honteusement ce programme depuis iratd vers le serveur DEVEDI sous /editique/bin/
#
# Auteur		yann kloniecki
#
#  Attention: param�tres positionnels (@ si vide)
#  variables re�ues: $1= DNS_Name ou IP Destination
#                    $2= User Destination
#                    $3= Password Destination
#                    $4= Sas Emetteur
#                    $5= Sas Destination
#		     $6= Fichier Emetteur
#                    $7= Fichier Destination
#                    
# Usage: devedi4sharv.sh <DNS_Name Destinataire> <User Destinataire> <Password Destinataire> <String et/ou Fichier en Emission> <String et/ou fichier en reception> 
#			les param�tres 1 2 3 sont optionnels (par d�faut param�tres serveur ged Sharav Agora)
#			si 4 = @ alors 4 = /SASGED/m13/TP/in/ (sas d'emission cpr par d�faut)
#			si 6 = @ alors 6 = /SASGED/SORT/M36P/ATRAITER/ (sas reception Agora Sharav par d�faut)
#			SI 5 = @ alors le nom de fichier destination sera identique � celui d'emission
#
#			
#
#-------------------------------------------------------------------------------
NBARGS=7
CMD="$0 $*"

LOG_BASE="/logtmp/log/m13/tsns/ftp"

LOG="${LOG_BASE}/devedi4sharav.log"

if [ ! $# -eq ${NBARGS} ]
then
	#envoyer un mail a l'admin
	echo "------ $(date) ------" | tee -a ${LOG}
	echo "Ligne de commande: \"${CMD}\"" | tee -a ${LOG}
	echo "Arguments attendus ${NBARGS} <> $# recus !" | tee -a ${LOG}
	echo "--Sortie--" | tee -a ${LOG}
	return 1
fi

# R�cup�ration des arguments
# ou Valorisation per d�faut des variables si @

if [ ${1} = "@" ] 
then
	dns_name_dest="192.168.52.44"	# Adresse IP du site cible Sharav Agora
else
	dns_name_dest=${1}		# Nom DNS du site cible ou adresse IP pass� en argument
fi

if [ ${2} = "@" ] 
then
	user_dest="ftpcpr13"		# Utilisateur du site cible Sharav Agora
else
	user_dest=${2}			# Utilisateur du site cible pass� en argument
fi

if [ ${3} = "@" ] 
then
	password_dest="tchutchu"	# Password du site en reception Sharav Agora
else
	password_dest=${3}		# Password du site en reception pass� en argument
fi

if [ ${4} = "@" ] 
then
	if [ ${5} = "@" ] 
	then
		
		#chmod 777 "/SASGED/m13/TP/in/"${7}
		sas_emission="/SASGED/m13/TP/in/"${7}	# SAS du site en emission pass� en argument
	else
		#chmod 777 "/SASGED/m13/TP/in/"${5}
		sas_emission="/SASGED/m13/TP/in/"${5}		# SAS du site en emission pass� en argument
	fi
else
	if [ ${5} = "@" ] 
	then
		#chmod 777 ${4}${7}
		sas_emission=${4}${7}		# SAS du site en emission pass� en argument
	else
		#chmod 777 ${4}${5}
		sas_emission=${4}${5}		# SAS du site en emission pass� en argument
	fi
fi

if [ ${6} = "@" ] 
then
	if [ ${7} = "@" ] 
	then
		echo "Param�tres incoh�rents... " >> $LOG 	# le dernier argument ne peut �tre @
 		exit 1
	else
		#chmod 777 "/SASGED/SORT/M36P/ATRAITER/"${7}
		sas_dest="/SASGED/SORT/M36P/ATRAITER/"${7}	# SAS du site en destination et fichier pass� en argument
	fi
else
	if [ ${7} = "@" ] 
	then
		echo "Param�tres incoh�rents... " >> $LOG 	# le dernier argument ne peut �tre @
 		exit 1
	else 
		#echo "chmod 777 ${6}${7}" >> $LOG 
		#chmod 777 ${6}${7}
		sas_dest=${6}${7}		# SAS et fichier du site en emission pass� en argument
	fi
fi


#dns_name_dest=${1}			# Nom DNS du site cible ou adresse IP
#user_dest=${2}				# Utilisateur du site cible
#password_dest=${3}			# Password du site en reception

#sas_emission=${4}			# R�pertoire du site en emission
#sas_dest=${5}				# R�pertoire du site en reception


echo "----------------------------------------------------------" >> $LOG
echo "     devedi4traverso.sh    $(date)                        " >> $LOG
echo "----------------------------------------------------------" >> $LOG
echo " DNS Name Cible:      $dns_name_dest" >> $LOG
echo " User Cible:          $user_dest" >> $LOG
echo " Password Cible:      $password_dest" >> $LOG
echo " SAS Emetteur:        $sas_emission" >> $LOG
echo " SAS Destinataire:    $sas_dest" >> $LOG
echo "----------------------------------------------------------" >> $LOG

# Commande putftp


echo "/editique/bin/putftp -o -n $dns_name_dest -u $user_dest -p $password_dest -s $sas_emission -d $sas_dest" >> $LOG

/editique/bin/putftp -o -n $dns_name_dest -u $user_dest -p $password_dest -s $sas_emission -d $sas_dest -f "trf" 
if [ $? = 0 ]
then
	echo "Transfert putftp correctement effectu�... " >> $LOG
else
	echo "Echec du Transfert putftp... " >> $LOG
 	exit 1
fi
echo $? >> $LOG