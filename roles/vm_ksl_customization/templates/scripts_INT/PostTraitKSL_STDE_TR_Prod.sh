#!/bin/bash
#
#-------------------------------------------------------------------------------
#	Shell PostTraitKSL_STDE_TR.sh appelé par KSL
#
#
#	yann kloniecki
#  
# Variables décrites dans ce traitement et exemple
#
#       "$dtrx"                                         02
#       "$dheu"                                         15263393
#       "$cagt_01"                              8064
#       "$emisged"                              0.0
#       "$ndescor"                              0.0
#       "$fichier"                                      /editique/ksl/ksl51a/serveur/instance_ora/tmp/ksl8952_0.pdf
#       "$etat"                                         3806
#       "$agent"                                        *GRA
#       "$date_creation"                        070702
#       "$tx"                                   G81
#       "$site"                                         M13
#       "$agence"                               0
#       "$type"                                         A
#       "$imprimante"                   MNI-DIR-D
#       "$traitement"                           /appcpr/ts/agra/script/lnc_cpr_tr.sh
#       "$environnement                 PS
#       "$numenvironnement"             01
#       "$numedition"                   0006
#       "$clez43"                               3806*GRA07070215263714G81
#       "$site_emetteur"                        M13
#       "$retour_host"                  @
#       "$retour_login"                         @
#       "$retour_path"                  @
#       "$destination"                          6
#       "$impressions"                          1
#       "$retour"                               0 #si OK
#	"$nbpages"				50
#	"$mad"				imp|sas
#
#-------------------------------------------------------------------------------

NBARGS=28

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
	return 1
fi

FICHIER=$6

TYPE=${13}
IMPRIMANTE=${14}
typeset -l ENVIRONNEMENT
ENVIRONNEMENT=${16#?}

case "${ENVIRONNEMENT}" in
        "i" | "s" | "p" | "r" )
                :
                ;;
        * )
                echo "------ $(date) ------" | tee -a ${LOG}
                echo "Ligne de commande: \"${CMD}\"" | tee -a ${LOG}
                echo "Variable environnement non prevue: \"${ENVIRONNEMENT}\"!" | tee -a ${LOG}
                echo "--Sortie--" | tee -a ${LOG}
                return 1
esac

TMP=$(basename ${FICHIER})
LOG_FILE="${LOG_BASE}/t${ENVIRONNEMENT}n${ENVIRONNEMENT}/cpr/${TMP%.*}.STDE_TR.log"

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

#on verifie que le fichier renvoye par ksl existe bien
if [ ! -f "${FICHIER}" ]
then
	echo "Fichier \"${FICHIER}\" inexistant!!"
	return 1
fi

#impression
SERVEUR="hpserveurx" # par defaut on imprime sur hpserveurx
[ ${TYPE} = "B" ] && SERVEUR="ghostserveur"
chaineimp="//${SERVEUR}/${IMPRIMANTE} -U usergra%usergra -c 'print ${FICHIER}'"
# on imprime $NBEX fois le document
while (true)
do
	NBEX=$((NBEX-1))
	echo "Impression de \"${FICHIER}\" sur \"//${SERVEUR}/${IMPRIMANTE}\" avec le user usergra%usergra. Reste ${NBEX}"
	eval "/usr/bin/smbclient ${chaineimp}"

	if [ ! ${?} = 0 ]
	then
		echo "Erreur D'impression!!"
		return 1
	fi

	[ ${NBEX} -le 0 ] && break
done

#\rm -fe ${FICHIER} // Pascal -e marche plus
\rm -fv ${FICHIER}