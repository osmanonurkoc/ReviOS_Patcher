
# ReviOS Unattended Patcher 🚀

This repository provides a one-click, unattended deployment script to patch a fresh Windows installation using the **ReviOS Playbook** and the **Ameliorated (AME) CLI Wizard**. 

Instead of manually downloading files and clicking through the Ameliorated UI, this script fully automates the process. It downloads the necessary dependencies, applies essential registry tweaks, executes the ReviOS Playbook with a pre-defined set of optimal parameters, and cleans up after itself upon reboot. Perfect for post-installation setups.

## ⚠️ Important Prerequisite

Before running the script, you **must** manually disable Windows Defender. Modern Windows security mechanisms (such as Tamper Protection) prevent scripts from bypassing the antivirus automatically. 

1. Open **Windows Security**.
2. Go to **Virus & threat protection** > **Manage settings**.
3. Turn off **Real-time protection** and **Tamper Protection**.

*(Note: The Ameliorated CLI will permanently disable Defender during the execution phase as configured in the script).*

---

## ⚙️ How It Works

1. **Workspace Creation**: Creates a temporary working directory (`C:\Revision`).
2. **Dependency Fetching**: Silently downloads `7za.exe` via BITS, fetches the latest AME CLI (`TrustedUninstaller.CLI.exe`), and grabs the latest `.apbx` ReviOS Playbook directly from GitHub.
3. **Extraction**: Unpacks all necessary files locally.
4. **Registry Tweaks**: Injects custom registry configurations for a smoother developer experience.
5. **Unattended Execution**: Runs the AME CLI with pre-configured flags (bypassing the GUI completely).
6. **Cleanup & Reboot**: Schedules a `RunOnce` task to silently delete the `C:\Revision` workspace on the next startup and automatically reboots the system.

---

## 🛠️ Customization (Boolean System)

The script is designed to be fully modular. At the very top of the `.cmd` file, you will find a **PLAYBOOK CONFIGURATION** block. You can easily enable or disable specific ReviOS features by simply changing the values to `1` (Enable) or `0` (Disable).

:: Example Configuration
set "CFG_REMOVE_EDGE=1"          :: Edge will be removed
set "CFG_INSTALL_BRAVE=0"        :: Brave will NOT be installed
set "CFG_DISABLE_DEFENDER=1"     :: Defender will be disabled

Right-click the script, select **Edit**, change the values to your liking, save the file, and then run it!

---

## 📋 Playbook Configuration Parameters

The script parses the default ReviOS `playbook.conf` and passes specific arguments to the Ameliorated CLI. Below is the comprehensive list of all available Playbook features and whether they are **Enabled (✔️)** or **Disabled (❌)** by default in this script. You can change any of these using the boolean system mentioned above.

| Feature | Default Status | Description |
| :--- | :---: | :--- |
| **Disable Defender** | ✔️ | Disables Windows Defender for maximum performance. |
| **Disable Hibernate** | ✔️ | Disables Hibernate and Fast Startup to free disk space. |
| **Remove Microsoft Edge** | ✔️ | Purges the Edge browser from the system. |
| **Remove OneDrive** | ✔️ | Completely removes OneDrive integration. |
| **Remove AI Components** | ✔️ | Removes Windows AI features (Recall & Copilot). |
| **Remove Microsoft Teams** | ✔️ | Uninstalls Microsoft Teams. |
| **Remove Photos App** | ✔️ | Removes the default UWP Photos application. |
| **Remove Dev Home App** | ✔️ | Removes the Dev Home UWP application. |
| **Remove Xbox Apps** | ✔️ | Cleans up Xbox-related UWP apps and services. |
| **Remove 'Your Phone'** | ✔️ | Removes the Phone Link / Your Phone integration. |
| **Enable Dark Mode** | ✔️ | Forces system-wide Dark Mode. |
| **Legacy Context Menu** | ✔️ | Restores the classic Windows 10 right-click menu in Windows 11. |
| **Remove Pinned Items** | ✔️ | Cleans up default pinned bloatware in the Start Menu. |
| **Disable Auto Maintenance** | ✔️ | Stops Windows from running scheduled automatic maintenance. |
| **Apply Revision Wallpaper**| ❌ | *Left at Windows default.* |
| **Disable Transparency** | ❌ | *Transparency effects remain enabled.* |
| **Install Brave Browser** | ❌ | *Browser choice is left to the user.* |
| **Install Firefox Browser** | ❌ | *Browser choice is left to the user.* |

---

## 🛠️ Included Registry Tweaks

Before executing the playbook, the script applies several custom registry modifications to improve quality of life:

* **PowerShell Enhancements**: Fixes `.ps1` file associations, sets the default execution action to run with `Bypass` mode, and changes the system execution policy to `RemoteSigned`.
* **Winget Hash Override**: Enables hash override for Windows Package Manager (`winget`) to prevent installation blocks.
* **File Explorer Cleanup**: Removes the "Gallery" pin from the Windows File Explorer navigation pane.
* **Association Resets**: Force-deletes manual user choice overrides for `.ps1` extensions to ensure proper execution.

---

## 🚀 Usage

1. Download the latest release of the `.cmd` script.
2. Edit the script to configure your boolean toggles if desired.
3. Right-click and select **Run as Administrator**.
4. Sit back and wait. The script will download everything, apply the patches, and reboot your PC automatically in 15 seconds once finished. 

*Note: The `C:\Revision` folder will be completely wiped from your drive silently the moment you log back into Windows.*

---

## 🙌 Credits
* [Ameliorated (AME)](https://ameliorated.io/) - For the TrustedUninstaller CLI tool.
* [ReviOS](https://revi.cc/) - For the excellent Windows playbook.

## 📄 License
This project is licensed under the [GPL License](LICENSE).

---
*Created by [@osmanonurkoc](https://github.com/osmanonurkoc)*
