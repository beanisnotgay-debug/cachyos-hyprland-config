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

echo -e "${YELLOW}[1/4] Installing packages...${NC}"
if [ -f packages.txt ]; then
    pacman -S --needed - < packages.txt
    echo -e "${GREEN}Packages installed${NC}"
else
    echo -e "${YELLOW}packages.txt not found, skipping${NC}"
fi

echo ""
echo -e "${YELLOW}[2/4] Installing AUR packages...${NC}"
if command -v yay &> /dev/null; then
    echo "yay found, you may need to manually install AUR packages"
elif command -v paru &> /dev/null; then
    echo "paru found, you may need to manually install AUR packages"
else
    echo "No AUR helper found, skipping AUR packages"
fi

echo ""
echo -e "${YELLOW}[3/4] Copying configs...${NC}"
if [ -d config ]; then
    cp -rf config/* /home/$SUDO_USER/.config/ 2>/dev/null || cp -rf config/* ~/.config/
    echo -e "${GREEN}Configs copied${NC}"
else
    echo -e "${YELLOW}config/ not found, skipping${NC}"
fi

echo ""
echo -e "${YELLOW}[4/4] Setting up shell configs...${NC}"
for f in .bashrc .zshrc .bash_profile .bash_logout; do
    if [ -f "$f" ]; then
        cp "$f" /home/$SUDO_USER/"$f" 2>/dev/null || cp "$f" ~/
        echo "  Copied $f"
    fi
done

echo ""
echo -e "${GREEN}=== Installation Complete ===${NC}"
echo ""
echo "You may need to:"
echo "  - Restart your shell"
echo "  - Log out and back in for DE/WM configs"
echo "  - Manually install any AUR packages"
echo "  - Run 'dots-hyprland/setup' if using that system"