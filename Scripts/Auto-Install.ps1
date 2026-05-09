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
        "https://github.com/b4rtik/SharpKatz",
        "https://github.com/cube0x0/SharpSystemTriggers",
        "https://github.com/x64dbg/x64dbg",
        "https://github.com/forrest-orr/moneta",
        "https://github.com/tomcarver16/ADSearch",
        "https://github.com/sensepost/pipetap",
        "https://github.com/ZeroMemoryEx/Amsi-Killer",
        "--recursive https://github.com/hasherezade/pe-sieve",
        "--recursive https://github.com/hasherezade/pe-bear",
        "--recursive https://github.com/hasherezade/exe_to_dll",
        "--recursive https://github.com/hasherezade/pe_to_shellcode",
        "https://github.com/adrecon/AzureADRecon",
        "https://github.com/Mr-Un1k0d3r/AMSI-ETW-Patch",
        "https://github.com/V-i-x-x/AMSI-BYPASS",
        "https://github.com/GhostPack/Certify",
        "https://github.com/br-sn/CheekyBlinder",
        "https://github.com/AlessandroZ/LaZagne",
        "https://github.com/outflanknl/EvilClippy",
        "https://github.com/decoder-it/KrbRelayEx",
        "https://github.com/med0x2e/GadgetToJScript",
        "https://github.com/swisskyrepo/SharpLAPS",
        "https://github.com/tyranid/DotNetToJScript",
        "https://github.com/PowerShellMafia/PowerSploit",
        "https://github.com/hausec/PowerZure",
        "https://github.com/leoloobeek/LAPSToolkit",
        "https://github.com/S3cur3Th1sSh1t/Caro-Kann",
        "https://github.com/dafthack/MailSniper",
        "https://github.com/besimorhino/powercat",
        "https://github.com/itm4n/PrivescCheck",
        "https://github.com/NetSPI/PowerUpSQL",
        "https://github.com/PwnDexter/Invoke-EDRChecker",
        "https://github.com/ohpe/juicy-potato",
        "https://github.com/wavestone-cdt/EDRSandblast",
        "https://github.com/GhostPack/ForgeCert",
        "https://github.com/NationalSecurityAgency/ghidra",
        "https://github.com/cube0x0/MiniDump",
        "https://github.com/GhostPack/PSPKIAudit",
        "https://github.com/phra/PEzor",
        "https://github.com/rasta-mouse/PPEnum",
        "https://github.com/Idov31/Nidhogg",
        "https://github.com/itm4n/PPLcontrol",
        "https://github.com/itm4n/PPLdump",
        "https://github.com/mgeeky/ProtectMyTooling",
        "https://github.com/topotam/PetitPotam",
        "https://github.com/skahwah/SQLRecon",
        "https://github.com/GhostPack/Rubeus",
        "https://github.com/thefLink/Hunt-Sleeping-Beacons",
        "https://github.com/matterpreter/OffensiveCSharp",
        "https://github.com/logangoins/SharpSuccessor",
        "https://github.com/obfuscar/obfuscar",
        "https://github.com/ricardojoserf/NativeDump",
        "https://github.com/dnSpy/dnSpy",
        "https://github.com/GhostPack/Seatbelt",
        "https://github.com/med0x2e/SigFlip",
        "https://github.com/mdsecactivebreach/SharpShooter",
        "https://github.com/GhostPack/SharpUp",
        "https://github.com/Mayyhem/SharpSCCM",
        "https://github.com/CCob/SharpBlock",
        "https://github.com/GhostPack/SharpDPAPI",
        "https://github.com/mgeeky/Stracciatella",
        "https://github.com/FSecureLABS/SharpGPOAbuse",
        "https://github.com/G0ldenGunSec/SharpSecDump",
        "https://github.com/mandiant/SharPersist",
        "https://github.com/mgeeky/SharpWebServer",
        "https://github.com/GhostPack/SharpWMI",
        "https://github.com/SpecterOps/SharpHound",
        "https://github.com/PwnDexter/SharpEDRChecker",
        "https://github.com/PhrozenIO/SharpShellPipe",
        "https://github.com/FuzzySecurity/StandIn",
        "https://github.com/CCob/SweetPotato",
        "https://github.com/eladshamir/Whisker",
        "https://github.com/rasta-mouse/ThreatCheck",
        "https://github.com/eshard/obfuscator-llvm",
        "https://github.com/Neo23x0/signature-base",
        "https://github.com/elastic/protections-artifacts",
        "https://github.com/VirusTotal/yara",
        "https://github.com/fortra/nanodump",
        "https://github.com/0vercl0k/wtf",
        "https://github.com/0vercl0k/windbg-scripts",
        "https://github.com/AlessandroZ/LaZagne",
        "https://github.com/sensepost/ruler",
        "https://github.com/EgeBalci/deoptimizer",
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
