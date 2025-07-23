# Création VM 
Playbook Ansible de déploiement d'une vm 

# Prérequis
Les prerequis sont:

- ansible version 2.9.0
- L'utilisateur `ansible` est accessible par sd-ansible.cpr.local.
- Le nom dns choisi doit respecter la norme de nommage 

**Documentation**
- [Convention nommage ressources](https://wiki.cpr.local/xwiki/bin/view/POLE%20ARCHITECTURE/Conventions%20de%20Nommage/Nommage%20des%20ressources%20internes%20-%20Serveurs/)

## 1. Contrôle nommage + Provisionnement adresse IP

```bash
ansible-playbook -v Gestion_addr_IP-DNS.yml -e "dnsname=sd-apps-dk01int action=add/del"
```

## 2. Connexion vmware + création Vm Cprp13

```bash
#ansible-playbook -v Create_VM_FromInventories.yml -e "df=EPP_DK01 vcenter_target=PROD"  -i inventories/integration/hosts.ini --ask-vault-pass
ansible-playbook -v Create_VM_FromInventories.yml -e "df=KSL_TC vcenter_target=PROD/WEBLO os=DEB11/DEB12/RHE8/RHE9"  -i inventories/production/hosts.ini --ask-vault-pass
```

## 3. Customization
# Docker
```bash
ansible-playbook -v Customize_VM_Docker.yml -e "df=APPS_DK01"  -i inventories/integration/hosts.ini
```
# Middleware
```bash
ansible-playbook -v Customize_VM_MID.yml -e "df=APPS_MD01"  -i inventories/integration/hosts.ini
```
# Hraccess
```bash
ansible-playbook -v Customize_VM_HRA.yml -e "df=HRA_TC"  -i inventories/integration/hosts.ini
```

# KSL
```bash
ansible-playbook -v Customize_VM_KSL.yml -e "df=KSL_TC"  -i inventories/integration/hosts.ini
```

# SIDR
```bash
ansible-playbook -v Customize_VM_SIDR.yml -e "df=SIDR_SI"  -i inventories/integration/hosts.ini
```

# LDAP
```bash
ansible-playbook -v Customize_VM_LDAP.yml -e "df=LDAP_MD05"  -i inventories/poc/hosts.ini
```

## 4. Playbook Installation Cyberwatch + Sentinel One (pour DEB ou RHEL)
```bash
ansible-playbook -v Install_Cyber_tools.yml -e "df=KSL_TC" -i inventories/integration/hosts.ini
```

## 5. Playbook Installation Docker (projet DEVOPS_APPLICATION)
```bash
ansible-playbook -v install_docker.yml -i inventories/integration/hosts.ini -e "df=EPP_DK01" --ask-vault-pass
```

## 6. Playbook Creation VM (penser a jouer cybersecurity et supervision)
```bash
ansible-playbook -v general_VM.yml -e "dnsname=sd-ldap-md05poc action=add  df=LDAP_MD05 vcenter_target=PROD os=RHE7"  -i inventories/poc/hosts.ini --ask-vault-pass
```

## 7. Playbook Ajout suppression centreon (pour preprod prod)
```bash
ansible-playbook -v Admin_centreon.yml -e "df=KSL_TC action=add/del" -i inventories/integration/hosts.ini
## 7. Appliquer LDAP sur une machine specifique

```bash
ansible-playbook -v Application_LDAP.yml -e "df=nom_de_la_machine" -i inventories/hosts.ini --ask-vault-pass
```

## TIPS. Password
# Change pwd 
```bash
ansible-playbook -v Password_RollOver.yml -e "df=EPP_WL  user=ansible/oracle ansible_password=ansible" -i inventories/integration/hosts.ini
```
# Create adm pwd 
```bash
ansible-playbook -v Adduser.yml -e "df=DEC_JS  user=admtme/admtma" -i inventories/integration/hosts.ini
```

