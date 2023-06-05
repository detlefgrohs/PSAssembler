

#CODE
"; Code Line 1"
"; Code Line 2"
"; Code Line 3"
for ($index = 0; $index -lt 5; $index += 1) {
    "       LDA `$$($index)"
}

for ($index = 0; $index -lt 16; $index += 1) {
    "       DATA.b  `$$($index.ToString('X2'))"
}
#ENDC

