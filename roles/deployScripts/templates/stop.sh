#!/bin/bash
# Script arret Weblogic
####################################################
clear
export BEA_HOME=/SOFT/oracle/wls_121300
export WL_HOME=${BEA_HOME}/wlserver
export JAVA_HOME=/SOFT/oracle/java_current
export SCRIPT_HOME=/u01/scripts

echo "******************************"
echo "** Script stop weblogic     **"
echo "******************************"
echo "*"
echo "*"
echo "*"
echo "*"

CIBLE=$1
DOMAIN_USED="/u01/domains/"$HOSTNAME"_domain"

stopNM()
{
if [ $CIBLE != '' ]  ; then
  echo "*"
  echo "** Arret NodeManager **"
  ${WL_HOME}/common/bin/wlst.sh ${SCRIPT_HOME}/stopNM.py $HOSTNAME
        if [ "$?" -ne "0" ]; then
                echo "*"
                echo "*"
                echo "Erreur Arret NodeManager. Procedure interrompue."
        else
                echo "*"
                echo "**  Arret NodeManager OK **"
                echo "*"
        fi
  echo "**  Procedure terminee.     **"
  echo "*"
  echo "******************************"
else
  exit
fi
}

stopAD()
{
if [ $CIBLE != '' ]  ; then
  echo "*"
  echo "** Arret AdminServer **"
  ${WL_HOME}/common/bin/wlst.sh ${SCRIPT_HOME}/stopAD.py $HOSTNAME
        if [ "$?" -ne "0" ]; then
                echo "*"
                echo "*"
                echo "Erreur Arret AdminServer. Procedure interrompue."
        else
                echo "*"
                echo "**  Arret AdminServer OK **"
                echo "*"
        fi
  echo "**  Procedure terminee.     **"
  echo "*"
  echo "******************************"
else
  exit
fi
}

stopMS()
{
if [[ $CIBLE != '' ]]  ; then
  echo "*"
  echo "** Arret ManagedServer **"
  ${WL_HOME}/common/bin/wlst.sh ${SCRIPT_HOME}/stopMS.py $HOSTNAME $CIBLE
        if [ "$?" -ne "0" ]; then
                echo "*"
                echo "*"
                echo "Erreur Arret ManagedServer. Procedure interrompue."
        else
                echo "*"
                echo "**  Arret ManagedServer OK **"
                echo "*"
        fi
  echo "**  Procedure terminee.     **"
  echo "*"
  echo "******************************"
else
  exit
fi
}

case $CIBLE in
   NM)
      stopNM 
      ;;
   AD)
      stopAD
      ;;
   MS1|MS2)
      stopMS
      ;;
   ALL)
      stopMS
      stopAD
      stopNM
      ;;
   *)
     echo "Verifiez les parametres de lancement"
     ;;
esac
