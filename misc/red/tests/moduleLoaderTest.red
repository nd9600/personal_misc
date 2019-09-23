Red [
    Title: "Module loader tests"
]

tests: context [
    moduleLoader: context load %lib/moduleLoader.red

    ; setUp: func [] [
    ; ]

    ; tearDown: func [] [
    ; ]

    testImportingEverythingFromABlock: function [] [
        h: moduleLoader/import [
            a: 1 
            b: 2 
            c: b * 2 
            d: function [][c + 1] 
            export [a b c d]
        ]
    
        assert [
            h/a == 1
            h/b == 2
            h/c == (2 * 2)
            (h/d) == (2 * 2 + 1)
        ]
    ]

    testImportingAFunctionThatDependsOnSomethingElse: function [] [
        h: moduleLoader/import/only [
            a: 1 
            b: 2 
            c: b * 2 
            d: function [][c + 1] 
            export [d]
        ] [
            d
        ]
    
        assert [
            (h/d) == (2 * 2 + 1)
            none? in h 'c
        ]
    ]

    testImportingOneThingWhenTwoThingsAreExported: function [] [
        h: moduleLoader/import/only [
            a: 1 
            b: 2 
            c: b * 2 
            d: function [][c + 1] 
            export [d c]
        ] [
            d
        ]
    
        assert [
            (h/d) == (2 * 2 + 1)
            none? in h 'c
        ]
    ]

    testImportingSomethingThatIsntExported: function [] [
        h: moduleLoader/import/only [
            a: 1 
            b: 2 
            c: b * 2 
            d: function [][c + 1] 
            export [d]
        ] [
            c d
        ]
    
        assert [
            (h/d) == (2 * 2 + 1)
            none? in h 'c
        ]
    ]
]