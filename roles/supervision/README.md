## 1. Playbook Add centreon 

```bash
ansible-playbook -v Admin_centreon.yml -e "df=ODI_MD01 action=add/del" -i inventories/integration/hosts.ini --ask-vault-pass
```