# Will Build the Book from the Individual Files and then run Pandoc to generate the final PDF
$Global:scriptDir = Split-Path $script:MyInvocation.MyCommand.Path

$Global:GeneratedMarkdownFileName = "$($scriptDir)\Book.md"

function AddMarkdownFile() {
    param($markdownFileName)

    Get-Content "$($Global:scriptDir)\$($markdownFileName)" | Add-Content $Global:GeneratedMarkdownFileName
    # Not sure if I need this. I think there is a chapters setting for the Latex PDF generator...
    "
\pagebreak    
    " | Add-Content $Global:GeneratedMarkdownFileName
}

# Remove the previously generated markdown if it exists
Remove-Item $GeneratedMarkdownFileName -ErrorAction SilentlyContinue

AddMarkdownFile "Title Page.md"
AddMarkdownFile "Chapter 00 - Prologue.md"

AddMarkdownFile "Chapter XX - Assembly Routines.md"

# AddMarkdownFile "Chapter xx - Epilogue.md"

$pandocParameters = @(    
    "--to=pdf",
    "--output=Book.pdf",
    "--pdf-engine=xelatex"
    "--from=markdown-implicit_figures"
    # "--variable=fontfamily:Microsoft Sans Serif"
);

pandoc $GeneratedMarkdownFileName $pandocParameters
#$GeneratedMarkdownFileName -o ".\Writing Amazon Books.pdf" --pdf-engine=xelatex --from=markdown-implicit_figures

# & '.\Writing Amazon Books.pdf'


# Changes still to make to this script
# All the script to work from the command line
# Specify Font
# Look at the other errors when running PanDoc
