# Middleware
```bash
ansible-playbook -v Customize_VM_ODA.yml -e "df=ODA_MD01"  -i inventories/production/hosts.ini 
```
# General 
```bash
ansible-playbook -v general_VM.yml -e "dnsname=sd-oda-md01pro action=add  df=ODA_MD01 vcenter_target=PROD os=RHE8"  -i inventories/production/hosts.ini --ask-vault-pass
ansible-playbook -v Install_Cyber_tools.yml -e "df=ODA_MD01" -i inventories/production/hosts.ini
qnsible-playbook -v Admin_centreon.yml -e "df=ODA_MD01 action=add" -i inventories/integration/hosts.ini

```