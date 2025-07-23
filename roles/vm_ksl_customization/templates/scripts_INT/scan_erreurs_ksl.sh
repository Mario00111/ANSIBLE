#!/bin/sh
#
# Script permettant de scanner les arborescences editique/ksl $ENVIRONNEMENTS
# a la recherche d'eventuels fichiers remontes en erreur par ksl
# a executer tous les jours
# 

ENVIRONNEMENTS="integration recette preprod prod"
MAILTO="yann.kloniecki@cpr.sncf.fr ext.steria.lippi@cpr.sncf.fr stephane.le-labourier@cpr.sncf.fr"
MAILCONTENT="/tmp/`basename $0`_$$.tmp"
TMP=${MAILCONTENT}_$$

#on initialise le fichier de mail
> $MAILCONTENT

for env in $ENVIRONNEMENTS
do
	# on recherche les fichiers en erreur datant de moins d'un jour (ils se trouvent dans les repertoires erreurs normalement!)
	find /$env -mtime -1 -ls | grep erreurs | grep -v erreurs$ | awk '{print $9, $8, $10, "-", $7, "octets -", $11}' 2> /dev/null 1> $TMP
	#so on a trouve des erreurs on met ca dans le fichier qui va etre envoye par mail
	[ -s "$TMP" ] && echo "$env:" >> $MAILCONTENT && cat $TMP >> $MAILCONTENT
done

# on sort si on a trouve aucun fichier erreur datant de moins d'un jour
[ ! -s "$MAILCONTENT" ] && \rm -ef $MAILCONTENT $TMP && exit

# sinon on mail le resultat
for Membre in $MAILTO
do
	cat $MAILCONTENT | mailx -s "KSL/editique: Fichiers en erreur." $Membre
done

\rm -fe $MAILCONTENT $TMP
