Rebol [
    Title: "Tiny Framework: routing"
]

routing: make object! [

    ; used to check if the HTTP request uses an acceptable method
    accepted_route_methods: copy ["ANY" "GET" "POST" "HEAD" "PUT" "DELETE" "CONNECT" "OPTIONS" "TRACE" "PATCH"]
    
    ; needed to parse the HTTP request
    route_methods_rule: copy ["GET" | "POST" | "HEAD" | "PUT" | "DELETE" | "CONNECT" | "OPTIONS" | "TRACE" | "PATCH"]
    
    routes: copy []
    
    route_files: [%routes.r]

    get_routes: func [
        "gets the app's routes"
        /local current-dir temp_routes
    ] [
        ;changes to the directory where routes are defined first, then changes back after finding the route
        current-dir: system/options/path
        change-dir root_dir/routing

        ; 'routes is a series like ["ANY" [] "GET" [] "POST" []]
        temp_routes: copy/deep accepted_route_methods
        loop length? temp_routes [temp_routes: insert/only next temp_routes copy []]
        routes: head temp_routes

        ; loads the data for each routing file
        f_reduce :load route_files

        ; loops through every routing file
        forall route_files [
            ; if the current variable is called routes, add its content to the routes hashmap
            if (equal? first route_files 'routes) [
                routes_from_this_file: first next route_files
                foreach actual_route routes_from_this_file [

                    ; if the route_method is ANY, GET or POST, add it to the appropriate series
                    ; otherwise, add it to the GET series
                    route_method: select actual_route 'method
                    if (not find accepted_route_methods route_method) [
                        route_method: "GET"
                    ]
                    route_url: select actual_route 'url
                    route_controller: select actual_route 'controller
                    
                    routes_for_method: select routes route_method
                    append routes_for_method reduce [route_url route_controller]
                ]
            ]
        ]

        ;speeds up finding routes, but the initial creation is slower
        ;routes: to-map routes

        change-dir current-dir
    ]

    find_route: func [
        "gets the route controller for a route URL, checked against the routes for all HTTP methods"
        route_method [string!] "GET or POST"
        route_url "the URL of the route"
        /local routes_for_method route_controller
    ] [
        if (not find accepted_route_methods route_method) [
            print rejoin [route_method " is not an accepted route method. Only" accepted_route_methods " are accepted"]
        ]
        
        ; first checks against "ANY" routes, then the specific route method
        routes_for_method: select routes "ANY"
        route_controller_results: get_route_controller routes_for_method route_url
        
        if (not route_controller_results) [
            routes_for_method: select routes route_method
            ;print ""
            ;probe routes
            ;probe route_method
            ;probe routes_for_method
            route_controller_results: get_route_controller routes_for_method route_url
        ]
        return route_controller_results
    ]

    get_route_controller: func [
        "gets the route controller for a route URL, checked against the routes for a specific HTTP method"
        routes_for_method [series!] "the routes to check against"
        url_to_check [string!] "the URL to check"
        /local route_controller
    ] [   
        ; tries to find a route in the ones without parameters first
        route_controller: select routes_for_method url_to_check
                
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
        
        ;print ""
        ;print url_to_check
        ;probe routes_for_method

        if route_controller [
            return reduce [route_controller []]
        ]
        foreach route routes_for_method [
            parameters: copy []
                
            ;print append copy "route: " route
            while [not any [tail? route tail? url_to_check]] [                 
                ;probe ""
                ;probe route
                ;probe url_to_check
                any [
                    if (equal? first route first url_to_check) [
                        ;probe append copy "matched " first route
                        true
                    ]

                    if (equal? first route #"{") [
                        ;probe "{ found, matching with }"
                        
                        parameter_is_last_thing_in_route: tail? next find route "}"
                        either parameter_is_last_thing_in_route [
                            append parameters url_to_check
                            route: next find route "}"
                            url_to_check: tail url_to_check
                        ] [
                            parameters_match: consume_parameter route url_to_check
                            ;probe parameters_match
                            either (parameter_match_in_url != false) [
                                ;probe "matched with }"
                                chars_after_end_of_parameter_in_route: parameters_match/1
                                chars_after_end_of_parameter_in_url: parameters_match/2
                                parameter_match_in_url: parameters_match/3
                                
                                append parameters parameter_match_in_url                                
                                route: chars_after_end_of_parameter_in_route
                                url_to_check: chars_after_end_of_parameter_in_url
                            ] [
                                break
                            ]
                        ]
                    ]
                    break
                ]
                
                either (all [tail? next route tail? next url_to_check]) [
                    route_controller: select routes_for_method head route
                    return reduce [route_controller parameters]
                ] [
                    route: next route
                    url_to_check: next url_to_check
                ]
            ]
            url_to_check: head url_to_check
            ;probe "end"
        ]
        return none
    ]

    consume_parameter: func [
        "matches and consumes parameters in defined routes and URLs"
        route [string!] "the defined route with the parameter"
        url_to_check [string!] "the URL with the parameter"
        /local parsing_rule
    ] [
        ;if match,
        ;   return string to between "}"
        ;if no match,
        ;   return false
        
        ;find the first character after } in the route, and all characters after
        ;   return false if there is none
        ;find the characters beginning at that single character in the url_to_check
        ;   return false if there are none
        ;parameter match will be all characters up to that point
        ;return the characters after the parameter in the route and url. and the parameter
        chars_after_end_of_parameter_in_route: next find route "}"
        char_after_end_of_parameter_in_route: first chars_after_end_of_parameter_in_route
        
        if (chars_after_end_of_parameter_in_route = none) [
            return false
        ]
        
        chars_after_end_of_parameter_in_url: find url_to_check char_after_end_of_parameter_in_route
                
        if (none? chars_after_end_of_parameter_in_url) [
            return false
        ]
        
        parse url_to_check [copy parameter_match_in_url to chars_after_end_of_parameter_in_url]
                
        return reduce [chars_after_end_of_parameter_in_route chars_after_end_of_parameter_in_url parameter_match_in_url]
    ]
]