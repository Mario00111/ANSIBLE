#!/bin/bash
#
#-------------------------------------------------------------------------------
#	Shell logafpimp.sh appelé par le service KSL lancement_Shell_GRA_suite
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
#                    $7= mode (D ou P) (debug/prod)
#                    $8= nombre de pages
#                    $9= media (afp/pdf/...)
#		     $10=index_suivi pour table MSAafpimp suivi traitement 
#		     $11=status
#-------------------------------------------------------------------------------
NBARGS=11


LOG_BASE="/logtmp/log/m13/tsns/pilot"
CMD="$0 $*"

LOG="${LOG_BASE}/pil.log"

if [ ! $# -eq ${NBARGS} ]
then
	#envoyer un mail a l'admin
	echo "------ $(date) ------" | tee -a ${LOG}
	echo "Ligne de commande: \"${CMD}\"" | tee -a ${LOG}
	echo "Arguments attendus ${NBARGS} <> $# recus !" | tee -a ${LOG}
	echo "--Sortie--" | tee -a ${LOG}
	return 1
fi



dateTrait=$(date +%y/%m/%d)		# date
heureTrait=$(date +%H:%M:%S)		# heure
status=${11}				# status (T00, T01,...)
FILENAME=$(basename $2)			# imp: on récupère ex: EDIGRA.04182659.pdf
impedit=${FILENAME%.*}			# nom long du fichier
imp_01=${10} 				#
imp=`echo $imp_01 | awk -F"." '{print $1}' `		# on enlève l'extension ex: EDIGRA.04182659 
nomfic1=`echo $imp_01 | awk -F"-" '{print $3}' `	# nom du fichier recepteur des infos
nomfic=`echo $nomfic1 | awk -F"." '{print $1}' `	# nom du fichier recepteur des infos
ged=${1} 				# mise en ged
pages=${8} 				# pages
typeimp="T"				# typeimp (P pour prod, T pour test)



if [ ${11} = "T01" ] # traitement ok
then
	code_ret="TRAITEMENT OK" 
else
	code_ret="TRAITEMENT KO" 
fi

#if [ ${1} = 1 ] # mise en ged
#then
#	echo "Fichier mis en GED" >> $LOG
#fi

#Infos de connexion au serveur pilote
PILSERV=pilmast
PILUSER=ismadm
PILFILE=/home/data_in/IMP

ligne="$dateTrait;$heureTrait;$status;$imp;$impedit;$typeimp;$ged;$pages;$code_ret"
#echo $ligne >> $LOG
#echo "Inscription resultat:\n$ligne\ndans PILUSER@PILSERV:$PILFILE"
rsh $PILSERV -l $PILUSER "echo \"$ligne\" > $PILFILE/$nomfic.IMP_02"

echo "----------------------------------------------------------" >> $LOG
echo "     logafpimp_fgic.sh     $nomfic.IMP_02" >> $LOG
echo "----------------------------------------------------------" >> $LOG
echo ${CMD} >> $LOG			# ligne de paramètres
echo $dateTrait >> $LOG			# date
echo $heureTrait >> $LOG		# heure
echo $status >> $LOG			# status (T00, T01,...)
echo $imp >> $LOG			# imp
echo $nomfic >> $LOG			# nom du fichier recepteur des infos
echo $impedit  >> $LOG			# impedit
echo $ged >> $LOG			# ged
echo $pages  >> $LOG			# nbre de pages
echo $code_ret >> $LOG
echo "----------------------------------------------------------" >> $LOG

