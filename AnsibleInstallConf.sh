######################################
# Nom du script:  AnsibleInstallConf.sh
# Utilité: ce script permet l'installation de Ansible ainsi que son arborescence suivant les recommandations et bonnes pratiques
# Usage: sudo chmod +x AnsibleInstallConf.sh
#        sudo ./AnsibleInsatallConf.sh
# Auteur: Guilhem SCHLOSSER
# Mise à jour le: 28/10/2023
# 
# Future implémentation gestion des secrets
######################################

#!/bin/bash

# Functions
# Function to detect the Linux distribution family
detect_linux_family() {
    if [ -e /etc/os-release ]; then
        . /etc/os-release  # Utilisez un point au lieu de source
        echo "$ID_LIKE"
    else
        echo "Unknown"
    fi
}

# Variables
title="Install Ansible and folder tree structure\n\n"
explain=" According to recommended best practice, this script will:\nInstall python3 & pip;\nInstall Ansible for the user;\nCreate the tree structure and models in the project folder."
# Default project path is the user's home directory
path="$HOME"
# List of packages to install, separated by spaces
packages="tree python3 python3-pip"

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
    source /etc/os-release
    case "$ID_LIKE" in
        debian)
            install_command="sudo apt install"
            ;;
        rhel|fedora)
            if command -v dnf &> /dev/null; then
                install_command="sudo dnf install"
            elif command -v yum &> /dev/null; then
                install_command="sudo yum install"
            else
                echo "Neither DNF nor YUM is available for package installation."
                exit 1
            fi
            ;;
        *)
            echo "Distribution family not supported."
            exit 1
            ;;
    esac
fi

# Use eval to install packages according to distribution (automatic selection of package managers)
eval "$install_command -y $packages"

# Checks if Ansible is already installed
if ! command -v ansible &>/dev/null; then
    # Installing Ansible according to the Linux family
    linux_family=$(detect_linux_family)

    case $linux_family in
        "debian" | "ubuntu")
            sudo apt update
            sudo apt install -y python3-pip
            sudo python3 -m pip install --user ansible
            ;;
        "centos" | "rhel")
            sudo yum install -y python3-pip
            sudo python3 -m pip install --user ansible
            ;;
        *)
            echo "The Linux family is not supported for Ansible installation."
            exit 1
            ;;
    esac
fi

# Check loop for project and tree creation
while true; do
    read -p "Please enter the project name (directory name) : " project_name

    if [ -d "$path/$project_name" ]; then
        if [ -z "$(ls -A "$path/$project_name")" ]; then
            echo "The directory exists and is empty. Create the Ansible project tree."

            # Creating the Ansible tree structure in one sudo command with line breaks
            sudo mkdir -p "$path/$project_name/production" \
                "$path/$project_name/staging" \
                "$path/$project_name/group_vars/clear" \
                "$path/$project_name/group_vars/secret" \
                "$path/$project_name/host_vars" \
                "$path/$project_name/library" \
                "$path/$project_name/module_utils" \
                "$path/$project_name/filter_plugins" \
                "$path/$project_name/roles/common/tasks" \
                "$path/$project_name/roles/common/handlers" \
                "$path/$project_name/roles/common/templates" \
                "$path/$project_name/roles/common/files" \
                "$path/$project_name/roles/common/vars" \
                "$path/$project_name/roles/common/defaults" \
                "$path/$project_name/roles/common/meta" \
                "$path/$project_name/roles/common/library" \
                "$path/$project_name/roles/common/module_utils" \
                "$path/$project_name/roles/common/lookup_plugins" \
                "$path/$project_name/roles/webtier/tasks" \
                "$path/$project_name/roles/webtier/handlers" \
                "$path/$project_name/roles/webtier/templates" \
                "$path/$project_name/roles/webtier/files" \
                "$path/$project_name/roles/webtier/vars" \
                "$path/$project_name/roles/webtier/defaults" \
                "$path/$project_name/roles/webtier/meta" \
                "$path/$project_name/roles/webtier/library" \
                "$path/$project_name/roles/webtier/module_utils" \
                "$path/$project_name/roles/webtier/lookup_plugins"

            # File creation site.yml, webservers.yml, dbservers.yml
            sudo touch "$path/$project_name/site.yml" \
                "$path/$project_name/webservers.yml" \
                "$path/$project_name/dbservers.yml"

            # Generates a fully commented Ansible configuration file
            cd "$path/$project_name/"
            sudo ansible-config init --disabled > ansible.cfg # Necessary to specify vault paths and limit commands

            # Structure display
            echo "Ansible structure has been created in the $path/$project_name."
            tree -a "$path/$project_name"

            break
        else
            echo "The directory exists, but is not empty. Directory contents :"
            ls "$path/$project_name"
            read -p "Please choose another project name : " project_name
        fi
    else
        sudo mkdir -p "$path/$project_name"
        echo "No directory named $project_name was found, so it was created."

        # Creating the Ansible tree structure in one sudo command with line breaks
        sudo mkdir -p "$path/$project_name/production" \
            "$path/$project_name/staging" \
            "$path/$project_name/group_vars/clear" \
            "$path/$project_name/group_vars/secret" \
            "$path/$project_name/host_vars" \
            "$path/$project_name/library" \
            "$path/$project_name/module_utils" \
            "$path/$project_name/filter_plugins" \
            "$path/$project_name/roles/common/tasks" \
            "$path/$project_name/roles/common/handlers" \
            "$path/$project_name/roles/common/templates" \
            "$path/$project_name/roles/common/files" \
            "$path/$project_name/roles/common/vars" \
            "$path/$project_name/roles/common/defaults" \
            "$path/$project_name/roles/common/meta" \
            "$path/$project_name/roles/common/library" \
            "$path/$project_name/roles/common/module_utils" \
            "$path/$project_name/roles/common/lookup_plugins" \
            "$path/$project_name/roles/webtier/tasks" \
            "$path/$project_name/roles/webtier/handlers" \
            "$path/$project_name/roles/webtier/templates" \
            "$path/$project_name/roles/webtier/files" \
            "$path/$project_name/roles/webtier/vars" \
            "$path/$project_name/roles/webtier/defaults" \
            "$path/$project_name/roles/webtier/meta" \
            "$path/$project_name/roles/webtier/library" \
            "$path/$project_name/roles/webtier/module_utils" \
            "$path/$project_name/roles/webtier/lookup_plugins"

        # File creation site.yml, webservers.yml, dbservers.yml
        sudo touch "$path/$project_name/site.yml" \
            "$path/$project_name/webservers.yml" \
            "$path/$project_name/dbservers.yml"

        # Generates a fully commented Ansible configuration file
        cd "$path/$project_name/"
        sudo ansible-config init --disabled > ansible.cfg # Necessary to specify vault paths and limit commands

        # Structure display
        echo "Ansible structure has been created in the $path/$project_name."
        tree -a "$path/$project_name"
		
		# Task End message
		echo "Task End"

		# Ask user to press a key to exit
		read -p "Press any key to exit..."

		# This line will pause the script until the user presses a key
		read -n 1 -s
		
        break
    fi
done
