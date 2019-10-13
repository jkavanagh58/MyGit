#!/bin/bash
sudo apt-get -y install ssh
sudo nano /etc/ssh/sshd_config
sudo service ssh --full-restart
# If you want to remove after testing
# sudo apt-get --purge remove ssh