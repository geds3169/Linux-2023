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

# Fonction pour détecter la famille de distribution Linux
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
title="####################################\n# Install Ansible and create folder tree structure #\n####################################\n\n"
explain="According to recommended best practices, this script will create the directory structure for your project.\n"
# Utiliser la variable user_home pour définir le chemin du répertoire personnel de l'utilisateur
path="$user_home"

# Vérifier si Ansible est installé
if ! command -v ansible &>/dev/null; then
    echo "Ansible is not installed. Installing Ansible..."

    # Vérifier la famille de distribution pour utiliser les commandes d'installation appropriées
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

    # Utiliser eval pour installer Ansible en fonction de la distribution (sélection automatique des gestionnaires de paquets)
    eval "$install_command -y ansible"
fi

while true; do
    printf "$title"
    printf "$explain"

    # Demander le nom du projet (nom du répertoire)
    read -p "Please enter the project name (directory name), or type 'exit' to quit: " project_name

    if [ "$project_name" = "exit" ]; then
        echo "Exiting the script."
        exit 0
    fi

    # Créer le répertoire du projet
    project_directory="$path/$project_name"
    
    # Vérifier si le répertoire du projet existe déjà
    if [ -d "$project_directory" ]; then
        echo "Project directory '$project_directory' already exists."
    else
        # Créer le répertoire du projet dans le répertoire personnel de l'utilisateur
        if mkdir -p "$project_directory"; then
            echo "Project '$project_name' has been created in '$project_directory'."
        else
            echo "Failed to create project directory '$project_directory'."
            exit 1
        fi

        # Création de la structure de répertoire
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

        # Création des fichiers site.yml, webservers.yml, dbservers.yml
        touch "$project_directory/site.yml" \
            "$project_directory/webservers.yml" \
            "$project_directory/dbservers.yml"

        # Création d'un fichier ansible.cfg avec des paramètres personnalisés
        echo -e "[defaults]\nvault_password_file = /path/to/vault_password_file\nvault_identity_list = /path/to/secret_vars.yml" | tee "$project_directory/ansible.cfg" > /dev/null

        # Création d'un fichier vault.yaml avec un exemple
        echo -e "---\nmysql_user: \"admin\"\nmysql_password: \"Test_34535\"\nroot_password: \"Test_34049\"" | tee "$project_directory/vault.yaml" > /dev/null

        # Création d'un fichier .gitignore pour exclure certains fichiers (fichier de coffre-fort préconfiguré)
        echo -e "**/*vault*\n**/*secret.yml*\n**/*secret_data/*\n**/*.log\ntemp/\ndata/\nrequirements.yml\nmy_ansible.cfg\nuser_configs/" | tee "$project_directory/.gitignore" > /dev/null

        echo "Project structure has been created for '$project_name'."
    fi
done

echo "All tasks have been completed. The script is finished."

