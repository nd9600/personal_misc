Red [
    Title: "Tree tests"
]

dotenv: context load %lib/dotenv.red

tests: context [
    testItLoadsFromAString: does [
        dotenv/loadEnv/env {
            ABC="1234"
        }

        assert [
            (get-env "ABC") == "1234"
        ]
    ]
]