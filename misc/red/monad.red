Red [
    Title: "Monads in Red"
]

Object: make object! [
    type: copy []
    is_type: function [type_string [string!]] [not none? find self/type type_string]
]

Monad: make Object [
    type: append self/type "Monad"
]

Maybe: make Monad [
    type: append self/type "Maybe"
]
Just: make Maybe [
    type: append self/type "Just"
    data: []
]
Nothing: make Maybe [
    type: append self/type "Nothing"
]

maybeReturn: function [x [any-type!]] [make Just [data: x]]
maybeBind: function [
    m [object!] "the Maybe instance" 
    f [any-function!] "the function to bind, should take an a! and return a Maybe-b!"
] [
    case [
        m/is_type "Nothing" [return make Nothing []]
        m/is_type "Just" [f m/data]
    ]
]
maybe->>=: make op! :maybeBind

; square: function [x][x ** 2]        (maybeReturn 3) maybe->>= lambda [maybeReturn square ?]    == Just 9
