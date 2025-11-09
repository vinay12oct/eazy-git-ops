@echo off
echo ======================================================
echo 🔄 GitOps Script - Update account.yml with new tag
echo ======================================================

REM ---------------------------
REM Variables
REM ---------------------------
set "WORKSPACE=C:\ProgramData\Jenkins\.jenkins\workspace\account"
set "GITOPS_DIR=%WORKSPACE%\section9\kubernetes"
set "DEPLOYMENT_FILE=%GITOPS_DIR%\account.yml"
set "IMAGE_TAG=s%BUILD_NUMBER%"
set "GIT_REPO=git@github.com:vinay12oct/eazy-git-ops.git"
set "SSH_KEY=C:\ProgramData\Jenkins\.ssh\id_rsa"

echo.
echo 📁 GitOps Directory: %GITOPS_DIR%
echo 📄 Deployment File: %DEPLOYMENT_FILE%
echo 🏷️ Image Tag: %IMAGE_TAG%
echo.

REM ---------------------------
REM Debug Info
REM ---------------------------
echo 🔍 Current Directory: %CD%
echo 👤 Running as: %USERNAME%
echo 📅 Date/Time: %date% %time%
echo.

REM ---------------------------
REM Step 1: Ensure deployment file exists
REM ---------------------------
if not exist "%DEPLOYMENT_FILE%" (
    echo ❌ Deployment file not found!
    echo Expected path: %DEPLOYMENT_FILE%
    echo 🔍 Directory contents:
    dir "%GITOPS_DIR%"
    exit /b 1
)

REM ---------------------------
REM Step 2: Update account.yml with new image tag
REM ---------------------------
echo 🔄 Updating deployment file with tag %IMAGE_TAG%...
powershell -NoProfile -ExecutionPolicy Bypass ^
    "(Get-Content '%DEPLOYMENT_FILE%') -replace '(image:\s+vinay12oct/account:).*','$1%IMAGE_TAG%' | Set-Content '%DEPLOYMENT_FILE%'"
echo ✅ Updated %DEPLOYMENT_FILE% with tag %IMAGE_TAG%
echo.

REM ---------------------------
REM Step 3: Git commit and push
REM ---------------------------
cd "%GITOPS_DIR%" || exit /b 1
git config user.email "jenkins@example.com"
git config user.name "Jenkins CI"

git add "%DEPLOYMENT_FILE%"
git commit -m "Update account image to tag %IMAGE_TAG%" || echo ℹ️ No changes to commit

git -c core.sshCommand="ssh -i %SSH_KEY% -o StrictHostKeyChecking=no" push origin main
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Git push failed!
    exit /b 1
)

echo ======================================================
echo 🎉 account.yml updated and pushed successfully!
echo ======================================================
exit /b 0

