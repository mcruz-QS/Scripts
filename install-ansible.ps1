function Invoke-Ansible
{
    [cmdletbinding()]
    param()
    write-verbose "Starting Ansible Setup"
    Send-StepStatusBegun -name "Ansible Configuration Started"
    $resourceGroupName = $Global:runningConfig.Azure.ResourceGroup
    $VMs = Get-AzureRmVM -ResourceGroupName $resourceGroupName

    $ansibleAcct = (Get-AzureKeyVaultSecret -VaultName qsinf -Name ansible-svc-acct).SecretValueText
    $ansbilePW = (Get-AzureKeyVaultSecret -VaultName qsinf -Name ansible-svc-pw).SecretValueText
    $res = foreach( $vm in $VMs.Name){
        Invoke-AzureRmVMRunCommand -ResourceGroupName $resourceGroupName -VMName $vm -CommandId 'RunPowerShellScript' -ScriptPath ".\ansible.ps1" -parameter @{"arg1" = $ansbilePW ; "arg2" = $ansibleAcct}
    }
    if ($res.Status -eq "Succeeded"){ 
        Send-StepStatusCompleted -name "Ansible Configuration Complete"
    } else{
        Send-StepStatusCompleted -name "Ansible Configuration Failed"
    }
}