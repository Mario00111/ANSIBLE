#!/bin/ksh
#
#-------------------------------------------------------------------------------
#	Shell PostTraitKSL_DECM_TD.sh appelé par KSL
#
#
#	yann kloniecki
#  Attention: paramètres positionnels (@ si vide)
#  variables reçues: $1= Emis ged
#                    $2= Chemin vers le fichier
#                    $3= recette|integration|preprod|prod
#                    $4= nombre d'impressions
#                    $5= Code Erreur
#                    $6= destination (INT ou MSP)
#                    $7= mode (D ou P ou S) (debug/prod/SAS)
#                    $8= nombre de pages
#                    $9= MAD mise a dispo (imp/impression ou sas)
#                    $10= dest1 extension du fichier a destination de 
#                    $11= dest2 extension du fichier a destination de 
#
#-------------------------------------------------------------------------------

NBARGS=11

LOG_BASE="/logtmp/log/m13"
CMD="$0 $*"

LOG="${LOG_BASE}/$(basename ${0})_err.log"

if [ ! $# -eq $NBARGS ]
then
	#envoyer un mail a l'admin
	echo "------ $(date) ------" | tee -a ${LOG}
	echo "Ligne de commande: \"${CMD}\"" | tee -a ${LOG}
	echo "Arguments attendus $NBARGS <> $# recus !" | tee -a ${LOG}
	echo "--Sortie--" | tee -a ${LOG}
	return 0
fi

#Verif du code retour
if [ ! "${5}" == "0" ]
then
	echo "------ $(date) ------" | tee -a ${LOG}
	echo "Ligne de commande: \"${CMD}\"" | tee -a ${LOG}
	echo "Code retour = ${5}" | tee -a ${LOG}
	echo "--Sortie--" | tee -a ${LOG}
	return 0
fi

case "${3}" in
	"recette" )
		ENV="s"
		;;
	"integration" )
		ENV="i"
		;;
	"preprod" )
		ENV="p"
		;;
	"prod" )
		ENV="r"
		;;
	* )
		echo "------ $(date) ------" | tee -a ${LOG}
		echo "Ligne de commande: \"${CMD}\"" | tee -a ${LOG}
		echo "Environnement non prevu: \"${3}\"!" | tee -a ${LOG}
		echo "--Sortie--" | tee -a ${LOG}
		return 0
esac

FILENAME=$(basename ${2})
LOG_FILE="${LOG_BASE}/t${ENV}n${ENV}/cpr/${FILENAME%.*}.DECM_TD.log"

if [ ! -d "$(dirname ${LOG_FILE})" ]
then
	echo "------ $(date) ------" | tee -a ${LOG}
	echo "Ligne de commande: \"${CMD}\"" | tee -a ${LOG}
	echo "Repertoire de destination des log \"$(dirname ${LOG_FILE})\" Inexistant!" | tee -a ${LOG}
	echo "--Sortie--" | tee -a ${LOG}
	return 0
fi

exec >> ${LOG_FILE} 2>&1
echo "------ $(date) ------"
echo "Utilisateur:" $(id)
echo "Ligne de commande: \"${CMD}\""

# Extensions
DEST1=${10}
DEST2=${11}

SRC_BASE="${2%.*}"                # le fichier source avec chemin sans extension
FILENAME="$(basename $2)"         # le fichier destination sans chemin avec extension

if [ ${1} = "1" ] #copie du fichier afp sous /import_ged pour mise en ged
then
	#on construit le nom du fichier afp
	AFP_FILE="${SRC_BASE}.${10}"
	#on verifie que le fichier a copier existe bien
	if [ ! -f "${AFP_FILE}" ]
	then
		echo "Fichier source \"${AFP_FILE}\" inexistant!!"
		return 0
	fi

	#si on est en prod on depose dans les repertoire d'import ged de prod, sinon on depose dans la ged en test
	[ "${3}" = "prod" ] && TMP_GED_DIR="/import_ged_prod/ged" || TMP_GED_DIR="/import_ged_test/ged_test"

	BASENAME=$(basename ${AFP_FILE})
	# on passe l'extension du fichier AFP_FILE en majuscule pour integration avec le programme de ged
	typeset -u EXT_MAJ=${10} # on met l'extension du fichier en majuscule
	typeset -Z6 nbpages=${8}
	typeset -L6 FILTRE=${BASENAME}

	#test pour savoir ou placer le fichier en ged
	case "${FILTRE}" in
		"EDIDCM" ) GED_DIR=${TMP_GED_DIR}/EDIDCD ;; #cas particulier du EDIDCM qui part dans le repertoire ged import EDIDCD
		* ) GED_DIR=${TMP_GED_DIR}/${FILTRE} ;;
	esac

	GED_DEST=${GED_DIR}/${BASENAME%.*}.${nbpages}.${EXT_MAJ}

	#creation du repertoire sur le serveur de ged s'il n'existe pas
	if [ ! -d ${GED_DIR} ]
	then
		mkdir ${GED_DIR} && chmod 777 ${GED_DIR}
		#on teste le retour
		if [ ! ${?} = 0 ]
		then
			echo "Erreur lors de la creation du repertoire \"${GED_DIR}\" en GED!!"
			return 0
		fi
	fi

	echo "Copie de ${AFP_FILE} dans ${GED_DEST}"
	# Max, ici il faut faire un mv car le fichier reste dans result !!!
	cp ${AFP_FILE} ${GED_DEST}.TRF && chmod 666 ${GED_DEST}.TRF && mv ${GED_DEST}.TRF ${GED_DEST}

	#on teste le retour
	if [ ! ${?} = 0 ]
	then
		echo "Erreur lors de la copie du fichier \"${AFP_FILE}\" en GED!!"
		return 0
	fi
fi

if [ "${9}" == "sas" ]
then
	BUREAU=${FILENAME%%.*} # 1ere partie du nom du fichier sans extension X.Y.Z => X
	DESTNAME=${FILENAME#*.} # on supprime le nom du bureau du nom du fichier X.Y.Z => Y.Z
	FICTYPE=${DESTNAME%%.*} # 2eme partie du nom du fichier X.Y.Z => Y
	typeset -u ENV
	ENV="${3}"

####### debut copie via smbclient #######
	# on copie les fichiers dans $ENV\STDE\TD\BUREAUX\$TYPEFIC\$BUREAU, ou $ENV\STDE\TD\BUREAUX devrait toujours exister, le reste on le cree
	# On essaye de copier le fichier, si ca ne marche pas c'est que le repertoire n'existe pas, donc on le cree et on reessaye,
	# et apres ca si ca marche toujours pas: c'est mal!
	SAMBA="/usr/local/samba/bin/smbclient //hpdata10/Resultats_Editique -U edit%12345 -N"
	# penser a doubler les '\' quand ils sont suivis de $
	DIR="${ENV}\STDE\TD\BUREAUX\\${FICTYPE}"
	DEST="${DIR}\\${BUREAU}"
	echo "Copie de \"${2}\" dans \"${DEST}\\${DESTNAME}\" via smbclient"
	${SAMBA} -c "put ${2} ${DEST}\\${DESTNAME}"
	if [ ! ${?} = 0 ]
	then	# la copie a echoue, on cree le repertoire
		${SAMBA} -c "md ${DIR}"				# d'abord le repertoire 'type de fichier' (ex: EDIS4A)
		${SAMBA} -c "md ${DEST}" 			# puis le bureau
		${SAMBA} -c "put ${2} ${DEST}\\${DESTNAME}"	# enfin, on retente une copie qui normalement devrait bien se passer
		if [ ! ${?} = 0 ]
		then	# la copie a echoue malgre la creation du repertoire, donc on sort en erreur (pb d'acces/mdp/user/droit/...?)
			echo "Erreur lors du l'envoi du fichier via smbclient (samba)!!"
			return 0
		fi
	fi
####### fin copie via smbclient #######

	\rm -fe "${2}"
else
	if [ "${7}" == "D" -o "${7}" == "P" ]
	then
        	SRC="${SRC_BASE}.${DEST1}"
		#on verifie que le fichier existe bien
		if [ ! -f "${SRC}" ]
		then
			echo "Fichier source \"${SRC}\" inexistant!!"
			return 0
		fi
	
        	typeset -Z6 nbpages=${8}
        	typeset -l destination="${6}"
        	DEST="/IMPMSA/${3}/${destination}/${FILENAME%.*}.${nbpages}.${DEST1}"
		#on verifie que le repertoire existe bien
		if [ ! -d "$(dirname ${DEST})" ]
		then
			echo "Repertoire de destination \"$(dirname ${DEST})\" inexistant!!"
			return 0
		fi
	
        	echo "Deplacement de \"${SRC}\" dans \"${DEST}\""
        	\mv "${SRC}" "${DEST}.TRF"
        	\mv "${DEST}.TRF" "${DEST}"

		#on teste le retour du second mv seulement, si le premier echoue, le second echouera automatiquement!
		if [ ! ${?} = 0 ]
		then
			echo "Erreur lors du deplacement du fichier!!"
			return 0
		fi

	fi
	
	if [ "${7}" == "D" -o "${7}" == "S" ]
	then
        	SRC="${SRC_BASE}.${DEST2}"
		#on verifie que le fichier existe bien
		if [ ! -f "${SRC}" ]
		then
			echo "Fichier source \"${SRC}\" inexistant!!"
			return 0
		fi

		typeset -u ENV
		ENV="${3}"

####### debut copie via smbclient #######
		# on copie les fichiers dans $ENV\STDE\TD\GLOBAL\, ou $ENV\STDE\TD\GLOBAL devrait toujours exister
		# penser a doubler les '\' quand ils sont suivis de $
		SAMBA="/usr/local/samba/bin/smbclient //hpdata10/Resultats_Editique -U edit%12345 -N"
		DEST="${ENV}\STDE\TD\GLOBAL\\${FILENAME%.*}.${DEST2}"

		echo "Copie de \"${SRC}\" dans \"${DEST}\" via smbclient"
		${SAMBA} -c "put ${SRC} ${DEST}"

		if [ ! ${?} = 0 ]
		then    # la copie a echoue
			echo "Erreur lors du l'envoi du fichier via smbclient (samba)!!"
			return 0
		fi
####### fin copie via smbclient #######

		\rm -fe "${SRC}"

	fi
fi

#On supprime le fichier AFP_FILE s'il a ete traité
[ ! -z "${AFP_FILE}" ] && \rm -fe ${AFP_FILE}
