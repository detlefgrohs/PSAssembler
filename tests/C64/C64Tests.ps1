

# loop.asm
..\..\source\PSAssembler.ps1 .\loop\loop.asm -GeneratePRG > .\loop\loop.txt

..\..\source\Compare-BinaryFiles.ps1 .\loop\loop.prg .\loop\loop.test.prg


