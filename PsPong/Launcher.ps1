# Ensure PowerShell 7+
if ($PSVersionTable.PSEdition -ne 'Core') {
    $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue

    if (-not $pwsh) {
        Write-Error "PowerShell 7 (pwsh) is required but not installed."
        exit 1
    }

    & $pwsh.Source -NoLogo -NoProfile -File $PSCommandPath
    exit
}

Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class NativeMethods {
    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int vKey);
}
"@

."$($PSScriptRoot)\PsPong.ps1"