Red []

do %helpers.red

stack: make object! [
    s: copy []
    push: function [element /only] [
        either only [
            append/only s element
        ] [
            append s element
        ]
    ]
    pop: does [
        if self/empty [return none]
        element: last s
        remove back tail s
        :element
    ]
    peek: does [
        if self/empty [return none]
        last s
    ]
    empty: does [empty? s]
]

f3: function [
    str [string!]
] [
    output: copy []

    outputStack: make stack [
        s: copy ['output]
        value: does [get to-word self/peek]
    ]

    counter: 0
    getNewStackElementName: does [
        name: rejoin ['a counter]
        counter: counter + 1
        set to-word :name copy []
        to-lit-word :name
    ]

    ; when you get to the start of an array, push a lit-word! onto the stack
    ; when at a digit, append to the peeked value - append (get to-word outputStack/peek) digit
    ; when you get to the end of an array, pop from the stack and append/only the value to the peeked value if stack not empty

    digit: charset "0123456789"
    arrayRule: [
        "[" (
            either not-equal? counter 0 [ 
                newStackElementName: getNewStackElementName 
                outputStack/push newStackElementName
            ] [
                counter: counter + 1
            ]
        )
        any [element]
        "]" (
            currentStackElementName: outputStack/pop
            currentStackElementValue: get to-word currentStackElementName
            if (not outputStack/empty) [
                append/only (get to-word outputStack/peek) currentStackElementValue
            ]
        )
    ]
    element: [
        arrayRule
        | copy data digit (
            append (get to-word outputStack/peek) to-integer data
        )
    ]

    parse str arrayRule
    output
]

f2: function [
    str [string!]
] [
    here: [where: (print "" print where)]
    output: copy []

    digit: charset "0123456789"
    arrayRule: ["[" any [element] "]"]
    element: [
        copy data arrayRule (
            parsedArray: f2 data
            loop length? parsedArray [remove back tail output]
            append/only output parsedArray
        )
        | copy data digit (
            append output to-integer data
        )
    ]

    parse str arrayRule
    output
]

str: "[123[45]67]"
probe f3 str

assert [(f3 "[]") == [] ]
assert [(f3 "[1]") == [1] ]
assert [(f3 "[12]") == [1 2] ]
assert [(f3 "[123]") == [1 2 3] ]
assert [(f3 "[[]]") == [[]] ]
assert [(f3 "[[1]2]") == [[1] 2] ]
assert [(f3 "[[1][2]]") == [[1] [2]] ]
assert [(f3 "[[1][2][[34]]]") == [[1] [2] [[3 4]]] ]
assert [(f3 "[123[45]]") == [1 2 3 [4 5]] ]
assert [(f3 "[123[45]6]") == [1 2 3 [4 5] 6] ]
assert [(f3 "[123[45]67]") == [1 2 3 [4 5] 6 7] ]

comment [
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
]