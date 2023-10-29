#!/bin/bash

# Function to detect the Linux distribution family
detect_linux_family() {
    if [ -e /etc/os-release ]; then
        . /etc/os-release
        if [ -n "$ID_LIKE" ]; then
            echo "$ID_LIKE"
        elif [ -n "$ID" ]; then
            echo "$ID"
        else
            echo "Unknown"
        fi
    else
        echo "Unknown"
    fi
}

# Variables
title="Install Ansible in a Virtual Environment\n\n"
explain="This script will install Python3, create a virtual environment, activate it, and install Ansible within the virtual environment."
# Default project path is the user's home directory
path="$HOME"
venv_name="ansible_venv"
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
        install_command="sudo apt install -y"
        ;;
    "rhel" | "fedora")
        if command -v dnf &> /dev/null; then
            install_command="sudo dnf install -y"
        elif command -v yum &> /dev/null; then
            install_command="sudo yum install -y"
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
eval "$install_command $packages"

# Create a virtual environment
python3 -m venv "$path/$venv_name"

# Activate the virtual environment
source "$path/$venv_name/bin/activate"

# Install Ansible in the virtual environment
pip install ansible

# Check if Ansible is installed
if command -v ansible &>/dev/null; then
    echo "Ansible has been successfully installed in the virtual environment."
    echo "You can deactivate the virtual environment with 'deactivate'."
else
    echo "Failed to install Ansible. Please check for any errors in the installation process."
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
