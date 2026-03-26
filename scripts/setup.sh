#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up Finly development environment..."

# ---- Melos ----
if ! command -v melos &>/dev/null; then
  echo "==> Installing melos globally..."
  dart pub global activate melos
else
  echo "==> melos already installed ($(melos --version))"
fi

# Ensure Dart pub global bin is on PATH
DART_PUB_BIN="$HOME/.pub-cache/bin"
if [[ ":$PATH:" != *":$DART_PUB_BIN:"* ]]; then
  echo ""
  echo "  WARNING: $DART_PUB_BIN is not in your PATH."
  echo "  Add this to your ~/.zshrc or ~/.bashrc:"
  echo "    export PATH=\"\$PATH:$DART_PUB_BIN\""
  echo ""
fi

# ---- Lefthook ----
if ! command -v lefthook &>/dev/null; then
  echo "==> Installing lefthook..."

  OS="$(uname -s)"
  ARCH="$(uname -m)"

  case "$OS" in
    Linux)
      PLATFORM="linux"
      ;;
    Darwin)
      PLATFORM="darwin"
      ;;
    *)
      echo "  ERROR: Unsupported OS: $OS. Install lefthook manually:"
      echo "  https://github.com/evilmartians/lefthook/releases"
      exit 1
      ;;
  esac

  case "$ARCH" in
    x86_64)  BIN_ARCH="x86_64" ;;
    aarch64|arm64) BIN_ARCH="arm64" ;;
    *)
      echo "  ERROR: Unsupported architecture: $ARCH"
      exit 1
      ;;
  esac

  LEFTHOOK_VERSION="1.6.18"
  DOWNLOAD_URL="https://github.com/evilmartians/lefthook/releases/download/v${LEFTHOOK_VERSION}/lefthook_${LEFTHOOK_VERSION}_${PLATFORM^}_${BIN_ARCH}"
  INSTALL_DIR="$HOME/.local/bin"
  mkdir -p "$INSTALL_DIR"

  echo "  Downloading lefthook ${LEFTHOOK_VERSION} for ${PLATFORM}/${BIN_ARCH}..."
  curl -fsSL "$DOWNLOAD_URL" -o "$INSTALL_DIR/lefthook"
  chmod +x "$INSTALL_DIR/lefthook"

  if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo ""
    echo "  WARNING: $INSTALL_DIR is not in your PATH."
    echo "  Add this to your ~/.zshrc or ~/.bashrc:"
    echo "    export PATH=\"\$PATH:$INSTALL_DIR\""
    echo ""
  fi
else
  echo "==> lefthook already installed ($(lefthook version))"
fi

# ---- Install git hooks ----
echo "==> Installing git hooks via lefthook..."
lefthook install

# ---- Flutter dependencies ----
echo "==> Getting Flutter dependencies..."
flutter pub get

echo ""
echo "Done! Development environment is ready."
echo ""
echo "Useful commands:"
echo "  make analyze       - Run static analysis"
echo "  make format        - Format code"
echo "  make lint          - Format check + analyze"
echo "  make test          - Run tests"
echo "  make gen           - Run build_runner (code generation)"
echo "  make gen-watch     - Watch mode for code generation"
echo "  make clean         - Clean and reinstall dependencies"
