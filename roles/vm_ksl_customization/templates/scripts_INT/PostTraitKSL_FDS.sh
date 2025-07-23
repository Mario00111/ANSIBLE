#!/bin/bash
#
#-------------------------------------------------------------------------------
#	Shell PostTraitKSL_FDS.sh appel� par KSL
#
#
#	Stephane Le Labourier
#  Attention: param�tres positionnels (@ si vide)
#  variables re�ues: $1= Fichier � traiter
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
