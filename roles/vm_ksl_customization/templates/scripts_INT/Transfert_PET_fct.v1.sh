#-------------------------------------------------------------------------------
__APP__=Transfert_PET_fct.sh
#
# Auteur(s)          : JP CORIZZI, DSI-TO/T
# 
# Version            : 04/2021 ................................ 1.0.0
__VERSION__=1.0.0
#	Description
#   - Bibliothéque de fonction de transferts vers la PET via SSH
#   - Necessite Transfert_PET.cfg
#
#-------------------------------------------------------------------------------

#---------------------------------------- functions
function log
{
  # $1  : CODE RETOUR
  # $2  : Typologie de procédure
  # $3  : Message d'erreur
  #
	local RC=$1
  local PROCEXE=$2
	local msg=$3
	#
	echo "$(date "${LOG_date_format}");${PROCEXE};${RC};${msg}" | tee -a  ${FULLPATH_log}
	return 0
}

function transfert
{
  # $1  : Port de connexion
  # $2  : Full path du fichier à transfére
  # $3  : user@host:path destination
  #
  local rc=255
  local tr_PORT=$1
  local tr_SRC=$2
  local tr_DEST=$3
  #
  until ( [[ ${rc} -eq 0 ]] || [[ ${MAX_RETRY} -eq 0 ]] )
  do
    scp -q -P ${tr_PORT} "${tr_SRC}" "${tr_DEST}"
    rc=$?
    if ( [[ ${rc} -ne 0 ]] ) then
      log ${rc} "${PROC}" "ECHEC du transfert : Nouvelle tentative (${MAX_RETRY}) dans ${WAIT_RETRY} secondes"
      ((MAX_RETRY--))
      sleep ${WAIT_RETRY}
    fi
  done
  return ${rc}
}
#---------------------------------------- functions
