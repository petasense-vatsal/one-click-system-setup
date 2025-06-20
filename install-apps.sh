#!/bin/bash

# Standalone application installer
# This script can be run independently to install applications

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔══════════════════════════════════════╗"
echo "║        Application Installer         ║"
echo "╚══════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${CYAN}This script will help you install essential applications.${NC}"
echo -e "${YELLOW}You can choose individual apps, categories, or presets.${NC}"
echo

# Export SETUP_MODE to be used by the applications module
export SETUP_MODE=""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}[ERROR]${NC} This script should not be run as root. Please run as a regular user."
    exit 1
fi

# Run the applications module
if [[ -f "$SCRIPT_DIR/modules/applications/applications.sh" ]]; then
    bash "$SCRIPT_DIR/modules/applications/applications.sh"
else
    echo -e "${RED}[ERROR]${NC} Applications module not found: $SCRIPT_DIR/modules/applications/applications.sh"
    exit 1
fi

echo -e "${GREEN}"
echo "╔══════════════════════════════════════╗"
echo "║     Application Setup Complete!      ║"
echo "╚══════════════════════════════════════╝"
echo -e "${NC}" 