# Import AD module
Import-Module ActiveDirectory;

# Get a list of the computers from AD and out put to csm in current path
Get-ADComputer -Filter * -Properties * | Select-Object * | Export-Csv -Path 'All AD Computer Objects.csv' -NoTypeInformation;
