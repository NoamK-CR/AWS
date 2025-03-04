
if (Test-Path -Path "C:\Rclone\Rclone") {

    Write-Host "S3 Mount already exists!" -BackgroundColor "Red" -ForegroundColor "DarkRed"
}

else { ##Transfering Data from AWS S3 to the target path.

    New-Item -ItemType Directory -Path C:\Rclone\Rclone 

    # Insert the AWS S3 URL for the deployment of the configuration files and installation files. 
    # In place of "<S3 URL>" insert the files path URLs from your deplyment S3 Bucket.  
    # The script pulls the Rclone start script, installation exe and config file from S3 bucket to the destinations machine.  
    
    Invoke-WebRequest -Uri https://<S3 URL>.amazonaws.com/rclone/rclone.ps1 -OutFile "C:\Rclone\Rclone.ps1" # starting file
    
    Invoke-WebRequest -Uri https://<S3 URL>.amazonaws.com/rclone/rclone/rclone.1 -OutFile "C:\Rclone\Rclone\rclone.1" # Rclone settings file
    
    Invoke-WebRequest -Uri https://<S3 URL>.amazonaws.com/rclone/rclone/rclone.exe -OutFile "C:\Rclone\Rclone\rclone.exe" # Installation exe
   
    Invoke-WebRequest -Uri https://<S3 URL>.amazonaws.com/rclone/rclone/rclone.conf -OutFile "C:\Rclone\Rclone\rclone.conf" # Costume configuration file 

    Write-Host "Configuration Files had been deployed!" -ForegroundColor "Yellow" -BackgroundColor "DarkGreen"
}
    if (!(Test-Path -Path"C:\Program Files (x86)\WinFsp")) {

        # Insert the AWS S3 URL for the deployment and installation of WinFsp MSI.
        # Put your deployment S3 URL IN PLACE OF <S3 URL> !!
        ## Transfering and installing Winfsp.msi on the target system.
        Invoke-WebRequest -Uri https://<S3 URL>.amazonaws.com/winfsp-1.10.22006.msi -OutFile "C:\Windows\Temp\winfsp-1.10.22006.msi"

        ## Installing WinFsp setup. 
        $MSIInstaller = "C:\Windows\Temp\winfsp-1.10.22006.msi"
        $ArgumentList = "/I $MSIInstaller /qn"

        Start-Process "msiexec.exe" -ArgumentList $ArgumentList -Wait

        Write-Host "WinFsp has been installed!" -ForegroundColor "Yellow" -BackgroundColor "DarkGreen"
    }

    else {
        
        Write-Host "WinFsp already installed!" -BackgroundColor "Red" -ForegroundColor "DarkRed"
    }

if (Get-ScheduledTaskInfo -TaskName "Rclone") {

    Write-Host "Task alredy exists!" -BackgroundColor "Red" -ForegroundColor "DarkRed"
    
    break
}

else {
   
    ## Create a new task action
    $Action = New-ScheduledTaskAction `
        -Execute 'powershell.exe' `
        -Argument '-WindowStyle hidden -file C:\Rclone\Rclone.ps1'

    ## Create a new trigger (At LogOn)
    $Trigger = New-ScheduledTaskTrigger -AtLogOn

    ## The name & Description of the scheduled task.
    $TaskName = "Rclone"
    $Description = "Map AWS S3 to Windows Network Drive"

    ## Set the task principal's user ID and run level.
    $TaskPrincipal = New-ScheduledTaskPrincipal -UserId "LOCALSERVICE" -LogonType ServiceAccount

    ## Set the task compatibility value to Windows 7.
    $Compatibility = New-ScheduledTaskSettingsSet -Compatibility Win7

    ## Register the scheduled task
    Register-ScheduledTask `
        -TaskName $TaskName `
        -Action $Action `
        -Trigger $Trigger `
        -Description $description `
        -User "System" `
    
    ## Set vadditional settings.
    Set-ScheduledTask -TaskName $TaskName -Settings $Compatibility -Principal $TaskPrincipal
    
    Write-Host "Task Installed!" -ForegroundColor "Yellow" -BackgroundColor "DarkGreen"
    
    break
}
