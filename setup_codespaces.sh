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


# --- Main Execution ---

setup_cpp
setup_rust
