Rebol [
    Title: "Tiny Framework: routing"
]

get-routes: func [
    "gets the app's routes"
    /local current-dir route_files routes] [
    current-dir: system/options/path
    change-dir root-dir/routing
    routes: copy []

    ;loads the data for each routing file
    route_files: [%routes.r %routes2.r]
    f_reduce :load route_files

    probe route_files

    ;loops through every routing file
    forall route_files [
        ;if the current variable is called routes, add its content to the routes hashmap
        if (equal? first route_files 'routes) [
            actual_route: first next route_files
            f_fold :append routes actual_route
        ]
    ]

    ;speeds up finding routes, but the initial creation is slower
    routes: to-map routes

    change-dir current-dir
    return routes
]

; routes charset is aAzZ-_/, parameters are delimited by { and }, the name inbetween is passed to controller as a variable
; parameters are any string