#====== CONFIG DE ADDS ===========

#Installation d'Active Directory (AD DS)
# Lancer en PowerShell administrateur sur SRV-DC01, après 01-config-base.ps1.
# Le serveur redémarre à la fin de Install-ADDSForest : lancer les vérifications APRÈS le redémarrage.
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

#Installation du service DNS
Install-WindowsFeature DNS -IncludeManagementTools

#Test de prérequis
Test-ADDSForestInstallation -DomainName novatech.local -DomainNetbiosName NOVATECH -InstallDns

#Promotion de la forêt
Install-ADDSForest -DomainName novatech.local -DomainNetbiosName NOVATECH -InstallDns

#Vérifications

Get-ADDomain

dcdiag /q

net share

dcdiag.exe /test:sysvolcheck /test:advertising