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
-TemplateParameterFile ..\ARM-Deploy-Templates\Policy-Assignment\ARM-AssignSpokePolicy-Parameters.json `
-TemplateFile ..\ARM-Deploy-Templates\Policy-Assignment\ARM-AssignSpokePolicy.json `
-assignmentName $assignmentName `
-policyId $policyId

Start-Sleep 120

New-AzRoleAssignment `
-ObjectId $deployment.Outputs.assignmentIdentity.Value `
-Scope $("/subscriptions/" + $deployment.Outputs.vnetHub.Value.Split("/")[2] + "/resourceGroups/" + $deployment.Outputs.vnetHub.Value.Split("/")[4]) `
-RoleDefinitionName "Network Contributor"

New-AzRoleAssignment `
-ObjectId $deployment.Outputs.assignmentIdentity.Value `
-RoleDefinitionName "Contributor" `
-Scope $("/subscriptions/" + $spokeSubscriptionId)