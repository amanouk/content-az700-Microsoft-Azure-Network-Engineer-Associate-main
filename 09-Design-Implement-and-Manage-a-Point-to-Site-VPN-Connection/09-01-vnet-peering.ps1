$HubVnet = Get-AzVirtualNetwork -Name "hub-vnet"
$Spoke1Vnet = Get-AzVirtualNetwork -Name "spoke1-vnet"

Add-AzVirtualNetworkPeering -Name 'hub-spoke1' `
    -VirtualNetwork $HubVnet `
    -RemoteVirtualNetworkId $Spoke1Vnet.Id `
    -AllowForwardedTraffic `
    -AllowGatewayTransit
