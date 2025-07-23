#!/bin/bash
#
#-------------------------------------------------------------------------------
#	Shell PostTraitKSL_ESPP_TR appel� par KSL
#
#
# fabrice devin
#  Attention: param�tres positionnels (@ si vide)
#  variables re�ues: $1= chemin du dossier encour
#                    $2= identifiant de la demande
#                    $3= chemin du dossier de sauvegarde
#                    $4= nom du fichier de donn�es
#-------------------------------------------------------------------------------


#D�placement du dossier contenant les PJ
mv "${1}${2}" "${3}"

#D�placement du fichier de donn�es dans le dossier de sauvegarde de la demande
if [[ -f "${1}${4}" ]]
then
  mv "${1}${4}" "${3}/${2}/${4}" 
fi