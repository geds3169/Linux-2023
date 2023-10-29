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

# Get the current user and their home directory
if [ -n "$SUDO_USER" ]; then
    user_name="$SUDO_USER"
else
    user_name="$USER"
fi

user_home="/home/$user_name"

# Function to detect the Linux distribution family
detect_linux_family() {
    if [ -e /etc/os-release ]; then
        linux_family=$(grep -i "^ID_LIKE" /etc/os-release | cut -d'=' -f2)
        if [ -z "$linux_family" ]; then
            linux_family=$(grep -i "^ID" /etc/os-release | cut -d'=' -f2)
        fi
        printf "$linux_family"
    else
        printf "Unknown"
    fi
}

# Variables
title="####################################\n# Install Ansible and create folder tree structure #\n####################################\n\n"
explain="According to recommended best practices, this script will create the directory structure for your project.\n\n"
# Use the user_home variable to define the user's home directory path
path="$user_home"

# Check if Ansible is installed
if ! command -v ansible &>/dev/null; then
    printf "\nWarning: Ansible is not installed. Installing Ansible...\n\n"
    # Check the Linux distribution family to use the appropriate installation commands
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
                printf "Warning: Neither DNF nor YUM is available for package installation.\n\n"
                exit 1
            fi
            ;;
        *)
            printf "Warning: Distribution family not supported.\n\n"
            exit 1
            ;;
    esac
    # Use eval to install Ansible based on the distribution (automatically selecting package managers)
    eval "$install_command -y ansible"
fi

# Check if Python3 is installed
if ! command -v python3 &>/dev/null; then
    printf "\nWarning: Python3 is not installed. Please install Python3.\n\n"
else
    # Display the Python3 version
    python_version=$(python3 --version 2>&1)
    printf "Python3 version: $python_version\n\n"
fi

# Check if Pip3 is installed
if ! command -v pip3 &>/dev/null; then
    printf "\nWarning: Pip3 is not installed. Please install Pip3.\n\n"
fi

# Display the Ansible version
ansible_version=$(ansible --version | head -n 1)
printf "Ansible version: $ansible_version\n\n"

while true; do
    printf "$title"
    printf "$explain"

    # Ask for the project name (directory name)
    read -p "Please enter the project name (directory name), or type 'exit' to quit: " project_name

    if [ "$project_name" = "exit" ]; then
        printf "\nExiting the script.\n\n"
        exit 0
    fi

    # Create the project directory
    project_directory="$path/$project_name"
    
    # Check if the project directory already exists
    if [ -d "$project_directory" ]; then
        printf "\nProject directory '$project_directory' already exists.\n\n"
    else
        # Create the project directory in the user's home directory
        if mkdir -p "$project_directory"; then
            printf "\nProject '$project_name' has been created in '$project_directory'.\n"
            # Display a warning message
            printf "Warning: You need to configure the ansible.cfg file in the project directory with your specific paths.\n\n"
        else
            printf "\nFailed to create project directory '$project_directory'.\n\n"
            exit 1
        fi

        # Create the directory structure
        mkdir -p "$project_directory/production" \
            "$project_directory/staging" \
            "$project_directory/group_vars/clear" \
            "$project_directory/group_vars/secret" \
            "$project_directory/host_vars" \
            "$project_directory/library" \
            "$project_directory/module_utils" \
            "$project_directory/filter_plugins" \
            "$project_directory/roles/common/tasks" \
            "$project_directory/roles/common/handlers" \
            "$project_directory/roles/common/templates" \
            "$project_directory/roles/common/files" \
            "$project_directory/roles/common/vars" \
            "$project_directory/roles/common/defaults" \
            "$project_directory/roles/common/meta" \
            "$project_directory/roles/common/library" \
            "$project_directory/roles/common/module_utils" \
            "$project_directory/roles/common/lookup_plugins" \
            "$project_directory/roles/webtier/tasks" \
            "$project_directory/roles/webtier/handlers" \
            "$project_directory/roles/webtier/templates" \
            "$project_directory/roles/webtier/files" \
            "$project_directory/roles/webtier/vars" \
            "$project_directory/roles/webtier/defaults" \
            "$project_directory/roles/webtier/meta" \
            "$project_directory/roles/webtier/library" \
            "$project_directory/roles/webtier/module_utils" \
            "$project_directory/roles/webtier/lookup_plugins"

        # Create site.yml, webservers.yml, dbservers.yml files
        touch "$project_directory/site.yml" \
            "$project_directory/webservers.yml" \
            "$project_directory/dbservers.yml"

        # Create an ansible.cfg file with custom settings
        cat <<EOL > "$project_directory/ansible.cfg"
[defaults]
vault_password_file = /path/to/vault_password_file
vault_identity_list = /path/to/secret_vars.yml
EOL

        # Create a vault.yaml file with an example
        cat <<EOL > "$project_directory/vault.yaml"
---
mysql_user: "admin"
mysql_password: "Test_34535"
root_password: "Test_34049"
EOL
    
        # Create a .gitignore file to exclude certain files (preconfigured vault file)
        cat <<EOL > "$project_directory/.gitignore"
**/*vault*
**/*secret.yml*
**/*secret_data/*
**/*.log
temp/
data/
requirements.yml
my_ansible.cfg
user_configs/
EOL

        # Just a message reminding you of the directory creation and the project name
        printf "Project structure has been created for '$project_name'.\n\n"

        # Display the project tree with the 'tree' command
        tree -a "$project_directory"

    fi
done

printf "All tasks have been completed. The script is finished.\n"
