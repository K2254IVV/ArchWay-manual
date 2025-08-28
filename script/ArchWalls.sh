#!/bin/bash

# ArchWall Chooser - Wallpaper switcher for KDE Plasma and Xfce4
# Version 2.0
# Supports automatic configuration application for both desktop environments

# Configuration variables
LIST_URL="https://raw.githubusercontent.com/K2254IVV/ArchWay-manual/refs/heads/main/files/list.conf"
WALLPAPER_BASE_URL="https://github.com/K2254IVV/ArchWay-manual/raw/main/files"
KDE_CONFIG_URL="https://github.com/K2254IVV/ArchWay-manual/raw/refs/heads/main/files/KCONFIG"
XFCE_CONFIG_URL="https://github.com/K2254IVV/ArchWay-manual/raw/refs/heads/main/files/XFCONFIG"

DOWNLOAD_DIR="$HOME/Pictures/ArchWalls"
CONFIG_DIR="$HOME/.config/archwall_chooser"
CURRENT_WALLPAPER_FILE="$CONFIG_DIR/current_wallpaper.txt"
FIRST_RUN_FILE="$CONFIG_DIR/first_run"

# Create necessary directories
mkdir -p "$DOWNLOAD_DIR" "$CONFIG_DIR"

# Function to fetch content from URL
fetch_url() {
    local url="$1"
    if command -v curl &> /dev/null; then
        curl -s -L "$url"
    elif command -v wget &> /dev/null; then
        wget -qO- "$url"
    else
        echo "Error: curl or wget not found!" >&2
        return 1
    fi
}

# Function to download file
download_file() {
    local url="$1"
    local output_path="$2"
    if command -v curl &> /dev/null; then
        curl -s -L -o "$output_path" "$url"
    else
        wget -q -O "$output_path" "$url"
    fi
}

# Function to detect desktop environment
detect_desktop_environment() {
    if [[ "$XDG_CURRENT_DESKTOP" == *"KDE"* ]] || [[ "$DESKTOP_SESSION" == *"plasma"* ]]; then
        echo "kde"
    elif [[ "$XDG_CURRENT_DESKTOP" == *"XFCE"* ]] || [[ "$DESKTOP_SESSION" == *"xfce"* ]]; then
        echo "xfce"
    else
        echo "unknown"
    fi
}

# Function to apply KDE configuration
apply_kde_config() {
    echo "Applying KDE Plasma configuration..."
    
    local kde_config_path="$CONFIG_DIR/KCONFIG"
    local target_config="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
    
    # Download KDE configuration
    if download_file "$KDE_CONFIG_URL" "$kde_config_path"; then
        # Backup current configuration
        if [ -f "$target_config" ]; then
            cp "$target_config" "$target_config.backup.$(date +%Y%m%d_%H%M%S)"
            echo "Backup created: $target_config.backup"
        fi
        
        # Apply new configuration
        if cp "$kde_config_path" "$target_config"; then
            echo "KDE configuration applied successfully!"
            
            # Restart plasmashell to apply changes
            echo "Restarting Plasma shell..."
            killall plasmashell 2>/dev/null
            sleep 2
            kstart5 plasmashell 2>/dev/null &
            
            return 0
        else
            echo "Error: Failed to apply KDE configuration!" >&2
            return 1
        fi
    else
        echo "Error: Failed to download KDE configuration!" >&2
        return 1
    fi
}

# Function to apply Xfce4 configuration
apply_xfce_config() {
    echo "Applying Xfce4 configuration..."
    
    local xfce_config_path="$CONFIG_DIR/XFCONFIG"
    
    # Download Xfce4 configuration
    if download_file "$XFCE_CONFIG_URL" "$xfce_config_path"; then
        # The XFCONFIG file should contain xfconf-query commands
        if [ -f "$xfce_config_path" ]; then
            # Make it executable and run
            chmod +x "$xfce_config_path"
            if bash "$xfce_config_path"; then
                echo "Xfce4 configuration applied successfully!"
                return 0
            else
                echo "Error: Failed to execute Xfce4 configuration script!" >&2
                return 1
            fi
        fi
    else
        echo "Error: Failed to download Xfce4 configuration!" >&2
        return 1
    fi
}

# Function to check and apply first-run configuration
check_first_run() {
    if [ ! -f "$FIRST_RUN_FILE" ]; then
        echo "First run detected! Checking for configuration files..."
        
        local de=$(detect_desktop_environment)
        
        case $de in
            "kde")
                if fetch_url "$KDE_CONFIG_URL" | head -n 1 | grep -q "DOCTYPE"; then
                    echo "KDE configuration not available or is HTML"
                else
                    echo "KDE configuration found! Would you like to apply it? (y/N)"
                    read -r response
                    if [[ "$response" =~ ^[Yy]$ ]]; then
                        apply_kde_config
                    fi
                fi
                ;;
            "xfce")
                if fetch_url "$XFCE_CONFIG_URL" | head -n 1 | grep -q "DOCTYPE"; then
                    echo "Xfce4 configuration not available or is HTML"
                else
                    echo "Xfce4 configuration found! Would you like to apply it? (y/N)"
                    read -r response
                    if [[ "$response" =~ ^[Yy]$ ]]; then
                        apply_xfce_config
                    fi
                fi
                ;;
        esac
        
        # Create first run marker file
        touch "$FIRST_RUN_FILE"
        echo "First run configuration completed."
    fi
}

# Function to set wallpaper in KDE
set_kde_wallpaper() {
    local wallpaper_path="$1"
    if command -v plasma-apply-wallpaperimage &> /dev/null; then
        plasma-apply-wallpaperimage "$wallpaper_path"
    else
        # Alternative method via dbus
        dbus-send --session --dest=org.kde.plasmashell --type=method_call /PlasmaShell org.kde.PlasmaShell.evaluateScript "string:
        var Desktops = desktops();
        for (i=0;i<Desktops.length;i++) {
            d = Desktops[i];
            d.wallpaperPlugin = 'org.kde.image';
            d.currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
            d.writeConfig('Image', 'file://$wallpaper_path');
        }"
    fi
    echo "$wallpaper_path" > "$CURRENT_WALLPAPER_FILE"
}

# Function to set wallpaper in Xfce4
set_xfce_wallpaper() {
    local wallpaper_path="$1"
    # Get active monitor and workspace
    local monitor_path=$(xfconf-query -c xfce4-desktop -l | grep "last-image" | head -1 2>/dev/null)
    if [ -n "$monitor_path" ]; then
        xfconf-query -c xfce4-desktop -p "$monitor_path" -s "$wallpaper_path"
    else
        # Fallback to common path
        xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s "$wallpaper_path"
    fi
    echo "$wallpaper_path" > "$CURRENT_WALLPAPER_FILE"
}

# Function to download wallpaper
download_wallpaper() {
    local wallpaper_name="$1"
    local download_url="$WALLPAPER_BASE_URL/$wallpaper_name"
    local local_path="$DOWNLOAD_DIR/$wallpaper_name"
    
    if [ ! -f "$local_path" ]; then
        echo "Downloading: $wallpaper_name"
        if ! download_file "$download_url" "$local_path"; then
            echo "Error: Failed to download wallpaper!" >&2
            return 1
        fi
    fi
    echo "$local_path"
}

# Main function
main() {
    echo "=========================================="
    echo "      ArchWall Chooser v2.0"
    echo "=========================================="

    # Check for first run and apply configuration if available
    check_first_run

    # Fetch wallpaper list
    echo "Loading wallpaper list..."
    wallpapers=($(fetch_url "$LIST_URL"))
    
    if [ ${#wallpapers[@]} -eq 0 ]; then
        echo "Error: Failed to load wallpaper list or list is empty!" >&2
        exit 1
    fi

    # Show selection menu
    echo "Available wallpapers:"
    PS3="Enter your choice: "
    select choice in "${wallpapers[@]}" "Exit"; do
        if [ "$REPLY" -eq $((${#wallpapers[@]}+1)) ]; then
            echo "Exiting."
            exit 0
        elif [ -n "$choice" ]; then
            selected_wallpaper="$choice"
            break
        else
            echo "Invalid choice! Please try again."
        fi
    done

    # Download and set wallpaper
    wallpaper_path=$(download_wallpaper "$selected_wallpaper")
    de=$(detect_desktop_environment)

    case $de in
        "kde")
            echo "Setting wallpaper in KDE Plasma..."
            set_kde_wallpaper "$wallpaper_path"
            ;;
        "xfce")
            echo "Setting wallpaper in Xfce4..."
            set_xfce_wallpaper "$wallpaper_path"
            ;;
        *)
            echo "Error: Unsupported desktop environment!" >&2
            exit 1
            ;;
    esac

    echo "Done! Wallpaper set: $selected_wallpaper"
}

# Run main function
main "$@"
