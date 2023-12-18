# Minecraft Server Updater

## Overview
This script streamlines the Minecraft server update process by automating the download and extraction of necessary files from shared URLs. It utilizes the 7z compression tool and is optimized for Dropbox, though other cloud storage solutions can be used.

## Prerequisites
- Ensure you have 7z installed on your system.
- Utilize Dropbox or an alternative cloud storage platform.
- Specify the files you want to keep in the cloud by adding them to "upload.txt".
- If hosting is shared with friends, include their file URLs in "sharedUrls.txt".

## Important Notes
- Always maintain a manual backup of your server files as a precautionary measure. In the event of unexpected issues, having a backup ensures you can quickly restore your server to a stable state.
- If you need to make changes to tracked files or folders, delete or rename the local file. Make sure to remove shared URLs from "sharedUrls.txt" to avoid potential conflicts.
- Paths on "upload.txt" are relative so if you want to track something in config or another folder place them like config/something, extension is necessary for files.

## Functionality
1. Downloads files from shared URLs specified in "sharedUrls.txt".
2. Extracts files to a temporary folder, organizes them by date, and selects the latest version.
3. Replaces specified files in "upload.txt" on your Minecraft server with the latest versions.

## How to Use
1. Modify "run.bat" with your cloud folder details and server execution command.
2. Add the files you want to keep in the cloud to "upload.txt".
3. Include shared file URLs in "sharedUrls.txt" if applicable.
4. Run the script to automatically update your Minecraft server files.

**Note:** The start and end files will be in 7z format, so ensure you have 7z installed for the script to work correctly.

Feel free to contribute and enhance the script based on your specific server setup or requirements.