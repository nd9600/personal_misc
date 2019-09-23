Red []

routes: copy []

setRoutes: func [
    "sets the app's routes"
    routeFilesToLoad [block!] "the routes to load, containing files or strings"
    /local tempRoutes
] [
    append routes routeFilesToLoad
]

export [routes setRoutes]