ufcs: function [
    b
] [
    returned: copy []
    param: none
    while [not tail? b] [
        f: first b
        probe type? f
        either word? f [
            if all [(to-lit-word f) <> '. any-function? get f] [insert head returned f]
        ] [
            insert tail returned f
        ]
        b: next b
    ]
    returned
]
