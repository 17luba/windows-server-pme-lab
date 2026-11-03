#=========  CONFIG DES GPO =============

#Politique de mdp
Get-ADDefaultDomainPasswordPolicy
Set-ADDefaultDomainPasswordPolicy -Identity "novatech.local" -MinPasswordLength 12 -MaxPasswordAge 90.00:00:00 -LockoutThreshold 5 -LockoutDuration 00:30:00 -LockoutObservationWindow 00:30:00
Get-ADDefaultDomainPasswordPolicy

#Les autres GPO sont faites dans l'interface graphique