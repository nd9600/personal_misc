Red [
    Title: "Problems"
    Documentation:
]

do %functional.red

counter: 1
qprint: func [thing] [
    print rejoin ["^/###^/" counter]
    probe thing
    counter: counter + 1
    none
]

block: copy [1 2 3 4]

; 1
myLast: function[b][
    first back tail b
]
qprint myLast block

; 2
secondLast: function[b][
    first back back tail b
]
qprint secondLast block

; 3
myPick: function[b index][
    i: 1
    while [i < index] [
        b: next b
        i: i + 1
    ]
    first b
]
qprint myPick block 2

; 4
count: function[b][
    length: 0
    while [not tail? b] [
        b: next b
        length: length + 1
    ]
    length
]
qprint count block

; 5
myReverse: function[b][
    reversed: copy []
    while [not tail? b] [
        insert head reversed first b
        b: next b
    ]
    reversed
]
qprint myReverse block

; 6
palindrome: function[b][
    (myReverse b) == b
]
qprint palindrome block
probe palindrome [1 2 1]

; 7
flatten: function[b][
    flattened: copy []
    while [not tail? b] [
        element: first b
        either block? element [
            append flattened flatten element
        ] [
            append flattened element
        ]
        b: next b
    ]
    flattened
]
qprint flatten block
probe flatten [1 [[2 3] [4]] 1]

; 8
rleCompress: function[b][
    compressed: copy []
    previous: none
    while [not tail? b] [
        element: first b
        if previous <> element [append compressed element]
        previous: element 
        b: next b
    ]
    compressed
]
qprint rleCompress block
probe rleCompress [1 1 1 2 2 3 3 3 4 5 5 6]

; 9
pack: function[b][
    packed: copy []
    previous: none
    foreach element b [
        either previous == element [
            append last packed element
        ] [
            append/only packed reduce [element]
        ]
        previous: element 
    ]
    packed
]
qprint pack block
probe pack [1 1 1 2 2 3 3 3 4 5 5 6]

; 10
rle: function[b][
    f_map lambda [reduce [length? ? first ?]] pack b
]

qprint rle block
probe rle [1 1 1 2 2 3 3 3 4 5 5 6]
