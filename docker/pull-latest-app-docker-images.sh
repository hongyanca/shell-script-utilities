#!/usr/bin/env bash

# Use a nullglob so empty directories don't cause errors
shopt -s nullglob

txtrst=$(tput sgr0)    # Text reset
txtred=$(tput setaf 1) # Red
txtgrn=$(tput setaf 2) # Green
txtblu=$(tput setaf 4) # Blue

UPDATED_APPS=()
# Define apps to skip
SKIP_LIST=("trilium-legacy" "README")

# Loop through directories in /apps
APPS_DIR="/apps"
INSTALLED_APPS=($(ls /apps))
for APP_PATH in "${INSTALLED_APPS[@]}"; do
    # Get the folder name without the trailing slash
    APP_NAME=$(basename "$APP_PATH")

    # Check if app is in skip list
    if [[ " ${SKIP_LIST[*]} " =~ " ${APP_NAME} " ]]; then
        continue
    fi

    cd "$APPS_DIR/$APP_PATH" || continue

    # Check if docker-compose.yml or docker-compose.yaml exists
    if [[ ! -f "$APPS_DIR/$APP_PATH/docker-compose.yml" && ! -f "$APPS_DIR/$APP_PATH/docker-compose.yaml" ]]; then
        continue
    fi

    # 1. Get images used in the docker-compose app
    IMAGES=$(docker-compose config --images 2>/dev/null)

    if [ -z "$IMAGES" ]; then
        continue
    fi

    echo "Updating ${txtblu}$APP_NAME${txtrst}..."
    IMGS_USED_IN_APP=($IMAGES)
    IS_APP_UPDATED=False
    for OCI_IMAGE in "${IMGS_USED_IN_APP[@]}"; do
        IMG_HASH_BEFORE=$(docker images -q $OCI_IMAGE)
        docker pull $OCI_IMAGE
        IMG_HASH_AFTER=$(docker images -q $OCI_IMAGE)
        if [ "$IMG_HASH_BEFORE" != "$IMG_HASH_AFTER" ]; then
            UPDATED_APPS+=("$APP_NAME")
            IS_APP_UPDATED=True
            echo "${txtred}Pulled new image $OCI_IMAGE for $APP_NAME${txtrst}"
        fi
    done

    if [ "$IS_APP_UPDATED" == "False" ]; then
        echo "${txtgrn}$APP_NAME is already up to date${txtrst}"
    fi
    echo

done

# Summary Output
echo "---------------------------------------------------------"
if [ ${#UPDATED_APPS[@]} -eq 0 ]; then
    echo "${txtgrn}All apps are up to date.${txtrst}"
else
    echo "The following apps were updated with newer images:"
    # Make items in UPDATED_APPS unique
    UPDATED_APPS=($(printf "%s\n" "${UPDATED_APPS[@]}" | sort -u))
    for app in "${UPDATED_APPS[@]}"; do
        echo " - ${txtred}$app${txtrst}"
    done
    echo

    # Restart service suggestion
    echo "Restart the updated services:"
    echo " sudo systemctl restart ${UPDATED_APPS[*]}"
fi
echo
