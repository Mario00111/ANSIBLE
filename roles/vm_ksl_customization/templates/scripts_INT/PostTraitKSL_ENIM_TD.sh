#!/bin/bash
#
#-------------------------------------------------------------------------------
#	Shell PostTraitKSL_ENIM_TD.sh appelé par KSL
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
#		     $12=index_suivi pour table MSAafpimp suivi traitement 
#-------------------------------------------------------------------------------


charge_variable_config () #1er parametre nom de la variable, 2nd nom du fichier
{
echo $(grep -w "^$1" "$2" | cut -d'=' -f2)
}


NBARGS=12
# repertoire du fichier csv pour traitement particulier des sas
CSVDIR="/editique/bin/ini"
# repertoire des logs
LOG_BASE="/logtmp/log/m13"
CMD="$0 $*"
STATUS="T01"
ligne_param="$*"


LOG="${LOG_BASE}/$(basename ${0})_err.log"

if [ ! $# -eq $NBARGS ]
then
	#envoyer un mail a l'admin
	echo "------ $(date) ------" | tee -a ${LOG}
	echo "Ligne de commande: \"${CMD}\"" | tee -a ${LOG}
	echo "Arguments attendus $NBARGS <> $# recus !" | tee -a ${LOG}
	echo "--Sortie--" | tee -a ${LOG}
	return 1
fi

#Verif du code retour
if [ ! "${5}" == "0" ]
then
	echo "------ $(date) ------" | tee -a ${LOG}
	echo "Ligne de commande: \"${CMD}\"" | tee -a ${LOG}
	echo "Code retour = ${5}" | tee -a ${LOG}
	echo "--Sortie--" | tee -a ${LOG}
	return 1
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
		return 1
esac

TEMP="$(basename "${2}")"
LOG_FILE="${LOG_BASE}/t${ENV}n${ENV}/cpr/${TEMP%.*}.ENIM_TD.log"

params="$ligne_param $LOG_FILE"
ligne_param=$params

if [ ! -d "$(dirname ${LOG_FILE})" ]
then
	echo "------ $(date) ------" | tee -a ${LOG}
	echo "Ligne de commande: \"${CMD}\"" | tee -a ${LOG}
	echo "Repertoire de destination des logs \"$(dirname ${LOG_FILE})\" Inexistant!" | tee -a ${LOG}
	echo "--Sortie--" | tee -a ${LOG}
	return 1
fi

exec >> ${LOG_FILE} 2>&1
echo "------ $(date) ------"
echo "Utilisateur:" $(id)
echo "Ligne de commande: \"${CMD}\""

#on supprime les eventuels apostrophes du nom du fichier (remplaces par '_')
FILENAME="$(basename "${2}"| sed -e "s/\'/_/g")"
FILEPATH="$(dirname "${2}")/${FILENAME}"
echo \"${2}\" | grep -c \' > /dev/null 2>&1
if [ "$?" = "0" ] #on a trouve un ' dans le nom du fichier
then
	\mv "${2}" "${FILEPATH}"
fi

# Extensions
DEST1=${10}
DEST2=${11}

SRC_BASE="${FILEPATH%.*}"                # le fichier source avec chemin sans extension
FILENAME="$(basename $FILEPATH)"         # le fichier destination sans chemin avec extension

if [ "${9}" == "sas" ]
then
	#TYPEFIC="$(echo ${FILENAME} | cut -d'.' -f3)"

	if [ ! -z "$(echo ${FILENAME} | cut -d'.' -f6)" ]
	then # Trois index en + devant TYPE.DATE.EXTENSION = BUREAU.YYYYY.XXXXX.TYPE.DATE.EXTENSION
		#----------------------------------------------------------------------------------------------------
		# Pour obtenir ceci, il faut jouer sur la constitution de IND_PTF dans l'edition ksl.
		# IND_PTF pour EDIBPV par exemple est composée de la chaine: code_portefeuille+.+Code Regime+.+caisse_prenante
		# ce qui a pour effet de rajouter un index dans le nom de fichier soit:
		# CODE_PORTEFEUILLE.CODE_REGIME.CAISSE_PRENANTE.TYPE.DATE.EXTENSION
		# Dans ce cas, on va alors s'appuyer pour le traitement de ce fichier sur un fichier paramètre (csv) 
		# particulier dont le nom ets celui de l'edition (par ex: EDIBPV.csv)
		#----------------------------------------------------------------------------------------------------
		TYPEFIC="$(echo ${FILENAME} | cut -d'.' -f4)"
		CSVFIC="${CSVDIR}/${TYPEFIC}.csv"

		if [ ! -r "${CSVFIC}" ]
		then
			echo "Fichier CSV ${CSVFIC} Absent ou inaccessible en lecture!!"
			STATUS="T00"
			params="$ligne_param $STATUS"
			/editique/bin/logafpimp_gen.sh ${params}
			return 1
		fi

		#Chargement des variables depuis le fichier ${CSVFIC}
		ServeurCible=$(charge_variable_config ServeurCible ${CSVFIC})
		ServeurCible_User=$(charge_variable_config ServeurCible_User ${CSVFIC})
		ServeurCible_Passwd=$(charge_variable_config ServeurCible_Passwd ${CSVFIC})
		StructureN1=$(charge_variable_config StructureN1 ${CSVFIC})

		#on cherche dans le fichier CSV si le bureau est declare, sinon on utilise les variables par defaut
		BUREAU=${FILENAME%%.*} # 1ere partie du nom du fichier sans extension BUREAU.XXX.XXX.XXX.XXX => BUREAU
		RES=$(grep -w ^${BUREAU} ${CSVFIC}) # on cherche l'entree code portefeuille (BUREAU) dans le fichier CSV

		if [ ! -z "${RES}" ]
		then #on a trouvé le code portefeuille
			StructureN2=$(echo ${RES} | cut -d';' -f2)
			StructureN2Prefixe=$(echo ${RES} | cut -d';' -f3)
			StructureN2Suffixe=$(echo ${RES} | cut -d';' -f4)
		else #code portefeuille inexistant dans CSV on utilise les valeurs par defaut
			StructureN2=$(charge_variable_config StructureN2Defaut ${CSVFIC})
			StructureN2Prefixe=$(charge_variable_config StructureN2DefautPrefixe ${CSVFIC})
			StructureN2Suffixe=$(charge_variable_config StructureN2DefautSuffixe ${CSVFIC})
		fi

		StructureFinale=${StructureN2Prefixe}${StructureN2}${StructureN2Suffixe}

		typeset -u ENV
		ENV="${3}"

		####### debut copie via smbclient #######
		SAMBA="/usr/bin/smbclient ${ServeurCible} -U ${ServeurCible_User}%${ServeurCible_Passwd} -N"
		# penser a doubler les '\' quand ils sont suivis de $
		DIR0="${ENV}"
		DIR1="${DIR0}\\${StructureN1}"
		DIR2="${DIR1}\\${StructureFinale}"
		
		echo "Copie de \"${FILEPATH}\" dans \"${DIR2}\" via smbclient"
		${SAMBA} -c "put ${FILEPATH} ${DIR2}\\${FILENAME}"
		if [ ! ${?} = 0 ]
		then	# la copie a echoue, on cree l'arborescence
			${SAMBA} -c "md ${DIR1}"				# d'abord StructureN1
			${SAMBA} -c "md ${DIR2}"				# puis StructureFinale
			${SAMBA} -c "put ${FILEPATH} ${DIR2}\\${FILENAME}"		# enfin, on retente une copie qui normalement devrait bien se passer
			if [ ! ${?} = 0 ]
			then	# la copie a echoue malgre la creation du repertoire, donc on sort en erreur (pb d'acces/mdp/user/droit/...?)
				echo "Erreur lors du l'envoi du fichier via smbclient (samba)!!"
				STATUS="T00"
				params="$ligne_param $STATUS"
				/editique/bin/logafpimp_gen.sh ${params}
				return 1
			fi
		fi
		####### fin copie via smbclient #######

	else #1 seul index: BUREAU.TYPE.DATE.EXTENSION
		BUREAU=${FILENAME%%.*} # 1ere partie du nom du fichier sans extension BUREAU.TYPE.DATE.EXTENSION => BUREAU
		DESTNAME=${FILENAME#*.} # on supprime le nom du bureau du nom du fichier BUREAU.TYPE.DATE.EXTENSION => TYPE.DATE.EXTENSION
		FICTYPE=${DESTNAME%%.*} # 2eme partie du nom du fichier TYPE.DATE.EXTENSION => TYPE
		typeset -u ENV
		ENV="${3}"

		####### debut copie via smbclient #######
		# on copie les fichiers dans $ENV\ENIM\TD\BUREAUX\$BUREAU, ou $ENV\CPR\GEN\TD\BUREAUX devrait toujours exister, le reste on le cree
		# On essaye de copier le fichier, si ca ne marche pas c'est que le repertoire n'existe pas, donc on le cree et on reessaye,
		# et apres ca si ca marche toujours pas: c'est mal!
		SAMBA="/usr/bin/smbclient //hpdata10/Resultats_Editique -U edit%12345"
		# penser a doubler les '\' quand ils sont suivis de $
		DIR="${ENV}\ENIM\TD\BUREAUX\\${FICTYPE}"
		DEST="${DIR}\\${BUREAU}"
		echo "Copie de \"${FILEPATH}\" dans \"${DEST}\\${DESTNAME}\" via smbclient"
		${SAMBA} -c "put ${FILEPATH} ${DEST}\\${DESTNAME}"
		if [ ! ${?} = 0 ]
		then	# la copie a echoue, on cree le repertoire
			${SAMBA} -c "md ${DIR}"				# d'abord le repertoire 'type de fichier' (ex: EDIS4A)
			${SAMBA} -c "md ${DEST}" 			# puis le bureau
			${SAMBA} -c "put ${FILEPATH} ${DEST}\\${DESTNAME}"	# enfin, on retente une copie qui normalement devrait bien se passer
			if [ ! ${?} = 0 ]
			then	# la copie a echoue malgre la creation du repertoire, donc on sort en erreur (pb d'acces/mdp/user/droit/...?)
				echo "Erreur lors du l'envoi du fichier via smbclient (samba)!!"
				STATUS="T00"
				params="$ligne_param $STATUS"
				/editique/bin/logafpimp_gen.sh ${params}
				return 1
			fi
		fi
		####### fin copie via smbclient #######

	fi

	\rm -fv "${FILEPATH}"

else
	if [ "${7}" == "D" -o "${7}" == "P" -o "${7}" == "G" ]
	then
        	SRC="${SRC_BASE}.${DEST1}"
		#on verifie que le fichier existe bien
		if [ ! -f "${SRC}" ]
		then
			echo "Fichier source \"${SRC}\" inexistant!!"
			STATUS="T00"
			params="$ligne_param $STATUS"
			/editique/bin/logafpimp_gen.sh ${params}
			return 1
		fi
	
        	#typeset -Z6 nbpages=${8}
        	nbpages=${8:0:6}
        	typeset -l destination="${6}"
        	DEST="/IMPMSA/${3}/${destination}/${FILENAME%.*}.${nbpages}.${DEST1}"
		#on verifie que le repertoire existe bien
		if [ ! -d "$(dirname ${DEST})" ]
		then
			echo "Repertoire de destination \"$(dirname ${DEST})\" inexistant!!"
			STATUS="T00"
			params="$ligne_param $STATUS"
			/editique/bin/logafpimp_gen.sh ${params}
			return 1
		fi
	
		#Copie du fichier en ged si la variable emis ged est positionnee
		if [ ${1} = "1" ] #copie du fichier afp sous /import_ged pour mise en ged
		then
			#on construit le nom du fichier afp a mettre en ged
			# on passe l'extension du fichier AFP_FILE en majuscule pour integration avec le programme de ged
			typeset -u EXT_MAJ=${DEST1} # on met l'extension du fichier en majuscule
			AFP_FILE="${FILENAME%.*}.${nbpages}.${EXT_MAJ}"

			#creation du repertoire s'il n'existe pas
			typeset -L6 REP=${AFP_FILE}

			#si on est en prod on depose dans les repertoire d'import ged de prod, sinon on depose dans la ged en test
			[ "${3}" = "prod" ] && GED_DIR="/import_ged_prod/ged/${REP}" || GED_DIR="/import_ged_test/ged_test/${REP}"

			#creation du repertoire sur le serveur de ged s'il n'existe pas
			if [ ! -d ${GED_DIR} ]
			then
				mkdir ${GED_DIR} && chmod 777 ${GED_DIR}
				#on teste le retour
				if [ ! ${?} = 0 ]
				then
					echo "Erreur lors de la creation du repertoire \"${GED_DIR}\" en GED!!"
					STATUS="T00"
					params="$ligne_param $STATUS"
					/editique/bin/logafpimp_gen.sh ${params}
					return 1
				fi
			fi

			echo "Copie de ${SRC} dans ${GED_DIR}/${AFP_FILE}"
			cp ${SRC} ${GED_DIR}/${AFP_FILE}.TRF && chmod 666 ${GED_DIR}/${AFP_FILE}.TRF && mv ${GED_DIR}/${AFP_FILE}.TRF ${GED_DIR}/${AFP_FILE}

			#on teste le retour
			[ ! ${?} = 0 ] && echo "Erreur lors de la copie du fichier \"${AFP_FILE}\" en GED!!" && return 1
		fi
    if [ "${7}" = "G" ]
    then
          echo "Suppression de \"${SRC}\""
          \rm "${SRC}"
    else
        	echo "Deplacement de \"${SRC}\" dans \"${DEST}\""
        	\mv "${SRC}" "${DEST}.TRF"
        	\mv "${DEST}.TRF" "${DEST}"
    

      		#on teste le retour du second mv seulement, si le premier echoue, le second echouera automatiquement!
      		if [ ! ${?} = 0 ]
      		then
      			echo "Erreur lors du deplacement du fichier!!"
      			STATUS="T00"
      			params="$ligne_param $STATUS"
      			/editique/bin/logafpimp_gen.sh ${params}
      			return 1
      		fi
    fi
	fi

	
	if [ "${7}" == "D" -o "${7}" == "S" ]
	then
        	SRC="${SRC_BASE}.${DEST2}"
		#on verifie que le fichier existe bien
		if [ ! -f "${SRC}" ]
		then
			echo "Fichier source \"${SRC}\" inexistant!!"
			STATUS="T00"
			params="$ligne_param $STATUS"
			/editique/bin/logafpimp_gen.sh ${params}
			return 1
		fi

		typeset -u ENV
		ENV="${3}"

		####### debut copie via smbclient #######
		# on copie les fichiers dans $ENV\CPR\GEN\TD\BUREAUX\$TYPEFIC\$BUREAU, ou $ENV\CPR\GEN\TD\BUREAUX devrait toujours exister, le reste on le cree
		# penser a doubler les '\' quand ils sont suivis de $
		SAMBA="/usr/bin/smbclient //hpdata10/Resultats_Editique -U edit%12345"
		DEST="${ENV}\ENIM\TD\GLOBAL\\${FILENAME%.*}.${DEST2}"

		echo "Copie de \"${SRC}\" dans \"${DEST}\" via smbclient"
		${SAMBA} -c "put ${SRC} ${DEST}"

		if [ ! ${?} = 0 ]
		then    # la copie a echoue
			echo "Erreur lors du l'envoi du fichier via smbclient (samba)!!"
			STATUS="T00"
			params="$ligne_param $STATUS"
			/editique/bin/logafpimp_gen.sh ${params}
			return 1
		fi
		####### fin copie via smbclient #######

		\rm -fv "${SRC}"

	fi
fi

params="$ligne_param $STATUS"
echo "traitement OK: lancement de /editique/bin/logafpimp_gen.sh ${params}"
/editique/bin/logafpimp_gen.sh ${params}
