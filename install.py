import subprocess
import os
import time
import sys

def print_header(title):
    """Prints a formatted header."""
    print("============================================================")
    print(f"                  {title}")
    print("============================================================")
    print("")

def run_command(command, check=True, capture_output=False, shell=True, env=None):
    """
    Runs a shell command.
    :param command: The command string to execute.
    :param check: If True, raises a CalledProcessError for non-zero exit codes.
    :param capture_output: If True, captures stdout and stderr.
    :param shell: If True, the command will be executed through the shell.
    :param env: A dictionary of environment variables.
    :return: CompletedProcess object if capture_output is True, otherwise None.
    """
    try:
        if capture_output:
            result = subprocess.run(command, check=check, shell=shell, capture_output=True, text=True, env=env)
            return result
        else:
            subprocess.run(command, check=check, shell=shell, env=env)
    except subprocess.CalledProcessError as e:
        print(f"❌ Error executing command: {command}")
        print(f"   Exit Code: {e.returncode}")
        if capture_output:
            print(f"   Stdout: {e.stdout}")
            print(f"   Stderr: {e.stderr}")
        raise # Re-raise the exception to stop script execution if check=True

def release_apt_lock():
    """Checks for and releases APT locks."""
    print("🔄 Checking for apt lock...")
    for i in range(1, 6):
        try:
            # Check for specific lock files
            fuser_apt_lock = run_command("sudo fuser /var/lib/apt/lists/lock", check=False, capture_output=True).returncode
            fuser_dpkg_lock = run_command("sudo fuser /var/lib/dpkg/lock-frontend", check=False, capture_output=True).returncode

            if fuser_apt_lock == 0 or fuser_dpkg_lock == 0:
                print(f"   - Apt lock detected, waiting... (Attempt {i}/5)")
                time.sleep(5)
            else:
                print("   - No apt lock detected, proceeding...")
                return
        except Exception as e:
            print(f"   - Error during lock check: {e}")
            time.sleep(5)

    print("❌ Apt lock still held. Attempting to kill locking process...")
    try:
        # Attempt to kill processes holding the locks
        run_command("sudo kill -9 $(sudo fuser /var/lib/apt/lists/lock 2>/dev/null) 2>/dev/null", check=False)
        run_command("sudo kill -9 $(sudo fuser /var/lib/dpkg/lock-frontend 2>/dev/null) 2>/dev/null", check=False)
        run_command("sudo dpkg --configure -a", check=False)
        run_command("sudo rm -f /var/lib/apt/lists/lock /var/lib/dpkg/lock-frontend", check=False)
        print("   - Lock released, proceeding...")
    except Exception as e:
        print(f"   - Failed to release lock: {e}")
        sys.exit(1) # Exit if cannot release lock


# --- Main Script Execution ---
if __name__ == "__main__":
    start_time = time.time()

    print_header("Starting System Update and Node.js Installation")

    # LANGKAH 1: Konfigurasi untuk menghindari semua prompt
    print("🔄 Setting up non-interactive mode and pre-seeding debconf...")
    os.environ['DEBIAN_FRONTEND'] = 'noninteractive'

    try:
        run_command("echo 'libc6 libraries/restart-without-asking boolean true' | sudo debconf-set-selections")
        run_command("echo 'libssl1.1 libraries/restart-without-asking boolean true' | sudo debconf-set-selections")
        run_command("echo 'libssl3 libraries/restart-without-asking boolean true' | sudo debconf-set-selections")
    except Exception as e:
        print(f"❌ Failed to set debconf selections: {e}")
        sys.exit(1)

    print("   - Configuring needrestart for auto-restart...")
    try:
        run_command("sudo mkdir -p /etc/needrestart/conf.d")
        needrestart_conf = """$nrconf{restart} = 'a';"""
        with open("/tmp/no-prompt.conf", "w") as f: # Write to a temp file first
            f.write(needrestart_conf)
        run_command("sudo mv /tmp/no-prompt.conf /etc/needrestart/conf.d/no-prompt.conf")
    except Exception as e:
        print(f"❌ Failed to configure needrestart: {e}")
        sys.exit(1)

    print("   - Adding custom APT configuration to prevent prompts...")
    try:
        apt_conf_content = """APT::Get::Assume-Yes "true";
APT::Get::allow-downgrades "true";
APT::Get::allow-remove-essential "true";
APT::Get::allow-change-held-packages "true";
DPkg::Options {
   "--force-confdef";
   "--force-confold";
   "--force-overwrite";
   "--force-unsafe-io";
};
DPkg::Lock::Timeout "60";
APT::Install-Recommends "false";
APT::Install-Suggests "false";
APT::Get::Fix-Missing "true";
APT::Get::Fix-Broken "true";
Dpkg::Pre-Install-Pkgs {""};
Dpkg::Pre-Invoke {""};
Dpkg::Post-Invoke {""};
Dpkg::Post-Install-Pkgs {""};
Dir::Etc::SourceList "";
quiet "1";
"""
        with open("/tmp/99custom-settings", "w") as f: # Write to a temp file first
            f.write(apt_conf_content)
        run_command("sudo mv /tmp/99custom-settings /etc/apt/apt.conf.d/99custom-settings")
    except Exception as e:
        print(f"❌ Failed to write APT configuration: {e}")
        sys.exit(1)

    # LANGKAH 2: Tambahkan repository NodeSource untuk Node.js
    print("🔄 Setting up NodeSource repository...")
    release_apt_lock()
    try:
        # Use a temporary file for the curl output before piping to bash
        run_command("curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -")
    except Exception:
        print("❌ Failed to set up NodeSource repository. Exiting...")
        sys.exit(1)

    # LANGKAH 3: Update dan Upgrade sistem
    print("🔄 Updating package lists...")
    release_apt_lock()
    for i in range(1, 4):
        try:
            run_command("sudo apt-get update -y -qq")
            break
        except Exception:
            print(f"   - Failed to update package lists (Attempt {i}/3). Retrying...")
            time.sleep(2)
    else: # This 'else' block executes if the loop completes without a 'break'
        print("❌ Failed to update package lists after retries. Exiting...")
        sys.exit(1)

    print("🔄 Upgrading packages...")
    try:
        # The apt.conf settings should handle the prompts now
        run_command("sudo apt-get dist-upgrade -y -qq")
    except Exception:
        print("❌ Failed to upgrade packages. Exiting...")
        sys.exit(1)

    # LANGKAH 4: Install Node.js dan npm
    print("🔄 Installing Node.js and npm...")
    release_apt_lock()
    try:
        run_command("sudo apt-get install -qq -y nodejs")
    except Exception:
        print("❌ Failed to install Node.js. Exiting...")
        sys.exit(1)

    node_status = "❌ Gagal diinstall"
    npm_status = "❌ Gagal diinstall"

    try:
        node_version_result = run_command("node -v", capture_output=True)
        npm_version_result = run_command("npm -v", capture_output=True)

        if node_version_result.returncode == 0:
            node_version = node_version_result.stdout.strip()
            node_status = f"✅ Berhasil diinstall (versi {node_version})"
        if npm_version_result.returncode == 0:
            npm_version = npm_version_result.stdout.strip()
            npm_status = f"✅ Berhasil diinstall (versi {npm_version})"

        if "Gagal" in node_status or "Gagal" in npm_status:
            print("❌ Failed to install Node.js and npm. Exiting...")
            sys.exit(1)

    except Exception:
        print("❌ Failed to verify Node.js and npm installation. Exiting...")
        sys.exit(1)

    # LANGKAH 5: Install required npm modules
    print("🔄 Installing npm modules: hpack, socks, colors, node-fetch@2, axios, http2-wrapper...")
    modules_status = "⚠️ Beberapa modul gagal diinstall"
    try:
        run_command("npm config set yes true")
        npm_install_result = run_command("npm install hpack socks colors node-fetch@2 axios http2-wrapper", capture_output=True)
        if npm_install_result.returncode == 0:
            modules_status = "✅ Semua modul berhasil diinstall"
        else:
            print("❌ Failed to install npm modules. Exiting...")
            print(f"Error details: {npm_install_result.stderr}")
            sys.exit(1)
    except Exception as e:
        print(f"❌ An error occurred during npm module installation: {e}")
        sys.exit(1)

    # LANGKAH 6: Download script dari GitHub
    print("🔄 Downloading scripts from GitHub...")
    scripts_to_download = {
        "RAW.js": "https://raw.githubusercontent.com/pengodehandal/auto-install/refs/heads/main/RAW.js",
        "TLS.js": "https://raw.githubusercontent.com/pengodehandal/auto-install/refs/heads/main/TLS.js",
        "bypass.js": "https://raw.githubusercontent.com/pengodehandal/auto-install/refs/heads/main/bypass.js",
        "flash.js": "https://raw.githubusercontent.com/pengodehandal/auto-install/refs/heads/main/flash.js",
        "pez.js": "https://raw.githubusercontent.com/pengodehandal/auto-install/refs/heads/main/pez.js",
    }
    scripts_status = "✅ Semua script berhasil didownload ke direktori saat ini"
    current_dir_path = os.getcwd()

    for script_name, url in scripts_to_download.items():
        print(f"   - Downloading {script_name}...")
        try:
            run_command(f"wget -q {url} -O {script_name}")
        except Exception:
            print(f"   - ❌ Failed to download {script_name}.")
            scripts_status = "⚠️ Beberapa script gagal didownload"

    if not all(os.path.exists(script_name) for script_name in scripts_to_download.keys()):
        scripts_status = "⚠️ Beberapa script gagal didownload"


    # LANGKAH 7: Cleanup setelah instalasi
    print("🔄 Cleaning up...")
    try:
        run_command("sudo apt-get clean -qq")
        run_command("sudo rm -f /etc/apt/apt.conf.d/99custom-settings")
        run_command("sudo rm -f /etc/needrestart/conf.d/no-prompt.conf")
    except Exception as e:
        print(f"⚠️ Error during cleanup: {e}")

    # Hitung waktu yang diperlukan
    end_time = time.time()
    duration = int(end_time - start_time)
    minutes = duration // 60
    seconds = duration % 60

    # Clear console
    subprocess.run("clear", shell=True)

    # Tampilkan ringkasan instalasi
    print_header("INSTALASI SELESAI")
    print(f"⏱️ Waktu instalasi: {minutes} menit {seconds} detik")
    print("")
    print("📦 Paket yang diinstall:")
    print(f"   - Node.js: {node_status}")
    print(f"   - npm: {npm_status}")
    print("")
    print("📚 Modul npm yang diinstall:")
    print("   - hpack")
    print("   - socks")
    print("   - colors")
    print("   - node-fetch (versi 2)")
    print("   - axios")
    print("   - http2-wrapper")
    print("")
    print(f"📝 Status Modul: {modules_status}")
    print("")
    print("📜 Download Script:")
    for script_name in scripts_to_download.keys():
        print(f"   - {script_name}")
    print("")
    print(f"📝 Status Scripts: {scripts_status}")
    print("")
    print(f"📁 Lokasi script: {current_dir_path}/")
    print("")
    print_header("SISTEM SIAP DIGUNAKAN")
