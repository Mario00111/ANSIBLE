#!/bin/bash
#-------------------------------------------------------------------------------
__APP__=Transfert_PET
#
# Auteur(s)          : JP CORIZZI, DSI-TO/T
# 
# Version            : 03/2022 ................................ 1.0.1
__VERSION__=1.0.1
# Version            : 04/2021 ................................ 1.0.0
#	Description
#   - Normalisation des transferts vers la PET via SSH
#
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#                  $1= Chemin complet du fichier à transferer
#                  $2= Repertoire de destination (distant)
#                  $3= Nom de  l'hôte distant  (si non renseigné, Hôte de par defaut de l'environnement)
#                  $4= login FTP de l'hôte distant    
# DEPRECATED       $5= mot de passe FTP de l'hôte distant
# EVOL             $6= Chemin absolue vers le fichier de log
#                       Si on passe autre chose qu'un chemin se sera pris comme valeur du champ "${PROCEXE}"   dans le log
#                       Sinon on utilisera la fichier de log "standard" défini dans le fichier ".cfg"
# DEPRECATED       $7= Mode debug (y ou n)
#                  $8= Emisged (0 ou 1)
#-------------------------------------------------------------------------------

( [[ "${DEBUG}" == "Y" ]] ) && set -x
LOG_date_format="+%Y%m%d %H:%M:%S"
#
BASE_bin=$(dirname $0)
source ${BASE_bin}/Transfert_PET.cfg
source ${BASE_bin}/Transfert_PET_fct.sh
#-------------------------------------------------------------------------------
case $# in
  8 )
    FULLPATH_fic="${1}"
    DEST_path="${2}"
    DEST_hote="${3:-${PET_HOTE}}"
    DEST_user="${4}"
    # EVOL de la gestion de l'argment 6
    PROC=$$
    #
    Debug="${7}"
    EmiseGed="${8}"
    ;;
  6 )
    FULLPATH_fic="${1}"
    DEST_path="${2}"
    DEST_hote="${3:-${PET_HOTE}}"
    DEST_user="${4}"
    # 
    PROC="${5}"
    #
    EmiseGed="${6}"
    ;;
  * )
    echo "** Nb d'arguments incorrect."
    exit 200
    ;;
esac

#-------------------------------------------------------------------------------
# Si le fichier à envoyer existe,on déclenche le transfert
if ( [[ -e ${FULLPATH_fic} ]] ) then
  transfert ${PET_PORT} "${FULLPATH_fic}" "${DEST_user}@${DEST_hote}:${DEST_path}"
  rc=$?
  #
  MSG_transfert="Transfert de ${FULLPATH_fic} vers ${DEST_user}@${DEST_hote}:${DEST_path}"
  if ( [[ ${rc} -eq 0 ]] ) then
    MsgRC="${MSG_transfert}" 
    log ${rc} "${PROC}" "${MsgRC}"
    #---------------------------------------- Transfert OK, on supprime le fichier si besoin.
    
    if ( [[ "${EmiseGed}" == "0" ]] ) then
      Msg="Suppression du fichier"
      rm -f ${FULLPATH_fic}
      rc=$?
      if ( [[ ${rc} -ne 0 ]] ) then
        rc=151
        Msg="${Msg} en erreur"
      fi
      log ${rc} "${PROC}" "${Msg}"
    fi
  else
    rc=150
    MsgRC="ABORT - ${MSG_transfert}"
    log ${rc} "${PROC}" "${MsgRC}"
  fi
else
  rc=241
  MsgRC="ABORT - Fichier ${FULLPATH_fic} inexistant."
  log ${rc} "${PROC}" "${MsgRC}"
fi
 #
exit ${rc}
