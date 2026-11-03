#====== CONFIG SERVICE DHCP ============

#Installations du service
Install-WindowsFeature DHCP -IncludeManagementTools

#Autorisation du serveur DHCP dans l'AD
Add-DhcpServerInDC -DnsName "srv-dc01.novatech.local" -IPAddress 192.168.10.10 

#Config de la plage d'adresse
Add-DhcpServerv4Scope -Name "LAN-NovaTech" -StartRange 192.168.10.100 -EndRange 192.168.10.200 -SubnetMask 255.255.255.0 -State Active

#Options distribuées aux clients (serveur DNS et domaine)
Set-DhcpServerv4OptionValue -ScopeId 192.168.10.0 -DnsServer 192.168.10.10 -DnsDomain "novatech.local"


#Vérifications
Get-DhcpServerInDC

Get-DhcpServerv4Scope

Get-DhcpServerv4OptionValue -ScopeId 192.168.10.0