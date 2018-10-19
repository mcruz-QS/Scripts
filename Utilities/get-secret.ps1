function get-azsecret {
param(
    $vaultName
)
    Try{
        $a = Get-AzureKeyVaultSecret -VaultName $vaultName
        $a | ForEach-Object { if ($_.name -match "vm"){
            Get-AzureKeyVaultSecret -VaultName $_.VaultName  -Name $_.name |Select-Object name, SecretValueText }
        }
    }catch{
        $Error[0].Exception.Message
    }
}