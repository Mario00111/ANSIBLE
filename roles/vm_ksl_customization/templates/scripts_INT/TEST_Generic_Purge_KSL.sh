#Script de purge KSL generique preprod/prod

#Designation des variables
Horodateur=$(date '+%d/%m/%Y %X')
case ${HOSTNAME} in 
	kslprod01.cpr.sncf.fr) Path_conf=/editique/bin
						   Path_log=/editique/bin/log
						   Fic_conf=List_purge_KSLPROD.config
						  ;;
	   	       naelan) Path_conf=/editique/bin
	   					   Path_log=/editique/bin/log
						   Fic_conf=List_purge_NAELAN.config
						  ;;
						*) echo "[ERR 1] Erreur serveur hote inconnu"; exit 1
						  ;;
esac
LOG=${Path_log}/TEST_Generic_Purge_KSL.log

#Controles du fichier.config (si il existe, si les argument obligatoires ne sont pas manquant)
if [ ! -d ${Path_conf} ]
	then
		echo "[ERR 2] Chemin du fichier config absent" >> ${LOG}
		exit 2
fi

if [ ! -f ${Path_conf}/${Fic_conf} ]
	then
		echo "[ERR 3] Le fichier config n'existe pas" >> ${LOG}
		exit 3
fi

#Exécution de la purge :
echo "${Horodateur} : Debut purge des répertoires tmp du serveur ksl" >> ${LOG}
while read line
  do
	#Skip des lignes commentees dans le fichier de config
	echo "$line" | grep -q '^#' && continue
    CHEMIN=$(echo "$line" | cut -d':' -f1)
    RETENTION=$(echo "$line" | cut -d':' -f2)
    TYPE=$(echo "$line" | cut -d':' -f3)
    NOM=$(echo "$line" | cut -d':' -f4)
    Horodateur=$(date '+%d/%m/%Y %X')
	#Skip des lignes ayant des arguments manquants
	if [ -z "${CHEMIN}" -o -z "${RETENTION}" -o -z "${TYPE}" ]
		then
			echo "[WARN] Argument manquant, la ligne suivante n'est pas traitee :" >> ${LOG} 
			echo "$line" >> ${LOG}
			continue
	fi
    echo "${Horodateur} : Suppression des fichiers ${CHEMIN}" >> ${LOG}
    if [ -z "${NOM}" ]
      # Si il n'y a pas de nommage a respecter
      then
        find "${CHEMIN}" -type ${TYPE} -mtime +${RETENTION} -print >> ${LOG} #-exec rm -rf "{}" \;
      # Si il y a un nommage a respecter
      else
        find "${CHEMIN}" -type ${TYPE} -name "${NOM}" -mtime +${RETENTION} -print >> ${LOG} #-exec rm -rf "{}" \;
    fi
    echo "${Horodateur} : Fin purge du répertoire ${CHEMIN}">> ${LOG}
done < /${Path_conf}/${Fic_conf}
#fin
