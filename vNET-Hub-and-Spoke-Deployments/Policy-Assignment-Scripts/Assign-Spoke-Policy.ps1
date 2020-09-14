param(
	[Parameter(Mandatory=$true)]
	$managementGroupId,
	[Parameter(Mandatory=$true)]
	$assignmentName,
	[Parameter(Mandatory=$true)]
	$location,
	[Parameter(Mandatory=$true)]
	$spokeSubscriptionId
)

$policyId = "/providers/Microsoft.Management/managementGroups/$($managementGroupId)/providers/Microsoft.Authorization/policyDefinitions/Deploy-vNET-Spoke"

Select-AzSubscription -SubscriptionId $spokeSubscriptionId
$deployment= New-AzSubscriptionDeployment `
-Name $assignmentName -Location $location `
-TemplateParameterFile ..\ARM-Deploy-Templates\ARM-AssignSpokePolicy-Parameters.json `
-TemplateFile ..\ARM-Deploy-Templates\ARM-AssignSpokePolicy.json `
-assignmentName $assignmentName `
-policyId $policyId

Select-AzSubscription -SubscriptionId $deployment.Outputs.vnetHub.Value.Split("/")[2]
New-AzRoleAssignment `
-ObjectId $deployment.Outputs.assignmentIdentity.Value `
-ResourceGroupName $deployment.Outputs.vnetHub.Value.Split("/")[4] `
-RoleDefinitionName "Network Contributor"