function Clear-EdgeData {
    $edgeProcesses = @("msedge")

    # Stopping all running processes to make sure it's not running.
    foreach ($processName in $edgeProcesses) {
        Get-Process -Name $processName -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                $_.Kill()
                Write-Output "Killed $processName process: $($_.Id)"
            } catch {
                Write-Output "Failed to kill $processName process: $($_.Id)"
            }
        }
    }

    # Monitor the closure tasks.
    while ($true) {
        $runningProcesses = Get-Process -Name $edgeProcesses -ErrorAction SilentlyContinue
        if ($runningProcesses.Count -eq 0) {
            Write-Output "All $edgeProcesses processes have stopped."
            break
        } else {
            Write-Output "Waiting for $edgeProcesses processes to stop..."
            Start-Sleep -Seconds 1
        }
    }

    # Fetching current user home directory.
    $userHome = [System.Environment]::GetFolderPath('UserProfile')

    # Defined paths which will be targeted. Simply meaning, all files within folder will be removed, if possible.
    $edgePaths = @(
        "$userHome\AppData\Local\Microsoft\Edge\User Data\Default\Cache",
        "$userHome\AppData\Local\Microsoft\Edge\User Data\Default\Code Cache",
        "$userHome\AppData\Local\Microsoft\Edge\User Data\Default\GPUCache",
        "$userHome\AppData\Local\Microsoft\Edge\User Data\Default\Local Storage"
    )

    # Rolling over each defined path attemping to clear the contents if the directory exists.
    foreach ($path in $edgePaths) {
        if (Test-Path -Path $path) {
            $deleteCount = 0
            try {
                Get-ChildItem -Path $path -Recurse -Force | ForEach-Object {
                    try {
                        Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction Stop
                        $deleteCount++
                    } catch {
                        # If needed, for debugging.
                    }
                }
                if ($deleteCount -gt 0) {
                    Write-Output "Cleared contents of: $path"
                } else {
                    Write-Output "No content was cleared from: $path"
                }
            } catch {
                Write-Output "Failed to clear contents of: $path"
            }
        } else {
            Write-Output "No directory found at: $path"
        }
    }
}

Clear-EdgeData
