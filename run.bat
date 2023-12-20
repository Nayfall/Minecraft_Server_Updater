@echo off
setlocal enabledelayedexpansion

REM ------------- SETUP -------------

:: Local route (Use %USERNAME% as your user folder)
set "localRoute=C:\Users\%USERNAME%\Dropbox"

:: Local file name (Is the name the local save will have, need extension .zip)
set "localFileName=minecraftServer.zip"

:: ---------------------------------

:: Local file route
set "localFile=%localRoute%\%localFileName%"

:: Actual Folder
set "actualFolder=%~dp0"

:: Temporal Folder
set "tempFolder=%actualFolder%\temp"

:: Shared Urls file
set "urlsFile=%actualFolder%\sharedUrls.txt"

:: Upload file
set "uploadFile=%actualFolder%\upload.txt"

REM ------------- START -------------

:askReplace
set /P "replaceLocalFiles=Want to replace local files with updated ones? (Y/N): "
if /I "!replaceLocalFiles!" equ "Y" (
    echo Realizing replacing logic...
    goto replaceLogic
) else if /I "!replaceLocalFiles!" equ "N" (
    echo Skipping replacing logic
    goto executeServer
) else (
    echo Only avaible options are Y and N
    goto askReplace
)

:replaceLogic
:: Create a temporal folder
mkdir "%tempFolder%" 2>nul

if exist "%localFile%" (
    :: Copy localFile to tempFolder if exists
    copy "%localFile%" "%tempFolder%"
    echo %localFile% copied to %tempFolder%
) else (
    echo %localFile% dont exist
)

:: Counter
set "counter=1"

:: Verify if urls txt exists
if exist "%urlsFile%" (
:: Iterate over all urls
    set "counter=1"
    for /F "tokens=*" %%A in (%urlsFile%) do (
        set "url=%%A"

        :: Assemble file name
        set "fileName=file!counter!.zip"
  
        :: Check if URL is valid
        curl --head --fail --silent --show-error "!url!" >nul
        if errorlevel 1 (
            echo Invalid URL: !url!
        ) else (
            :: Download from provided URL
            curl -LJ "!url!" --output "%tempFolder%\!fileName!"
    
            :: Increment counter
            set /a counter+=1
        )
    )
) else (
    echo "%urlsFile%" is not provided
)

:: Initialize latestFolder
set "latestFolder="
set "latestDate=0"

:: Check if downloaded files have a size greater than 1 MB and extract
for %%F in ("%tempFolder%\*.zip") do (
  if %%~zF geq 1048576 (
    :: Extract file to tempFolder
    powershell Expand-Archive -Path "%%F" -DestinationPath "%tempFolder%"
    set "extractStatus=!errorlevel!"
    if !extractStatus! neq 0 (
      echo Error extracting file: "%%F"
    )
  ) else (
    echo Downloaded file "%%F" is smaller than 1 MB. Deleting the file
    del "%%F"
  )
)

:: Verify if tempFolder has numeric folders
set "hasNumericFolders=false"
for /d %%D in ("%tempFolder%\*") do (
    echo %%~nxD | findstr /r "^[0-9]*$" >nul
    if %errorlevel% equ 0 (
        set "hasNumericFolders=true"
        echo Folder found: %%D
    )
)

:: Find latest date folder
if "%hasNumericFolders%"=="true" (
    for /d %%D in ("%tempFolder%\*") do (
        set "folderDate=%%~nxD"
        if !folderDate! gtr !latestDate! set "latestFolder=%%D" & set "latestDate=!folderDate!"
    )
) else (
    echo No folders with numeric names
)

:: Realize logic on latestFolder
if defined latestFolder (
    echo Latest folder: %latestFolder%

    :: Copy latestFolder content
    call :CopyFilesAndFolders "%latestFolder%" "%actualFolder%" "true"

    echo Latest folder replaced in main directory
) else (
    echo No folders found
)

:: Delete tempFolder
rmdir /s /q "%tempFolder%"

:executeServer
:: Server execution (Place your server execution command)
java @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.20.1-47.2.18/win_args.txt %*
:: ---------------------------------

REM ------------- UPLOAD -------------

:: Obtain date in format YYYYMMDD
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set "date=%%I"
set "actualDate=!date:~0,8!"

:: Obtain time in format HHMM
set "actualTime=!TIME:~0,5!"

:: Obtain time zone offset and adjust time
for /f "tokens=*" %%T in ('wmic timezone get offset ^| find "+"') do set "timezoneOffset=%%T"
set /a "hourOffset=%timezoneOffset:~0,3%"
set /a "minuteOffset=%timezoneOffset:~3,2%"
set /a "adjustedHour=!TIME:~0,2!+hourOffset"
if !adjustedHour! lss 10 set "adjustedHour=0!adjustedHour!"

set "actualDate=!actualDate!_!adjustedHour!!TIME:~3,2!"

echo Actual Date: %actualDate%

:: Target Folder
set "targetFolder=%actualFolder%\%actualDate%"

:: Create actualDate folder
mkdir "%targetFolder%"

:: Verification loop
:verifyUpload
if not exist "%uploadFile%" (
    echo File %uploadFile% dont exist, please create a valid one
    pause
    goto verifyUpload
)

:: Copy files and folders to actualDate folder
call :CopyFilesAndFolders "%actualFolder%" "%targetFolder%" "false"

:: Create a new file with actualDate folder
powershell Compress-Archive -Path "%actualFolder%\%actualDate%" -DestinationPath "%actualFolder%\%localFileName%"

:: Delete actualDate folder
rmdir /s /q "%targetFolder%"

:: Move the file to Local folder
move "%actualFolder%\%localFileName%" "%localRoute%"

pause

REM ------------- FUNCTIONS -------------

:: Copy files and folders from "upload.txt" to destination
:copyFilesAndFolders
set "source=%~1"
set "destination=%~2"
set "deleteDestination=%~3"

for /F "tokens=*" %%A in ('findstr /N "^" "%uploadFile%"') do (
    set "line=%%A"
    set "line=!line:*:=!"
    set "line=!line: =!"
    if /I "!line!"=="files=[" (
        set "copyFiles=true"
        set "copyFolders=false"
    ) else if /I "!line!"=="folders=[" (
        set "copyFiles=false"
        set "copyFolders=true"
    ) else if /I "!line!"=="]" (
        set "copyFiles=false"
        set "copyFolders=false"
    ) else if "!copyFiles!"=="true" (
        echo Copying: "%source%\!line!" to "%destination%\!line!"
        echo F|xcopy "%source%\!line!" "%destination%\!line!" /Y
    ) else if "!copyFolders!"=="true" (
        if "%deleteDestination%"=="true" (
            echo Removing and replacing "%source%\!line!"
            rmdir /s /q "%destination%\!line!"
            mkdir "%destination%\!line!" 2>nul
            echo D|xcopy "%source%\!line!" "%destination%\!line!" /E
        ) else (
            echo Copying: "%source%\!line!" to "%destination%\!line!\"
            echo D|xcopy "%source%\!line!" "%destination%\!line!\" /E
        )
    )
)
EXIT /B 0