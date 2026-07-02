#!/bin/bash

# setup_codespace.sh
set -e

# --- Configuration ---
echo "Starting Codespace setup script..."

# --- Function Definitions ---
setup_cpp() {
    echo "--- 1. Setting up C++ Development Environment (Libraries) ---"
    sudo apt update
    CPP_PACKAGES=(
        cmake
        build-essential
        libboost-all-dev 
        libplplot-dev
        libarmadillo-dev
        libcairo2-dev
        libeigen3-dev
    )

    echo "Installing C++ development packages: ${CPP_PACKAGES[*]}"
    sudo apt install -y "${CPP_PACKAGES[@]}"

    echo "C++ libraries installed successfully."
}

setup_rust() {
    echo ""
    echo "--- 2. Setting up Rust Development Environment (rustup) ---"

    if command -v rustup &> /dev/null; then
        echo "Rust is already installed. Updating existing installation..."
        rustup update
    else
        echo "Installing Rust via rustup."
        if ! command -v curl &> /dev/null; then
            echo "Installing curl..."
            sudo apt install -y curl
        fi

        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    fi

    source "$HOME/.cargo/env"
    echo "Rust installed successfully."
    echo "Rust version: $(rustc --version)"
}


setup_nerdfonts() {
    # Use $HOME instead of ~ to prevent literal tilde expansion bugs in strings
    fonts_dir="$HOME/.local/share/fonts"
    fonts=(
        "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf"
        "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFont-Regular.ttf"
        "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Hack/Regular/HackNerdFont-Regular.ttf"
    )

    echo ""
    echo "--- 3. Setup Nerd Fonts ---"

    echo "Creating font directory"
    mkdir -p "$fonts_dir"

    echo "Download Fonts"
    for font in "${fonts[@]}"; do
        font_name_raw="${font##*/}"
        font_name="${font_name_raw%%\?*}"
        echo "Downloading ${font_name} ..."
        font_dest="${fonts_dir}/${font_name}"
        
        # Fixed: Added $ to font, and wrapped paths in quotes to handle spaces safely
        curl -fLo "$font_dest" "$font"
    done
    
    echo "Refresh Cache"
    fc-cache -f -v

    fc-list : family | grep -i "nerd"
    echo "Finished"
}

# --- Main Execution ---

setup_cpp
setup_rust
setup_nerdfonts

