# =========================
# Ianito Windows PowerShell Profile
# Target: Windows 11 (PowerShell 7+ recommended), non-admin unless noted
# =========================

function Get-Proxy (){
    Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' | Select-Object ProxyServer, ProxyEnable        
}

function Set-Proxy { 
    [CmdletBinding()]
    [Alias('proxy')]
    [OutputType([string])]
    Param
    (
        # server address
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        $server,
        # port number
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        $port    
    )
    #Test if the TCP Port on the server is open before applying the settings
    If ((Test-NetConnection -ComputerName $server -Port $port).TcpTestSucceeded) {
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyServer -Value "$($server):$($port)"
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyEnable -Value 1
        Get-Proxy #Show the configuration 
    }
    Else {
        Write-Error -Message "The proxy address is not valid:  $($server):$($port)"
    }    
}
function Remove-Proxy (){    
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyServer -Value ""
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyEnable -Value 0
}


# ----- Basic quality-of-life -----
Set-PSReadLineOption -EditMode Emacs -HistoryNoDuplicates:$true -PredictionSource History
Set-Alias which Get-Command
Set-Alias ll Get-ChildItem
Set-Alias la 'Get-ChildItem -Force'

# Pretty sizes for Get-ChildItem
function ls-h { Get-ChildItem @args | Select-Object Mode, LastWriteTime,
    Name, @{n='Length(GB)';e={ if($_.Length){ [math]::Round($_.Length/1GB,3) } }} }

# ----- Networking (Linux-ish shorthands) -----
function ipaddr {
    # IP/DNS/Gateway; objects for scripting
    Get-NetIPConfiguration
}
function netif {
    # Legacy dump (includes “Physical Address” = MAC)
    ipconfig /all
}
function macs {
    Get-NetAdapter | Select-Object Name,Status,MacAddress,LinkSpeed
}
function arptable { arp -a }

# ----- Storage (df/lsblk equivalents) -----
function disks { Get-Disk | Select-Object Number,FriendlyName,PartitionStyle,OperationalStatus,Size }
function physdisks { Get-PhysicalDisk | Select-Object FriendlyName,MediaType,Size,HealthStatus }
function parts { Get-Partition | Select-Object DiskNumber,PartitionNumber,DriveLetter,Size }
function volumes {
    Get-Volume | Select-Object DriveLetter,FileSystemType,FileSystemLabel,HealthStatus,SizeRemaining,Size
}
function dfw {
    # df -h style summary of file system drives
    Get-PSDrive -PSProvider FileSystem |
    Select-Object Name,
        @{n='Used(GB)';e={[math]::Round(($_.Used/1GB),2)}},
        @{n='Free(GB)';e={[math]::Round(($_.Free/1GB),2)}},
        @{n='Size(GB)';e={[math]::Round((($_.Used+$_.Free)/1GB),2)}}
}

# ----- WSL helpers -----
function wsl-list { wsl -l -v }
function wsl-distros { wsl --list --online }

function wsl-install-ubuntu {
<#
.SYNOPSIS
  Install latest LTS Ubuntu (24.04 at time of writing) on WSL2.
.NOTES
  Requires Windows 11; runs user-scoped. If WSL feature isn’t present,
  Windows will prompt or install it automatically.
#>
    wsl --set-default-version 2
    wsl --install -d Ubuntu-24.04
}

function wsl-enable-systemd {
<#
.SYNOPSIS
  Enables systemd inside the default WSL distro.
.NOTES
  Prompts for sudo inside the distro.
#>
    wsl -e bash -lc "set -e;
sudo mkdir -p /etc;
printf '[boot]\nsystemd=true\n' | sudo tee /etc/wsl.conf >/dev/null"
    wsl.exe --shutdown
    Write-Host "Systemd enabled. Start your distro again (e.g., 'wsl' or Ubuntu app)."
}

function wsl-open { explorer.exe "\\wsl$" }    # open WSL files in Explorer
function wsl-hosts {
    # quick hostnames/addresses seen by Windows
    Get-Content "$env:SystemRoot\System32\drivers\etc\hosts"
}

# ----- OpenSSH on Windows (server) -----
function ssh-enable {
<#
.SYNOPSIS
  Installs and enables the built-in OpenSSH Server, opens firewall.
.NOTES
  Run in an elevated (Admin) PowerShell session.
#>
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    Start-Service sshd
    Set-Service -Name sshd -StartupType Automatic
    if (-not (Get-NetFirewallRule -Name OpenSSH-Server-In-TCP -ErrorAction SilentlyContinue)) {
        New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' `
          -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 | Out-Null
    }
    Write-Host "OpenSSH Server installed and started."
}

function ssh-status {
    Get-Service sshd -ErrorAction SilentlyContinue | Format-Table Status,Name,StartType
    Test-NetConnection -ComputerName localhost -Port 22 | Select-Object ComputerName,RemotePort,TcpTestSucceeded
}

function ssh-setup-keys {
<#
.SYNOPSIS
  Ensures %USERPROFILE%\.ssh exists and opens authorized_keys in Notepad.
.NOTES
  Use correct NTFS ACLs; this helper sets minimal safe defaults.
#>
    $ssh = Join-Path $HOME ".ssh"
    $auth = Join-Path $ssh "authorized_keys"
    New-Item -ItemType Directory -Path $ssh -Force | Out-Null
    if (-not (Test-Path $auth)) { New-Item -ItemType File -Path $auth | Out-Null }
    # Lock down permissions to the owner
    icacls $ssh /inheritance:r /grant:r "$($env:USERNAME):(OI)(CI)F" | Out-Null
    icacls $auth /inheritance:r /grant:r "$($env:USERNAME):R" | Out-Null
    notepad $auth
    Write-Host "Paste your public key, save, then try: ssh $env:USERNAME@$(hostname)"
}

# ----- Convenience aliases mirroring Linux names (non-invasive) -----
Set-Alias ip a -ErrorAction SilentlyContinue  # placeholder to avoid muscle memory confusion
Set-Alias lsblk disks
Set-Alias df dfw
Set-Alias ifconfig netif

# ----- Version peek -----
function wver { $PSVersionTable; wsl -l -v 2>$null }

$ENV:HOME=$ENV:USERPROFILE
$ENV:USER=$ENV:USERNAME
$ENV:XDG_CONFIG_HOME=$ENV:USERPROFILE+"\.config"

Invoke-Expression (& "$ENV:HOME\scoop\shims\starship.exe" init powershell --print-full-init | Out-String)

#$proxy='http://127.0.0.1:16005'
#$ENV:HTTP_PROXY=$proxy
#$ENV:HTTPS_PROXY=$proxy
#$ENV:ALL_PROXY=$proxy

Write-Output "Setup..."
