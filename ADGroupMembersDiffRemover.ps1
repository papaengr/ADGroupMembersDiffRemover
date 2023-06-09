$group1 = 'ABCGroup1'
$group2 = 'ABCGroup2'
$outFile = 'DiffResults.csv'

$group1Members = Get-ADGroup -Identity $group1 -Property members -ErrorAction Stop | Select-Object -ExpandProperty members
$group2Members = Get-ADGroup -Identity $group2 -Property members -ErrorAction Stop | Select-Object -ExpandProperty members
$bothMembers = Compare-Object -ReferenceObject $group1Members -DifferenceObject $group2Members -ExcludeDifferent -IncludeEqual -PassThru

If ($bothMembers) {
    Remove-ADGroupMember -Identity $group2 -Members $bothMembers -Confirm:$false -ErrorAction Stop
    $bothMembers | Set-ADUser -Enabled $true -Verbose
    $bothMembers | Get-ADObject -Property SamAccountName |
        Select-Object -Property SamAccountName, DistinguishedName, @{n='RemovedFrom'; e={$group2}} |
        Export-Csv -NoTypeInformation -Path $outFile
} Else {
    Write-Warning "Found no members both in '$($group1)' and in '$($group2)'."
    Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
}
