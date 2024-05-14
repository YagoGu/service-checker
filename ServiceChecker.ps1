$ServicesFilePath="C:\Users\Administrator\Desktop\Projects\service-checker\Services.csv"
$LogPath="C:\Users\Administrator\Desktop\Projects\service-checker\Logs"
$LogFile="Services-$(Get-Date -Format "yyyy-MM-dd hh-mm").txt"
$ServicesList=Import-Csv -Path $ServicesFilePath -Delimiter ','

foreach($Service in $ServicesList){
    $CurrentServiceStatus=(Get-Service -Name $Service.Name).Status

    if($Service.Status -ne $CurrentServiceStatus){
        $Log="Service: $($Service.Name) is currently $CurrentServiceStatus, should be $($Service.Status)"
        Write-Output $Log
        <#This will create a new file in case it doesn't exist with that name
        and in case that it exists add a new line#>
        Out-file -FilePath "$LogPath\$LogFile" -Append -InputObject $Log

        $Log="Setting $($Service.Name) to $($Service.Status)"
        Write-Output $Log
        <#
        -Force paramter only works on powershell 7+
        #>
        Set-Service -Name $Service.Name -Status $Service.Status -Force
        Out-file -FilePath "$LogPath\$LogFile" -Append -InputObject $Log

        $AfterServiceStatus=(Get-Service -Name $Service.Name).Status
        if($Service.Status -eq $AfterServiceStatus){
            $Log="Action was succesful $($Service.Name) is now $AfterServiceStatus"
            Write-Output $Log
            Out-file -FilePath "$LogPath\$LogFile" -Append -InputObject $Log
        }
        else{
            <#In case that something went wrong#>
            $Log="Action failed $($Service.Name) is still $AfterServiceStatus, should be $($Service.Status)"
            Write-Output $Log
            Out-file -FilePath "$LogPath\$LogFile" -Append -InputObject $Log
        }
    }
}