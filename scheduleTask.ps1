param (
    [string]$TaskName, # Name Of the task
    [string]$ScriptPath, # Path to the powershell script
    [string]$TriggerType,# The type of trigger for the scheduled task. Supported values are "Daily", "Weekly", and "Once".
    [int]$Interval, # (For "Weekly" trigger type) The interval in weeks between task runs. Default is 1.
    [string[]]$DaysOfWeek, # in this format @("Monday", "Thursday"), multiple days can be specified
    [string]$StartTime
)

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -File `"$ScriptPath`""

switch ($TriggerType) {
    'Daily' {
        $trigger = New-ScheduledTaskTrigger -Daily -At $StartTime
    }
    'Weekly' {
        if ($DaysOfWeek -isnot [array]) {
            Write-Host "The 'DaysOfWeek' parameter must be an array of day names for weekly execution."
            return
        }
        $trigger = New-ScheduledTaskTrigger -Weekly -At $StartTime -WeeksInterval $Interval -DaysOfWeek $DaysOfWeek
    }
    'Once' {
        $trigger = New-ScheduledTaskTrigger -Once -At $StartTime
    }
    default {
        Write-Host "Invalid trigger type. Supported values are: Daily, Weekly, Once."
        return
    }
}

$settings = New-ScheduledTaskSettingsSet

Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Description "Scheduled task: $TaskName" -RunLevel Highest
