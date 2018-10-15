    Title: "Monads in Red"
]

Monad: make object! [
    type: copy ["Monad"]
    is_type: function [type_string [string!]] [not none? find self/type type_string]
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
maybe-return: function [x] [make Just [data: x]]
maybe-bind: function [m f] [
    case [
        m/is_type "Nothing" [return make Nothing []]
        m/is_type "Just" [maybe-return (f m/data)]
    ]
]
maybe->>=: make op! :maybe-bind
