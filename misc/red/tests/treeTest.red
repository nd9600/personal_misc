Red [
    Title: "Tree tests"
]

do %lib/tree.red

tests: context [
    testPreorderTraversal: function [] [
        root: make TreeNode [value: 1234]
        n1: make TreeNode [value: 1]
        n2: make TreeNode [value: 2]
        n1/insertNode n2

        n3: make TreeNode [value: 3]

        root/insertNode n1
        root/insertNode n3

        l: copy []
        root/preOrder lambda [append l ?/value]
        assert [
            (l) == [1234 1 2 3] ; it calls the function the first time it sees a node
        ]
    ]

    testPostOrderTraversal: function [] [
        root: make TreeNode [value: 1234]
        n1: make TreeNode [value: 1]
        n2: make TreeNode [value: 2]
        n1/insertNode n2

        n3: make TreeNode [value: 3]

        root/insertNode n1
        root/insertNode n3

        ;       1234
        ;     1      3
        ;   2

        l: copy []
        root/postOrder lambda [append l ?/value]
        assert [
            (l) == [2 1 3 1234] ; it calls the function the last time it sees a node
        ]
    ]
]