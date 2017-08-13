function Set-AdaptivaServer
{
    Param(
        $Server
    )

    # Define which keys to update
    $RegPathAdaptivaClient = 'HKLM:\SOFTWARE\Wow6432Node\Adaptiva\Client'
    $ClientKeyServerName = 'server_locator.server_name' 
    $ClientKeyServerHostName = 'setup.server_host_name'
    $ClientKeyInactive = 'client_data_manager.inactivated_client'
    $ClientKeyMigrate = 'client_data_manager.migrated_client'

    # Find the path to AdaptivaServiceRestart.exe
    $InstallPath = Get-ItemPropertyValue -Path $RegPathAdaptivaClient -Name 'slm.installation_path'
    $RestartExeChildPath = '\bin\AdaptivaServiceRestart.exe'
    $RestartExePath = Join-Path -Path $InstallPath -ChildPath $RestartExeChildPath

    # Update the servername in registry
    Set-ItemProperty -Path $RegPathAdaptivaClient -Name $ClientKeyServerName -Value $Server
    Set-ItemProperty -Path $RegPathAdaptivaClient -Name $ClientKeyServerHostName -Value $Server

    # Set keys to notify Adaptiva to migrate at next service start
    Set-ItemProperty -Path $RegPathAdaptivaClient -Name $ClientKeyInactive -Value ''
    Set-ItemProperty -Path $RegPathAdaptivaClient -Name $ClientKeyMigrate -Value 'true'

    # Restart the AdaptivaClient service
    $Result = Start-Process -FilePath $RestartExePath -ArgumentList " 10 AdaptivaClient" -PassThru
    $Result.ExitCode
}