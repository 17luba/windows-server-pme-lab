#==== CONFIG SERVICE DNS ========

#Config de la zone (zone inverse)
Add-DnsServerPrimaryZone -NetworkId "192.168.10.0/24" -ReplicationScope "Domain"

Set-DnsServerPrimaryZone -Name "10.168.192.in-addr.arpa" -DynamicUpdate Secure

Register-DnsClient

Add-DnsServerResourceRecordA -ZoneName "novatech.local" -Name "srv-fichiers" -IPv4Address 192.168.10.20 -CreatePtr

Add-DnsServerResourceRecordCName -ZoneName "novatech.local" -Name "intranet" -HostNameAlias "srv-dc01.novatech.local"

#Vérifications

Resolve-DnsName srv-fichiers.novatech.local

Resolve-DnsName intranet.novatech.local

nslookup.exe 192.168.10.10 192.168.10.10