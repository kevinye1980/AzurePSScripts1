#
# ARMSamples.ps1
#
#Add ARM Account
#Login-AzureRmAccount

#Persist account info into disk so that you can load it into a new session without lauching login in window again
#Save-AzureRmProfile -Path AzureRmProfile.json
Select-AzureRmProfile -Path AzureRmProfile.json

#Test 1 - List out all the Azure Resource Providers
Write-Host "Fetching out Azure Resource Providers..."
Get-AzureRmResourceProvider | Select -ExpandProperty resourcetypes | Format-Table -Wrap -AutoSize ResourceTypeName

