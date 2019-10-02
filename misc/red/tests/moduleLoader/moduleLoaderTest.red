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

    testImportingASingleThing: function [] [
        h: moduleLoader/import [
            a: 1 
            b: 2 
            c: b * 2 
            d: function [][c + 1] 
            export a
        ]
    
        assert [
            h == 1
        ]
    ]

    testImportingASingleThingThatDependsOnSomethingElse: function [] [
        h: moduleLoader/import [
            a: 1 
            b: 2 
            c: b * 2 
            d: function [][c + 1] 
            export d
        ]
    
        assert [
            h == 5
        ]
    ]

    testImportingASingleObject: function [] [
        h: moduleLoader/import [
            o: context [
                block: []
                _append: function [e] [append self/block e]
                _clear: does [clear head self/block]
            ] 
            export o
        ]
    
        assert [
            empty? h/block
        ]

        h/_append 1234
        assert [
            not empty? h/block
            (first h/block) == 1234
        ]

        h/_clear
        assert [
            empty? h/block
        ]

        h/_append [1 2 3]
        assert [
            not empty? h/block
            (first next h/block) == 2
            (last h/block) == 3
        ]
    ]

    testImportingWithDataThatShouldPersist: function [] [
        routing: moduleLoader/import %tests/moduleLoader/fileToImport.red

        routing/setRoutes [1 2 3]
        assert [
            (routing/routes) == [1 2 3]
        ]
    ]

    ; won't work until I get op!s able to be made inside objects
    ; testImportingOp: function [] [
    ;     obj: moduleLoader/import [
    ;         f: make op! function [x y] [x + y]
    ;     ]

    ;     probe obj
    ;     assert [
    ;         (obj/f 1 2) == 3
    ;     ]
    ; ]
]