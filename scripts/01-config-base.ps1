#======= CONFIG DE BASE DU SERVEUR =======

#Ajout de l'adresse au serveur
New-NetIPAddress -InterfaceAlias Ethernet -IPAddress 192.168.10.10 -PrefixLength 24

#Ajout de l'adresse DNS
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 192.168.10.10

#Renommage du serveur
Rename-Computer -NewName SRV-DC01 -Restart