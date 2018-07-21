################################################
# Created by: Luciano Patrão		       #
# Date: 10-05-2017   			       #
# Import VMs from TXT VMs file and PowerON     #
################################################

###### Credentials and vCenter connection ######

$vCenter = "10.10.20.36"
$user = "gramsc_admin@fuldatal.de"
$pwd = "1 Magnus2"

Get-Module -Name VMware* -ListAvailable | Import-Module

Connect-VIServer $vCenter -User $user -Password $pwd

cls

$Report=@()
$NrVMsOff = 0
$NrVMsOn = 0
   
#Import vm name from file created
$VMlist = Get-Content "AddYourPathHere\PoweronVMs.txt   
     
	foreach ($vm in $VMlist)
	{
	$VMname = Get-VM $vm | Select Name, @{N="Powerstate";E={($_).powerstate}}
	       
		#Check VM powerstate  
        if ($VMname.Powerstate -like "PoweredOff") 
			{
			   	Write-Host "VM --> ", $VMname.Name, " in the list is PowerOff, sript will start the VM " 
				Start-VM -VM $VMname.Name -Verbose:$false
            	Sleep 2 
					 
				$Report += "VM --> " + $VMname.Name + " in the list is PowerOff, sript will start the VM "  
				$NrVMsOff = $NrVMsOff + 1 
			}    
        Elseif ($VMname.Powerstate -like "PoweredOn")
			{  
                Write-Host "VM --> ", $VMname.Name, " in the list is already PowerON, no action taken"
                                   
				#Creating VMS report   
                $Report += "VM --> " + $VMname.Name + " in the list is already PowerON, no action taken"  
				$NrVMsOn = $NrVMsOn + 1                
            }  
    }  
 
$Report += " --- Total of " + $NrVMsOn + " VMs PowerOn no changes"
$Report += " --- Total of " + $NrVMsOff + " VMs were PowerOff script did PowerON"
write-host "Creating report ..."  
Sleep 3

$Path= "c:\scripts\VMPower"
$PowerOff = "$Path\PowerOffVMs.txt"
$Report | Out-File $PowerOff
      
#Disconnect vCenter Server  
Disconnect-VIServer $vCenter -Confirm:$false