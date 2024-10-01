# Azure Unused Disk Deletion Script

This Bash script is designed to identify and delete unused Azure disks. It ensures that critical or backup disks, attached disks, and disks larger than 5GB are preserved. Before deletion, the script checks the age of the disk and prompts for user confirmation to prevent accidental data loss.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Usage](#usage)
- [How It Works](#how-it-works)
- [Log Information](#log-information)
- [License](#license)

## Prerequisites

Before running this script, ensure you have the following:

- **Azure CLI**: Make sure the Azure CLI is installed on your system. You can download it [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
- **Bash**: This script is written for a Unix-like environment (Linux, macOS, or WSL on Windows).
- **Azure Account**: You must be logged into your Azure account using `az login`.

## Setup Instructions

1. **Clone the repository** (or download the script file):

   ```bash
   git clone https://github.com/MathanKumar23/Shell-Script.git
   cd <repository-directory>

   ```

2. **Make the script executable**:

   `chmod +x delete_unused_disks.sh`

3. **Open the script** in your favorite text editor to review or modify any configurations if necessary.

## Usage

---

To run the script, use the following command:

`./delete_unused_disks.sh`

During execution, the script will ask if you want to run in dry-run mode:

- **Dry-run mode**: If you answer "y", the script will simulate the deletion of disks without actually deleting them, allowing you to see what would be deleted.
- **Normal mode**: If you answer "n", the script will proceed to delete disks after user confirmation.

### Example Output

`Do you want to run in dry-run mode? (y/n) n
Checking disks...
myDisk1 is attached to a VM. Skipping deletion.
myDisk2 is only 20 days old. Skipping deletion.
Deleting Disk myOldDisk...
Are you sure you want to delete myOldDisk? (y/n) y`

## How It Works

---

1.  **Disk Listing**: The script retrieves a list of all disks in your Azure account.
2.  **Validation**: It checks each disk for:
    - Tags (`critical` or `backup`)
    - Attachment status (whether it's attached to a VM)
    - Size (skips if greater than 5GB)
    - Age (skips if less than 30 days old)
3.  **Confirmation**: Before deleting a disk, the script asks for user confirmation.

## Log Information

---

All actions, including deletions, are logged in a file named `disk_deletion.log`. This file records the disk names and their corresponding resource groups.

## License

---

This project is licensed under the MIT License. See the LICENSE file for details.
