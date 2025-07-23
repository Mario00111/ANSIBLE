#!/bin/bash


############################### Param obligatoire #################################

if [ -z "$1" ]
then
   echo "                 "
   echo ">>>>>>>   Parametre DNSNAME obligatoire  <<<<<<<<<"
   echo "                 "
   exit
fi
############################### Initialisation des variables #################################

full_dnsname=$1

index_type=('s' 'v' 't' 'ct' 'ci' 'esx' 'phy' 'tpl' 'san')
index_bu=('d' 'm' 'v' 'a' 't' 'p')
index_application=('apps' 'epp' 'eppdmz' 'hra' 'ksl' 'mgmt' 'oda' 'odi' 'rfd' 'rit' 'rgu' 'saj' 'sit' 'trc' 'sidr' 'sys' 'ldap')
index_role=('db' 'md' 'fi' 'dc' 'wk' 'dk' 'cl' 'ht' 'bk')
index_env=('int' 'for' 'qua' 'poc' 'pre' 'pra' 'pro' 'dev')

##############################################################################################
############################## Affichages menu ###############################################

##########################################################################################
############################## Affichages menu ###########################################
#for element in "${index_env[@]}"
#do
#    echo "$element"
#done

# split dnsname sur -
split_dnsname=($(echo "$full_dnsname" | awk -F '-' '{print $1, $2, $3}'))

# Check noramlisation dnsname 3 champs non vide = xx-XXX-xxxxxx
for (( i=0; i<=2; i++ ))
do
   if [ -z "${split_dnsname[$i]}" ]
   then
      echo "                 "
      echo ">>>>>>>   Nommage dns incorrect verifier : xx-xxx-xxx  <<<<<<<<<"
      echo "                 "
      exit 10
   else
      format_nommage="OK"
   fi
done

# Check par zone du nom DNS
for (( i=0; i<=2; i++ ))
do
      ####### ZONE 1 "$1" TYPE & BU #########
      if [ "$i" == "0" ] && [ "$format_nommage" == "OK" ]
      then
      #### Check Type value
      for type in "${index_type[@]}"
      do
         if [[ "${split_dnsname[$i]:0:1}" == "$type" ]]; then
            echo "valeur Type :$type:OK"
            confirm_type="1"
         fi
      done
      if [[ $confirm_type -ne "1" ]]
      then
         echo "valeur Type :${split_dnsname[$i]:0:1}:Pas dans la norme"
         exit 10
      fi
      #### Check BU value
      for bu in "${index_bu[@]}"
      do
         if [[ "${split_dnsname[$i]:1:1}" == "$bu" ]]; then
            echo "valeur BU :$bu:OK"
            confirm_bu="1"
         fi
      done
      if [[ $confirm_bu -ne "1" ]]
      then
         echo "valeur BU :${split_dnsname[$i]:1:1}:Pas dans la norme"
         exit 10
      fi
      fi
      ####### ZONE 2 "$1" APPLICATION #########
      if [ "$i" == "1" ] && [ "$format_nommage" == "OK" ]
      then
      #### Check application value
      for application in "${index_application[@]}"
      do
         if [[ "${split_dnsname[$i]}" == "$application" ]]; then
            echo "valeur application :${split_dnsname[$i]}:OK"
            confirm_application="1"
            ## Specifique mgmt
            if [[ "${split_dnsname[$i]}" == "mgmt" ]]; then
            bypass_env_mgmt="1"
            fi
         fi
      done
      if [[ $confirm_application -ne "1" ]]
      then
         echo "valeur application :${split_dnsname[$i]}:Pas dans la norme"
         exit 10
      fi
      fi
      ####### ZONE 3 "$2" ROLE & ENV #########
      if [ "$i" == "2" ] && [ "$format_nommage" == "OK" ]
      then
      #### Check Role value
      for role in "${index_role[@]}"
      do
         if [[ "${split_dnsname[$i]:0:2}" == "$role" ]]; then
            echo "valeur Role :${split_dnsname[$i]:0:2}:OK"
            confirm_role="1"           
         fi
      done
      if [[ $confirm_role -ne "1" ]]
      then
         echo "valeur Role :${split_dnsname[$i]:0:2}:Pas dans la norme"
         exit 10
      fi
      #### Chech numeric vm value
      if ! [[ ${split_dnsname[$i]:2:2} =~ ^[0-9]+$ ]]
      then 
         echo "valeur numero de vm non numerique :${split_dnsname[$i]:2:2}:Pas dans la norme"
         exit 10
      else
         echo "valeur numero vm :${split_dnsname[$i]:2:2}:OK"
      fi
      #### Check Env value
      for env in "${index_env[@]}"
      do
         if [ "${split_dnsname[$i]:4:3}" == "$env" ]; then
            echo "valeur Env :${split_dnsname[$i]:4:3}:OK"
            # conversion pour subnet pprod
            #if [ "$env" == "pre"]; then
            #   $env="pprod"
            #elif [ "$env" == "pro"]; then
            #   $env="prod"
            #fi
            confirm_env="1"
         fi
      done
      if [[ $confirm_env -ne "1" ]] && [[ $bypass_env_mgmt -ne "1" ]] 
      then
         echo "valeur Env :${split_dnsname[$i]:4:3}:Pas dans la norme"
         exit 10
      elif [[ $confirm_env -ne "1" ]] && [[ $bypass_env_mgmt -eq "1" ]]
      then
         echo "valeur Env par defaut pour MGMT :prod"
      else
         echo ">>>>> Controle terminee <<<<<"
      fi
      fi    
done
exit 0

##########################################################################################
##########################################################################################