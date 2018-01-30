Red [
    Title: "Uniform Function Call syntax for Red"
    Documentation: https://tour.dlang.org/tour/en/gems/uniform-function-call-syntax-ufcs
]

apply: function [f args][do compose [(f) (args)] ]

ufcs: function [
    data [block!]
] [
    output: copy data
    recursive_data: copy []

    datatypes: [integer! | string!]
    rules: [
        any [
                copy ufcs_data [datatypes '. word! block!] 
                    (
                        first_arg: first ufcs_data
                        f: third ufcs_data
                        second_arg: fourth ufcs_data
                        args: head insert copy head second_arg first_arg

                        o: apply :f args
                        b: compose [(f) (args)]
                        probe b
                        data_after_match: next find/only data second_arg

                        append output o
                        append recursive_data o
                        append recursive_data data_after_match

                        probe rejoin ["recursive_data: " recursive_data]
                        final_output: ufcs recursive_data
                        probe rejoin ["final_output: " final_output]
                        return final_output
                    )
            |
                skip
        ]
    ]
    parse data rules
    return first output
]

d: [4 . add [5] . add [6]]
;[4 . add [5] . add [6]]
;[9 . add [6]]
;[15]

ufcs d

;ufcs ["a1" . append ["b2"] . append ["c3"] . append ["d4"]]
;append append append "a1" "b2" "c3" "d4"
