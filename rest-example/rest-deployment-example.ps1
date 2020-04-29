# https://docs.microsoft.com/en-us/rest/api/storagerp/storageaccounts/create

# Get things from Key Vault
$keyVaultName = "nepeters-keyvault"
$tenantId = (Get-AzKeyVaultSecret -VaultName $keyVaultName -Name tenant).SecretValueText
$appid = (Get-AzKeyVaultSecret -VaultName $keyVaultName -Name appid).SecretValueText
$password = (Get-AzKeyVaultSecret -VaultName $keyVaultName -Name password).SecretValueText
$subscription = (Get-AzKeyVaultSecret -VaultName $keyVaultName -Name subscription).SecretValueText

# Deployment values
$resourceGroup = "rest-demo-one"
$deploymentName = "nepetersrestdemo"

# Get Bearer Token
$token = (Invoke-RestMethod -Uri https://login.microsoftonline.com/$tenantId/oauth2/token?api-version=1.0 -Method Post -Body @{"grant_type" = "client_credentials"; "resource" = "https://management.core.windows.net/"; "client_id" = "$appid"; "client_secret" = "$password" }).access_token

# Headers With Token
$headers = @{
    'authorization' = "Bearer $token"
    'host' = "management.azure.com"
}

# Body With Template Inline
$body = '{
	"properties": {
		"template": {
			"$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
			"contentVersion": "1.0.0.0",
			"resources": [{
				"name": "demorest",
				"type": "Microsoft.Storage/storageAccounts",
				"apiVersion": "2019-06-01",
				"location": "[resourceGroup().location]",
				"kind": "StorageV2",
				"sku": {
					"name": "Premium_LRS",
					"tier": "Premium"
				}
			}]
		},
		"parameters": {},
		"mode": "Complete"
	}
}'

# Build REST URI and Create Deployment
$uri = "https://management.azure.com/subscriptions/$subscription/resourcegroups/$resourceGroup/providers/Microsoft.Resources/deployments/$deploymentName" + "?api-version=2019-10-01"
Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json" -Method PUT -Body $body
