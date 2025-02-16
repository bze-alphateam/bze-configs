#!/usr/bin/env bash
set -euo pipefail

# Constant definition for BZE_HOME_DIR - adjust as needed.
BZE_HOME_DIR="/home/bze/.bze"

# Check if a version argument was provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 v7.2.0"
  exit 1
fi

version="$1"

# Create the cosmovisor upgrade directory
upgrade_dir="${BZE_HOME_DIR}/cosmovisor/upgrades/${version}/bin/"
echo "Creating upgrade directory: ${upgrade_dir}"
mkdir -p "$upgrade_dir"

# Build the tar file name and URL for download
TAR_FILE="bze-${version#v}-linux-amd64.tar.gz"
URL="https://github.com/bze-alphateam/bze/releases/download/${version}/${TAR_FILE}"

echo "Downloading binary archive from: ${URL}"
curl -L -o "$TAR_FILE" "$URL"

# Create a temporary directory for extraction
tmpdir=$(mktemp -d)
echo "Extracting ${TAR_FILE} to temporary directory ${tmpdir}..."
tar -xzf "$TAR_FILE" -C "$tmpdir"

# Assume the extracted archive contains the binary named "bze"
binary_path="${tmpdir}/bzed"
if [ ! -f "$binary_path" ]; then
  echo "Error: Expected binary 'bzed' was not found in the archive."
  rm -rf "$tmpdir"
  exit 1
fi

echo "Running ./bzed version for $version..."
"$binary_path" version

# Copy the binary to the upgrade bin folder and make it executable
echo "Copying binary to ${upgrade_dir}..."
cp "$binary_path" "$upgrade_dir"
chmod +x "${upgrade_dir}/bzed"

# Clean up the temporary directory and the downloaded tar file
rm -rf "$tmpdir"
rm "$TAR_FILE"

echo "Upgrade preparation for version ${version} is complete."
