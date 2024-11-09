#!/bin/bash

## this script will create the cosmovisor folders needed for all upgrades and will download the specific binaries for them

# Set base directory
BASE_DIR="$HOME/.bze/cosmovisor/upgrades"
VERSIONS=("v5.1.2" "v6.0.0" "v6.1.0" "v7.0.0" "v7.1.0" "v7.1.1")

# Create base directory if it doesn't exist
mkdir -p "$BASE_DIR"

# Loop over each version to create directories, download, and verify binary
for version in "${VERSIONS[@]}"; do
  # Create version and bin directories
  VERSION_DIR="$BASE_DIR/$version"
  BIN_DIR="$VERSION_DIR/bin"
  mkdir -p "$BIN_DIR"

  # Define the download URL based on version
  TAR_FILE="bze-${version#v}-linux-amd64.tar.gz"
  URL="https://github.com/bze-alphateam/bze/releases/download/$version/$TAR_FILE"

  # Download the tar file
  echo "Downloading $URL..."
  wget -q -P "$BIN_DIR" "$URL"

  # Extract the tar file
  echo "Extracting $TAR_FILE in $BIN_DIR..."
  tar -xf "$BIN_DIR/$TAR_FILE" -C "$BIN_DIR"

  # Run the binary to confirm version
  echo "Running ./bzed version for $version..."
  "$BIN_DIR/bzed" version

  # Clean up the downloaded tar file
  rm "$BIN_DIR/$TAR_FILE"
done

echo "All versions downloaded, extracted, and verified."
