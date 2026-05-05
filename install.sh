#!/bin/sh
set -e

REPO="runnon/devkat-releases"
BINARY="devkat-push"
INSTALL_DIR="${HOME}/.local/bin"

echo ""
echo "  devkat — session tracking for AI coding tools"
echo ""

# Check macOS
if [ "$(uname -s)" != "Darwin" ]; then
    echo "  Error: devkat currently only supports macOS."
    exit 1
fi

# Download URL
# Get latest release download URL
DOWNLOAD_URL=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | grep "browser_download_url.*macos" | cut -d '"' -f 4)

# Create temp dir
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Download and extract
echo "  Downloading..."
curl -fsSL "$DOWNLOAD_URL" -o "$TMP_DIR/devkat.tar.gz"
tar -xzf "$TMP_DIR/devkat.tar.gz" -C "$TMP_DIR"

# Create install dir if needed
mkdir -p "$INSTALL_DIR"

# Install
mv "$TMP_DIR/$BINARY" "$INSTALL_DIR/$BINARY"
chmod +x "$INSTALL_DIR/$BINARY"

# Add to PATH for this session
export PATH="$INSTALL_DIR:$PATH"

# Persist PATH if needed
case ":$PATH:" in
    *":$INSTALL_DIR:"*) ;;
    *)
        SHELL_NAME=$(basename "$SHELL")
        if [ "$SHELL_NAME" = "zsh" ]; then
            echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$HOME/.zshrc"
        elif [ "$SHELL_NAME" = "bash" ]; then
            echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$HOME/.bashrc"
        fi
        ;;
esac

echo "  ✓ Installed"
echo ""
echo "  Now run:"
echo ""
echo "    devkat-push --login"
echo ""
echo "  That's it. Sessions sync automatically after setup."
echo ""
