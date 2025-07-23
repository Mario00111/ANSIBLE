#!/bin/bash
#
#-------------------------------------------------------------------------------
#	Shell PostTraitKSL_GRA_TR.sh appel?ar le service KSL lancement_Shell_GRA_suite
#
# 20150907 SIERA Apercu avant impression vers citi82seu03
#
#	yann kloniecki
#   Attention: param?es positionnels (@ si vide)
#  variables re?s: $1= Jour (2car)
#                    $2= Heure (8car)
#                    $3= Code agent (4car)
#                    $6= Fichier
#                    $13= Type serveur (A pour hpserveurx, B pour ghostserveur)
#                    $14= Imprimante
#                    $16= Environnement (2 car)
#                    $24= Destination (1car)
#                    $25= Nb d'impressions
#                    $26= Code retour

#
# Variables d?ites dans ce traitement et exemple 
#
#	"$dtrx" 					02
#	"$dheu" 					15263393
#	"$cagt_01" 				8064
#	"$emisged" 				0.0
#	"$ndescor" 				0.0
#	"$fichier" 					/editique/ksl/ksl51a/serveur/instance_ora/tmp/ksl8952_0.pdf
#	"$etat" 					3806
#	"$agent" 					*GRA
#	"$date_creation" 			070702
#	"$tx"					G81
#	"$site" 					M13
#	"$agence" 				0
#	"$type" 					A
#	"$imprimante" 			MNI-DIR-D
#	"$traitement" 				/appcpr/ts/agra/script/lnc_cpr_tr.sh
#	"$environnement			PS
#	"$numenvironnement" 		01
#	"$numedition" 			0006
#	"$clez43" 				3806*GRA07070215263714G81
#	"$site_emetteur"			M13
#	"$retour_host" 			@
#	"$retour_login" 			@
#	"$retour_path" 			@
#	"$destination"				6
#	"$impressions"				1
#	"$cderet"				0
#
#-------------------------------------------------------------------------------

NBARGS=26

LOG_BASE="/logtmp/log/m13"
CMD="$0 $*"

LOG="${LOG_BASE}/$(basename ${0})_err.log"

if [ ! $# -eq ${NBARGS} ]
then
	#envoyer un mail a l'admin
	echo "------ $(date) ------" | tee -a ${LOG}
	echo "Ligne de commande: \"${CMD}\"" | tee -a ${LOG}
	echo "Arguments attendus $NBARGS <> $# recus !" | tee -a ${LOG}
	echo "--Sortie--" | tee -a ${LOG}
	return 1
fi

PDF="${3}${1}${2}.pdf"
GED="${3}${1}${2}.AFP"
TMP="${3}${1}${2}"
FICHIER=$6

TYPE=${13}
IMPRIMANTE=${14}
typeset -l ENVIRONNEMENT
ENVIRONNEMENT=${16#?}
DESTINATION=${24}
NBEX=${25}
RETOUR=${26}

#Verif du code retour
if [ ! "${RETOUR}" == "0" ]
then
	echo "------ $(date) ------" | tee -a ${LOG}
	echo "Ligne de commande: \"${CMD}\"" | tee -a ${LOG}
	echo "Code retour = ${RETOUR}" | tee -a ${LOG}
	echo "--Sortie--" | tee -a ${LOG}
	return 1
fi

#verification de l'environnement
case ${ENVIRONNEMENT} in
	'i' | 's' )
		MACHINE_DEST=iratd
		;;
	'p' )
		MACHINE_DEST=prepatd
		;;
	'r' )
		MACHINE_DEST=prodatd
		;;
	* )
		echo "------ $(date) ------" | tee -a ${LOG}
		echo "Ligne de commande: \"${CMD}\"" | tee -a ${LOG}
		echo "Environnement non prevu: \"${ENVIRONNEMENT}\"!" | tee -a ${LOG}
		echo "--Sortie--" | tee -a ${LOG}
		return 1
esac

LOG_FILE="${LOG_BASE}/t${ENVIRONNEMENT}n${ENVIRONNEMENT}/cpr/${TMP}.GRA_TR.log"

if [ ! -d "$(dirname ${LOG_FILE})" ]
then
	echo "------ $(date) ------" | tee -a ${LOG}
	echo "Ligne de commande: \"${CMD}\"" | tee -a ${LOG}
	echo "Repertoire de destination des log \"$(dirname ${LOG_FILE})\" Inexistant!" | tee -a ${LOG}
	echo "--Sortie--" | tee -a ${LOG}
	return 1
fi

exec >> ${LOG_FILE} 2>&1
echo "------ $(date) ------"
echo "Utilisateur: $(id)"
echo "Ligne de commande: \"${CMD}\""

#on verifie que le fichier renvoye par ksl existe bien
if [ ! -f "${FICHIER}" ]
then
	echo "Fichier ${FICHIER} inexistant!!"
	return 1
fi

case ${DESTINATION} in
1|2|4 ) #impression
	SERVEUR="srv-wins.cpr.sncf.fr" # par defaut on imprime sur hpserveurx
	[ ${TYPE} = "B" ] && SERVEUR="srv-wins.cpr.sncf.fr"
	[ ${TYPE} = "C" ] && SERVEUR="srv-wins.cpr.sncf.fr"
	chaineimp="//${SERVEUR}/${IMPRIMANTE} -U usergra%usergra -W=SERVEURS -c 'print ${FICHIER}'"
	# on imprime le nombre de copie $NBEX demandees
	while (true)
	do
		NBEX=$((NBEX-1))
		echo "Impression de ${FICHIER} sur //${SERVEUR}/${IMPRIMANTE} avec le user usergra%usergra. Reste ${NBEX}"
		eval "/usr/bin/smbclient ${chaineimp}"
		if [ ! ${?} = 0 ]
		then
			echo "Erreur D'impression!!"
			return 1
		fi
		[ ${NBEX} -le 0 ] && break
	done
	;;
3|5 ) #previsu PDF
  CAISSEOP="SIERA"
	echo "nom du fichier pdf: ${PDF}"
	USER_DEST=comws13
	CHEMIN_DEST="/logtmp/tmp/m13/t${ENVIRONNEMENT}n${ENVIRONNEMENT}/agra"
  if [ "${CAISSEOP}" == "SIERA" ]
    then
        USER_DEST="oprint"
        PASS_DEST="oprint"
        CHEMIN_DEST="/logtmp/tmp/m04/trnr/agra"
        MACHINE_DEST="192.168.192.42"
        echo "Copie de ${FICHIER} sur machine SIERA ${MACHINE_DEST} user ${USER_DEST} destination ${CHEMIN_DEST}/${PDF}" >> ${LOG_FILE}
        putftp -o -n ${MACHINE_DEST} -u ${USER_DEST} -p ${PASS_DEST} -f "trf" -s ${FICHIER} -d ${CHEMIN_DEST}/${PDF}
        CODE_RETOUR=$?
	      if [ "${CODE_RETOUR}" != "0" ]
	        then
		          echo " $(date +%y/%m/%d) $(date +%H:%M:%S) Erreur lors de la copie du fichier ${PDF} pour agent ${3} depuis $(whoami)@$(hostname) sur ${MACHINE_DEST}!" >> $LOG
		          return 1
		      else
		          echo " $(date +%y/%m/%d) $(date +%H:%M:%S) : Copie de ${PDF} pour agent ${3} sur ${MACHINE_DEST} termin ©e." >> ${LOG_FILE}
	      fi
  fi
#	20150910 \rcp ${FICHIER} ${USER_DEST}@${MACHINE_DEST}:${CHEMIN_DEST}/${PDF}
  
	;;
G ) #Fichier ?estination de la GED
	echo "nom du fichier ged: ${GED}"
	
	#copie du fichier afp sous /import pour mise en ged

	#si on est en prod on depose dans les repertoire d'import ged de prod sinon...
	[ "${ENVIRONNEMENT}" == "r" ] && GED_DIR="/import_ged_prod/ged/EDIGRG_NA" || GED_DIR="/import_ged_test/ged_test/EDIGRG_NA"

	# on passe l'extension du fichier $12 en majuscule pour integration avec le programme de ged
	GED_DEST=${GED_DIR}/${GED}

	echo "Copie de ${GED} dans ${GED_DEST}"
	cp ${FICHIER} ${GED_DEST}.TRF && chmod 666 ${GED_DEST}.TRF && mv ${GED_DEST}.TRF ${GED_DEST}

	#on teste le retour
	if [ ! ${?} = 0 ]
	then
		echo "Erreur lors du deplacement du fichier ${FICHIER} sous ${GED_DEST}!!"
		return 1
	fi
	;;	
* )
	echo "Erreur!!! Variable destination (pos 24) <> [1-5|G]"
	return 1
esac

# \rm -fe ${FICHIER}
