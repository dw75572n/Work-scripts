
Import-Module ServerManager

####Adds server roles################################################

$servertype = Read-Host "Enter the number for the type of server you wish to setup (1) App, (2) Web, (3) Both"

switch ($servertype)
{
   
       1 { @( Add-WindowsFeature Web-server, web-webserver, web-common-http, 
         web-static-content, web-default-doc, web-dir-browsing, web-http-errors, 
         web-http-redirect, web-app-dev, web-asp-net, web-net-ext, web-asp, web-cgi, 
         web-ISAPI-ext, web-ISAPI-filter, web-includes, web-health, web-http-logging, web-log-libraries,
         web-request-monitor, web-http-tracing, web-custom-logging, web-odbc-logging, 
         web-security, web-basic-auth, web-windows-auth, web-digest-auth, web-client-auth,
         web-cert-auth, web-url-auth, web-filtering, web-ip-security, web-performance, web-stat-compression,
         web-dyn-compression, web-mgmt-tools, web-mgmt-console, web-scripting-tools, web-mgmt-service, MSMQ, 
         MSMQ-Services, MSMQ-server, net-framework-core, NET-HTTP-Activation,   
         NET-Non-HTTP-Activ, WAS, WAS-Process-Model, WAS-NET-Environment, WAS-Config-APIs ) }
       
       2 { @(Add-WindowsFeature application-server,AS-Web-Support,AS-Ent-Services, AS-TCP-Port-Sharing, 
         AS-WAS-Support, AS-HTTP-Activation, AS-MSMQ-Activation, AS-TCP-Activation,  AS-Named-Pipes, 
         AS-Dist-Transaction, AS-Incoming-Trans, AS-Outgoing-Trans ) }
       
       3 { @( Add-WindowsFeature Web-server, web-webserver, web-common-http, 
         web-static-content, web-default-doc, web-dir-browsing, web-http-errors, 
         web-http-redirect, web-app-dev, web-asp-net, web-net-ext, web-asp, web-cgi, 
         web-ISAPI-ext, web-ISAPI-filter, web-includes, web-health, web-http-logging, web-log-libraries,
         web-request-monitor, web-http-tracing, web-custom-logging, web-odbc-logging, 
         web-security, web-basic-auth, web-windows-auth, web-digest-auth, web-client-auth,
         web-cert-auth, web-url-auth, web-filtering, web-ip-security, web-performance, web-stat-compression,
         web-dyn-compression, web-mgmt-tools, web-mgmt-console, web-scripting-tools, web-mgmt-service, MSMQ, 
         MSMQ-Services, MSMQ-server, net-framework-core, NET-HTTP-Activation,   
         NET-Non-HTTP-Activ, WAS, WAS-Process-Model, WAS-NET-Environment, WAS-Config-APIs, application-server,
         AS-NET-Framework,AS-Web-Support,AS-Ent-Services, AS-TCP-Port-Sharing, 
         AS-WAS-Support, AS-HTTP-Activation, AS-MSMQ-Activation, AS-TCP-Activation,  AS-Named-Pipes)}

       Default {"The Server type could not be determined"}

       }

 ##########Creates Private Queues#######################################                           
                               
[System.Reflection.Assembly]::LoadWithPartialName("System.Messaging") | Out-Null

Write-Host "Creating the new queue and setting FullControl permissions for hazeljob"
$qb = [System.Messaging.MessageQueue]::Create(".\private$\hazeljob")

$qb.SetPermissions("everyone", 
      [System.Messaging.MessageQueueAccessRights]::FullControl,            
      [System.Messaging.AccessControlEntryType]::Set)   


  Write-Host "Creating the new queue and assigning permissions to hazeladmin"
      
 $q1 = [System.Messaging.MessageQueue]::Create(".\private$\hazeladmin")

 $q1.SetPermissions("everyone", 
      [System.Messaging.MessageQueueAccessRights]::FullControl,            
      [System.Messaging.AccessControlEntryType]::Set) 
   
###########Creates Neccessary Folders##################################     
      
       New-Item 'C:\Packages' -ItemType directory
       New-Item 'C:\Websites' -ItemType directory
       New-Item 'C:\Feeds' -ItemType directory
       New-Item 'C:\sqldata' -ItemType directory
       New-Item 'C:\sqllogs' -ItemType directory
    
Write-Host "Setting up report server"
$ccode = Read-Host "Please Enter Company Code"
(&schtasks /create /tn "ExtractSSRSData" /tr "'C:\Program Files\HazelTree\HTFS.Job.Launcher\HTFS.Common.Job.Launcher.exe' SetSSRSDataInDb admin 'CompanyCode=$ccode'" /sc "DAILY" /RL "HIGHEST" /NP )

$apath = Read-Host "Please enter path of atlas folder"
$hpath = Read-Host "Please enter path of hazeltree folder"

Move-Item -Path $apath -Destination 'C:\Program Files\' -Force

Move-Item -Path $hpath -Destination 'C:\websites\' -Force


Set-Location -Path C:\Windows\Microsoft.NET\Framework\v4* 

cmd.exe /c "installutil /servicename="HTFS.Job.Service" /displayname="HTFS Job Service" "c:\Program Files\HazelTree\HTFS.Job.Service\HTFS.Common.Job.Service.exe""

