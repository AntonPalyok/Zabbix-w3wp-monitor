
# Get running application pools
$activePoolsInfo = Invoke-Expression "$env:windir\System32\inetsrv\appcmd.exe list wp"

#key = ApplicationPoolName
#value = ProcessId
$activePools = @{}

ForEach ($item in $activePoolsInfo) {
	$item -match "WP ""(\d+)"" \([^:]+:([^\)]+)\)" | Out-Null
	
	$activePools.Add($Matches[2], [int]$Matches[1])
}


# Get All running processes in the system using performance counter to obtain their instance names
# Note: Ignore errors, because it returns warning when some counters returns partial result
# e.g: some process started or was killed during counter collection.
$infoFromCounter = Get-Counter -ErrorAction SilentlyContinue -Counter "\Process(*)\ID Process" | 
	Select -Expand CounterSamples | 
	Select Path, CookedValue

# Create hashtable of process Id and it's instance name

#key = ProcessId
#value = ProcessName
$processesFromCounter = @{}

ForEach ($item in $infoFromCounter) {
	$processId = [int]$item.CookedValue
	
	# PID = 0 usually has "idle" and several "conhost"
	if ($processId -ne 0) {
		$item.Path -match "\\process\(([^\)]+)\)\\id process$" | Out-Null
		$processesFromCounter.Add($processId, $Matches[1])
	}
}

# Create final map of Application Pool Name and its Instance Name of the process.

$processes = New-Object System.Collections.ArrayList

ForEach ($pool in $activePools.Keys) {
	$processId = $activePools[$pool]
	
	$temp = [PSCustomObject]@{
		"ProcessId" = $processId
		"ApplicationPoolName" = $pool
		"InstanceName" = $processesFromCounter[$processId]
	}
	
	$processes.Add($temp) | Out-Null
}

# Return result in Zabbix Low-level Discovery format

Write-Host "{"
Write-Host "`t`"data`": ["

$index = 1
$separator = ","

ForEach ($item in $processes) {
	Write-Host "`t`t{"
	Write-Host "`t`t`t`"{#APP_POOL}`": `"$($item.ApplicationPoolName)`","
	Write-Host "`t`t`t`"{#INSTANCE_NAME}`": `"$($item.InstanceName)`""
	
	# don't write last comma
	if ($index -ge $processes.Count) {
		$separator = ""
	}

	Write-Host "`t`t}$separator"
	
	$index++
}

Write-Host "`t]"
Write-Host "}"
