Red []

f: function [
    str [string!]
    startingSequence [string!]
    endingSequence [string!]
] [
    output: copy []

    justStartToEnd: [startingSequence thru endingSequence]

    recursiveOutput: none
    startToEnd: [
        [
            startingSequence
            opt [copy foundInternalStructure thru justStartToEnd (
                recursiveOutput: f foundInternalStructure startingSequence endingSequence
            )]
            copy middle to endingSequence endingSequence
        ] (
            parsedMiddle: f middle startingSequence endingSequence
            blockToAppend: copy []
            either not none? recursiveOutput [
                append/only output reduce [recursiveOutput parsedMiddle]
            ] [
                append/only output parsedMiddle
            ]
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

str: "00 a 11 a 222 b 333 b 444"
f str "a" "b"