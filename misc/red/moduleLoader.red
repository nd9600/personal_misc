#!/usr/local/bin/red

Red [
    Title: "Red Module loader"
    License: "MIT"
]

; removing "export block!" or "export ALL" from the file to load as a module, encap'ing it, do'ing it, then extracting the variables from the current scope might work

a: copy [b: 1 c: 2 d: [4 5 6] export [d c]]

exporting: copy []
output: copy []

; find variables to export
parse a [thru 'export copy d skip (append exporting first d)]

; append variables to output
parse a [any [
    to set-word! copy data [skip skip] (
        variable: to-word first data
        exportingAll: not none? find exporting 'ALL
        exportingVariable: not none? find exporting variable
        if any [exportingAll exportingVariable] [
            append/only output data
        ]
        unset 'variable
    )
]]

probe exporting
probe output
