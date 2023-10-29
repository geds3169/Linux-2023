######################################
# Nom du script:  AnsibleInstallConf.sh
# Utilité: ce script permet l'installation de Ansible ainsi que son arborescence suivant les recommandations et bonnes pratiques
# Usage: sudo chmod +x AnsibleInstallConf.sh
#        sudo -H ./AnsibleInstallConf.sh # -H permet de garantir que le répertoire du projet et l'environnement Ansible sont créés dans le répertoire de l'utilisateur qui exécute le script.
# Auteur: Guilhem SCHLOSSER
# Mise à jour le: 28/10/2023
######################################

#!/bin/bash

# Get the current user and their home directory
if [ -n $SUDO_USER ]; then
    user_name="$SUDO_USER"
else
    user_name="$USER"
fi

user_home="/home/$user_name"

echo "The ansible project and virtual environment will be placed in the user's home directory : $user_home"

# Function to detect the Linux distribution family
detect_linux_family() {
    if [ -e /etc/os-release ]; then
        linux_family=$(grep -i "^ID_LIKE" /etc/os-release | cut -d'=' -f2)
        if [ -z "$linux_family" ]; then
            linux_family=$(grep -i "^ID" /etc/os-release | cut -d'=' -f2)
        fi
        echo "$linux_family"
    else
        echo "Unknown"
    fi
}

# Variables
title="Install Ansible and folder tree structure\n\n"
explain="According to recommended best practice, this script will:\nInstall Python3, pip, and Ansible;\nCreate the tree structure and models in the project folder."
# Default project path is the user's home directory
path="$user_home"
# List of packages to install, separated by spaces
packages="tree python3 python3-pip python3-venv"

# Script
echo -e "$title"
echo -e "$explain"

# Check user privileges
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root or with sudo privileges."
    exit 1
fi

# Check distribution family to use correct installation commands
linux_family=$(detect_linux_family)

case $linux_family in
    "debian" | "ubuntu")
        install_command="sudo apt install"
        ;;
    "rhel" | "fedora")
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

# Use eval to install packages according to distribution (automatic selection of package managers)
eval "$install_command -y $packages"

# Install Python 3 and Ansible
if ! command -v python3 &>/dev/null; then
    echo "Installing Python3..."
    eval "$install_command -y python3"
fi

if ! command -v pip3 &>/dev/null; then
    echo "Installing pip3..."
    eval "$install_command -y python3-pip"
fi

if ! command -v ansible &>/dev/null; then
    echo "Installing Ansible..."
    sudo python3 -m pip install --user ansible
fi

# Check if Ansible environment is active
if [ -n "$VIRTUAL_ENV" ]; then
    echo "Ansible environment is already active."
else
    echo "Activating Ansible environment..."
    ansible_env="$current_user_home/ansible-env"  # Absolute path to the Ansible environment
    if [ -d "$ansible_env" ]; then
        source "$ansible_env/bin/activate"
    else
        echo "Ansible environment not found. You may need to create it first."
    fi
fi

# Check environment
if [ -n "$VIRTUAL_ENV" ]; then
    echo "Environment is active."
    ansible --version
    python --version
else
    echo "Environment is not active."
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
            sudo ansible-config init --disabled > ansible.cfg

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
        sudo ansible-config init --disabled > ansible.cfg

        # Structure display
        echo "Ansible structure has been created in the $path/$project_name."

        break
    fi
done
