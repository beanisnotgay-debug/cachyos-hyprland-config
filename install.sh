#!/usr/bin/env bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== System Config Installer ===${NC}"
echo ""

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}Please run as root (sudo)${NC}"
    exit 1
fi

echo -e "${YELLOW}[1/5] Installing packages...${NC}"
if [ -f packages.txt ]; then
    PKG_COUNT=$(wc -l < packages.txt)
    echo -e "${YELLOW}Processing $PKG_COUNT packages from packages.txt...${NC}"
    # Show what will be installed
    echo -e "${YELLOW}Checking for needed packages...${NC}"
    pacman -S --needed --print - < packages.txt > /tmp/to_install.txt 2>/dev/null
    TO_INSTALL=$(wc -l < /tmp/to_install.txt)
    if [ "$TO_INSTALL" -eq 0 ]; then
        echo -e "${GREEN}All packages are already installed!${NC}"
    else
        echo -e "${YELLOW}Installing $TO_INSTALL needed packages...${NC}"
        if ! pacman -S --needed - < packages.txt; then
            echo -e "${RED}Warning: Some packages failed to install${NC}"
        fi
        echo -e "${GREEN}Package installation complete${NC}"
    fi
else
    echo -e "${YELLOW}packages.txt not found, skipping${NC}"
fi

echo ""
echo -e "${YELLOW}[2/5] Installing AUR packages...${NC}"
if [ -f aur-packages.txt ]; then
    if command -v yay &> /dev/null; then
        echo -e "${YELLOW}Checking for needed AUR packages...${NC}"
        yay -S --needed --print - < aur-packages.txt > /tmp/aur_to_install.txt 2>/dev/null
        AUR_TO_INSTALL=$(wc -l < /tmp/aur_to_install.txt)
        if [ "$AUR_TO_INSTALL" -eq 0 ]; then
            echo -e "${GREEN}All AUR packages are already installed!${NC}"
        else
            echo -e "${YELLOW}Installing $AUR_TO_INSTALL needed AUR packages...${NC}"
            yay -S --needed - < aur-packages.txt
        fi
    elif command -v paru &> /dev/null; then
        echo -e "${YELLOW}Checking for needed AUR packages...${NC}"
        paru -S --needed --print - < aur-packages.txt > /tmp/aur_to_install.txt 2>/dev/null
        AUR_TO_INSTALL=$(wc -l < /tmp/aur_to_install.txt)
        if [ "$AUR_TO_INSTALL" -eq 0 ]; then
            echo -e "${GREEN}All AUR packages are already installed!${NC}"
        else
            echo -e "${YELLOW}Installing $AUR_TO_INSTALL needed AUR packages...${NC}"
            paru -S --needed - < aur-packages.txt
        fi
    else
        echo -e "${YELLOW}Installing base-devel first...${NC}"
        pacman -S --needed base-devel git
        echo -e "${YELLOW}Installing yay...${NC}"
        cd /tmp && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
        echo -e "${YELLOW}Checking for needed AUR packages...${NC}"
        yay -S --needed --print - < aur-packages.txt > /tmp/aur_to_install.txt 2>/dev/null
        AUR_TO_INSTALL=$(wc -l < /tmp/aur_to_install.txt)
        if [ "$AUR_TO_INSTALL" -eq 0 ]; then
            echo -e "${GREEN}All AUR packages are already installed!${NC}"
        else
            echo -e "${YELLOW}Installing $AUR_TO_INSTALL needed AUR packages...${NC}"
            yay -S --needed - < aur-packages.txt
        fi
    fi
    echo -e "${GREEN}AUR packages installation complete${NC}"
else
    echo -e "${YELLOW}aur-packages.txt not found, skipping${NC}"
fi

echo ""
echo -e "${YELLOW}[3/5] Copying configs...${NC}"
if [ -d config ]; then
    echo -e "${YELLOW}Copying configurations...${NC}"
    cp -rf config/* /home/$SUDO_USER/.config/ 2>/dev/null || cp -rf config/* ~/.config/
    echo -e "${GREEN}Configs copied${NC}"
else
    echo -e "${YELLOW}config/ not found, skipping${NC}"
fi

echo ""
echo -e "${YELLOW}[4/5] Setting up shell configs...${NC}"
for f in .bashrc .zshrc .bash_profile .bash_logout; do
    if [ -f "$f" ]; then
        cp "$f" /home/$SUDO_USER/"$f" 2>/dev/null || cp "$f" ~/
        echo "  Copied $f"
    fi
done
echo -e "${GREEN}Shell configs copied${NC}"

echo ""
echo -e "${YELLOW}[5/5] Setting up Hyprland (dots-hyprland)...${NC}"
if [ -d dots-hyprland ]; then
    echo "Running dots-hyprland setup..."
    cd dots-hyprland && ./setup
    echo -e "${GREEN}dots-hyprland setup complete${NC}"
else
    echo -e "${YELLOW}dots-hyprland/ not found, skipping${NC}"
fi

echo ""
echo -e "${GREEN}=== Installation Complete ===${NC}"
echo ""
echo "You may need to:"
echo "  - Restart your shell"
echo "  - Log out and back in for DE/WM configs"
echo "  - Reboot to ensure all services start correctly"