#!/bin/bash
# Script demarrage Weblogic
#############################
clear

export BEA_HOME=/SOFT/oracle/wls_121300
export WL_HOME=${BEA_HOME}/wlserver
export JAVA_HOME=/SOFT/oracle/java_current
export SCRIPT_HOME=/u01/scripts


echo "******************************"
echo "** Script start weblogic    **"
echo "******************************"
echo "*"
echo "*"

CIBLE=$1
DOMAIN_USED="/u01/domains/"$HOSTNAME"_domain"

startNM()
{
if [ $CIBLE != "" ]  ; then
  echo "*"
  echo "** Demarrage du nodemanager **"
  nohup ${DOMAIN_USED}/bin/startNodeManager.sh > ${DOMAIN_USED}/nodemanager/nodemanager.out 2>&1 &
  echo "** NodeManager OK **"
  echo "*"
  echo "** Procedure terminee. **"
  echo "*"
  echo "******************************"
else
  echo "*"
  echo "*"
  echo "Une erreur s'est produite. Procedure interrompue."
  echo "*"
  echo "******************************"
  exit
fi
}

startAD()
{
if [ $CIBLE != "" ]; then
  echo "*"
  echo "**  Demarrage AdminServer  **"
  ${WL_HOME}/common/bin/wlst.sh ${SCRIPT_HOME}/startAD.py $HOSTNAME $CIBLE
        if [ "$?" -ne "0" ]; then
                echo "*"
                echo "*"
                echo "Erreur demarrage AdminServer. Procedure interrompue."
                exit
        else
                echo "*"
                echo "**  Demarrage AdminServer OK **"
                echo "*"
        fi
  echo "**  Procedure terminee.     **"
  echo "*"
  echo "******************************"
else
  exit
fi
}

startMS()
{
if [ $CIBLE != "" ]; then
  echo "*"
  echo "**  Demarrage  ManagedServer**"
  ${WL_HOME}/common/bin/wlst.sh ${SCRIPT_HOME}/startMS.py $HOSTNAME $CIBLE
        if [ "$?" -ne "0" ]; then
                echo "*"
                echo "*"
                echo "Erreur demarrage ManagedServer. Procedure interrompue."
                exit
        else
               echo "*"
               echo "**  Demarrage ManagedServer OK **"
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
      startNM
      ;;
   AD)
      startAD
      ;;
   MS1|MS2)
      startMS 
      ;;
   ALL)
      startNM
      startAD
      startMS
      ;;
   *)
     echo "Verifiez les parametres de lancement"
     ;;
esac
