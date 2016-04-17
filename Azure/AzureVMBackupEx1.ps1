#
# AzureVMBackupEx1.ps1
#
# When Azure backup is used at the first time, you need to register the Azure
# Backup provider to be used with your subscription. 
Register-AzureRmResourceProvider -ProviderNamespace "Microsoft.Backup"

#Create backup vault
$resourceGroupName = "AzureResourceGroup1"
$backupVault = New-AzureRmBackupVault -ResourceGroupName $resourceGroupName -Name "kevbackup-vault" -Region "southeastasia" -Storage LocallyRedundant

#Registering the VMs
$VMName = "<Your VM Name>"
$serviceName = "<VM Cloud Service Name>"
#At the moment it doesn't support to create Azure recovery service (public preview) to backup ARM VM
$registerJob = Register-AzureRmBackupContainer -Vault $backupVault -ServiceName $serviceName -Name $VMName