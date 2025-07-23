#!/bin/sh
# Suppresion si existant
yum erase -y $(rpm -qa |grep katello-ca-consumer)
subscription-manager remove --all
subscription-manager unregister
subscription-manager clean
# Register
rpm -Uvh http://satellite.cpr.sncf.fr/pub/katello-ca-consumer-latest.noarch.rpm
subscription-manager register --activationkey="KeyCPR" --org="CPRPSNCF"
subscription-manager attach --auto
