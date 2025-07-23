#!/bin/bash
#
# Archivage et nettoyage des repertoires editique:
# /${environnement}/${caisse}/[tr|td]/[etats|gra|grana|stde|decm|cpr/pirat]/[encours|erreurs|result|save|xml*]/*
# A executer tous les 1ers jours de chaque mois apres 00h00
#

Membre="yann.kloniecki@cpr.sncf.fr"
LOGF="/tmp/$(basename $0).log"
caisse=m13
LISTE_ENVIRONNEMENTS="recette preprod prod"
LISTE_MODE="tr td"
LISTE_TRAITEMENTS="etats gra grana stde decm cpr/pirat cpr/gen"
#les fichiers vieux de plus de NBJOURS seront supprimes
#NBJOURS=le nombre de jours du mois precedent, donc on supprime les fichiers plus vieux que le mois M-1
NBJOURS=$(TZ=12 ; date +%d)
HIST=3        	#nombre d'archives tgz a conserver pour le repertoire save
ARCH_DIR=mois_prec	# nom du repertoire de stockage des archives sous save

exec > $LOGF 2>&1
echo "--- Debut: $(date)"

#le script n'est demarrable que le 1er du mois entre 00h00 et 01h00
if [ ! "$(date +%d%H)" = "0100" ]
then
  echo "Ce script n'est activable que le 1er du mois entre 00h00 et 01h00!"
  cat $LOGF | mailx -s "$0: Erreur!" ${Membre}
  exit
fi

#on verifie que le script n'est pas lance trop frequemment
TIME_FILE=/var/locks/archive_editique.tim
if [ -f $TIME_FILE ] && [ -z "`find $TIME_FILE -mtime +27`" ]
then
  echo "N'executer ce script qu'une fois par mois!!!"
  echo "Supprimez $TIME_FILE pour forcer l'execution!"
  cat $LOGF | mailx -s "$0: Erreur!" ${Membre}
  exit
fi


for env in $LISTE_ENVIRONNEMENTS
do
  [ ! -d /$env ] && echo "***** /$env inexistant!!! *****" || for mode in $LISTE_MODE
  do
    [ ! -d /$env/$caisse/$mode ] && echo "***** /$env/$caisse/$mode inexistant!!! *****" || for traitement in $LISTE_TRAITEMENTS
    do
      #/$env/$caisse/$mode/$traitement/...

      REP=/$env/$caisse/$mode/$traitement

      [ ! -d $REP ] && echo "***** $REP inexistant!!! *****" ||
      (
      echo "Traitement de $REP"
      cd $REP

      # on traite le repertoire save:
      # on archive les fichiers vieux de plus de NBJOURS dans un fichier ${env}_$(date +%Y%m%d).tgz (ex. prod_20071230.tgz)
      # on ne garde que $HIST fichiers archive
      if [ -d save ]
      then
        # on verifie que le repertoire des archives existe sinon on le cree
        [ ! -d $ARCH_DIR ] && mkdir $ARCH_DIR
        # suppression des fichiers vieux de plus d'un mois
        echo "Suppression a +${NBJOURS} jours dans $REP/save"
        find save -type f -mtime +${NBJOURS} -exec rm {} \;
        # dans les repertoires save on archive ce qui reste (les fichiers du mois precedent)
        echo "Archivage de $REP/save dans ${ARCH_DIR}/${env}_$(TZ=12 ; date +%Y%m).tgz"
        time tar cf - save | gzip -c > ${ARCH_DIR}/${env}_$(TZ=12 ; date +%Y%m).tgz
        # Nombre de fichiers ${ARCH_DIR}/${env}_*.tgz presents dans le repertoire ARCH_DIR
        nbfiles=$(ls -1 ${ARCH_DIR}/${env}_*.tgz | wc -l)
        # on supprime les fichiers ${ARCH_DIR}/${env}_*.tgz les plus vieux, on ne garde que $HIST fichiers
        echo "Rotation des archives"
        [ $nbfiles -gt $HIST ] && ls -1t ${ARCH_DIR}/${env}_*.tgz | tail -$(expr $nbfiles - $HIST) | xargs rm
      else
        echo "***** $REP/save inexistant!!! *****"
      fi

      if [ -d result ]
      then
        #dans les repertoires result on supprime tout ce qui est vieux de plus de $NBJOURS jours...
        echo "Suppression a +${NBJOURS} jours dans $REP/result"
        find result -type f -mtime +${NBJOURS} -exec rm {} \;
      else
        echo "***** $REP/result inexistant!!! *****"
      fi

      if [ -d xml* ]
      then
        #dans les repertoires xml* (xmlfgtg/xmlstde/xmlcobol) on supprime tout ce qui est vieux de plus de 7 jours...
        echo "Suppression a +7 jours dans $REP/xml*"
        find xml* -type f -mtime +7 -exec rm {} \;
      else
        echo "***** $REP/xml* inexistant!!! *****"
      fi

      if [ -d erreurs ]
      then
        #dans les repertoires erreurs on supprime tout ce qui est vieux de plus de $NBJOURS jours...
        echo "Suppression a +60 jours dans $REP/erreurs"
        find erreurs -type f -mtime +60 -exec rm {} \;
      else
        echo "***** $REP/erreurs inexistant!!! *****"
      fi

#      if [ -d encours ]
#      then
#        #dans les repertoires encours normalement on ne devrait rien avoir, on supprime donc tout ce qui est vieux de plus de 2 jours
#        echo "Suppression a +2 jours dans $REP/encours"
#        find encours -type f -mtime +2 -exec rm {} \;
#      else
#        echo "***** $REP/encours inexistant!!! *****"
#      fi

      echo "Sortie de $REP"
      )
    done
  done
done

touch $TIME_FILE

echo "--- Fin: $(date)\n\n"

cat $LOGF | mailx -s "$0: Sauvegarde editique OK" ${Membre}
