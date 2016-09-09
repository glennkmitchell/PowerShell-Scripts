<#
    Name:Inactive Computer Report Generator
    Version:v0.2a
    Author: Glenn Mitchell
    Purpose:This script pulls a list of computers from AD and compiles a list of computers that have not logged in for
    more than xx days. The output of this report is in CSV format.
#>

# ==== START USER CONFIGURED SECTION ====

# How many days since the last login to be considered inactive
$inactiveThreshold = 90

# ==== END USER CONFIGURED SECTION ====

# make sure the AD module is available

# Output to console
Write-Host 'Attempting to import the AD module... ' -NoNewline

# Import the AD module. This is required.
Import-Module  -Name ActiveDirectory

# Output to console
Write-Host -Object 'Complete.'

# Get the current date in short date format 
$currentDate = Get-Date -Format 'HHmm ddMMyyyy'

# The filename of the resultant CSV file
$filename = "Inactive Computer Report - $currentDate.csv"

# Inactive date / last login date threshold
$inactiveDate = (Get-Date).AddDays(-($inactiveThreshold))

# Output to console
Write-Host  -Object 'Getting list of all inactive computers from AD'

# Get a list of the computers that have not logged in since the inactiveDate, we need to specify the LastLogonTimeStamp
# as a property as it is not normally included in the returned object detail
$inactiveComputers = Get-ADComputer -Filter {
    (LastLogonTimeStamp -lt $inactiveDate) -and !(OperatingSystem -like "*server*") 
} -Properties *

# Create the output that will contain each of the details of the inactive computers
$finalOutput = @()

# Loop through each of the computers and pull the name and last logon time, add it to an new object and put it in the output
# Write out these details to the console as well, this will keep the user informed
Foreach($computer in $inactiveComputers)
{
    #Get the computer name
    $computerName = $computer.Name
    
    # Get the date and time the computer last logged in
    #$lastLogonTime = [DateTime]::FromFileTime($computer.lastLogonTimeStamp)
    $lastLogonDate = ($computer.LastLogonDate)

    # Check if the computer is currently online
    $computerOnline = Test-Connection -ComputerName $computerName -Quiet -Count 1

    # create a new object that will hold the data
    $outputItem = New-Object -TypeName PSObject

    # copy the details of the object into the 
    $outputItem = $computer.psobject.Copy()

    # Add property to indicate if the device is currently online or not
    $outputItem | Add-Member -MemberType NoteProperty -Name 'Host Online' -Value $computerOnline -Force


    # Output the details to the console
    "Host: {0,-30} Last Logon: {1}" -f $computerName, $lastLogonDate

    # Add the item to the final output
    $finalOutput += $outputItem
}

# Output to console
Write-Host  -Object "Finalising and exporting report to file: $filename"

# Export to CSV
$finalOutput | Export-Csv -Path $filename -NoTypeInformation
