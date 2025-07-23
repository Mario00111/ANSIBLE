#!/bin/bash
#
#-------------------------------------------------------------------------------
#	Shell logeclatafpimp_stde.sh appel� par PostTraitKSL_STDE_Prod.sh
#
#
#	yann kloniecki
#  Attention: param�tres positionnels (@ si vide)
#  variables re�ues: $1= Emis ged
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
#		     $13=fichier log
#		     $13=status (T0x) 
#
#-------------------------------------------------------------------------------
NBARGS=14


LOG_BASE="/logtmp/log/m13/trnr/pilot"
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
status=${14}				# status (T00, T01,...)
FILENAME=$(basename $2)			# imp: on r�cup�re ex: EDIGRA.04182659.pdf
impedit=${FILENAME%.*}			# nom long du fichier
imp_01=${12} 				#
imp=`echo $imp_01 | awk -F"." '{print $1}' `		# on enl�ve l'extension ex: EDIGRA.04182659 
nomfic1=`echo $imp_01 | awk -F"-" '{print $3}' `	# nom du fichier recepteur des infos
nomfic=`echo $nomfic1 | awk -F"." '{print $1}' `	# nom du fichier recepteur des infos
ged=${1} 				# mise en ged
pages=${8} 				# pages
typeimp="P"				# typeimp (P pour prod)
fichier_log=${13}			# fichier log

# remplace les points car des underscores
# pour le cas des fichiers �clat�s, le nom *.IMP_03
# doit �tre diff�rent pour chaque fichier transmis
# au scrutateur
# pour .IMP_03 le nom du fichier n'est plus nomfic
# mais impeditsanspoint 

impeditsanspoint=$(echo $impedit | sed 's/\./\_/g')



if [ ${14} = "T01" ] # traitement ok
then
	code_ret="TRAITEMENT OK" 
else
	code_ret="TRAITEMENT KO" 
fi

#if [ ${1} = 1 ] # mise en ged
#then
#	echo "Fichier mis en GED" >> $LOG
#fi

#Infos de connexion au serveur pilot
PILSERV=pilmast
PILUSER=ismadm
PILFILE=/home/data_in/IMP

ligne="$dateTrait;$heureTrait;$status;$imp;$impedit;$typeimp;$ged;$pages;$code_ret;$fichier_log"
#echo $ligne >> $LOG
#echo "Inscription resultat:\n$ligne\ndans PILUSER@PILSERV:$PILFILE"
rsh $PILSERV -l $PILUSER "echo \"$ligne\" > $PILFILE/$impeditsanspoint.IMP_03"

echo "----------------------------------------------------------" >> $LOG
echo "     logeclatafpimp_stde.sh     $impeditsanspoint.IMP_03" >> $LOG
echo "----------------------------------------------------------" >> $LOG
echo ${CMD} >> $LOG			# ligne de param�tres
echo $dateTrait >> $LOG			# date
echo $heureTrait >> $LOG		# heure
echo $status >> $LOG			# status (T00, T01,...)
echo $imp >> $LOG			# imp
echo $nomfic >> $LOG			# nom du fichier recepteur des infos
echo $impedit  >> $LOG			# impedit
echo $impeditsanspoint >> $LOG		# impedit avec _ � la place des .
echo $ged >> $LOG			# ged
echo $pages  >> $LOG			# nbre de pages
echo $fichier_log >> $LOG		# fichier log
echo $code_ret >> $LOG
echo "----------------------------------------------------------" >> $LOG

