#!/bin/bash
#
# Description: This script manages 2FA token services using OATH one-time password command line tool
#
#
#
SETTINGS="Add Edit Remove Back"

STORE_DIR="$HOME/.2fa"

OATHTOOL="$(which oathtool 2>/dev/null)"

if [ "$OATHTOOL" == "" ]; then
    echo "Error: 'oathtool' command not found."
    exit 1
fi


_read_service_store()    {

    if [ ! -d "$STORE_DIR" ]; then
        echo "Creating directory to store secure tokens..."
        mkdir -p "$STORE_DIR"
        SERVICES="Settings Quit"
    else
        # Example SERVICES="Google Microsoft Dropbox Battlenet Facebook Settings Quit"
        SERVICES="$(find "$STORE_DIR" -type f -printf "%f\n" 2>/dev/null)"
        SERVICES="$SERVICES Settings Quit"
    fi
}


_get_pin()  {

    for ((i=1 ; i < 4 ; i=i+1)); do
        PIN=""
        read -p "PIN: " -t 30 PIN
        if [ $? -ne 0 ]; then
            echo "Timeout. Exiting..."
            exit 1
        else 
            if [ ! -f "$HOME/.2farc" ]; then
                echo "Creating a new pin file..."
                echo "$PIN" > "$HOME/.2farc"
                break
            else
                # Check if PIN is correct
                if [ "$(cat "$HOME"/.2farc)" != "$PIN" ]; then
                    echo "Invalid PIN. (Retries $i/3)"
                else
                    break
                fi
            fi
        fi
    done

    if [ $i -eq 4 ]; then
        echo "Maximum retries reached. Exiting..."
        exit 1
    fi
}


_add_service()  {

    local SERVICE=""
    local SECRET_KEY=""

    echo "Adding a new service..."
    read -p "Enter service name (ex: google): " -t 120 SERVICE
    if [ $? -ne 0 ]; then
        echo "Timeout exceeded..."
        return
    fi
    if [ "$SERVICE" == "" ]; then
        echo "Canceled..."
        return
    fi

    read -p "Enter 2FA secret key hash: " -t 120 SECRET_KEY
    if [ $? -ne 0 ]; then
        echo "Timeout exceeded..."
        return
    fi
    if [ "$SERVICE" == "" ]; then
        echo "Canceled..."
        return
    fi
    if [ "$SERVICE" == "" ]; then
        echo "Invalid service name..."
        return
    fi
    if [ "$SECRET_KEY" == "" ]; then
        echo "Invalid service key..."
        return
    fi
    echo "Adding service '$SERVICE'..."
    echo "$SECRET_KEY" > "$STORE_DIR/$SERVICE"
    read -p "Press Enter to continue..."
}


_edit_service()   {

    local _opt=""

    clear
    echo ""
    echo "# Select a Service: "
    echo ""
    select SERVICE in $SERVICES; do
        clear
        if [ -f "$STORE_DIR/$SERVICE" ]; then
            break
            clear
        elif [ "$_opt" = "Back" ]; then
            return
        fi
        clear
        echo ""
        echo "# Select a Service: "
        echo ""
    done

    local SECRET_KEY="$(cat "$STORE_DIR/$SERVICE")"

    local SERVICE2=""
    local SECRET_KEY2=""

    echo "Editing service '$SERVICE':"
    echo "Name: $SERVICE"
    read -p "Service name (Enter to keep existing): " -t 120 SERVICE2
    if [ $? -ne 0 ]; then
        echo "Timeout exceeded..."
        return
    fi
    echo "2FA Secret Key: $SECRET_KEY"
    read -p "2FA secret key hash (Enter to keep existing): " -t 120 SECRET_KEY2
    if [ $? -ne 0 ]; then
        echo "Timeout exceeded..."
        return
    fi
    if [ "$SERVICE2" != "" ]; then
        mv -f "$STORE_DIR/$SERVICE" "$STORE_DIR/$SERVICE2"
        SERVICE="$SERVICE2"
    fi
    if [ "$SECRET_KEY2" != "$SECRET_KEY" ]; then
        echo "$SECRET_KEY2" > "$STORE_DIR/$SERVICE"
    fi
    echo "Saving service '$SERVICE'..."
    read -p "Press Enter to continue..."
}


_remove_service()   {

    local _opt=""

    clear
    echo ""
    echo "# Select a Service: "
    echo ""
    select SERVICE in $SERVICES; do
        clear
        if [ -f "$STORE_DIR/$SERVICE" ]; then
            break
            clear
        elif [ "$_opt" = "Back" ]; then
            return
        fi
        clear
        echo ""
        echo "# Select a Service: "
        echo ""
    done

    local SECRET_KEY="$(cat "$STORE_DIR/$SERVICE")"

    echo "Do you wish to remove '$SERVICE' service?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes) 
                echo "Removing..."
                rm -f "$STORE_DIR/$SERVICE"
                break
                ;;
            No)
                echo "Canceling..."
                break
                ;;
        esac
    done
    read -p "Press Enter to continue..."
}

_generate_service_2fa() {

    local SERVICE="$1"

    local SECRET_KEY="$(cat "$STORE_DIR/$SERVICE")"
    echo "$SERVICE 2FA Code: "
    $OATHTOOL --base32 --totp "$SECRET_KEY" -d 6
    read -p "Press Enter to continue..."
}


_read_service_store

while [ "$opt" != "Quit" ]; do
    clear
    echo ""
    echo "# Select an Option: "
    echo ""
    select opt in $SERVICES; do
        clear
        if [ -f "$STORE_DIR/$opt" ]; then
            _generate_service_2fa "$opt"
            break
        elif [ "$opt" = "Settings" ]; then
            echo ""
            echo "# Settings:"
            echo ""
            select opt2 in $SETTINGS; do
                clear
                if [ "$opt2" = "Add" ]; then
                    _add_service
                elif [ "$opt2" = "Edit" ]; then
                    _edit_service
                elif [ "$opt2" = "Remove" ]; then
                    _remove_service
                elif [ "$opt2" = "Back" ]; then
                    _read_service_store
                    break 2 # Break to main menu loop
                fi
                clear
                echo ""
                echo "# Settings: "
                echo ""
                _read_service_store
            done
            _read_service_store
            read -t 1 # This is needed, for some reason, to correctly display the next main menu
        elif [ "$opt" = "Quit" ]; then
            clear
            break
        fi
        clear
        echo ""
        echo "# Select an Option: "
        echo ""
        _read_service_store
    done
    _read_service_store
done

clear
exit
