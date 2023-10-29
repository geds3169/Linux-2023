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
        printf "$linux_family"
    else
        printf "Unknown"
    fi
}

# Function to install a package based on the distribution's package manager
install_package() {
    package_name="$1"
    case $linux_family in
        "debian" | "ubuntu")
            if ! command -v $package_name &>/dev/null; then
                sudo apt-get update
                sudo apt-get install -y $package_name
            fi
            ;;
        "rhel" | "fedora")
            if ! command -v $package_name &>/dev/null; then
                if command -v dnf &> /dev/null; then
                    sudo dnf install -y $package_name
                elif command -v yum &> /dev/null; then
                    sudo yum install -y $package_name
                fi
            fi
            ;;
        *)
            printf "Warning: Distribution family not supported. Package $package_name may not be installed.\n\n"
            ;;
    esac
}

# Variables
title="####################################\n# Install Ansible and create folder tree structure #\n####################################\n\n"
explain="According to recommended best practices, this script will create the directory structure for your project.\n\n"

# Detect Linux distribution family
linux_family=$(detect_linux_family)

# List of packages to install, separated by spaces
packages="tree python3 ansible python3-pip"

IFS=" " read -ra package_array <<< "$packages"

# Install required packages
for package in "${package_array[@]}"; do
    install_package "$package"
done

# Display package versions
printf "Installed packages:\n"
for package in "${package_array[@]}"; do
    printf "$package "
    if command -v $package &>/dev/null; then
        $package --version | head -n 1
    else
        printf "Not installed\n"
    fi
done
printf "\n"

# Get the current user and their home directory
if [ -n "$SUDO_USER" ]; then
    user_name="$SUDO_USER"
else
    user_name="$USER"
fi

user_home="/home/$user_name"

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
    project_directory="$user_home/$project_name"

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

        # Create a .gitignore file
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

        printf "\nRemember:\n"
        printf "    - Modify the contents of the ansible.cfg file for vault configuration and other purposes.\n"
        printf "    - Encrypt your secret files (example vault.yml) and fill in the .gitignore\n\n"

        # Just a message reminding you of the directory creation and the project name
        printf "Project structure has been created for '$project_name'.\n\n"

        # Display the project tree with the 'tree' command
        tree -a "$project_directory"
    fi
done

printf "All tasks have been completed. The script is finished.\n"
