Rebol [
    Title: "Tiny Framework: parameter routes"
    Description: "routing.r will read anything in 'routes into the app's routes"
]

routes: [
    ["/route_test/{parameter}/h/{parameter}" "p1.html"]
    ["/route_test_2/{}" "p2.html"]
]