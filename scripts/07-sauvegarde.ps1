#========= SAUVEGARDES DES DONNEES =============

#Nouveau disque créé manuellement dans VirtualBox

#Initialisation du nouveau disk
Initialize-Disk -Number 1 -PartitionStyle GPT
New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter E
Format-Volume -DriveLetter E -FileSystem NTFS -NewFileSystemLabel "BACKUP"

#Installation du service de sauvegarde
Install-WindowsFeature Windows-Server-Backup -IncludeManagementTools

#Création du dossier et fichier de test
New-Item -ItemType Directory -Path C:\Donnees
"Fichier important - $(Get-Date)" | Out-File C:\Donnees\important.txt

#Lancement de sauvegarde à la main
wbadmin.exe start backup -backupTarget:E: -include:C:\Donnees -quiet
wbadmin.exe start systemstatebackup -backupTarget:E: -quiet


#******** SAUVEGARDE PLANIFIEE********

$arg     = "start systemstatebackup -backupTarget:E: -quiet"
$action  = New-ScheduledTaskAction -Execute "wbadmin.exe" -Argument $arg
$trigger = New-ScheduledTaskTrigger -Daily -At 21:00
Register-ScheduledTask -TaskName "Sauvegarde_SystemState" -Action $action -Trigger $trigger -User "SYSTEM" -RunLevel Highest
Get-ScheduledTask -TaskName "Sauvegarde_SystemState" | Select-Object TaskName, State, @{n="Compte";e={$_.Principal.UserId}}

#Test de recuperation après suppression d'un fichier
# wbadmin.exe get versions
# Remove-Item C:\Donnees\important.txt
# wbadmin.exe start recovery -version:<VERSION> -itemType:File -items:C:\Donnees -recursive -quiet
# Get-Content C:\Donnees\important.txt

