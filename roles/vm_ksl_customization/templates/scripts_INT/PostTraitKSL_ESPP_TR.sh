#!/bin/bash
#
#-------------------------------------------------------------------------------
#	Shell PostTraitKSL_ESPP_TR appelé par KSL
#
#
# fabrice devin
#  Attention: paramètres positionnels (@ si vide)
#  variables reçues: $1= chemin du dossier encour
#                    $2= identifiant de la demande
#                    $3= chemin du dossier de sauvegarde
#                    $4= nom du fichier de données
#-------------------------------------------------------------------------------


#Déplacement du dossier contenant les PJ
mv "${1}${2}" "${3}"

#Déplacement du fichier de données dans le dossier de sauvegarde de la demande
if [[ -f "${1}${4}" ]]
then
  mv "${1}${4}" "${3}/${2}/${4}" 
fi