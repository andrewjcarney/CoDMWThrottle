# CoDMWThrottle

A small script to set processor priority for Call of Duty: Modern Warfare.

## Installation and use.

Run as administrator

```PS > ./CodMWThrottle.ps1 -Install -Priority AboveNormal```

Priority Levels are here:
<https://docs.microsoft.com/en-us/dotnet/api/system.diagnostics.processpriorityclass?view=netframework-4.8>

The game will start with Normal Priority and raise to High after it's done loading.  It's reccomened to use AboveNormal, otherwise
you could run into problems with dropped frames.
