
$size = 5;

$generated = @();

for ($outerIndex = 0; $outerIndex -lt ($size + 1); $outerIndex += 1) {
    # "outerIndex = $($outerIndex)"
    $currentGenerated = @();

    $currentIndex = 0;
    for($innerIndex = 0; $innerIndex -lt $size; $innerIndex += 1) {
        if ($innerIndex -ge $outerIndex) {
            $currentGenerated += [byte][Math]::Ceiling($currentIndex);
            $currentIndex += ($size / ($size - $outerIndex));
        } else {
            $currentGenerated += 0xFF;
        }
    }

    # Now Flip the 1st part to make the second part...
    for($index = $size - 1; $index -ge 0; $index -= 1) {
        $value = $currentGenerated[$index];
        if ($value -ne 0xFF) {
            $value = (($size * 2) - 1) - $value;
        }
        $currentGenerated += [byte]$value;
    }
    $generated += $currentGenerated
}

# Now generated the reversed...
for($index = $size - 1; $index -ge 0; $index -= 1) {
    $offset = ($index + 1) * ($size * 2) - 1;

    for ($index2 = 0; $index2 -lt ($size * 2); $index2 += 1) {
        $value = $generated[$offset - $index2];
        $generated += [byte]$value;
    }
}

$pos = 0;
for ($index = 0; $index -lt $generated.Count; $index += 1) {
    $value = $generated[$index];
    Write-Host "`$$($value.ToString('X2')), " -NoNewline

    $pos += 1;
    if ($pos -ge ($size * 2)) { 
        Write-Host
        $pos = 0;
    }

}
