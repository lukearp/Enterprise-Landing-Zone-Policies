# Policies

## Deploy-vNET-Hub
Parameters Required

|Parameter Name|Description|
|--|--|
|vnetName|The VNET name of your Spoke|
|resourceGroupName|The Resource Group Name that the Spoke VNET will be deployed to.|
|vnetAddressSpace|The IPv4 Address Space for the Spoke VNET. Ex: \"10.10.0.0/22\"|
|dnsServers| Arrary of DNS Service IPs if wanting to use Custom DNS.  Ex: [\"10.10.1.1\",\"10.10.1.2\"]|
|gatewaySubnetAddressPrefix|Subnet address space for the VPN/Express Route Gateway. Ex: \"10.0.3.224/27\"|
|subnets|Names and address spaces of your Subnets.  Objects need a Name and Address Preffix property Ex: [{\"name\": \"subnet1\",\"addressPrefix\":\"10.10.0.0/24\"},{\"name\": \"subnet2\",\"addressPrefix\":\"10.10.1.0/24\"}]|
|gatewayType|Azure Gateway type. VPN or ExpressRoute|
|gatewaySku|Azure Gateway Sku. Currently, this template does not support Availability Zone Gateway SKUs|
|location|Azure Region that VNET will be deployed to. Ex: eastus|

JSON from Template:
```
"vnetName": {
	"type": "String",
	"metadata": {
		"description": "The VNET name of your Spoke"
	}
},
"resourceGroupName": {
	"type": "String",
	"metadata": {
		"description": "The Resource Group Name that the Spoke VNET will be deployed to."
	}
},
"vnetAddressSpace": {
	"type": "String",
	"metadata": {
		"description": "The IPv4 Address Space for the Spoke VNET. Ex: \"10.10.0.0/22\""
	}
},
"dnsServers": {
	"type": "Array",
	"defaultValue": [],
	"metadata": {
		"description": "Arrary of DNS Service IPs if wanting to use Custom DNS.  Ex: [\"10.10.1.1\",\"10.10.1.2\"]"
	}
},
"gatewaySubnetAddressPrefix": {
	"type": "String",
	"metadata": {
		"description": "Subnet address space for the VPN/Express Route Gateway. Ex: \"10.0.3.224/27\""
	}
},
"subnets": {
	"type": "Array",
	"metadata": {
		"description": "Names and address spaces of your Subnets.  Objects need a Name and Address Preffix property Ex: [{\"name\": \"subnet1\",\"addressPrefix\":\"10.10.0.0/24\"},{\"name\": \"subnet2\",\"addressPrefix\":\"10.10.1.0/24\"}]"
	},
	"defaultValue": []
},
"gatewayType": {
	"type": "String",
	"allowedValues": [
		"VPN",
		"ExpressRoute"
	],
	"defaultValue": "VPN",
	"metadata": {
		"description": "Azure Gateway type. VPN or ExpressRoute"
	}
},
"gatewaySku": {
	"type": "String",
	"allowedValues": [
		"Basic", "HighPerformance", "Standard", "UltraPerformance", "VpnGw1", "VpnGw2", "VpnGw3", "VpnGw4", "VpnGw5"
	],
	"defaultValue": "Basic",
	"metadata": {
		"description": "Azure Gateway Sku. Currently, this template does not support Availability Zone Gateway SKUs"
	}
},
"location": {
	"type": "String",
	"metadata": {
		"description": "Azure Region that VNET will be deployed to. Ex: eastus"
	}
}
```

## Deploy-vNET-Spoke
Parameters Required

|Parameter Name|Description|
|--|--|
|vnetName|The VNET name of your Spoke|
|resourceGroupName|The Resource Group Name that the Spoke VNET will be deployed to.|
|vnetAddressSpace|The IPv4 Address Space for the Spoke VNET. Ex: \"10.10.0.0/22\"|
|dnsServers| Arrary of DNS Service IPs if wanting to use Custom DNS.  Ex: [\"10.10.1.1\",\"10.10.1.2\"]|
|subnets|Names and address spaces of your Subnets.  Objects need a Name and Address Preffix property Ex: [{\"name\": \"subnet1\",\"addressPrefix\":\"10.10.0.0/24\"},{\"name\": \"subnet2\",\"addressPrefix\":\"10.10.1.0/24\"}]|
|hubVnetId|Resource ID of the HUB VNET that the Spoke will be peered to. Ex: /subscriptions/<subId>/resourceGroups/Policy-Tset/providers/Microsoft.Network/virtualNetworks/<vnet name>|
|location|Azure Region that VNET will be deployed to. Ex: eastus|

JSON from Template:
```
"vnetName": {
	"type": "String",
	"metadata": {
		"description": "The VNET name of your Spoke"
	}
},
"resourceGroupName": {
	"type": "String",
	"metadata": {
		"description": "The Resource Group Name that the Spoke VNET will be deployed to."
	}
},
"vnetAddressSpace": {
	"type": "String",
	"metadata": {
		"description": "The IPv4 Address Space for the Spoke VNET. Ex: \"10.10.0.0/22\""
	}
},
"dnsServers": {
	"type": "Array",
	"defaultValue": [],
	"metadata": {
		"description": "Arrary of DNS Service IPs if wanting to use Custom DNS.  Ex: [\"10.10.1.1\",\"10.10.1.2\"]"
	}
},
"subnets": {
	"type": "Array",
	"metadata": {
		"description": "Names and address spaces of your Subnets.  Objects need a Name and Address Preffix property Ex: [{\"name\": \"subnet1\",\"addressPrefix\":\"10.10.0.0/24\"},{\"name\": \"subnet2\",\"addressPrefix\":\"10.10.1.0/24\"}]"
	},
	"defaultValue": []
},
"hubVnetId": {
	"type": "String",
	"metadata": {
		"description": "Resource ID of the HUB VNET that the Spoke will be peered to. Ex: /subscriptions/<subId>/resourceGroups/Policy-Tset/providers/Microsoft.Network/virtualNetworks/<vnet name>"
	}
},
"location": {
	"type": "String",
	"metadata": {
		"description": "Azure Region that VNET will be deployed to. Ex: eastus"
	}
}
```

# How to use these Policies?

The files Deploy-vNet-Hub.json and Deploy-vNET-Spoke.json can be the body in a PUT REST call: https://docs.microsoft.com/en-us/rest/api/resources/policydefinitions/createorupdate.  Once the Policy Definitions are available in your desired scope, you can assign the Policies to your Azure Subscriptions.  

You can also use the ARM-DeployPolicyDefs-vNET-Hub-and-Spoke.json using a Management Group Deployment: https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-to-management-group

Example Deployment using Az Powershell Modules
```
$managementGroupId = "ID"
$location = "eastus"
New-AzManagementGroupDeployment -Name Hub-and-Spoke -ManagementGroupId $managementGroupId -Location $location -TemplateFile .\ARM-ManagementGroup-DeployPolicyDefs-vNET-Hub-and-Spoke.json -TemplateParameterFile .\ARM-ManagementGroup-DeployPolicyDefs-vNET-Hub-and-Spoke-Parameters.json
```