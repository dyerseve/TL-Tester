<#Begin Header#>
#requires -version 2
<#
.SYNOPSIS
  This script takes an EXE and copies it into every path in the system until it can find one that allows it to execute
.DESCRIPTION
  <Brief description of script>
.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>
.INPUTS
  None
.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>
.NOTES
  Version:        1.0
  Author:         Phil Ellis
  Creation Date:  2022-08-01
  Purpose/Change: Initial script development
  
.EXAMPLE
  .\tl-footholdfinder.ps1
#>
<#End Header#>

<#Script Specific Variables#>

<#Common Starter & Code Blocks#>

#current script directory
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
#current script name
$path = Get-Location
$scriptName = $MyInvocation.MyCommand.Name
$scriptLog = "$scriptPath\log\$scriptName.log"

#stop extra transcripts
try { Stop-Transcript | out-null } catch { }

#start a transcript file
try { Start-Transcript -path $scriptLog } catch { }

# TimeStamps
$Date = Get-Date -format "yyyy-MM-dd"
$Time = Get-Date -format "yyyy-MM-dd-hh-mm-ss"

<#Functions#>
<#Abort#>
Function Abort {
    #Close all open sessions
    try
    {
        Remove-PSSession $Session
    }
    catch
    {
        #Just suppressing Error Dialogs
    }

    Get-PSSession | Remove-PSSession
    #Close Transcript log
    try { Stop-Transcript | out-null } catch { }
    Exit
}

#checks if powershell is in Administrator mode, if not powershell will fix it  
<#Run-AsAdmin#>
Function Run-AsAdmin
{
	if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {     
		$arguments = "& '" + $myinvocation.mycommand.definition + "'"  
		Start-Process powershell -Verb runAs -ArgumentList $arguments  
		Break  
	}
}
#Example
#Run-AsAdmin

<#Pause#>
#Pause alternative, works when the other doesn'temp
Function Pause
{
    write-host "Press any key to continue..."
    [void][System.Console]::ReadKey($true)
}

<# Begin Program #>
Run-AsAdmin
$filename = "fitTLtest.exe"
$srcfile = "$scriptPath\$filename"
write-host $srcfile
$destdir = Get-ChildItem -Path (Read-Host -Prompt 'Enter the full name of the directory you want to copy to') -Directory -Recurse

foreach ($dir in $destdir){
    try
    {
        Copy-Item $srcfile $dir.FullName
    }
    Catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Debug "Error $ErrorMessage occurred on Item $FailedItem"
        Stop-Transcript
        Break
    }
    $destfilename = $dir.FullName + "\$filename"
    Write-Host "Attempting to run $destfilename"
    try
    {
        Start-Process -FilePath $destfilename -Wait
    }
    Catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Debug "Error $ErrorMessage occurred on Item $FailedItem"
        #Stop-Transcript
        #Break
    }
    Write-Host "Deleting $destfilename"
    try
    {
       Remove-Item $destfilename -Force
    }
    Catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Debug "Error $ErrorMessage occurred on Item $FailedItem"
        #Stop-Transcript
        #Break
    }
    
    #Pause
}

<# End Program #>

<#Begin Footer#>
Abort
<#End Footer#>