Get-ADDomainController -Filter * |
     Select-Object Name, Domain, Forest, OperationMasterRoles |
     Where-Object {$_.OperationMasterRoles} |
     Format-Table -Wrap -AutoSize