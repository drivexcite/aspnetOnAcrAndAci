$mainSubscription = 'fd4767b9-b7f1-4db7-a1dd-37c5159006e7'
$resourceGroup = 'HackaGroup'
$clusterName = 'HackaCluster'

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

# Tag the local image with the container registry url/repository/image
docker build -t "${imageName}:${applicationVersion}" .
docker tag "${imageName}:${applicationVersion}" $acrLoginServer/$imageName/"${imageName}:${applicationVersion}"

# Push image to ACR
$containerUrl = "${acrLoginServer}/${imageName}/${imageName}:${applicationVersion}".replace('"','')

az acr login -n $acrName
docker push $containerUrl

# Create cluster
az aks create --resource-group $resourceGroup --name $clusterName --node-vm-size Standard_B2ms --generate-ssh-keys --node-count 3 --enable-managed-identity --attach-acr $acrResourceId

# Create local configuration file to talk to the AKS Cluster
az aks get-credentials --resource-group $resourceGroup --name $clusterName

# To avoid messing up kubectl 
Set-Alias -Name k -Value kubectl

# Create namespace for workload
k create namespace $imageName

# Create deployment from template
Get-Content ./infra/templates/deployment.yaml | ForEach-Object { $ExecutionContext.InvokeCommand.ExpandString($_) } | Set-Content ./infra/${imageName}.yaml

# Send deployment to Kubernetes
k apply -f ./infra/${imageName}.yaml

# Diagnose deployment
$firstPod = k get pod -n ${imageName} -l app=${imageName} -o jsonpath='{.items[0].metadata.name}'
k describe pod -n ${imageName} $firstPod
k logs -n ${imageName} $firstPod 
k exec -it $firstPod printenv -n ${imageName}
k port-forward -n ${imageName} deployment/${imageName} 9090:80

