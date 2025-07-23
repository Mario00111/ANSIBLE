#!/bin/bash
#
#-------------------------------------------------------------------------------
#	Shell PostTraitKSL_FDS.sh appelé par KSL
#
#
#	Stephane Le Labourier
#  Attention: paramètres positionnels (@ si vide)
#  variables reçues: $1= Fichier à traiter
#                    $2= Repertoire de destination
#                    $3= Code erreur            
#-------------------------------------------------------------------------------


FIC=${1}
REPDEST=${2}
NBARGS=3



if [ ! $# -eq $NBARGS ]
then
	return 1
fi

mv ${1} ${2} 
