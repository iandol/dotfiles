#!/bin/zsh

# Enhanced SMB Unzip Script with better error handling

# Source configuration file if it exists
CONFIG_FILE="$(dirname "$0")/smb_unzip.conf"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    # Fallback to inline configuration
    SMB_SERVER="//10.10.47.188/monkey media"
    MOUNT_POINT="/mnt/smb-share"
    SMB_USERNAME="Ian"
    SMB_PASSWORD="your-password"
fi

# Function to cleanup on exit
cleanup() {
    if [[ -n $MOUNTED && "$MOUNTED" == "true" ]]; then
        log_info "Unmounting share on exit..."
        sudo umount "$MOUNT_POINT"
    fi
}

# Set trap to cleanup on script termination
trap cleanup EXIT INT TERM

# Add this variable after configuration
MOUNTED="false"

# Then in the mounting section, after successful mount:
MOUNTED="true"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
log_info() { echo -e "${GREEN}[INFO]${NC} $1" }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1" }
log_error() { echo -e "${RED}[ERROR]${NC} $1" }

# Check if running as root (mounting often requires sudo)
if [[ $EUID -eq 0 ]]; then
   log_warn "Running as root user"
fi

# Check arguments
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <zip_file> <subfolder>"
    echo "Example: $0 /path/to/archive.zip destination-folder"
    exit 1
fi

ZIP_FILE="$1"
SUBFOLDER="$2"
FULL_DEST_PATH="${MOUNT_POINT}/${SUBFOLDER}"

# Validate zip file exists
if [[ ! -f "$ZIP_FILE" ]]; then
    log_error "Zip file not found: $ZIP_FILE"
    exit 1
fi

# Check if unzip is available
if ! command -v unzip &> /dev/null; then
    log_error "unzip command not found. Install with: sudo apt install unzip"
    exit 1
fi

# Check if cifs-utils is available
if ! command -v mount.cifs &> /dev/null; then
    log_error "cifs-utils not found. Install with: sudo apt install cifs-utils"
    exit 1
fi

# Create mount point if it doesn't exist
if [[ ! -d "$MOUNT_POINT" ]]; then
    log_info "Creating mount point: $MOUNT_POINT"
    sudo mkdir -p "$MOUNT_POINT"
    if [[ $? -ne 0 ]]; then
        log_error "Failed to create mount point"
        exit 1
    fi
fi

# Check if already mounted
if mount | grep -q "$MOUNT_POINT"; then
    log_warn "Share already mounted at $MOUNT_POINT"
    read -q "response?Continue with existing mount? [y/N] "
    echo
    if [[ "$response" != "y" && "$response" != "Y" ]]; then
        log_info "Exiting..."
        exit 0
    fi
else
    # Mount the SMB share
    log_info "Mounting SMB share: $SMB_SERVER to $MOUNT_POINT"
    
    sudo mount -t cifs "$SMB_SERVER" "$MOUNT_POINT" \
        -o username="$SMB_USERNAME",password="$SMB_PASSWORD",uid=$(id -u),gid=$(id -g)
    
    if [[ $? -ne 0 ]]; then
        log_error "Failed to mount SMB share"
        exit 1
    fi
    
    log_info "SMB share mounted successfully"
fi

# Create destination subfolder
log_info "Creating destination folder: $FULL_DEST_PATH"
sudo mkdir -p "$FULL_DEST_PATH"
if [[ $? -ne 0 ]]; then
    log_error "Failed to create destination folder"
    # Unmount before exiting
    sudo umount "$MOUNT_POINT"
    exit 1
fi

# Set proper permissions on the folder
sudo chown $(id -u):$(id -g) "$FULL_DEST_PATH"

# Unzip the file
log_info "Unzipping $ZIP_FILE to $FULL_DEST_PATH"
unzip -o "$ZIP_FILE" -d "$FULL_DEST_PATH"

if [[ $? -eq 0 ]]; then
    log_info "Unzip completed successfully"
    echo "Files extracted to: ${SMB_SERVER}/${SUBFOLDER}"
else
    log_error "Unzip failed with error code $?"
fi

# Ask about unmounting
echo
read -q "response?Unmount the SMB share? [y/N] "
echo
if [[ "$response" == "y" || "$response" == "Y" ]]; then
    log_info "Unmounting $MOUNT_POINT"
    sudo umount "$MOUNT_POINT"
    if [[ $? -eq 0 ]]; then
        log_info "Share unmounted successfully"
    else
        log_error "Failed to unmount share"
    fi
else
    log_info "Share remains mounted at $MOUNT_POINT"
fi

log_info "Script completed"
