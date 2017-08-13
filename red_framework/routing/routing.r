Rebol [
    Title: "Tiny Framework: routing"
]

accepted_route_methods: ["ANY" "GET" "POST" "HEAD" "PUT" "DELETE" "CONNECT" "OPTIONS" "TRACE" "PATCH"]

get-routes: func [
    "gets the app's routes"
    /local current-dir routes
] [
    ;changes to the directory where routes are defined first, then changes back after finding the route
    current-dir: system/options/path
    change-dir root-dir/routing

    ; 'routes is a series like ["ANY" [] "GET" [] "POST" []]
    routes: copy/deep accepted_route_methods
    loop length? routes [routes: insert/only next routes copy []]
    routes: head routes

    ; loads the data for each routing file
    route_files: [%routes.r %routes2.r]
    f_reduce :load route_files

    ; loops through every routing file
    forall route_files [
        ; if the current variable is called routes, add its content to the routes hashmap
        if (equal? first route_files 'routes) [
            routes_from_this_file: first next route_files
            foreach actual_route routes_from_this_file [

                ; if the route_method is ANY, GET or POST, add it to the appropriate series
                ; otherwise, add it to the GET series
                route_method: first actual_route
                either (find accepted_route_methods route_method) [
                    route_url_and_controller: next actual_route
                    append select routes route_method route_url_and_controller
                ] [
                    append select routes "GET" actual_route
                ]
            ]
        ]
    ]

    ;speeds up finding routes, but the initial creation is slower
    ;routes: to-map routes

    change-dir current-dir
    return routes
]

find-route: func [
    "gets the route controller for a route URL, checked against the routes for all HTTP methods"
    routes [series!] "the routes series to search in"
    route_method [string!] "GET or POST"
    route_url "the URL of the route"
    /local routes_for_method route_controller
] [
    if (not find accepted_route_methods route_method) [
        do make error! rejoin [route_method " is not an accepted route method. Only" accepted_route_methods " are accepted"]
    ]
    
    ; first checks against "ANY" routes, then the specific route method
    routes_for_method: select routes "ANY"
    route_controller: get-route-controller routes_for_method route_url

    if (not route_controller) [
        routes_for_method: select routes route_method
        route_controller: get-route-controller routes_for_method route_url
    ]
    return route_controller
]

get-route-controller: func [
    "gets the route controller for a route URL, checked against the routes for a specific HTTP method"
    routes_for_method [series!] "the routes to check against"
    url_to_check [string!] "the URL to check"
    /local route_controller
] [
    ; tries to find a route in the ones without parameters first
    route_controller: select routes_for_method url_to_check
    
    ; maybe remove a route if it doesn't have a parameter in it
    
    ; if that fails, loop through all other routes - 
    ;     iterate over the route URL until the tail of it or url_to_check
    ;         if route_url[i] == url_to_check[i],
    ;             continue
    ;         elseif route_url[i] == "{",
    ;             try to match char after "}" in route_url with first matching char in url_to_check
    ;             if match,
    ;                 copy string in between "{" and "}" to variable
    ;             if no match,
    ;                 break
    ;         else,
    ;             break
    ;
    ;         if next chars of route and url_to_check at tail,
    ;             return head of route
    ;         else,
    ;             increment chars
    ;     reset position of url_to_check
    ; return none
    
    probe url_to_check
    probe routes_for_method
    if (not route_controller) [
        foreach route routes_for_method [
            if equal? route "/route_test/{parameter}/h" [
                probe route
                while [not any [tail? route tail? url_to_check]] [
                    print ""
                    probe first route
                    probe first url_to_check
                    probe route
                    probe url_to_check
                    
                    any [
                        if (equal? first route first url_to_check) [
                            true
                        ]

                        if (equal? first route #"{") [
                            probe "{ found, matching with }"
                            parameters_match: consume-parameter route url_to_check
                            either parameters_match [
                            
                            ] [
                                break
                            ]
                        ]
                        break
                    ]
                    
                    either (all [tail? next route tail? next url_to_check]) [
                        route_controller: select routes_for_method head route
                        return route_controller
                    ] [
                        route: next route
                        url_to_check: next url_to_check
                    ]
                ]
                url_to_check: head url_to_check
                probe "end"
                print ""
            ]
        ]
    ]
    return route_controller
]

consume-parameter: func [
    "matches and consumes parameters in defined routes and URLs"
    route [string!] "the defined route with the parameter"
    url_to_check [string!] "the URL with the parameter"
    /local parsing_rule
    ] [
        ;if match,
        ;   return string to between "}"
        ;if no match,
        ;   return false
        probe route
        probe url_to_check
        return true
    ]

; routes charset is aAzZ-_/, parameters are delimited by { and }, the string inbetween is passed to controller as a variable
; parameters are any string