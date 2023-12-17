@echo off
setlocal enabledelayedexpansion

REM ------------- SETUP -------------

:: Local route (Use %USERNAME% as your user folder)
set "localRoute=C:\Users\%USERNAME%\Dropbox"

:: Local file name (Is the name the local save will have, need extension .7z)
set "localFileName=minecraftServer.7z"

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

:: Create a temporal folder
mkdir "%tempFolder%" 2>nul

REM ------------- START -------------

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
        set "fileName=file!counter!.7z"
  
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
for %%F in ("%tempFolder%\*.7z") do (
  if %%~zF geq 1048576 (
    :: Extract file to tempFolder
    "%ProgramFiles%\7-Zip\7z.exe" x "%%F" -o"%%~dpF"
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
    xcopy "%latestFolder%\*" "%actualFolder%" /E /Y

    echo Content copied from latest folder to main directory
) else (
    echo No folders found
)

:: Delete tempFolder
rmdir /s /q "%tempFolder%"

:: Server execution (Place your server execution command)
java @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.20.1-47.2.17/win_args.txt %*
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
        echo Copying: "%actualFolder%\!line!" to "%targetFolder%\!line!"
        echo F|xcopy "%actualFolder%\!line!" "%targetFolder%\!line!"
    ) else if "!copyFolders!"=="true" (
        echo Copying: "%actualFolder%\!line!" to "%targetFolder%\!line!\"
        echo D|xcopy "%actualFolder%\!line!" "%targetFolder%\!line!\" /E
    )
)

:: Create a new file with actualDate folder
"%ProgramFiles%\7-Zip\7z.exe" a -t7z -r -w"%actualFolder%" "%actualFolder%\%localFileName%" "%actualDate%"

:: Delete actualDate folder
rmdir /s /q "%targetFolder%"

:: Move the file to Local folder
move "%actualFolder%\%localFileName%" "%localRoute%"

pause