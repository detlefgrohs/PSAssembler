$path = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition);

. "$($path)\..\..\..\source\PSAssembler.ps1" "$($path)\charanim.asm" -GenerateLST -ExecutePRG


#..\..\..\source\PSAssembler.ps1 .\charanim.asm -GenerateLST -ExecutePRG
