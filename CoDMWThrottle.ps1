<#
CoDMWThrottle.ps1

Copyright 2019 Andrew J Carney

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#>
param(
    [Parameter(Mandatory=$false)]
    [System.Diagnostics.ProcessPriorityClass]$Priority = [System.Diagnostics.ProcessPriorityClass]::AboveNormal,
    [Parameter(Mandatory=$false)]
    [switch]$Install
)

$this = (Join-Path $PSScriptRoot ($MyInvocation.MyCommand))

if ($Install.IsPresent) {
    if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error "Install failed.  Are you administrator?"
    }
    New-EventLog -LogName Application -Source "Bad modern warfare" -ErrorAction SilentlyContinue

    $principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    $action = New-ScheduledTaskAction -Execute  "${env:windir}\System32\WindowsPowerShell\v1.0\powershell.exe" `
                                      -Argument "-WindowStyle Hidden -File ${this} -Priority $Priority" `
                                      -WorkingDirectory $PSScriptRoot

    $trigger = New-ScheduledTaskTrigger -AtLogOn

    $task = New-ScheduledTask -Action $action -Description "Modern Warfare throttle" -Trigger $trigger -Principal $principal -ErrorAction Stop
    $task | Register-ScheduledTask -TaskName "Modern Warfare Throttle" -ErrorAction Stop
    Start-ScheduledTask -TaskName  "Modern Warfare Throttle" -ErrorAction Stop

    exit
}

while ($true) {
    $p = Get-Process ModernWarfare -ErrorAction Ignore
    if (($null -ine $p) -and ($p.PriorityClass -ne $Priority)) {
        $p.PriorityClass = $Priority
        Write-EventLog -LogName Application -Source "bad modern warfare" -EntryType Information -Message "Lowered CPU priority to $Priority" -EventId 1
    }
    Sleep -Seconds 10
}