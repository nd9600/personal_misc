Red []

routing: context [
    routes: copy []

    setRoutes: func [
        "sets the app's routes"
        routeFilesToLoad [block!] "the routes to load, containing files or strings"
    ] [
        self/routes: routeFilesToLoad
    ]
]

export routing