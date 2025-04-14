#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Main menu
main_menu() {
    clear
    echo -e "${YELLOW}"
    echo "   ▄▀▀▄ ▄▀▄  ▄▀▀▄ ▀▄  ▄▀▀█▄▄▄▄  ▄▀▀█▄   ▄▀▀▀█▀▀▄  ▄▀▀▄ ▀▀▄ "
    echo "  █  █ ▀  █ █  █ █ █ ▐  ▄▀   ▐ ▐ ▄▀ ▀▄ █    █  ▐ █   ▀▄ ▄▀ "
    echo "  ▐  █    █ ▐  █  ▀█   █▄▄▄▄▄    █▄▄▄█ ▐   █     ▐     █   "
    echo "    █    █    █   █    █    ▌   ▄▀   █    █          █    "
    echo "  ▄▀   ▄▀   ▄▀   █    ▄▀▄▄▄▄   █   ▄▀   ▄▀         ▄▀     "
    echo "  █    █    █    ▐    █    ▐   ▐   ▐   █          █       "
    echo "  ▐    ▐    ▐         ▐               ▐          ▐        "
    echo -e "${NC}"
    echo -e "${GREEN}Termux Multi-Tool${NC}"
    echo "1. System Information"
    echo "2. Network Scanner"
    echo "3. Phone Information"
    echo "4. Quick Update"
    echo "5. Exit"
    read -p "Choose an option: " choice

    case $choice in
        1) system_info ;;
        2) network_scanner ;;
        3) phone_info ;;
        4) quick_update ;;
        5) exit 0 ;;
        *) echo -e "${RED}Invalid option!${NC}"; sleep 1; main_menu ;;
    esac
}

# Dependency management
check_dependencies() {
    clear
    echo -e "${YELLOW}Checking dependencies...${NC}"
    
    # Install nmap if missing
    if ! command -v nmap &> /dev/null; then
        echo -e "${RED}nmap not found! Installing...${NC}"
        pkg install nmap -y
    fi
    
    # Install termux-api package if missing
    if ! command -v termux-telephony-deviceinfo &> /dev/null; then
        echo -e "${RED}termux-api package not found! Installing...${NC}"
        pkg install termux-api -y
    fi
    
    # Verify Termux-API app installation
    if ! termux-battery-status &> /dev/null; then
        echo -e "${YELLOW}\n[!] Termux-API App Required [!]${NC}"
        echo -e "Install from these sources:"
        echo -e "1. F-Droid: ${BLUE}https://f-droid.org/en/packages/com.termux.api/${NC}"
        echo -e "2. GitHub:  ${BLUE}https://github.com/termux/termux-api/releases${NC}"
        echo -e "\nAfter installation:"
        echo -e "1. Grant required permissions"
        echo -e "2. Restart Termux session"
        echo -e "\n${RED}Phone features will be disabled until installed!${NC}"
        sleep 5
    fi
}

# System information
system_info() {
    clear
    echo -e "${YELLOW}=== System Information ===${NC}"
    echo -e "${BLUE}Kernel:${NC} $(uname -r)"
    echo -e "${BLUE}Device:${NC} $(getprop ro.product.model)"
    echo -e "${BLUE}Android:${NC} $(getprop ro.build.version.release)"
    echo -e "${BLUE}Uptime:${NC} $(uptime | awk '{print $3}' | sed 's/,//')"
    echo -e "${BLUE}Storage:${NC}"
    df -h / | awk 'NR==2 {print $3 " used / " $2 " total"}'
    echo -e "${BLUE}RAM:${NC}"
    free -m | awk 'NR==2 {print $3 "MB used / " $2 "MB total"}'
    echo -e "\nPress enter to return..."
    read
    main_menu
}

# Network scanner
network_scanner() {
    clear
    echo -e "${YELLOW}=== Network Scanner ===${NC}"
    read -p "Enter IP range to scan (e.g., 192.168.1.0/24): " ip_range
    echo -e "${GREEN}Scanning... (Ctrl+C to stop)${NC}"
    nmap -sn $ip_range
    echo -e "\nPress enter to return..."
    read
    main_menu
}

# Phone information
phone_info() {
    clear
    echo -e "${YELLOW}=== Phone Information ===${NC}"
    
    # Final verification before showing info
    if ! termux-battery-status &> /dev/null; then
        echo -e "${RED}Termux-API app not detected!${NC}"
        echo -e "Install from:"
        echo -e "1. F-Droid: ${BLUE}https://f-droid.org/en/packages/com.termux.api/${NC}"
        echo -e "2. GitHub:  ${BLUE}https://github.com/termux/termux-api/releases${NC}"
        echo -e "\nAfter installation, restart Termux session"
        echo -e "\nPress enter to return..."
        read
        main_menu
    fi
    
    echo -e "${BLUE}Battery:${NC}"
    termux-battery-status | jq . 2>/dev/null || termux-battery-status
    echo -e "\n${BLUE}Device Info:${NC}"
    termux-telephony-deviceinfo | jq . 2>/dev/null || termux-telephony-deviceinfo
    echo -e "\n${BLUE}WiFi Connection:${NC}"
    termux-wifi-connectioninfo | jq . 2>/dev/null || termux-wifi-connectioninfo
    echo -e "\nPress enter to return..."
    read
    main_menu
}

# Quick update
quick_update() {
    clear
    echo -e "${YELLOW}=== Quick Update ===${NC}"
    apt update && apt upgrade -y
    echo -e "${GREEN}System updated!${NC}"
    sleep 1
    main_menu
}

# Start
check_dependencies
main_menu
