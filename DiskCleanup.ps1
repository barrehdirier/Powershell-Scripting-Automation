Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\*' | % {
    New-ItemProperty -Path $_.PSPath -Name StateFlags0001 -Value 2 -PropertyType DWord -Force};

# silently run with cleanup configuration to StateFlags0001 and with hidden Windows
Start-Process -FilePath CleanMgr.exe -ArgumentList '/sagerun:1' 