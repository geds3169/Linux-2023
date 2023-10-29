######################################
# Nom du script:  AnsibleInstallConf.sh
# Utilité: Ce script installe Ansible et configure la structure de répertoire conformément aux meilleures pratiques.
# Utilisation: 
#   - Assurez-vous que le script est exécutable avec : sudo chmod +x AnsibleInstallConf.sh
#   - Exécutez le script avec : sudo -H ./AnsibleInstallConf.sh
#   - L'option -H garantit que le répertoire du projet et l'environnement Ansible sont créés dans le répertoire de l'utilisateur qui exécute le script.
# Auteur: Guilhem SCHLOSSER
# Dernière mise à jour: 28/10/2023
######################################

#!/bin/bash

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
title="
####################################################
# Install Ansible and create folder tree structure #
####################################################\n\n"
explain="According to recommended best practice, this script will create the tree structure and models in the project folder.\n"
# Default project path is the user's home directory
path="/home/$USER"

# Check if Ansible is installed
if ! command -v ansible &>/dev/null; then
    echo "Ansible is not installed. Installing Ansible..."
    
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

    # Use eval to install Ansible according to distribution (automatic selection of package managers)
    eval "$install_command -y ansible"
fi

# Script
printf "$title"
printf "$explain"

# Check user privileges
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root or with sudo privileges."
    exit 1
fi

while true; do
    # Check loop for project and tree creation
    read -p "Please enter the project name (directory name), or type 'exit' to quit: " project_name

    if [ "$project_name" = "exit" ]; then
        echo "Exiting the script."
        exit 0
    fi

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

            # Check if Ansible is functional
            ansible --version

            # Create ansible.cfg with custom settings
            echo -e "[defaults]\nvault_password_file = /path/to/vault_password_file\nvault_identity_list = /path/to/secret_vars.yml" | sudo tee "$path/$project_name/ansible.cfg" > /dev/null

            # Display a warning message
            echo "Warning: You need to configure the ansible.cfg file in the project directory with your specific paths."
        else
            echo "The directory exists, but is not empty. Directory contents :"
            ls "$path/$project_name"
            read -p "Please choose another project name: " project_name
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

        # Check if Ansible is functional
        ansible --version

        # Create ansible.cfg with custom settings
        echo -e "[defaults]\nvault_password_file = /path/to/vault_password_file\nvault_identity_list = /path/to/secret_vars.yml" | sudo tee "$path/$project_name/ansible.cfg" > /dev/null

        # Create vault.yaml with an example
        echo -e "---\nmysql_user: "admin"\nmysql_password: "Test_34535"\nroot_password: "Test_34049"" | sudo tee "$path/$project_name/vault.yaml" > /dev/null

        # Create .gitignore to exclude some file (preconfigured vault file)
        echo -e "**/*vault*\n**/*secret.yml*\n**/*secret_data/*\n**/*.log\ntemp/\ndata/\nrequirements.yml\nmy_ansible.cfg\nuser_configs/" | sudo tee "$path/$project_name/.gitignore" > /dev/null
        
        # Display a warning message
        echo "Warning: You need to configure the ansible.cfg file in the project directory with your specific paths."
    fi
done

echo "All tasks have been completed. The script is finished."
