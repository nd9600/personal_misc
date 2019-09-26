Red [
    Title: "Tree tests"
]

dotenv: context load %lib/dotenv.red

tests: context [
    dotenv/loadEnv/env {
        ABC="1234"
    }
    testItLoadsFromAString: does [
        assert [
            (get-env "ABC") == 1234
        ]
    ]
]