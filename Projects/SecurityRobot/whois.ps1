function Get-IPGeolocation
{
    Param
    (
        [string]$IPAddress
    )
 
    $request = Invoke-RestMethod -Method Get -Uri "http://geoip.nekudo.com/api/$IPAddress"
 
    [PSCustomObject]@{
        IP        = $request.IP
        City      = $request.City
        Country   = $request.Country.Name
        Code      = $request.Country.Code
        Location  = $request.Location.Latitude
        Longitude = $request.Location.Longitude
        TimeZone  = $request.Location.Time_zone
    }
}


Function Get-MyWhoIs {
 
<#
.SYNOPSIS
Get WhoIS data
.DESCRIPTION
Use this command to get public WhoIS domain information for a given IP v4 address.
.PARAMETER Ip
Enter an IPv4 Address. This command has aliases of: Address
.PARAMETER Full
Show complete whoIs information.
.EXAMPLE
PS C:\> Get-MyWhoIs 208.67.222.222
OpenDNS, LLC
.EXAMPLE
PS C:\> Get-MyWhoIs 208.67.222.222 -full
 
 
IP                     : 208.67.222.222
Name                   : OPENDNS-NET-1
RegisteredOrganization : OpenDNS, LLC
City                   : San Francisco
StartAddress           : 208.67.216.0
EndAddress             : 208.67.223.255
NetBlocks              : 208.67.216.0/21
Updated                : 3/2/2012 8:03:18 AM
.NOTES
NAME        :  Get-MyWhoIs
VERSION     :  1.0   
LAST UPDATED:  4/3/2015
AUTHOR      :  Jeff Hicks (@JeffHicks)
 
Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/
 
  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************
.LINK
Invoke-RestMethod
.INPUTS
[string]
.OUTPUTS
[string] or [pscustomobject]
#>
 
[cmdletbinding()]
Param (
[parameter(Position=0,Mandatory,HelpMessage="Enter an IPv4 Address.",
ValueFromPipeline,ValueFromPipelineByPropertyName)]
[Alias("Address")]
[ValidatePattern("^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$")]
[string]$IP,
 
[Parameter(Helpmessage="Show complete WhoIs information.")]
[switch]$Full
)
 
Begin {
    Write-Verbose "Starting $($MyInvocation.Mycommand)"  
    $baseURL = 'http://whois.arin.net/rest'
    #default is XML anyway
    $header = @{"Accept"="application/xml"}
 
} #begin
 
Process {
    $url = "$baseUrl/ip/$ip"
    $r = Invoke-Restmethod $url -Headers $header
 
    Write-verbose ($r.net | out-string)
    if ($Full) {
    $propHash=[ordered]@{
        IP = $ip
        Name = $r.net.name
        RegisteredOrganization = $r.net.orgRef.name
        City = (Invoke-RestMethod $r.net.orgRef.'#text').org.city
        StartAddress = $r.net.startAddress
        EndAddress = $r.net.endAddress
        NetBlocks = $r.net.netBlocks.netBlock | foreach {"$($_.startaddress)/$($_.cidrLength)"}
        Updated = $r.net.updateDate -as [datetime]   
        }
        [pscustomobject]$propHash
    }
    else {
        #write just the name
        $r.net.orgRef.Name
    }
      
} #Process
 
End {
    Write-Verbose "Ending $($MyInvocation.Mycommand)"
} #end 
} #end Get-WhoIs


CLS



$List = (GC c:\IPList.txt)
#$list

Function GeoLocate{

$Variable = ForEach ($IP in $List){

#Get-IPGeolocation $IP | FT -AutoSize += $Variable

Get-IPGeolocation $IP += $Variable

} 

$Variable | FT -AutoSize
}



Function DoWhoIS{

$Variable2 = ForEach ($IP in $List){

Get-MyWhoIs $IP -Full # += $Variable2

}
$Variable2 | FT -AutoSize

}




#DoWhoIS
#GeoLocate

$ipAddy = [System.Net.Dns]::GetHostAddresses("adrianhall.co.uk")[0].IPAddressToString; 

$ipAddy 

Get-MyWhoIs -Full $ipAddy