# Policies

# What do these Policies do?

The two Policies in this folder are focused on deploying a [Hub and Spoke Azure VNET architecture](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/hub-spoke-network-topology#:~:text=Hub%20and%20spoke%20network%20topology%201%20Overview.%20As,complex%20multitier%20workloads%20in%20a%20single%20spoke.%20). 

The Deploy-vNet-Hub will deploy a Hub Virtual Network with an Azure VPN Gateway.  You also have the option to define subnet space for an Azure Firewall and Bastion host.  If you add the address space, the appliances will be deployed into the Resource Group.  

The Deploy-vNet-Spoke will deploy a Virtual Network and then peer to a Hub Virtual Network with Gateway Transit configured.  

All Subnets defined in the policy will have Network Security Groups created, except for special subnets used for Gateways, Firewalls, and Bastion Hosts.

The Deploy-SitetoSite-VPN will configure a Local Network Gateway and Connection object linked to your Virtual Network Gateway.  It allows you to configure all your Phase1 and Phase2 settings aswell as enable BGP.  This Policy will only work on Standard tier or above Virtual Network Gateway.  

# How to use these Policies?

The files Deploy-vNet-Hub.json and Deploy-vNET-Spoke.json can be the body in a PUT REST call: https://docs.microsoft.com/en-us/rest/api/resources/policydefinitions/createorupdate.  Once the Policy Definitions are available in your desired scope, you can assign the Policies to your Azure Subscriptions.  

You can also use the ARM-DeployPolicyDefs-vNET-Hub-and-Spoke.json using a Management Group Deployment: https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-to-management-group

Example Deployment using Az Powershell Modules
```
$managementGroupId = "ID"
$location = "eastus"
New-AzManagementGroupDeployment -Name Hub-and-Spoke -ManagementGroupId $managementGroupId -Location $location `
-TemplateUri https://raw.githubusercontent.com/lukearp/Enterprise-Landing-Zone-Policies/master/vNET-Hub-and-Spoke-Deployments/ARM-Deploy-Templates/Policy-Definition-Deploy/ARM-ManagementGroup-DeployPolicyDefs-vNET-Hub-and-Spoke.json `
-TemplateParameterUri https://raw.githubusercontent.com/lukearp/Enterprise-Landing-Zone-Policies/master/vNET-Hub-and-Spoke-Deployments/ARM-Deploy-Templates/Policy-Definition-Deploy/ARM-ManagementGroup-DeployPolicyDefs-vNET-Hub-and-Spoke-Parameters.json
```

# How to support multiple subscription deployments?

The Rememdiation task has to have rights to the HUB VNET.  When a Policy is assigned there is a Remediation Principal ID.  This is an Object ID of a Service principal.  This Object ID needs to be given rights to the Resource Group that has your HUB VNET.  This can easily be done using Cloud Shell:

```
New-AzRoleAssignment -ObjectId <Assignment Principal ID> -ResourceGroupName <resource group of hub vnet> -RoleDefinitionName "Contributor"
```

You can also use the Policy-Assignment-Scripts/Assign-Spoke-Policy.ps1 to assign and grant the System Assigned Identity Contributor rights to the Hub VNET.  It leverages the ARM-Deploy-Tempaltes/ARM-AssignSpokePolicy.json template.  Add values to the ARM-AssignSpokePolicy-Parameters.json and run the script.

From the Policy-Assignment-Script folder within the repo:
```
.\Assign-Spoke-Policy.ps1 -managementGroupId MANAGEMENTGROUPID -assignmentName NAME-OF-POLICY-ASSIGNMENT -location DEPLOYMENT-LOCATION -spokeSubscriptionId TARGET-SUBSCRIPTION
```

## Deploy-vNET-Hub
Parameters Required

|Parameter Name|Description|
|--|--|
|vnetName|The VNET name of your Spoke|
|resourceGroupName|The Resource Group Name that the Spoke VNET will be deployed to.|
|vnetAddressSpace|The IPv4 Address Space for the Spoke VNET. Ex: \"10.10.0.0/22\"|
|dnsServers| Arrary of DNS Service IPs if wanting to use Custom DNS.  Ex: [\"10.10.1.1\",\"10.10.1.2\"]|
|gatewaySubnetAddressPrefix|Subnet address space for the VPN/Express Route Gateway. Ex: \"10.0.3.224/27\"|
|firewallSubnetAddressPrefix|Leave Empty if you don't want to deploy. Subnet address space for an Azure Firewall. Ex: \"10.0.3.0/26\"|
|bastionSubnetAddressPrefix|Leave Empty if you don't want to deploy. Subnet address space for an Azure Bastion Host. Ex: \"10.0.3.192/27\"|
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
## Deploy-SitetoSite-VPN
Parameters Required

|Parameter Name|Description|
|--|--|
|vpnConnectionName|Name of Azure Connection Object|
|remoteVpnPeerIp|Peer IP of remote Gateway to build VPN Connection|
|remoteNetworks|Comma seperated address prefixes that represents the remote networks.  Ex: \"172.16.0.0/24,172.16.1.0/24\"|
|connectionProtocol|IKE Version, IKEv1 or IKEv2|
|sharedKey|Preshared Key for VPN Connection|
|phase1Integrity|Phase 1 Integrity|
|phase1Encryption|Phase 1 Encryption|
|phase1DhGroup|Phase 1 DH Group|
|phase2Integrity|Phase 2 Integrity|
|phase2Encryption|Phase 2 Encryption|
|phase2PfsGroup|Phase 2 Lifetime in Seconds|
|phase2LifeTimeSeconds|Phase 2 Lifetime in Seconds|
|phase2LifeTimeKB|Phase 2 Lifetime in KB|
|isPolicyBasedVPN|If the VPN will be a Policy Based connection.|
|bgpPeerIp|Remote BGP Peer IP.  If not using BGP leave blank.  BGP is not an Option on Policy VPNs|
|bgpAsn|Remote BGP ASN.  If not using BGP leave blank.  BGP is not an Option on Policy VPNs|
|azureGatewayName|Name of Azure VPN Gateway.|
|azureGatewayResourceGroupName|Name of Azure VPN Gateway Resource Group.|
|location|Azure Region for Azure VPN Gateway|

Json Parameters:
```
"vpnConnectionName": {
	"type": "string",
	"metadata": {
		"description": "Name of Azure Connection Object"
	}
},
"remoteVpnPeerIp": {
	"type": "string",
	"metadata": {
		"description": "Peer IP of remote Gateway to build VPN Connection"
	}
},
"remoteNetworks": {
	"type": "string",
	"metadata": {
		"description": "Comma seperated address prefixes that represents the remote networks.  Ex: \"172.16.0.0/24,172.16.1.0/24\""
	}
},
"connectionProtocol": {
	"type": "string",
	"metadata": {
		"description": "IKE Version, IKEv1 or IKEv2"
	},
	"allowedValues": [
		"IKEv2",
		"IKEv1"
	],
	"defaultValue": "IKEv2"
},
"sharedKey": {
	"type": "string",
	"metadata": {
		"description": "Preshared Key for VPN Connection"
	}
},
"phase1Integrity": {
	"type": "string",
	"metadata": {
		"description": "Phase 1 Integrity"
	},
	"allowedValues": [
		"MD5",
		"SHA1",
		"SHA256",
		"GCMAES128",
		"GCMAES192",
		"GCMAES256"
	]
},
"phase1Encryption": {
	"type": "string",
	"metadata": {
		"description": "Phase 1 Encryption"
	},
	"allowedValues": [
		"None",
		"DES",
		"DES3",
		"AES128",
		"AES192",
		"AES256",
		"GCMAES128",
		"GCMAES192",
		"GCMAES256"
	]
},
"phase1DhGroup": {
	"type": "string",
	"metadata": {
		"description": "Phase 1 DH Group"
	},
	"allowedValues": [
		"None",
		"DHGroup1",
		"DHGroup2",
		"DHGroup14",
		"DHGroup2048",
		"ECP256",
		"ECP384",
		"DHGroup24"
	]
},
"phase2Integrity": {
	"type": "string",
	"metadata": {
		"description": "Phase 2 Integrity"
	},
	"allowedValues": [
		"MD5",
		"SHA1",
		"SHA256",
		"SHA384",
		"GCMAES256",
		"GCMAES128"
	]
},
"phase2Encryption": {
	"type": "string",
	"metadata": {
		"description": "Phase 2 Encryption"
	},
	"allowedValues": [
		"DES",
		"DES3",
		"AES128",
		"AES192",
		"AES256",
		"GCMAES256",
		"GCMAES128"
	]
},
"phase2PfsGroup": {
	"type": "string",
	"metadata": {
		"description": "Phase 2 PFS Group"
	},
	"allowedValues": [
		"None",
		"PFS1",
		"PFS2",
		"PFS2048",
		"ECP256",
		"ECP384",
		"PFS24",
		"PFS14",
		"PFSMM"
	]
},
"phase2LifeTimeSeconds": {
	"type": "integer",
	"metadata": {
		"description": "Phase 2 Lifetime in Seconds"
	},
	"defaultValue": 27000
},
"phase2LifeTimeKB": {
	"type": "integer",
	"metadata": {
		"description": "Phase 2 Lifetime in KB"
	},
	"defaultValue": 102400000
},
"isPolicyBasedVPN": {
	"type": "boolean",
	"defaultValue": false,
	"metadata": {
		"description": "If the VPN will be a Policy Based connection."
	}
},
"bgpPeerIp": {
	"type": "string",
	"metadata": {
		"description": "Remote BGP Peer IP.  If not using BGP leave blank.  BGP is not an Option on Policy VPNs"
	}
},
"bgpAsn": {
	"type": "string",
	"metadata": {
		"description": "Remote BGP ASN.  If not using BGP leave blank.  BGP is not an Option on Policy VPNs"
	}
},
"azureGatewayName": {
	"type": "string",
	"metadata": {
		"description": "Name of Azure VPN Gateway."
	}
},
"azureGatewayResourceGroupName": {
	"type": "string",
	"metadata": {
		"description": "Name of Azure VPN Gateway Resource Group."
	}
},
"location": {
	"type": "string",
	"metadata": {
		"description": "Azure Region for Azure VPN Gateway"
	}
}        
```

# What are some Features that are planned in the future?

If there are any features that are wanted, submit an issue.  