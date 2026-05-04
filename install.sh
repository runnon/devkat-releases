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

# Login
echo "  Sign in with your devkat account:"
echo ""
"$INSTALL_DIR/$BINARY" --login

# Install daemon
echo ""
"$INSTALL_DIR/$BINARY" --install

echo ""
echo "  ✓ Done. Sessions will sync automatically."
echo "    Run 'devkat-push --status' anytime to check."
echo ""
