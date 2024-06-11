# Backup Script README

## Overview
This script is designed to help manage file backups on a Linux system. It provides a menu-based interface to add source directories, specify a destination directory, set a backup schedule, and initiate backups using cron jobs.

### Authors
- Angelo Prebianca
- Joao Machado
- Marcos Renato

### Project
Final project for Systems Administration.

## Features
- Add multiple source directories for backup.
- Specify a single destination directory.
- Set backup frequency using cron scheduling.
- Start and schedule backups.
- Color-coded interface for better readability.

## Usage
Run the script in a bash terminal to start the backup manager.

```bash
./backup_script.sh
```

### Menu Options
1. **Add Source Directory**: Add one or more directories to the list of sources to be backed up.
2. **List and Remove Source Directories**: Display the current list of source directories and remove any if needed.
3. **Set Backup Destination**: Specify the destination directory where backups will be stored.
4. **Set Backup Frequency**: Define the schedule for the backup using cron syntax.
5. **Start and Schedule Backup**: Initiate the backup process and set up the cron job.
6. **Exit**: Exit the backup script.

## Color Codes
- **Blue**: General information and prompts.
- **Green**: Success messages.
- **Red**: Error messages or warnings.
- **White**: Default text color.

## Functions

### `Menu`
Displays the main menu and handles user input for various options.

### `adcOrigem`
Prompts the user to add a source directory for backup.

### `rmvOrigem`
Lists current source directories and allows the user to remove any.

### `setDestino`
Prompts the user to set or change the backup destination directory.

### `freqBackup`
Prompts the user to set the schedule for backups and validates the input.

### `getInput`
Checks if a cron schedule is already set, prompts the user to set a new schedule if needed.

### `startBackup`
Validates the source and destination directories, creates the backup script, schedules it using cron, and executes the backup.

## Example Cron Schedule
To set the backup schedule, provide the following inputs when prompted:
- **Minute**: 0-59 or *
- **Hour**: 0-23 or *
- **Day of Month**: 1-31 or *
- **Month**: 1-12 or *
- **Day of Week**: 0-6 or *

The script will generate a cron schedule string and inform you of the set schedule.

## Notes
- Ensure the script has execute permissions.
- The script will create the backup directory if it does not exist, upon user confirmation.
- Only one backup destination can be set at a time.
- The script will remove any previous backup cron jobs before scheduling a new one.

## License
This project is licensed under the MIT License.
