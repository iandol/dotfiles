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

Invoke-Expression (& 'C:\Users\Ian\scoop\shims\starship.exe' init powershell --print-full-init | Out-String)

$proxy='http://127.0.0.1:16005'
$ENV:HTTP_PROXY=$proxy
$ENV:HTTPS_PROXY=$proxy
$ENV:ALL_PROXY=$proxy
$ENV:HOME=$ENV:USERPROFILE
$ENV:USER=$ENV:USERNAME
$ENV:XDG_CONFIG_HOME=$ENV:USERPROFILE+"\.config"

Write-Output "Welcome stranger..."