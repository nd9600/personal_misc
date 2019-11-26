Red [
    Title: "A Pattern Language mapper"
    License: "MIT"
]

do %lib/helpers.red

makeUrlFromPatternNumber: function [
    n [integer!]
] [
    paddedN: pad/left/with n 3 #"0"
    to-url rejoin [
        "http://www.iwritewordsgood.com/apl/patterns/apl" paddedN ".htm"
    ]
]

getLinksFromPage: function [
    url [url!]
] [
    tags: copy []
    text: copy ""
    html-code: [
        copy tag ["<" thru ">"] (append tags tag) 
        | copy txt to "<" (append text txt)
    ]
    page: attempt [read url]
    if not found? page [
        return none
    ]

    parse page [to "<" some html-code]

    links: copy []
    foreach tag tags [
        if parse tag [
            "<A" thru "HREF="
                [
                    {"} copy link to {"} 
                    | copy link to ">"
                ]
            to end
        ] [
            append links link
        ]
    ]
    links
]

addLinksForPatternNumber: function [
    currentN [integer!]
    patternMap [map!]
] [
    urlForPattern: makeUrlFromPatternNumber currentN
    linksFromPage: getLinksFromPage urlForPattern
    if not found? linksFromPage [
        exit
    ]

    linksToPatterns: linksFromPage
        |> [f_filter lambda [startsWith ? "apl"]]

    patternsLinkedTo: linksToPatterns
        |> [f_map lambda [
            parse ? ["apl" copy n to "."]
            to-integer n
        ]]
        |> :unique

    either found? patternMap/:currentN [
        append patternMap/:currentN patternsLinkedTo
    ] [
        put patternMap currentN patternsLinkedTo
    ]

    print ""
    prettyPrint currentN    
    prettyPrint patternMap
]

main: function [
] [
    patternMap: make map! []
    
    currentPatternNumber: 51
    while [
        currentPatternNumber <= 253
    ] [
        addLinksForPatternNumber currentPatternNumber patternMap
        currentPatternNumber: currentPatternNumber + 1
    ]

    prettyPrint patternMap
    ; write %patternMap.txt patternMap
]

main