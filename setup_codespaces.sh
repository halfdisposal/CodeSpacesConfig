#!/bin/bash

# setup_codespace.sh
# Automated setup script for GitHub Codespace development environment.

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
JULIA_VERSION="1.10.0" # Latest stable version at time of writing
JULIA_DOWNLOAD_URL="https://julialang-s3.s3.amazonaws.com/bin/linux/x64/${JULIA_VERSION%.*}/julia-${JULIA_VERSION}-linux-x86_64.tar.gz"

echo "Starting Codespace setup script..."

# --- Function Definitions ---

setup_cpp() {
    echo "--- 1. Setting up C++ Development Environment (Libraries) ---"

    # Update package lists
    sudo apt update

    # Install core build tools and dependencies.
    # Note: Eigen is typically header-only and often installed via libeigen3-dev.
    # Dlib and Armadillo can be complex, so we rely on the apt packages for simplicity
    # and compatibility, along with core dependencies like Boost.
    CPP_PACKAGES=(
        cmake                 # Necessary for building complex projects
        build-essential       # Includes g++, make, etc.
        libboost-all-dev      # Common dependency for Dlib and Armadillo
        libplplot-dev         # Plplot development files
        libarmadillo-dev      # Armadillo linear algebra library
        libcairo2-dev         # Cairo graphics library
        libeigen3-dev         # Eigen C++ template library
    )

    echo "Installing C++ development packages: ${CPP_PACKAGES[*]}"
    sudo apt install -y "${CPP_PACKAGES[@]}"

    echo "C++ libraries installed successfully."
}

setup_rust() {
    echo ""
    echo "--- 2. Setting up Rust Development Environment (rustup) ---"

    # Check if rustup is already installed
    if command -v rustup &> /dev/null; then
        echo "Rust is already installed. Updating existing installation..."
        rustup update
    else
        echo "Installing Rust via rustup."
        # Install curl if not present
        if ! command -v curl &> /dev/null; then
            echo "Installing curl..."
            sudo apt install -y curl
        fi

        # Use the rustup script to install Rust, default stable channel, no prompts (-y)
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    fi

    # Ensure cargo is available in the current shell session's PATH
    # This is important for the script to continue without relying on user logging in again.
    source "$HOME/.cargo/env"
    echo "Rust installed successfully."
    echo "Rust version: $(rustc --version)"
}

setup_julia() {
    echo ""
    echo "--- 3. Setting up Julia Development Environment ---"

    # Install wget for downloading if not present
    if ! command -v wget &> /dev/null; then
        echo "Installing wget..."
        sudo apt install -y wget
    fi

    JULIA_DIR="julia-${JULIA_VERSION}"

    if [ -d "/opt/julia/bin" ]; then
        echo "Julia is already installed in /opt/julia. Skipping installation."
        return
    fi

    echo "Downloading Julia ${JULIA_VERSION} from ${JULIA_DOWNLOAD_URL}"
    # Download the generic Linux binary to /tmp
    wget -qO /tmp/julia.tar.gz "$JULIA_DOWNLOAD_URL"

    # Create the target directory and extract the archive, stripping the top-level directory
    sudo mkdir -p /opt/julia
    echo "Extracting Julia to /opt/julia..."
    sudo tar xzf /tmp/julia.tar.gz -C /opt/julia --strip-components=1

    # Create a symbolic link for easy access from anywhere (e.g., /usr/local/bin)
    sudo ln -s /opt/julia/bin/julia /usr/local/bin/julia

    # Clean up the downloaded file
    rm /tmp/julia.tar.gz

    echo "Julia installed successfully."
    echo "Julia version: $(julia --version)"
}

# --- Main Execution ---

setup_cpp
setup_rust
setup_julia

echo ""
echo "================================================="
echo "Codespace Setup Complete!"
echo "Your C++, Rust, and Julia environments are ready."
echo "================================================="

# Inform the user about the PATH updates
echo ""
echo "Note: The terminal session used to run this script has been updated with:"
echo "1. Julia: Accessible via 'julia' command."
echo "2. Rust: Accessible via 'rustc' and 'cargo' commands."
echo "For other new terminals, you might need to run 'source \$HOME/.cargo/env' once."
