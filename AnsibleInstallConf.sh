######################################
# Nom du script:  AnsibleInstallConf.sh
# Utilité: ce script permet l'installation de Ansible ainsi que son arborescence suivant les recommandations et bonnes pratiques
# Usage: sudo chmod +x AnsibleInstallConf.sh
#        sudo ./AnsibleInstallConf.sh
# Auteur: Guilhem SCHLOSSER
# Mise à jour le: 28/10/2023
# 
# Future implémentation gestion des secrets
######################################

#!/bin/bash

# Variables
title="Install Ansible and folder tree structure\n\n"
explain=" According to recommended best practice, this script will:\nInstall Ansible for the user;\nCreate the tree structure and models in the project folder."
# Default project path is the user's home directory
path="$HOME"

# Script
echo -e "$title"
echo -e "$explain"

# Check user privileges
if [ "$(id -u)" != "0" ]; then
    echo "Ce script doit être exécuté en tant que root ou avec des privilèges sudo."
    exit 1
fi

# Check distribution family to use correct installation commands
if [ -e /etc/os-release ]; then
    if grep -i "Debian" /etc/os-release; then
        install_command="sudo apt install"
    elif grep -i "Fedora" /etc/os-release || grep -i "Red Hat" /etc/os-release; then
        if command -v dnf &> /dev/null; then
            install_command="sudo dnf install"
        elif command -v yum &> /dev/null; then
            install_command="sudo yum install"
        else
            echo "Neither DNF nor YUM is available for package installation."
            exit 1
        fi
    else
        echo "Distribution not supported."
        exit 1
    fi
fi

# Create a virtual environment for Ansible
virtualenv ansible-env

# Activate the virtual environment
source ansible-env/bin/activate

# Install Ansible
pip install ansible

# Rest of your script (project creation, etc.)
