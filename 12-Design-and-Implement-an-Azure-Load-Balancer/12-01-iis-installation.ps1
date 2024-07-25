#IIS config for HUB-VM-01

Set-AzVMExtension -ResourceGroupName $rg `
    -ExtensionName "IIS" `
    -VMName "hub-vm-01" `
    -Location "EastUS" `
    -Publisher Microsoft.Compute `
    -ExtensionType CustomScriptExtension `
    -TypeHandlerVersion 1.8 `
    -SettingString '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'
#
#
#
#IIS config for HUB-VM-02

Set-AzVMExtension -ResourceGroupName $rg `
    -ExtensionName "IIS" `
    -VMName "hub-vm-02" `
    -Location "EastUS" `
    -Publisher Microsoft.Compute `
    -ExtensionType CustomScriptExtension `
    -TypeHandlerVersion 1.8 `
    -SettingString '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'
