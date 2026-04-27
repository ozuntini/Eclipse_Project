#!/bin/bash
# Installation script for Eclipse Project
# For Raspberry Pi and Python environment setup

set -e  # Exit on any error

echo "=== Eclipse Project System and Python Installation ==="

# Update system
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install system dependencies
echo "Installing system dependencies..."
sudo apt install -y python3-pip python3-venv git
sudo apt install -y gphoto2 libgphoto2-dev libgphoto2-port12
sudo apt install -y build-essential pkg-config tmux

# Clone project repository
if [ `pwd` = "$HOME/Eclipse_Project" ]; then 
    echo "Cloning Eclipse Projects repository..."
    git clone https://github.com/ozuntini/Solar_Eclipse_Photography.git
    git clone https://github.com/ozuntini/Filter_Control.git
    git clone https://github.com/ozuntini/MonHubEclipse.git
else
    echo "Error: Not in the project directory."
    exit 1
fi

# Create directory for logs
echo "Creating logs directory..."
mkdir -p ~/Eclipse_Project/logs

# Create virtual environment
echo "Creating Python virtual environment..."
python3 -m venv ~/eclipse_env

# Activate environment
echo "Activating virtual environment..."
source ~/eclipse_env/bin/activate

# Install Python dependencies
echo "Installing Python packages..."
pip install --upgrade pip
pip install -r ./Solar_Eclipse_Photography/requirements.txt

# USB configuration for multi-cameras
echo "Configuring USB rules for Canon cameras..."
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="04a9", MODE="0666"' | sudo tee /etc/udev/rules.d/99-canon-cameras.rules

# USB configuration for Gemini flatpanel
echo "Configuring USB rules for Gemini flatpanel..."
echo 'ACTION=="add", SUBSYSTEM=="tty", SUBSYSTEMS=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", SYMLINK+="gflatpanel", MODE="0666", RUN+="/usr/bin/stty -F /dev/%k -hupcl"' | sudo tee /etc/udev/rules.d/99-gflatpanel.rules

# udevadm reload and trigger to apply new rules
sudo udevadm control --reload-rules
sudo udevadm trigger

# Test GPhoto2 installation
echo "Testing GPhoto2 installation..."
gphoto2 --version
echo "Camera detection test:"
gphoto2 --auto-detect

echo ""
echo "✅ Installation completed successfully!"
echo ""
echo "To activate the environment: source ~/eclipse_env/bin/activate"
echo "To run the application: cd MonHubEclipse and ./MHE_Launcher.sh"
echo "                        cd Solar_Eclipse_Photography and ./SEP_Launch.sh"
echo "                        cd Filter_Control and ./FC_Launch.sh"
echo ""