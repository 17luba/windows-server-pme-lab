\# Infrastructure Windows Server d'une PME (NovaTech) – projet de laboratoire



Mise en place, dans un laboratoire virtuel, de l'infrastructure Windows d'une petite entreprise fictive : contrôleur de domaine Active Directory, DNS, DHCP, stratégies de groupe et sauvegarde. Les commandes sont écrites en PowerShell et regroupées dans `scripts/`.



\## Contexte



NovaTech SARL est une PME fictive de 20 salariés répartis en quatre services (Direction, Comptabilité, Informatique, Commercial). Elle n'a aucune gestion centralisée : postes hors domaine, adresses IP saisies à la main, aucune règle de sécurité commune, aucune sauvegarde.



Ma mission d'administrateur système : centraliser les comptes et les postes, appliquer des règles de sécurité et protéger les données. Le laboratoire simule l'entreprise avec un serveur et un poste client.



\## Architecture



Tout tourne dans VirtualBox, sur un réseau interne isolé nommé `LAB-NOVA` (192.168.10.0/24), sans accès à Internet.



| Machine | Rôle | Système | Adresse IP |

|---|---|---|---|

| `SRV-DC01` | Contrôleur de domaine : AD DS, DNS, DHCP, sauvegarde | Windows Server 2022 | 192.168.10.10 (fixe) |

| `PC-CLIENT01` | Poste utilisateur, membre du domaine | Windows 10 | DHCP (plage .100 à .200) |



Domaine : `novatech.local` (nom NetBIOS : `NOVATECH`).



\## Ce qui a été réalisé



\- \[x] Installation et configuration de base du serveur (IP fixe, nom, DNS)

\- \[x] Active Directory : création du domaine `novatech.local`

\- \[x] DNS : zone directe et zone inverse, enregistrements A, CNAME et PTR

\- \[x] DHCP : serveur autorisé dans l'AD, étendue, options DNS et domaine

\- \[x] OU, groupes de sécurité et 6 utilisateurs (dont 5 créés depuis un fichier CSV)

\- \[x] GPO : politique de mot de passe, blocage du Panneau de configuration, blocage des supports USB

\- \[x] Poste client joint au domaine et GPO vérifiées avec `gpresult`

\- \[x] Sauvegarde et test de restauration avec Windows Server Backup

\- \[ ] Audit de sécurité du laboratoire (Kali Linux, Nmap, Wireshark) : à venir



\## Étapes détaillées



\### 1. Configuration de base du serveur

Le serveur reçoit un nom (`SRV-DC01`) et une adresse IP fixe, et il est son propre serveur DNS, ce dont l'Active Directory a besoin pour s'installer.

Script : \[`scripts/01-config-base.ps1`](scripts/01-config-base.ps1)



!\[ipconfig](docs/captures/01-ipconfig-all.png)



\### 2. Active Directory

Installation des rôles AD DS et DNS, test des prérequis, puis promotion du serveur en contrôleur du domaine `novatech.local`. Vérification avec `Get-ADDomain` et `dcdiag`, et contrôle des partages `SYSVOL` et `NETLOGON`.

Script : \[`scripts/02-ad-ds.ps1`](scripts/02-ad-ds.ps1)



!\[Get-ADDomain](docs/captures/02-get-addomain.png)



\### 3. DNS

Création de la zone inverse, d'un enregistrement A (`srv-fichiers`), d'un alias CNAME (`intranet`) et activation des mises à jour dynamiques sécurisées pour que les machines enregistrent leur pointeur (PTR).

Script : \[`scripts/03-dns.ps1`](scripts/03-dns.ps1)



!\[Résolution DNS](docs/captures/03-resolve-dnsname.png)



\### 4. DHCP

Le serveur DHCP est autorisé dans l'AD, puis une étendue `LAN-NovaTech` distribue les adresses 192.168.10.100 à 192.168.10.200, avec le serveur DNS et le nom de domaine.

Script : \[`scripts/04-dhcp.ps1`](scripts/04-dhcp.ps1)



!\[Étendue DHCP](docs/captures/04-dhcp-scope.png)



\### 5. OU, groupes et utilisateurs

Quatre OU (une par service) plus une OU `Postes` pour les ordinateurs, un groupe de sécurité `GRP\_<service>` par OU, un utilisateur créé à la main puis cinq autres depuis un fichier CSV avec une boucle PowerShell. Le mot de passe initial est demandé à l'exécution : aucun mot de passe n'est stocké dans ce dépôt.

Script : \[`scripts/05-ou-groupes-utilisateurs.ps1`](scripts/05-ou-groupes-utilisateurs.ps1) – données : \[`scripts/utilisateurs.csv`](scripts/utilisateurs.csv)



!\[OU et utilisateurs](docs/captures/05-aduc-ou-utilisateurs.png)



\### 6. Stratégies de groupe (GPO)

\- \*\*Politique de mot de passe\*\* du domaine : 12 caractères minimum, expiration à 90 jours, verrouillage du compte après 5 essais pendant 30 minutes (avant : 7 caractères, 42 jours, aucun verrouillage).

\- \*\*`GPO\_Bloquer\_PanneauConfig`\*\* : interdit le Panneau de configuration. Liée aux OU Direction, Comptabilite et Commercial, pas à Informatique.

\- \*\*`GPO\_Bloquer\_USB`\*\* : refuse l'accès aux supports amovibles (configuration ordinateur). Liée à l'OU Postes.



La politique de mot de passe est dans \[`scripts/06-gpo.ps1`](scripts/06-gpo.ps1). Les deux autres GPO ont été créées dans la console \*Gestion de stratégie de groupe\* (clic droit sur l'OU, « Créer un objet GPO dans ce domaine, et le lier ici »).



!\[GPO](docs/captures/06-gpmc-arborescence.png)



\### 7. Poste client

`PC-CLIENT01` reçoit son adresse par DHCP, rejoint le domaine et est déplacé dans l'OU `Postes`. Les tests confirment que le Panneau de configuration est bloqué pour un utilisateur de la Direction et que les GPO s'appliquent (`gpresult /r`).



!\[gpresult](docs/captures/07-gpresult.png)



\### 8. Sauvegarde et restauration

Un second disque virtuel (`E:`, étiqueté `BACKUP`) reçoit les sauvegardes de Windows Server Backup : un dossier de test, puis l'état du système (qui contient l'Active Directory). La sauvegarde de l'état du système est planifiée chaque jour à 21 h avec une tâche exécutée sous le compte `SYSTEM`. J'ai testé la restauration : fichier supprimé, puis restauré depuis la sauvegarde.

Script : \[`scripts/07-sauvegarde.ps1`](scripts/07-sauvegarde.ps1)



!\[Restauration](docs/captures/08-restauration-ok.png)



\## Difficultés rencontrées



| Problème | Cause | Solution |

|---|---|---|

| Aucune carte réseau dans Windows Server | Type d'adaptateur VirtualBox (Intel PRO/1000 T Server) sans pilote dans Windows Server 2022 | Passage à Intel PRO/1000 MT Desktop |

| Création de la zone DNS inverse refusée | Identifiant réseau saisi avec l'adresse d'une machine (`192.168.10.10/24`) | Utiliser l'adresse du réseau : `192.168.10.0/24` |

| `nslookup` ne trouvait pas le nom de l'adresse | Aucun enregistrement PTR : la zone inverse n'acceptait pas les mises à jour dynamiques | `Set-DnsServerPrimaryZone -DynamicUpdate Secure` puis `Register-DnsClient` |

| Mot de passe refusé à la première connexion d'un utilisateur | La règle de complexité interdit d'inclure le nom du compte dans le mot de passe | Choix d'une phrase de passe sans le nom ni le prénom |

| Tâche planifiée créée avec le mauvais compte | Retour à la ligne au milieu de la commande : `-User "SYSTEM"` n'a pas été pris en compte | Suppression avec `Unregister-ScheduledTask` puis recréation sur une seule ligne |

| Boucle PowerShell du CSV en erreur | Backticks de continuation de ligne oubliés | Ajout des backticks et vérification de la syntaxe avec `Parser::ParseFile` |



\## Ce que j'ai appris



\*J’ai appris à administrer Windows Server en PowerShell plutôt qu’avec l’interface : en trouvant les commandes avec Get-Command -Syntax, puis en les regroupant dans des scripts, j’ai pu créer cinq utilisateurs d’un seul coup depuis un fichier CSV.



J’ai compris que l’Active Directory ne fonctionne pas sans le DNS : le DNS contient les enregistrements qui permettent à un poste de trouver le contrôleur de domaine. C’est pour ça que le serveur est son propre serveur DNS, et que le DHCP donne cette adresse aux postes. J’ai aussi vu qu’il faut une zone inverse avec des enregistrements PTR pour que nslookup retrouve un nom à partir d’une adresse



J’ai appris qu’une GPO se lie à une OU et s’applique à tous les objets qu’elle contient, ce qui évite de configurer chaque poste à la main. Il y a deux types de réglages : ceux de l’utilisateur, comme le blocage du Panneau de configuration, qui le suivent sur n’importe quel poste, et ceux de l’ordinateur, comme le blocage des clés USB, qui s’appliquent à la machine quel que soit l’utilisateur. J’ai vérifié leur application avec gpresult.



J’ai pris des instantanés de la machine virtuelle avant les opérations risquées, comme la promotion en contrôleur de domaine : si ça se passait mal, je pouvais revenir à l’état précédent en deux clics. Mais j’ai compris que ce n’est pas une sauvegarde : ça dépend de la VM. Pour les vraies sauvegardes, j’ai utilisé Windows Server Backup et testé la restauration.\*



\## Structure du dépôt



```

windows-server-pme-lab/

├── README.md

├── .gitignore

├── scripts/

│   ├── 01-config-base.ps1

│   ├── 02-ad-ds.ps1

│   ├── 03-dns.ps1

│   ├── 04-dhcp.ps1

│   ├── 05-ou-groupes-utilisateurs.ps1

│   ├── 06-gpo.ps1

│   ├── 07-sauvegarde.ps1

│   └── utilisateurs.csv

└── docs/

&#x20;   └── captures/

```



Les scripts regroupent les commandes exécutées pendant le laboratoire et se lancent étape par étape, dans l'ordre des numéros, en PowerShell administrateur. Ils ne sont pas prévus pour être relancés tels quels sur une machine déjà configurée.

