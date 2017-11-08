Rebol [
    Title: "Tiny Framework: First controller"
]

index: does ["hello world"]

param_test: func [
    parameters [block!]
] [
    template: templater/t_load "first.twig.html"
    variables: make map! reduce [
        'parameter parameters/1
    ]
    
    return templater/compile template variables
]