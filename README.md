# Minecraft Server Updater

## Overview

This script streamlines the Minecraft server update process by automating the download and extraction of necessary files from shared URLs. Is made for Dropbox, though other cloud storage solutions can be used.

## Prerequisites

- Utilize Dropbox or an alternative cloud storage platform.
- Specify the files you want to keep in cloud by adding them to "upload.txt".
- If hosting is shared with friends, include their files URLs in "sharedUrls.txt".

## Important Notes

- Always maintain a manual backup of your server files as a precautionary measure. In the event of unexpected issues, having a backup ensures you can quickly restore your server to a stable state.
- Paths on "upload.txt" are relative so if you want to track something in config or another folder place them like config/something, extension is necessary for files.

## Functionality

1. Copy your local files from configured cloud folder to server directory.
2. Downloads files from shared URLs specified in "sharedUrls.txt".
3. Extracts files to a temporary folder, organizes them by date, and selects the latest version.
4. Replaces specified files in "upload.txt" on your Minecraft server with the latest versions.

## How to Use

1. Modify "run.bat" with your cloud folder details and server execution command.
2. Add the files you want to keep in cloud to "upload.txt".
3. Include shared file URLs in "sharedUrls.txt" if applicable.
4. Run the script to automatically update your Minecraft server files.

Feel free to contribute and enhance the script based on your specific server setup or requirements.