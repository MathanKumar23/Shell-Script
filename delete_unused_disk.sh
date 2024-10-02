#Below script used to delete the unused disk in azure
# Checks the all available disk in all region
# If it's given critical or backup Tag, attached to any Machine or more than 5GB skipping deletion.
# If it's not meeting above criteria, will check the age of the dik creation, before deleting the disk
# Also ask for user confirmation before proceeding with deleting disk

# Function to calculate the age of a disk in days
disk_age_in_days() {
    disk_creation_date=$1
    current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Convert both dates to seconds since epoch and calculate the difference
    disk_creation_seconds=$(date -d "$disk_creation_date" +%s)
    current_seconds=$(date -d "$current_date" +%s)
    age_in_seconds=$((current_seconds - disk_creation_seconds))

    # Convert seconds to days
    echo $((age_in_seconds / 86400))
}

#!/bin/bash
delete_disks() {
    # set -x # This will run the script in debug mode
    # Fetch all disks and store them in a temporary file
    temp_file=$(mktemp)
    az disk list --query "[].{name:name, resourceGroup:resourceGroup, diskState:diskState, size:diskSizeGB, criticalTag:tags.critical, backupTag:tags.backup, timeCreated:timeCreated}" -o tsv >"$temp_file"

    # Open a file descriptor for the temporary file
    exec 3<"$temp_file"

    # IFS=$'\t' allows you to split input based on tabs in the $disks list.
    while IFS=$'\t' read -u 3 -r disk_name resource_group diskState size criticalTag backupTag time_created; do
        # Check if disk is tagged as critical or backup
        if [[ "$criticalTag" == "true" || "$backupTag" == "true" ]]; then
            echo "$disk_name is tagged as critical or backup. Skipping deletion."
        # Check disk state (attached to a VM)
        elif [ "$diskState" = "Attached" ]; then
            echo "$disk_name is attached to a VM. Skipping deletion."
        # Check the disk size
        elif [ "$size" -gt 5 ]; then
            echo "$disk_name is larger than 5GB. Skipping deletion."
        else
            # Optional: Check the age of the disk
            age_in_days=$(disk_age_in_days "$time_created")
            if [ "$age_in_days" -lt 30 ]; then
                echo "$disk_name is only $age_in_days days old. Skipping deletion."
            else
                echo "Deleting Disk $disk_name"
                # Log the action
                echo "$(date): Deleting disk $disk_name in resource group $resource_group" >>disk_deletion.log
                # Confirm before deletion
                # If dry-run mode is enabled, just simulate the deletion
                if [[ "$dry_run" == "y" ]]; then
                    echo "Dry-run: Would delete $disk_name."
                else
                    # Ask for confirmation before actual deletion
                    echo "About to ask for confirmation for disk: $disk_name"
                    read -p "Are you sure you want to delete $disk_name? (y/n) " confirmation
                    if [[ "$confirmation" == "y" ]]; then
                        az disk delete --name "$disk_name" --resource-group "$resource_group" --yes
                    else
                        echo "Skipping $disk_name."
                    fi
                fi
            fi
        fi

    done

    # Close the file descriptor
    exec 3<&-
    # Remove the temporary file
    rm "$temp_file"
}

# Call the function with an optional dry run
read -p "Do you want to run in dry-run mode? (y/n) " dry_run
if [[ "$dry_run" == "y" ]]; then
    echo "Dry run mode. The following disks would be deleted:"
    delete_disks
else
    delete_disks
fi
