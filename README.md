
# Pour Variable vcenter_target
# PROD/WEBLO/SUPERVISION

# Pour Variable typesa_app_var 
# [AP_DF] : Apache server du domaine fonctionnel
# [JS_DF] : Jonas server du domaine fonctionnel
# [TC_DF] : Tomcat server du domaine fonctionnel
# [WL_DF] : Weblogic server du domaine fonctionnel
# [DK_DF] : Docker server du domaine fonctionnel/technique
# OU DIRECTEMENT DF groupe complet all SA 

# NOMENCLATURE
# Domaine Fonctionnel/technique sur 3 Lettres
# [EPP] : Espace Personnel
# [DVS] : DevOps
# [RFD] : Referentiel Documentaire
# [RIT] : Referentiel Assuré
# [RGU] : Repertoire de gestion des carrieres uniques
# [SIT] : Site institutionnel
# [TRC] : TRECC
# [ITO] : InterOps
# [MAN] : Management 
# [SYS] : Système

## TIPS 
# Liste vm depuis vmware
```bash
ansible-inventory -i config.vmware.yml --graph/list > Extact_VM_by_OS.txt
```

# Liste vm depuis fichiers hosts.ini
```bash
ansible-inventory -i inventories/production/hosts.ini --graph/list > Extact_VMLocale_by_OS.txt
```


## 1. Contrôle nommage + Provisionnement adresse IP //  Suppression IP-DNS

```bash
ansible-playbook -v Gestion_addr_IP-DNS.yml -e "dnsname=nom-vms-to_add_or_del action=add/del"
```

# Creation vm sur cluster vcenter depuis template
# Parametre du playbook "df=${TYPESA_APP} vcenter_target=PROD/WEBLO/SUPERVISION" 
ansible-playbook -v Create_VM_FromInventories.yml -e "df=APPS_DK vcenter_target=PROD os=DEB/RHE"  -i inventories/production/hosts.ini --ask-vault-pass

# Customization Middlawre vm simple
# Parametre du playbook "df=${TYPESA_APP} vcenter_target=PROD/WEBLO/SUPERVISION" 
ansible-playbook -v Create_VM_FromInventories.yml -e "df=APPS_DK vcenter_target=PROD os=DEB"  -i inventories/production/hosts.ini --ask-vault-pass
ansible-playbook -v Customize_VM_MID.yml -e "df=AN_MID vcenter_target=PROD"  -i inventories/production/hosts.ini --ask-vault-pass

# Customization VTOM
# Parametre du playbook "df=${TYPESA_APP} vcenter_target=PROD/WEBLO/SUPERVISION" 
ansible-playbook -v Customize_VM_VTOM.yml -e "ansible_python_interpreter=/usr/bin/python3 df=VTM"  -i inventories/preproduction/hosts.ini --ask-vault-pass

# Customization Docker
# Parametre du playbook "env_var=${ENV} typesa_app_var=${TYPESA_APP} vcenter_target=PROD/WEBLO/SUPERVISION" 
ansible-playbook -v Customize_VM_Docker.yml -e "df=APPS_DK"  -i inventories/production/hosts.ini

# Test Variables
# add test roles/test => changer test.yaml en main 
ansible-playbook -v PYB_TEST/Create_TEST_VARIABLE.yml -e "ansible_python_interpreter=/usr/bin/python3 df=VTM vcenter_target=PROD"  -i inventories/qualification/hosts.ini --ask-vault-pass

# Enchainement pour creation VM docker 
# Part SYS
voir README_IP.md

# # # # # # # # # # # # # # # # # #
# Autres exemples 
ansible-playbook -v 1_install_weblogic.yml --inventory-file=EP_hosts
ansible-playbook -v 2_createDomain.yml --inventory-file=EP_hosts

ansible-playbook -v 1_install_weblogic.yml --inventory-file=group_vars/hosts/RIT_hosts
ansible-playbook -v 2_createDomain.yml --inventory-file=group_vars/hosts/RIT_hosts

ansible-playbook -v deployApp.yml --inventory-file=group_vars/hosts/RIT_hosts

ansible-playbook -vvvv 3_install_weblogic_122130.yml --inventory-file=group_vars/hosts/hosts --check

ansible-playbook -v restart_EP.yml --inventory-file=group_vars/hosts/EP_QUA_hosts
ansible-playbook -v Create_EP.yml --inventory-file=group_vars/hosts/EP_QUA_hosts

ansible-playbook -v Install_JDK.yml --extra-vars "jdk_var=jdk-8u162-linux-x64 host=devowsans1" --check

USER=root PASSWORD=rootMob ansible-playbook Password_RollOver.yml --inventory-file=group_vars/hosts/MOB_hosts
ansible-playbook -v Password_RollOver.yml --ask-vault-pass --inventory-file=group_vars/hosts/TEST_hosts

ansible-playbook -vvvv Create_VM.yml --inventory-file=group_vars/hosts/VCENTER_hosts

ansible-playbook -vvvv Create_VM_WL.yml --inventory-file=group_vars/hosts/VCENTER_hosts --ask-vault-pass

ansible-playbook -vvvv Create_VM_FromInventories.yml -e "env_var=${ENV} typesa_app_var=${TYPESA_APP}" -i inventories/${ENV}/hosts.ini 

ansible-playbook -vvvv Create_VM_FromInventories.yml -e "ansible_python_interpreter=/usr/bin/python3 env_var=production typesa_app_var=RH_SYS"  -i inventories/production/hosts.ini

ansible-playbook -vvvv Create_VM_FromInventories.yml -e "ansible_python_interpreter=/usr/bin/python3 env_var=developpement typesa_app_var=WL_SOA vcenter_target=WEBLO"  -i inventories/developpement/hosts.ini

ansible-playbook -vvvv Install_WLS_122_SOA_OSB_generic.yml -e "ansible_python_interpreter=/usr/bin/python3 env_var=developpement typesa_app_var=WL_SOA"  -i inventories/developpement/hosts.ini