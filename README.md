# Minecraft Server Updater

This script helps you by automating the download and extraction of necessary files specified in "sharedUrls.txt". Is made for Dropbox, though other cloud storage solutions can be used.

## Requirements

- Have installed Dropbox or an alternative cloud storage platform.
- Windows Operating System

## Functionality

1. Copies your local files from configured cloud folder to server directory.
2. Downloads files from shared URLs specified in "sharedUrls.txt".
3. Extracts files to a temporary folder, organizes them by date, and selects the latest version.
4. Replaces specified files in "upload.txt" on your Minecraft server with the latest versions.
5. When your server stops, takes specified files, compress them and moves to your installed cloud folder.

## How to Use

1. Modify "run.bat" with your cloud folder location, scroll down until you see server execution (Is above "UPLOAD" header) and place your server execution command.
2. Add the files you want to keep in cloud to "upload.txt".
3. Include your friends shared files URLs in "sharedUrls.txt" if you are sharing host.
4. Run the script to automatically update your Minecraft server files.

## Notes

- Always maintain a manual backup of your server files as a precautionary measure. In the event of unexpected issues, having a backup ensures you can quickly restore your server to a stable state.
- Paths on "upload.txt" are relative so if you want to track something in config or another folder place them like config/something, extension is necessary for files.
- If you want to realize modifications to an already uploaded files, you will need to type "N" on initial prompt, so your local files won't be replaced.

Feel free to contribute and enhance the script based on your specific server setup or requirements.
