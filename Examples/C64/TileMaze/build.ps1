


$path = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition);

. "$($path)\..\..\..\source\PSAssembler.ps1" "$($path)\TileMaze.asm" -GenerateLST -ExecutePRG
