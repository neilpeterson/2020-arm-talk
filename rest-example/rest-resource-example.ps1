# https://docs.microsoft.com/en-us/rest/api/storagerp/storageaccounts/create

# Get things from Key Vault
$keyVaultName = "nepeters-keyvault"
$tenantId = (Get-AzKeyVaultSecret -VaultName $keyVaultName -Name tenant).SecretValueText
$appid = (Get-AzKeyVaultSecret -VaultName $keyVaultName -Name appid).SecretValueText
$password = (Get-AzKeyVaultSecret -VaultName $keyVaultName -Name password).SecretValueText
$subscription = (Get-AzKeyVaultSecret -VaultName $keyVaultName -Name subscription).SecretValueText

# Deployment values
$resourceGroup = "rest-demo"
$storageAccountName = "nepetersrestdemo"

# Get Bearer Token
$token = (Invoke-RestMethod -Uri https://login.microsoftonline.com/$tenantId/oauth2/token?api-version=1.0 -Method Post -Body @{"grant_type" = "client_credentials"; "resource" = "https://management.core.windows.net/"; "client_id" = "$appid"; "client_secret" = "$password" }).access_token

# Headers With Token
$headers = @{
    'authorization' = "Bearer $token"
    'host' = "management.azure.com"
}

# Storage Account Body
$body = '{
	"sku": {
		"name": "Standard_GRS"
	},
	"kind": "Storage",
	"location": "eastus"
}'

# Build REST URI and Create Deployment
$uri = "https://management.azure.com/subscriptions/$subscription/resourceGroups/$resourceGroup/providers/Microsoft.Storage/storageAccounts/$storageAccountName" + "?api-version=2019-06-01"
Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json" -Method PUT -Body $body
