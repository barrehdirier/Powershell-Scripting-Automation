# Function aiming to test the presence of needed module
[bool]$global:IfLoaded= $False
[bool]$global:IfAvailable= $False
function Test-PSModule{
    if ($(Get-Module | Where-Object {$_.Name -Like 'PSWindowsUpdate'})) {$global:IfLoaded=$True}
    else {if($(Get-Module -ListAvailable | Where-Object {$_.Name -Like 'PSWindowsUpdate'})){$global:IfAvailable=$True}}
}
Function Install-PSModule{
    if (-not $IfAvailable) {
        try {            
            #Installing NuGet with force
            #Install-PackageProvider -Name NuGet -Force
            # Setting Microsofts PSGallery to Trusted
            Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
            # Install PSWindowsUpdate Module
            Install-Module -Name PSWindowsUpdate -ErrorAction Stop
            # Sets InstalledModule file to 1, to indicate modules etc. are installed.
            Set-Content C:\AutoUpdates\InstalledModule.txt -Value "True"
        }
        catch {
            Write-Host "Error: $($_.Exception.Message)"
        }
    }else {
        <# Do nothing cause module Available #>
    }
}

function Import-PSModule {
    if ($IfAvailable) {
        Import-Module -Name PSWindowsUpdate
        Test-PSModule
    }    
}

function Install-PSWindowsUpdate {
    try {
        if ($IfLoaded) {
            if (Get-WindowsUpdate) {
                # Looking for updates
                Get-WindowsUpdate | Out-File C:\AutoUpdates\Log\Updates_"$((Get-Date).ToString('dd-MM-yyyy_HH.mm.ss'))".txt
        
                # Install updates 
                Install-WindowsUpdate -Install -AutoReboot -AcceptAll
            }
            else{
                throw "No update to this day" 
            }
        }
    }
    catch {
        Out-File C:\AutoUpdates\Log\Updates_"$((Get-Date).ToString('dd-MM-yyyy_HH.mm.ss'))".txt -Value "$($_.Exception.Message)" 
    }
    
}

#-------main program------------

Test-PSModule
Install-PSModule
Import-PSModule
Install-PSWindowsUpdate
