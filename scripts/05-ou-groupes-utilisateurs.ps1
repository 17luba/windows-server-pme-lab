#===== CONFIG DES OU - GROUPE UTILISATEURS ========

#Création des OU
foreach ($service in "Direction","Comptabilite","Informatique","Commercial") {
    New-ADOrganizationalUnit -Name $service -Path "DC=novatech,DC=local" -ProtectedFromAccidentalDeletion $false
}

#Création de OU
New-ADOrganizationalUnit -Name "Postes" -Path "DC=novatech,DC=local" -ProtectedFromAccidentalDeletion $false

#Création des groupes
foreach ($service in "Direction","Comptabilite","Informatique","Commercial") {
    New-ADGroup -Name "GRP_$service" -GroupScope Global -GroupCategory Security -Path "OU=$service,DC=novatech,DC=local"
}

#Création de mdp par defaut pour les comptes utilisateurs
$mdp = Read-Host "Mot de passe initial des comptes (labo)" -AsSecureString

#Création d'un utilisateur
New-ADUser -Name "Alice Martin" -GivenName "Alice" -Surname "Martin" -SamAccountName "amartin" -UserPrincipalName "amartin@novatech.local" -Path "OU=Direction,DC=novatech,DC=local" -AccountPassword $mdp -ChangePasswordAtLogon $true -Enabled $true

#Ajout d'un utilisateur à un groupe
Add-ADGroupMember -Identity "GRP_Direction" -Members "amartin"

#Ajout d'un titre à l'utilisateur
Set-ADUser -Identity amartin -Department "Direction" -Title "Directrice generale"

#Aperçu du CSV
Import-Csv -Path C:\Lab\utilisateurs.csv

#Ajout des utilisateur dans leur groupe en suivant le fichier .csv
Import-Csv -Path C:\Lab\utilisateurs.csv | ForEach-Object {
    New-ADUser -Name "$($_.Prenom) $($_.Nom)" -GivenName $_.Prenom -Surname $_.Nom `
      -SamAccountName $_.Login -UserPrincipalName "$($_.Login)@novatech.local" `
      -Title $_.Poste -Department $_.Service -Path "OU=$($_.Service),DC=novatech,DC=local" `
      -AccountPassword $mdp -ChangePasswordAtLogon $true -Enabled $true
    Add-ADGroupMember -Identity "GRP_$($_.Service)" -Members $_.Login
}

#Vérifications
Get-ADGroup -Filter "Name -like 'GRP_*'" | Select-Object Name, DistinguishedName

Get-ADUser amartin -Properties MemberOf | Select-Object Name, Enabled, MemberOf

Get-ADUser -Filter * -Properties Department | Select-Object Name, SamAccountName, Department

Get-ADGroupMember -Identity GRP_Comptabilite | Select-Object Name

#A lancer APRÈS la jonction de PC-CLIENT01 au domaine
Get-ADComputer PC-CLIENT01 | Move-ADObject -TargetPath "OU=Postes,DC=novatech,DC=local"
redircmp "OU=Postes,DC=novatech,DC=local"

#Vérification
Get-ADComputer -Filter * | Select-Object Name, DistinguishedName





