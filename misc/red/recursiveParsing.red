Red []

if_statement: [
    [
        "{%" any   "if" some   
            copy ifCondition to "%}" "%}"
        copy stringToCompile to
        ["{%" any   "endif" any   "%}"]
        ["{%" any   "endif" any   "%}"]
    ]
    ()
]

f: function [
    str [string!]
    startingSequence [string!]
    endingSequence [string!]
] [
    output: copy []

    justStartToEnd: [startingSequence thru endingSequence]

    recursiveOutputToAppend: copy ""
    startToEnd: [
        [
            startingSequence
            opt [copy foundInternalStructure thru justStartToEnd (
                recursiveOutput: f copy foundInternalStructure 
                    startingSequence endingSequence
                recursiveOutputToAppend: recursiveOutput
            )]
            copy middle to endingSequence endingSequence
        ] (
            parsedMiddle: f middle startingSequence endingSequence
            blockToAppend: copy []
            if greater? length? recursiveOutputToAppend 0 [
                append blockToAppend recursiveOutputToAppend
            ]
            append blockToAppend parsedMiddle
            append/only output blockToAppend
        )
    ]

    any_character: complement make bitset! []
    anything: [copy data any_character (append output data)]

    rules: [
        any [
            startToEnd
            | anything
        ]
    ]
    parse str rules
    output
]

{
00  [
    11  [
         222 
    ] 
    333 
] 
 444
}

{
00 a 
    11 a 
        222 
    b 
    333 
b 
444
}

str: "00 a 11 a 222 b 333 b 444"
f str "a" "b"