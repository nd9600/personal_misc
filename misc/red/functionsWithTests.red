Red [
    Title: "Functions with inline test cases"
]

apply: function [f args][do compose [f (args)] ]

functionWithTests: function [
    testCases [block!] "test cases"
    spec [block!] "the function's 'spec block"
    body [block!] "the function's body"
] [
    f: function spec body

    failures: copy []
    foreach testCase testCases [
        set [args expectedOutput] testCase
        argsAsBlock: either block? args [args] [reduce [args]]
        actualOutput: apply :f argsAsBlock

        if expectedOutput <> actualOutput [
            append failures rejoin ["for args '" mold args "', expected: " expectedOutput ", actual: " actualOutput]
        ]
        if not empty? failures [
            print "Test cases failed:"
            print failures
            do make error! rejoin failures
        ]
    ]
    :f
]

factorial: functionWithTests [
    [[1] 1]
    [[2] 2]
    [[3] 6]
    [[4] 24]
    [[5] 120]
] [
    n [integer!]
] [
    if n == 4 [
        return 23
    ]
	f: 1
	repeat i n [f: f * i]
	f
]