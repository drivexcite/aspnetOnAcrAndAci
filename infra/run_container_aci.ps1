$mainSubscription = 'fd4767b9-b7f1-4db7-a1dd-37c5159006e7'
$resourceGroup = 'HackaGroup'

$acrName = 'HackaCR'

$imageName = 'webapp'
$applicationVersion = 'v1'

# Login to Azure
az login
az account set --subscription $mainSubscription

# Create resource group
az group create --name $resourceGroup --location westus

# Create an Azure Container Registry
az acr create --resource-group $resourceGroup --name $acrName --sku Basic
$acrResourceId = az acr show --name $acrName --resource-group $resourceGroup --subscription $mainSubscription --query id

# Creare service principal for use in ACI for pulling images from ACR
$acrLoginServer = az acr show --name $acrName --query loginServer
$servicePrincipal = az ad sp create-for-rbac --name "$acrName-service-principal" --scopes $acrResourceId --role acrpull | ConvertFrom-Json

# Tag the local image with the container registry url/repository/image
docker build -t "${imageName}:${applicationVersion}" .
docker tag "${imageName}:${applicationVersion}" $acrLoginServer/$imageName/"${imageName}:${applicationVersion}"

# Push image to ACR
$containerName = "${acrLoginServer}/${imageName}/${imageName}:${applicationVersion}".replace('"','')

az acr login -n $acrName
docker push $containerName

# Run the container in the cloud
$webApp = az container create --resource-group $resourceGroup --name $imageName --image $acrLoginServer/$imageName/"${imageName}:${applicationVersion}" --registry-username $servicePrincipal.appId --registry-password $servicePrincipal.password --dns-name-label $imageName --restart-policy OnFailure --environment-variables Environment=Production | ConvertFrom-Json

# To verify the deployed application
$webAppUrl = "http://$($webApp.ipAddress.fqdn)/"
$webAppUrl

# To diagnose possible errors, attach to stdout
az container attach --resource-group $resourceGroup --name $imageName