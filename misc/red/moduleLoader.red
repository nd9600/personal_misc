#!/usr/local/bin/red

Red [
    Title: "Red Module loader"
    License: "MIT"
]

a: copy [b: 1 c: b + 10 d: [4 5 6] export [d c e] e: c * 12]

import: function [
    "Imports variables from a block!, file! or string!, without polluting the global scope. Variables can be defined as functions of other, non-exported variables"
    input [block! file! string!] "the thing to import, like [b: 1 c: b + 10 d: [4 5 6] export [d c e] e: c * 12]"
] [
    inputAsBlock: case [
        block? input [input]
        any [file? input string? input] [load input]
    ]

    ; find variables to export, and remove [export block!] from the argument
    exportingVariables: copy []
    parse inputAsBlock [
        copy toExport to ['export block!] 
        skip copy exportingBlock skip (
            append exportingVariables first exportingBlock
        )
        copy fromExportToEnd thru end
    ]
    blockWithoutExport: compose [(toExport) (fromExportToEnd)]
    blockAsObject: context blockWithoutExport

    ; extract the variables from the current scope
    bitThatReturnsVariables: copy []
    foreach variableToExport exportingVariables [
        append bitThatReturnsVariables compose [(to-set-word :variableToExport) get in blockAsObject (to-lit-word :variableToExport)]
    ]
    
    context bitThatReturnsVariables
]

probe import a
quit
