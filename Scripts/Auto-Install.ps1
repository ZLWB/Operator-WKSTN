$admin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($admin) {
    Write-Host "You are already administrator - We continue Installation !" -ForegroundColor green
}
else {
    throw "It's necessary to run the script with administrator privileges !"
    exit
}

function SetupAll {
    $toolsPath = "C:\\Tools"
    $payloadsPath = "C:\\Payloads"
    $gitRepoList = @(
        "https://github.com/tevora-threat/SharpView",
        # ... (liste inchangée) ...
        "https://github.com/0vercl0k/rp"
    )

    function Download-File {
        param (
            [string]$Url,
            [string]$OutputPath
        )
        Invoke-WebRequest -Uri $Url -OutFile $OutputPath -UseBasicParsing
    }

    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey Installation..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    } else {
        Write-Host "Chocolatey already installed."
    }

    if (-not (Test-Path -Path $toolsPath)) {
        Write-Host "Creation of folder $toolsPath..."
        New-Item -Path $toolsPath -ItemType Directory | Out-Null
    }

    if (-not (Test-Path -Path $payloadsPath)) {
        Write-Host "Creation of folder $payloadsPath..."
        New-Item -Path $payloadsPath -ItemType Directory | Out-Null
    }

    Write-Host "Adding $toolsPath and $payloadsPath in Windows Defender exclusion..."
    Add-MpPreference -ExclusionPath $toolsPath
    Add-MpPreference -ExclusionPath $payloadsPath

    Write-Host "Tools installation with chocolatey..."
    choco install git.install -y
    choco install spice-agent -y
    choco install processhacker.install -y
    choco install visualstudio2022community --params "--add Microsoft.VisualStudio.Workload.NativeDesktop --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.CoreEditor --no-includeRecommended" -y

    $msbuildPath = (reg query "HKLM\\SOFTWARE\\Microsoft\\MSBuild\\ToolsVersions\\4.0" /v MSBuildToolsPath) -match "REG_SZ\\s+(.+)" | Out-Null
    $msbuildExe = "$matches[1]MSBuild.exe"

    if (-not (Test-Path $msbuildExe)) {
        Write-Host "MSBuild not found in registry hive... Checking in Visual Studio Folder..."
        $msbuildExe = "C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\MSBuild\\Current\\Bin\\MSBuild.exe"

        if (-not (Test-Path $msbuildExe)) {
            Write-Host "MSBuild not found in Visual Studio folder. Is Visual Studio installed?"
        }
    }

    & "C:\\Program Files (x86)\\Microsoft Visual Studio\\Installer\\setup.exe" modify `
    --installPath "C:\\Program Files\\Microsoft Visual Studio\\2022\\Community" `
    --config "a:\\.vsconfig" `
    --passive --norestart

    foreach ($repo in $gitRepoList) {
        $recursiveFlag = ""
        if ($repo -match "^--recursive\s") {
            Write-Host "Recursive cloning $repo"
            $recursiveFlag = "--recursive"
            $repo = $repo -replace "^--recursive\s", ""
        }

        $repoName = ($repo -split "/")[-1].Replace(".git", "")
        $repoPath = Join-Path -Path $toolsPath -ChildPath $repoName

        if (-not (Test-Path -Path $repoPath)) {
            Write-Host "Folder creation $repoPath for repo: $repoName..."
            New-Item -Path $repoPath -ItemType Directory | Out-Null
        }

        Push-Location "C:\\Program Files\\Git\\cmd"
        Write-Host "Cloning $repo into $repoPath..."
        & ./git.exe clone $recursiveFlag $repo $repoPath
        Pop-Location
    }

    Add-MpPreference -ExclusionPath "C:\\Users\\vagrant\\source"
    Write-Host "Tools installation completed successfully!" -ForegroundColor Green
}

SetupAll
