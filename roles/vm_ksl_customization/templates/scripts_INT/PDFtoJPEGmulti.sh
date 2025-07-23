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
#                    $3=dossier PJ
#-------------------------------------------------------------------------------

CPTPIECE=1
FichierPJTMP=${1}/${2}/"NomFichierTmp.txt"
FichierPJ=${1}/${2}/"NomFichierPJ.txt"
Prefix0=0
LOG=${1}/"log.txt"
#Création du répertoire contenant les pièces jointes
mkdir "${1}/${2}"

#Création du répertoire contenant les pièce jointe au format pdf
mkdir "${1}/${2}/pdf"

while [ $CPTPIECE != 0 ]
do
  if [ $CPTPIECE -gt 9 ]
  then
    Prefix0=""
  fi
  if [[ ( -f "${1}${2}_${Prefix0}${CPTPIECE}.pdf" || -f "${1}${2}_${Prefix0}${CPTPIECE}.jpg") ]]  
  then
    echo "Compteur piece jointe ${CPTPIECE}"
    echo "${1}${3}${2}"
    if [[ -f "${1}${2}_${Prefix0}${CPTPIECE}.pdf" ]] 
    then
      gs -dNOPAUSE -sDEVICE=jpeg -r300 -dAutoRotatePages=/None -sOutputFile=${1}/${2}/${2}"_"${Prefix0}${CPTPIECE}"-%03d.jpg"  ${1}${2}"_"${Prefix0}${CPTPIECE}".pdf"
      #Déplacement des fichiers initiaux vers le dossier PJ
      mv "${1}${2}_${Prefix0}${CPTPIECE}.pdf" "${1}/${2}/pdf/t_${2}_${Prefix0}${CPTPIECE}.pdf"
    else
    #Déplacement des fichiers initiaux vers le dossier PJ
    mv "${1}${2}_${Prefix0}${CPTPIECE}.jpg" "${1}/${2}/${2}_${Prefix0}${CPTPIECE}.jpg"
    fi
    CPTPIECE=$(($CPTPIECE+1))
  else
    CPTPIECE=0
  fi
done

#Parcours de la liste de fichiers produits
for file in `find ${1}${2} -type f -name ${2}*`
do
  #Récupération de la taille de l'image 
  size=`identify $file | awk '{print $3}'`
  #Récupération de largeur de l'image
  width=`echo $size | sed 's/[^0-9]/ /g' | awk '{print $1}'`
  #Récupération de la hauteur de l'image
  height=`echo $size | sed 's/[^0-9]/ /g' | awk '{print $2}'`
  #Contrôle si la largeur est inférieur à la haute => format Paysage
  if [ $width -gt $height ]  
  then
    #Rotation de l'image
    convert $file -rotate 90 $file
  fi
  #Récupération du nom de l'image uniquement
  nomFichier=`basename $file`
  echo ${nomFichier} >>$FichierPJTMP
done

#Tri du fichier
sort ${FichierPJTMP}>>$FichierPJ
rm ${FichierPJTMP}