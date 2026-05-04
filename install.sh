#!/bin/sh
set -e

REPO="runnon/devkat-releases"
BINARY="devkat-push"
INSTALL_DIR="${HOME}/.local/bin"

echo "devkat — installing $BINARY..."
echo ""

# Check macOS
if [ "$(uname -s)" != "Darwin" ]; then
    echo "Error: devkat-push currently only supports macOS."
    exit 1
fi

# Get latest release URL
DOWNLOAD_URL="https://github.com/$REPO/releases/latest/download/devkat-0.1.0-macos.tar.gz"

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

# Check if INSTALL_DIR is in PATH
case ":$PATH:" in
    *":$INSTALL_DIR:"*) ;;
    *)
        echo "  Adding $INSTALL_DIR to your PATH..."
        SHELL_NAME=$(basename "$SHELL")
        if [ "$SHELL_NAME" = "zsh" ]; then
            echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$HOME/.zshrc"
        elif [ "$SHELL_NAME" = "bash" ]; then
            echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$HOME/.bashrc"
        fi
        export PATH="$INSTALL_DIR:$PATH"
        ;;
esac

echo ""
echo "  ✓ Installed $BINARY to $INSTALL_DIR/$BINARY"
echo ""
echo "  Next steps:"
echo ""
echo "    1. Sign in:        devkat-push --login"
echo "    2. Enable daemon:  devkat-push --install"
echo "    3. Check status:   devkat-push --status"
echo ""
echo "  Sessions from Claude Code, Codex, and Cursor will sync automatically."
echo ""
