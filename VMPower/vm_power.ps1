################################################
# Created by: Luciano Patrão                   #
# Date: 10-05-2017                             #
# Power Off Virtual Infraestructure (VMs)      #
# Create List of all VMs powered off           #
################################################

###### Credentials and vCenter connection ######

$vCenter = "10.10.20.36"
$user = "gramsc_admin@fuldatal.de"
$pwd = "1 Magnus2"
 
Connect-VIServer $vCenter -User $user -Password $pwd

cls
$Report=@()
$Record=@()
$NrVMsOff = 0
$NrVMsOn = 0
$NrVMsToolson = 0
$NrVMsToolsoff = 0

#Create report per Cluster
#We can check PoweredON and PoweredOff VMs, just comment this part in the next line | where { $_.PowerState -eq "PoweredOn"}, if not the script will only check PoweredON VMs.

#$vms = Get-Cluster "Cluster Test"  | Get-vm | where { $_.PowerState -eq "PoweredOn"}
#Create report for full vCenter, remove comment if you want to use for all vCenter.
$vms = Get-vm | where { $_.PowerState -eq "PoweredOn"}
   
    foreach ($vm in $vms)
    {
    
        $VMname = Get-VM $vm | Select Name, @{N="Powerstate";E={($_).powerstate}}
           
        #Check VM powerstate
        if ($VMname.Powerstate -like "PoweredOff")
		
             {     
			  Write-Host "VM --> ", $VMname.Name, " Already Power off no action needed"
			  $NrVMsOff = $NrVMsOff + 1
             }
         Elseif ($VMname.Powerstate -like "PoweredOn")              
               
            {  
                Write-Host "VM --> ", $VMname.Name, " is Powered ON, adding to the list"
				$Report += $VMname.Name  
                $NrVMsOn = $NrVMsOn + 1
                                                
                #Creating VMs report
			    Write-Host  "Processing Power off for VM -> " -f Blue -nonewline; Write-Host "$vm" -f red
				Write-Host "Checking for VM VMware Tools State" -ForegroundColor Blue;Write-Host
				
				#Check VM VMware Tools State
				$ToolsState = get-view -Id $vm.Id
				If ($ToolsState.config.Tools.ToolsVersion -eq 0)
				{
					$Record += "$vm ######  VMware tools not detected. I will shutdown VM"
	                $NrVMsToolsoff = $NrVMsToolsoff + 1
					#Stop-VM $VMname.Name -Confirm:$false
					Sleep 3
				}
				
				Else
				
				{
					$Record += "$vm ######  VMware tools detected. I will attempt to gracefully shutdown"
	                $NrVMsToolson = $NrVMsToolson + 1
					#$vm | Shutdown-VMGuest -Confirm:$false  
					Sleep 5
            	}  
                         
             } 
    }  

$Record += ""
$Record += "#### Number of VMs that were Powered off ####"
$Record += "   Total of " + $NrVMsToolsoff + " VMs with no VMware Tools"
$Record += "   Total of " + $NrVMsToolson + " VMs with VMware Tools"
$Record += "   Total of " + $NrVMsOn + " VMs Powered off"


#Will write in the screen the VMs Totals    
Write-Host "Total of " $NrVMsToolsoff " VMs with no VMware Tools"
Write-Host "Total of " $NrVMsToolson " VMs with VMware Tools"
Write-Host "Total of " $NrVMsOn " VMs Powered off"
Write-Host "Total of " $NrVMsOff " were already VMs Powered Off"  
Write-Host "Total of " $NrVMsOn " VMs Powered On and added to the Power ON list script"
write-host "Creating reports ..."  
Sleep 3

$Path= "c:\scripts\VMPower"
$PowerON = "$Path\PowerOnVMs.txt"
$PoweredOFF = "$Path\Record-Powered-Off-VMs.txt"
$Report | Out-File $PowerON 
$Record | Out-File $PoweredOFF 
      
#Disconnect vCenter Server  
Disconnect-VIServer $vCenter -Confirm:$false