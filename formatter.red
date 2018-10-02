Red [
    Title: "Formatter / pretty printer"
]

output: copy ""

if_rule: ['if copy cond any-type! copy block block! (append output reduce [
    "if" space "(" cond ")" space "[" newline 
        tab block newline
    "]" newline
    ])
]


while_rule: ['while copy cond block! copy block block! (append output reduce [
    "while" space "[" cond "]" space "[" newline 
        tab block newline
    "]" newline
    ])
]

a: copy [
    if (1 < 2) [print 6]
    while [tail? b] [print first b]
    ]
parse a [ any [
    if_rule
    | while_rule
    | skip
] ]
print output