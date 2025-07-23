#!/bin/sh

ENV=$1
APP=$2

#ansible-playbook -vvvv PYB_TEST/Test_Disk_Vcenter.yml -e "env_var=${ENV} df=${APP}" -i inventories/${ENV}/hosts.ini --ask-vault-pass
ansible-playbook -v PYB_TEST/Create_TEST_VARIABLE.yml -e "env_var=${ENV} df=${APP}" -i inventories/${ENV}/hosts.ini --ask-vault-pass
#ansible-playbook -vvvv PYB_TEST/Create_TEST_VARIABLE.yml -e "env_var=${ENV} typesa_app_var=${APP}"
