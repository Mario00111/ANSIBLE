#!/bin/bash
#Script de deploiement de livrable 

################### Parametrage variables ##########################
####################################################################

#Nom domaine fonctionnel
Name_DF="App_CPRP"

#Nom serveur cible
Name_SC="ManagedServer_1"

#Fichier properties
Name_Fic_App_ToDeploy="/u01/scripts/deploy_param.properties"

#Repertoire config
Folder_destpathproperties="/u01/domains/config/$Name_DF"

#Repertoire livrables 
Sas_Livrables=/datas/Sas_Livrables

#Sas Applications
Sas_App=$Sas_Livrables/Sas_Application

#Sas Applications
Sas_Lb=$Sas_Livrables/Sas_Lib

#Sas Ressource Adapter
Sas_Ra=$Sas_Livrables/Sas_RessourceAdapter

#Sas Librairies partagées
Sas_Slb=$Sas_Livrables/Sas_ShareLib

#Sas d'archivage
Sas_Archive=$Sas_Livrables/Archive

####################################################################

################### Initialisation des variables ###################

# Mode normal
ResetColor="$(tput sgr0)"
# Surlign(bold)
boldon="$(tput smso)"
boldoff="$(tput rmso)"

#Nom user connect
user=`whoami`


#Declaration tableaux
declare -A Tab_Filename
declare -a Tab_Filename_Short

#Positionnement dans scripts
cd /u01/scripts

#Vidage fichier temporaire et ajout balise APPLICATIONS
echo '' > fictmpauto.properties 

#sauvegarde su fichier properties et suppression apres balise [SHAREDLIBS]
sed -i.BAK '/\[SHAREDLIBS\]/,$d' $Name_Fic_App_ToDeploy

################################ Fonction ################################# 

function Load_Delivery {

##################### SHAREDLIBS #####################
# Ajout balise SHAREDLIBS
sed -i '1i[SHAREDLIBS]\n' fictmpauto.properties
# Parcours du sas de deploiement Sharelibs
find -L $Sas_Slb -type f | ( while read File; do
{
	# Nom complet en absolu du fichier 
	Fullfilename=$(basename $File)
	# Extension du fichier
  Extension=${Fullfilename##*.}
	# Nom du fichier sans le chemin
  Filename=${Fullfilename%.*}
		# Nom du fichier court sans extension ni versionning
		# Parcours le filename match sur les fichiers AA-BB-Ccccc-[0-9] puis decoupe AA-BB-Ccccc
		jar xvf $File META-INF/MANIFEST.MF
		Filename_short=`cat META-INF/MANIFEST.MF | awk 'match($0,"Extension-Name: ") {print substr($O,17,RLENGTH)}' | tr -d '\r'`
		rm -Rf META-INF
	# Chargement tableaux nom complet/nom court        	
	if [[ $Filename_short != '' ]]
	then 	
		Tab_Filename[$i]=$Fullfilename
		Tab_Filename_Short[$i]=$Filename_short
		printf "%-40s %-50.9s \n" "$Fullfilename" "OK"
	else
		i=$i-1
		printf "%-40s %-50s \n" "$Fullfilename" "KO Erreur dans le nom de fichier ?"
	fi
((i++))
}
done
j=0
l=1
for Object_ToDeploy in "${Tab_Filename_Short[@]}"; do
	if [[ $Object_ToDeploy != '' ]]
	then
			echo "sl$l.name=$Object_ToDeploy" >> fictmpauto.properties
			echo "sl$l.path=$Sas_Slb/${Tab_Filename[$j]}" >> fictmpauto.properties
			echo "sl$l.targets=$Name_SC" >> fictmpauto.properties
			echo -e "\n" >> fictmpauto.properties
		((l++))
	fi
((j++))
done
)


##################### RESSOURCEADAPTER #####################
# Ajout balise RESSOURCEADAPTER
sed -i '$a[APPLICATIONS]\n' fictmpauto.properties
# Parcours du sas de deploiement Sharelibs
find -L $Sas_Ra -type f | ( while read File; do
{
	# Nom complet en absolu du fichier 
	Fullfilename=$(basename $File)
	# Extension du fichier
  Extension=${Fullfilename##*.}
	# Nom du fichier sans le chemin
  Filename=${Fullfilename%.*}
	# Nom du fichier court sans extension ni versionning
  # Parcours le filename match sur les fichiers AA-BB-Ccccc-[0-9] puis decoupe AA-BB-Ccccc
		Filename_short=$(echo $Fullfilename |  awk 'match($0,/^[A-Z]{2}-[A-Z]{2}-[A-Za-z0-9]+-[0-9]/) {print substr($0,RSTART,RLENGTH-2)} ')
	# Chargement tableaux nom complet/nom court        	
	if [[ $Filename_short != '' ]]
	then 	
		Tab_Filename[$i]=$Fullfilename
		Tab_Filename_Short[$i]=$Filename_short
		printf "%-40s %-50.9s \n" "$Fullfilename" "OK"
	else
		i=$i-1
		printf "%-40s %-50s \n" "$Fullfilename" "KO Erreur dans le nom de fichier ?"
	fi
((i++))
}
done
j=0
l=1
for Object_ToDeploy in "${Tab_Filename_Short[@]}"; do
	if [[ $Object_ToDeploy != '' ]]
	then
		# ecriture dans fictmp des parametres de l'appli sans properties
			echo "app$l.name=$Object_ToDeploy" >> fictmpauto.properties
			echo "app$l.path=$Sas_Ra/${Tab_Filename[$j]}" >> fictmpauto.properties
			echo "app$l.destpath=$Name_DF" >> fictmpauto.properties
			echo "app$l.targets=$Name_SC" >> fictmpauto.properties
			echo "app$l.pathproperties=" >> fictmpauto.properties
			echo "app$l.destpathproperties=" >> fictmpauto.properties
			echo -e "\n" >> fictmpauto.properties
		((l++))
	fi
((j++))
done
)

################### Compteur RA #######################
last_Ln=$(echo $last_Ln | tail -3 fictmpauto.properties)
compteur_App=${last_Ln:3:1}

##################### APPLICATIONS #####################

# Parcours du sas de deploiement Applications
find -L $Sas_App -type f | ( while read File; do
{
	# Nom complet en absolu du fichier 
	Fullfilename=$(basename $File)
	# Extension du fichier
        Extension=${Fullfilename##*.}
	# Nom du fichier sans le chemin
        Filename=${Fullfilename%.*}
	# Nom du fichier court sans extension ni versionning
	if [[ $Extension == "properties" ]]
	then
		# Parcours le filename match sur les fichiers properties AA-BB-Ccccc 
		Filename_short=$(echo $Fullfilename |  awk 'match($0,/^[A-Z]{2}-[A-Z]{2}-[A-Za-z0-9]+\./) {print substr($0,RSTART,RLENGTH-1)} ')
	else	
		# Parcours le filename match sur les fichiers AA-BB-Ccccc-[0-9] puis decoupe AA-BB-Ccccc
		Filename_short=$(echo $Fullfilename |  awk 'match($0,/^[A-Z]{2}-[A-Z]{2}-[A-Za-z0-9]+-[0-9]/) {print substr($0,RSTART,RLENGTH-2)} ')
	fi
	# Chargement tableaux nom complet/nom court        	
	if [[ $Filename_short != '' ]]
	then 	
		Tab_Filename[$i]=$Fullfilename
		Tab_Filename_Short[$i]=$Filename_short
		printf "%-40s %-50.9s \n" "$Fullfilename" "OK"
	else
		i=$i-1
		printf "%-40s %-50s \n" "$Fullfilename" "KO Erreur dans le nom de fichier ?"
	fi
((i++))
}
done
j=0
l=$(($compteur_App+1))
for Object_ToDeploy in "${Tab_Filename_Short[@]}"; do
	if [[ $Object_ToDeploy != '' ]]
	then
		# Le livrable avec properties oui ou non
		Properties_YesOrNo=$(echo ${Tab_Filename_Short[@]} | tr " " "\n" | grep "$Object_ToDeploy$" | wc -l)
		if [[ $Properties_YesOrNo = '2' ]]
		then
			for ((k=(($j+1));k<=${#Tab_Filename_Short[@]};k++))
			do
				if [[ $Object_ToDeploy = ${Tab_Filename_Short[$k]} ]]
                                then
                                # ecriture dans fictmp des parametres de l'appli + properties
                                        echo "app$l.name=$Object_ToDeploy" >> fictmpauto.properties
                                        if [[ ${Tab_Filename[$k]} =~ "properties"  ]]
                                        then
                                                echo "app$l.path=$Sas_App/${Tab_Filename[$j]}" >> fictmpauto.properties
                                        else
                                                echo "app$l.path=$Sas_App/${Tab_Filename[$k]}" >> fictmpauto.properties
                                        fi
                                        echo "app$l.destpath=$Name_DF" >> fictmpauto.properties
                                        echo "app$l.targets=$Name_SC" >> fictmpauto.properties
                                        if [[ ${Tab_Filename[$k]} =~ "properties"  ]]
                                        then
                                                echo "app$l.pathproperties=$Sas_App/${Tab_Filename[$k]}" >> fictmpauto.properties
                                        else
                                                echo "app$l.pathproperties=$Sas_App/${Tab_Filename[$j]}" >> fictmpauto.properties
                                        fi
                                        echo "app$l.destpathproperties=$Folder_destpathproperties" >> fictmpauto.properties
                                        echo -e "\n" >> fictmpauto.properties
                                ((l++))
                                fi
			done
		elif [[ $Properties_YesOrNo = '1' ]]
		then
		# ecriture dans fictmp des parametres de l'appli sans properties
			echo "app$l.name=$Object_ToDeploy" >> fictmpauto.properties
			echo "app$l.path=$Sas_App/${Tab_Filename[$j]}" >> fictmpauto.properties
			echo "app$l.destpath=$Name_DF" >> fictmpauto.properties
			echo "app$l.targets=$Name_SC" >> fictmpauto.properties
			echo "app$l.pathproperties=" >> fictmpauto.properties
			echo "app$l.destpathproperties=" >> fictmpauto.properties
			echo -e "\n" >> fictmpauto.properties
		((l++))
		fi
	fi
((j++))
done
)

if [[ $(stat -c "%s" fictmpauto.properties) != '' ]]
then 
	# Copie de fictmp dans le fichier [XXX]_domain.properties
	cat fictmpauto.properties >> $Name_Fic_App_ToDeploy
	Deploy_Ready="TRUE"
else
	Deploy_Ready="FALSE"
fi

}

function Entete_Liste()
{
        echo -e "\n"
        echo "****************************************************************"
        echo "Les fichiers a deployer doivent respecter la syntaxe suivante :"
        echo -e "\033[31m ${boldon}[NomCourtApplication]-[NomService]-[NomApplication]-[Versionning].[ear/war/properties]${boldoff} \033[0m"
        echo -e "\033[31m ${boldon}[NomCourtApplication]${boldoff} \033[0m : 2 caracteres majuscules alphabetiques"
        echo -e "\033[31m ${boldon}[NomService]${boldoff} \033[0m : 2 caracteres majuscules alphabetiques"
        echo -e "\033[31m ${boldon}[NomApplication]${boldoff} \033[0m : X caracteres alphanumeriques"
        echo -e "\033[31m ${boldon}[Versionning]${boldoff} \033[0m : 3 caracteres numeriques separes par ."
	echo -e "Pas de versionning pour les fichiers properties"
	echo -e "****************************************************************\n"
        echo -e "Liste des applications : \n"
}

##########################################################################################
############################### Effacement du terminal ###################################
clear
##########################################################################################
############################# controle du user ###########################################

if [ "$user" != "oracle" ]
then 
echo "Merci de vous connecter avec le user oracle, vous etes actuellement en $user"
exit 1
fi

##########################################################################################
############################## Traitement      ###########################################
i=0
# Fonction de chargement du fichier properties
Entete_Liste
Load_Delivery
echo -e "\n"
if [[ $Deploy_Ready = 'TRUE' ]] ;
then
	#./testDeploy.sh $Name_Fic_App_ToDeploy
	./deployApp.sh $Name_Fic_App_ToDeploy
else
	echo 'Deploiement interrompu'
fi
##########################################################################################
##########################################################################################
