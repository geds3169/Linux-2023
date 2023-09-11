######################################
# Nom du script:  Kernel_System_Update.sh
# Utilité: ce script sert à mettre à jour le noyau des distributions Linux de manière automatisé ou partiellement automatisé, log l'état initial et final
# Usage: sudo; chmod +x ; dos2unix
# Auteur: Guilhem SCHLOSSER
# Mise à jour le: 11/09/2023
######################################

#!/bin/bash

# Vérifie la distribution en cours d'exécution
if [ -f /etc/os-release ]; then
    source /etc/os-release
    distribution="$ID"
else
    echo "Impossible de détecter la distribution. Veuillez vérifier le fichier /etc/os-release."
    exit 1
fi

# Emplacement du fichier journal
log_file="/var/log/system_updates.csv"

# Fonction pour afficher un avertissement et des recommandations
display_warning_and_recommendations() {
    echo "=============================="
    echo "Avertissement et Recommandations"
    echo "=============================="
    echo "Avant de poursuivre avec cette opération, veuillez noter les points suivants :"
    echo "1. Assurez-vous d'avoir sauvegardé toutes les données importantes."
    echo "2. Si vous utilisez une machine virtuelle, créez un snapshot ou une sauvegarde de l'état actuel."
    echo "3. Vérifiez que vous disposez d'un espace disque suffisant pour les mises à jour."
    echo "4. Assurez-vous que votre système est stable avant de procéder à des mises à jour."
    echo "5. Si vous effectuez des opérations avancées telles que le redimensionnement de partitions, soyez extrêmement prudent et sauvegardez vos données."
    echo "6. En cas de doute, demandez de l'aide à un administrateur système expérimenté."
    echo "=============================="
    read -p "Appuyez sur Entrée pour continuer ou Ctrl+C pour annuler..."
}

# Fonction pour afficher l'espace disque disponible
display_disk_space() {
    echo "Espace disque disponible avant nettoyage :"
    df -h | grep '/$'
}

# Fonction pour supprimer les noyaux inutilisés
remove_unused_kernels() {
    echo "Suppression des noyaux inutilisés..."
    current_kernel=$(uname -r)
    installed_kernels=$(dpkg --list | grep linux-image | awk '{ print $2 }' | grep -v $current_kernel)

    if [ -z "$installed_kernels" ]; then
        echo "Aucun noyau inutilisé trouvé."
    else
        for kernel in $installed_kernels; do
            echo "Suppression de $kernel..."
            sudo apt remove --purge -y $kernel
        done
    fi
}

# Fonction pour afficher les mises à jour effectuées dans le format spécifié
display_updates() {
    echo "Mises à jour effectuées :"
    echo "Package,Version précédente,Version actuelle,Date" > "$log_file"

    case "$distribution" in
        debian|ubuntu)
            sudo apt update
            local updates=$(sudo apt list --upgradable 2>/dev/null | grep 'installed' | awk -F/ '{print $1}')
            for package in $updates; do
                local prev_version=$(dpkg -l | grep "ii  $package " | awk '{print $3}')
                local current_version=$(apt-cache policy $package | grep Installed | awk '{print $2}')
                local date=$(date +"%Y-%m-%d %H:%M:%S")
                echo "$package,$prev_version,$current_version,$date" >> "$log_file"
            done
            ;;
        centos|fedora)
            sudo yum update -y
            local updates=$(sudo yum list updates --quiet | awk '$1 ~ /^[a-zA-Z]/ {package=$1} $1 ~ /^[0-9]/ {print package,$1,$2}')
            for update in $updates; do
                IFS=' ' read -ra update_info <<< "$update"
                local package="${update_info[0]}"
                local prev_version="${update_info[1]}"
                local current_version="${update_info[2]}"
                local date=$(date +"%Y-%m-%d %H:%M:%S")
                echo "$package,$prev_version,$current_version,$date" >> "$log_file"
            done
            ;;
        opensuse)
            sudo zypper refresh
            sudo zypper update -y
            local updates=$(sudo zypper list-updates --quiet | awk '{print $3,$5}')
            for update in $updates; do
                IFS=' ' read -ra update_info <<< "$update"
                local package="${update_info[0]}"
                local current_version="${update_info[1]}"
                local date=$(date +"%Y-%m-%d %H:%M:%S")
                echo "$package,N/A,$current_version,$date" >> "$log_file"
            done
            ;;
        arch)
            local date=$(date +"%Y-%m-%d %H:%M:%S")
            echo "Arch Linux utilise un modèle de noyau en constante mise à jour,$date" >> "$log_file"
            ;;
        *)
            local date=$(date +"%Y-%m-%d %H:%M:%S")
            echo "Mise à jour du système non prise en charge pour cette distribution,$date" >> "$log_file"
            ;;
    esac

    echo "Mises à jour enregistrées dans : $log_file"
}

# Nettoie le système en supprimant les fichiers temporaires et les noyaux inutilisés
clean_system() {
    display_warning_and_recommendations
    display_disk_space
    echo "Nettoyage du système..."
    
    case "$distribution" in
        debian|ubuntu)
            sudo apt clean
            remove_unused_kernels  # Suppression des noyaux inutilisés
            ;;
        centos|fedora)
            sudo yum clean all
            ;;
        opensuse)
            sudo zypper clean --all
            ;;
        arch)
            sudo pacman -Scc
            ;;
        *)
            echo "Nettoyage du système non pris en charge pour cette distribution."
            ;;
    esac
    
    display_disk_space
}

# Met à jour le système (y compris le noyau)
update_system() {
    display_warning_and_recommendations
    display_disk_space

    echo "Mise à jour du système..."
    case "$distribution" in
        debian|ubuntu)
            sudo apt update
            sudo apt upgrade -y
            ;;
        centos|fedora)
            sudo yum update -y
            ;;
        opensuse)
            sudo zypper refresh
            sudo zypper update -y
            ;;
        arch)
            echo "Non applicable (Arch Linux utilise un modèle de noyau en constante mise à jour)."
            ;;
        *)
            echo "Mise à jour du système non prise en charge pour cette distribution."
            ;;
    esac
    display_disk_space

    # Affiche les mises à jour effectuées et les enregistre dans un fichier CSV
    display_updates
    
    read -p "Appuyez sur Entrée pour continuer..."
}

# ...

# Menu principal
while true; do
    clear
    echo "===== Menu Principal ====="
    echo "1. Nettoyer le système"
    echo "2. Mettre à jour le système (y compris le noyau)"
    echo "3. Afficher la liste des noyaux disponibles"
    echo "4. Installer un noyau"
    echo "5. Quitter"

    read -p "Choisissez une option (1/2/3/4/5) : " choice

    case "$choice" in
        1)
            clean_system
            ;;
        2)
            update_system
            ;;
        3)
            list_kernels
            ;;
        4)
            install_kernel
            ;;
        5)
            echo "Au revoir !"
            exit 0
            ;;
        *)
            echo "Option invalide. Veuillez choisir une option valide (1/2/3/4/5)."
            ;;
    esac
done
