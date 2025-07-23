#!/bin/bash
#
#-------------------------------------------------------------------------------
#	Shell PDFtoJPEG.sh appelé par KSL
#
#
#
#  Attention: paramètres positionnels (@ si vide)
#  variables reçues: $1= chemin
#                    $2= nom du fichier
#
#-------------------------------------------------------------------------------

CPTPIECE=1

while [ $CPTPIECE != 0 ]
do
  if [[ ( -f "${1}${2}_${CPTPIECE}.pdf" || -f "${1}${2}_${CPTPIECE}.jpg") ]]  
  then
    echo "Compteur piece jointe ${CPTPIECE}"
    if [[ -f "${1}${2}_${CPTPIECE}.pdf" ]] 
    then
      gs -dNOPAUSE -sDEVICE=jpeg -r300 -sOutputFile=${1}${2}"_"${CPTPIECE}".jpg"  ${1}${2}"_"${CPTPIECE}".pdf"
    fi
    CPTPIECE=$(($CPTPIECE+1))
  else
    CPTPIECE=0
  fi
done