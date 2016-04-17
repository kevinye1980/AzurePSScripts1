#
# AzureARMP2SEx1.ps1
# This script is used to create a Point-To-Site connection to a ARM VMs.
# For classic VMs, you can leverage the old Azure Portal to do this
#
$VNetName  = "DevTest2VNet"
$FESubName = "FrontEnd"
$BESubName = "Backend"
$GWSubName = "GatewaySubnet"
$VNetPrefix1 = "192.168.0.0/16"
$VNetPrefix2 = "10.254.0.0/16"
$FESubPrefix = "192.168.6.0/24"
$BESubPrefix = "10.254.2.0/24"
$GWSubPrefix = "192.168.200.0/26"
$VPNClientAddressPool = "172.16.202.0/24"
$RG = "DevTest2RG"
$Location = "SouthEast Asia"
$DNS = "8.8.8.8"
$GWName = "GW"
$GWIPName = "GWIP"
$GWIPconfName = "gwipconf"
$P2SRootCertName = "ARMP2SRootCert.cer"

#Connect to Azure Subscription

#Login-AzureRmAccount

New-AzureRmResourceGroup -Name $RG -Location $Location

#Create virtual network w/ address space and subnets
#In this case, we're using a public DNS server. You can change it to your own DNS IP address
$fesub = New-AzureRmVirtualNetworkSubnetConfig -Name $FESubName -AddressPrefix $FESubPrefix
$besub = New-AzureRmVirtualNetworkSubnetConfig -Name $BESubName -AddressPrefix $BESubPrefix
$gwsub = New-AzureRmVirtualNetworkSubnetConfig -Name $GWSubName -AddressPrefix $GWSubPrefix
New-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $RG -Location $Location -AddressPrefix $VNetPrefix1,$VNetPrefix2 -Subnet $fesub, $besub, $gwsub -DnsServer $DNS

#Get gateway subnet
$vnet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $RG
$subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $GWSubName -VirtualNetwork $vnet

#create a public IP
$pip = New-AzureRmPublicIpAddress -Name $GWIPName -ResourceGroupName $RG -Location $Location -AllocationMethod Dynamic
$ipconf = New-AzureRmVirtualNetworkGatewayIpConfig -Name $GWIPconfName -Subnet $subnet -PublicIpAddress $pip

$MyP2SRootCertPubKeyBase64 = "MIIDAjCCAe6gAwIBAgIQVS2ed1LxKo1ELUhyno2NTTAJBgUrDgMCHQUAMBkxFzAVBgNVBAMTDkFSTVAyU1Jvb3RDZXJ0MB4XDTE2MDQxNzA1NDQ0MFoXDTM5MTIzMTIzNTk1OVowGTEXMBUGA1UEAxMOQVJNUDJTUm9vdENlcnQwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDSMNkOCQcQ97lMSpit3SzNHJnCLalyuznY7kVX5mkeucgz1VnClCRW6r6N+TDiXhplIdVNux0hfwgTfl6GQtocGTORHU/qgmaKPqbxisE3HSJUUKmhxmHQAFlJCNd48PYc9FD1eCAxDPjudBpK4ENCVvA5SnW4+eFdlhckkbdQaK2hHn7dCXku+wk6V737HNGllPVJy8nkQbG+unEM1xyibeLhwSxDF/H514rOjRH0t/r5mby/sxoRvr2R+WjVM5D06aDEFW8CXE3T96nbYWt908OI1ox1zMkPFBoMG93LT95PYEU58JC+wgW8Ky0HnqnFHzzat1gPcJPLAuXxpDLNAgMBAAGjTjBMMEoGA1UdAQRDMEGAEFZkycKS/tvDWSxI8v59evGhGzAZMRcwFQYDVQQDEw5BUk1QMlNSb290Q2VydIIQVS2ed1LxKo1ELUhyno2NTTAJBgUrDgMCHQUAA4IBAQBzQzwKDNnOiXlENJHIn/fP73PXLAdQBa15LHn/PGKqFCuN9BcyXWVXrE0NSVyMnmyq/4Fh645lGItmLcMQBlntHL26KfEXcPf2jDxSGw7dexkJ3EqrLr8Z3M88DA1J8Weys6aHKL17nJQTTC91QULeqjBnK/L31A8XeN1XBA0S3bM8Y3XMgHrN8yvDKF/q3/J+YNnUkt+l3nR1dO3uwye+0Y+A/NTxBXO/4Vz0Cn8fWEMgcbLvNcStTZtoyqBdcU+PV4iBwW6248rRHpCDA7zDmW5jp/pJjWJvFIGAc8xC6oJWaWF3y3SXiQwm40+3R8xz9RkqZ54ZdCXxtrZeirWR"
$p2srootcert = New-AzureRmVpnClientRootCertificate -Name $P2SRootCertName -PublicCertData $MyP2SRootCertPubKeyBase64

#Create virtual network gateway
$gw = New-AzureRmVirtualNetworkGateway -Name $GWName -ResourceGroupName $RG -Location $Location -IpConfigurations $ipconf -GatewayType Vpn -VpnType RouteBased -EnableBgp $false -GatewaySku Standard -VpnClientAddressPool $VPNClientAddressPool -VpnClientRootCertificates $p2srootcert
$gw
#Upload root certificate to Azure
#To get public key, you need to export root certificate into a .cer file without exporting private key. And then open it with any text editor. 
#$Text = Get-Content -Path "C:\Kevinye\Cloud\ARMP2SRootCert.cer"
#$MyP2SRootCertPubKeyBase64 = for ($i=1; $i -lt $Text.Length -1 ; $i++){$Text[$i]}

#Get VPN client download link
Get-AzureRmVpnClientPackage -ResourceGroupName $RG -VirtualNetworkGatewayName $GWName -ProcessorArchitecture Amd64

