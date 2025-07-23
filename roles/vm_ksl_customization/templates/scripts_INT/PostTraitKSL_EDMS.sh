#!/bin/bash
#
#-------------------------------------------------------------------------------
#	Shell PostTraitKSL_EDMS.sh appelÚ par KSL serveur 
#
#
#	 Droit d'auteur : Fabrice Devin
#  Attention: paramÞtres positionnels (@ si vide)
#  variables reþues: $1= Repertoire dossier Ó traiter
#                    $2= Repertoire de destination
#                    $3= Repertoire de sauvegarde            
#-------------------------------------------------------------------------------

PATH_DOSSIER=${1}
PATH_REPDEST=${2}
PATH_REPSAVE=${3}
NBARGS=3



if [ ! $# -eq $NBARGS ]
then
	return 1
fi

cp -R ${1}/* ${2}
mv ${1} ${3} 
