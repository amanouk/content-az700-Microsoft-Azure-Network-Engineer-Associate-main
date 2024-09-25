Set-AzVMExtension -ResourceGroupName $rg `
    -ExtensionName "IIS" `
    -VMName "br-hub-vm-01" `
    -Location "CentralUS" `
    -Publisher Microsoft.Compute `
    -ExtensionType CustomScriptExtension `
    -TypeHandlerVersion 1.8 `
    -SettingString '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'
