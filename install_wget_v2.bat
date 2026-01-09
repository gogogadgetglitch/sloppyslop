@echo off
setlocal enabledelayedexpansion

echo ========================================
echo wget for Windows - Automatic Installer
echo ========================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script must be run as Administrator
    echo Please right-click and select "Run as administrator"
    pause
    exit /b 1
)

REM Set installation directory
set "INSTALL_DIR=%ProgramFiles%\wget"
set "WGET_URL=https://eternallybored.org/misc/wget/1.21.4/64/wget.exe"

echo Installing wget to: %INSTALL_DIR%
echo.

REM Create installation directory
if not exist "%INSTALL_DIR%" (
    echo Creating directory: %INSTALL_DIR%
    mkdir "%INSTALL_DIR%"
)

REM Download wget using PowerShell
echo Downloading wget.exe...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%WGET_URL%' -OutFile '%INSTALL_DIR%\wget.exe'}"

if not exist "%INSTALL_DIR%\wget.exe" (
    echo ERROR: Failed to download wget.exe
    pause
    exit /b 1
)

echo wget.exe downloaded successfully!
echo.

REM Add to system PATH using PowerShell (more reliable method)
echo Checking PATH variable...
set "PATH_TO_ADD=%INSTALL_DIR%"

REM Use PowerShell to modify the PATH
echo Adding wget to system PATH...
powershell -Command "& {$oldPath = [Environment]::GetEnvironmentVariable('Path', 'Machine'); if ($oldPath -notlike '*%PATH_TO_ADD%*') { $newPath = $oldPath + ';%PATH_TO_ADD%'; [Environment]::SetEnvironmentVariable('Path', $newPath, 'Machine'); Write-Host 'Successfully added to system PATH' } else { Write-Host 'wget directory is already in PATH' }}"

if %errorLevel% neq 0 (
    echo WARNING: PowerShell method failed, trying alternative method...
    
    REM Alternative method using reg add
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path /t REG_EXPAND_SZ /d "%PATH%;%PATH_TO_ADD%" /f >nul 2>&1
    
    if !errorLevel! equ 0 (
        echo Successfully added to PATH using registry method
    ) else (
        echo ERROR: Failed to add to PATH automatically
        echo.
        echo Please add the following directory to your PATH manually:
        echo %INSTALL_DIR%
        echo.
        echo Instructions:
        echo 1. Press Win + X and select "System"
        echo 2. Click "Advanced system settings"
        echo 3. Click "Environment Variables"
        echo 4. Under "System variables", select "Path" and click "Edit"
        echo 5. Click "New" and add: %INSTALL_DIR%
        echo 6. Click OK on all dialogs
    )
)

echo.
echo ========================================
echo Installation Complete!
echo ========================================
echo.
echo wget has been installed to: %INSTALL_DIR%
echo.
echo IMPORTANT: You may need to restart your command prompt
echo or PowerShell window for the PATH changes to take effect.
echo.
echo To test, open a NEW command prompt and type: wget --version
echo.
pause
