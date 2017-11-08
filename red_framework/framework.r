Rebol [
    Title: "Tiny Framework"
    Documentation: http://www.rebol.net/cookbook/recipes/0057.html
]

;brings in the base FP functions
do %functional.r

;brings in the routing functions into an object called 'routing
do %routing/routing.r

;brings in the templating functions into an object called 'templater
do %views/templater.r

root_dir: what-dir

web_dir: %.   ; the path to where you store your web files
controllers_dir: %controllers/

port: 8000

listen_port: open/lines append tcp://: port  ; port used for web connections

; set up the routes
routing/get_routes

errors: [
    400 "Forbidden" "No permission to access: "
    404 "Not Found" "Controller not found for: "
    500 "Internal server error" "Error: "
]

send-error: function [err-num file] [err] [
    err: find errors err-num
    insert http-port join "HTTP/1.0 " [
        err-num " " err/2 "^/Content-type: text/html^/^/"
        <html> <title> err/2 </title>
        <body><h1> "server-error" </h1><br /><p> "REBOL Webserver Error:" </p>
        <br /> <p> err/3 "  " <b>file</b> newline </p> </body> </html>
    ]
]

send-page: func [data mime] [
    insert data rejoin ["HTTP/1.0 200 OK^/Content-type: " mime "^/^/"]
    write-io http-port data length? data
]

; holds the request information which is printed out as connections are made
buffer: make string! 1024  ; will auto-expand if needed

; processes each HTTP request from a web browser. The first step is to wait for a connection on the listen_port. When a connection is made, the http-port variable is set to the TCP port connection and is then used to get the HTTP request from the browser and send the result back to the browser.
forever [
    print ""
    print "waiting for request"
    http-port: first wait listen_port
    clear buffer
    print "waiting over"

    ; gathers the browser's request, a line at a time. The host name of the client (the browser computer) is added to the buffer string. It is just for your own information. If you want, you could use the remote-ip address instead of the host name.
    while [not empty? request: first http-port][
        repend buffer [request newline]
    ]
    repend buffer ["Address: " http-port/host newline]
    file: "index.html"
    mime: "text/plain"
    
    ;  parses the HTTP header and copies the requested file name to a variable. This is a very simple method, but it will work fine for simple web server requests.
    parse buffer [
        [
            copy method routing/route_methods_rule
        ]
        [
            "http"
            | "/ "
            | copy file to " "
        ]
    ]
                 
    route_results: routing/find_route method file
    either (not none? route_results) [
        print append copy "route_results are: " mold route_results  
        route: parse route_results/1 "@"
        
        ; return an error if the controller is invalid
        either (equal? length? route 1) [
            print rejoin ["^"" route "^"" " is an incorrect controller"]
            send-error 500 rejoin ["^"" route "^"" " is an incorrect controller"]
        ] [
        
            route_parameters: route_results/2
            controller_name: append copy route/1 ".r"
            controller_function_name: copy route/2

            print append copy "method is: " method 
            print append copy "file is: " file
            print append copy "route is: " mold route  
            print append copy "route_parameters are: " mold route_parameters

            ; execute the wanted function from the controller file
            controller_path: append copy controllers_dir controller_name
            do read controller_path
            controller_output: do to-word controller_function_name
            probe controller_output

            ; takes the file's suffix and uses it to lookup the MIME type for the file. This is returned to the web browser to tell it what to do with the data. For example, if the file is foo.html, then a text/html MIME type is returned. You can add other MIME types to this list.
            parse file [thru "."
                            [
                                "html" (mime: "text/html")
                                | "gif"  (mime: "image/gif")
                                | "jpg"  (mime: "image/jpeg")
                            ]
                       ]

            ; check that the requested file exists, read the file and send it to the browser using the SEND-PAGE function described earlier. If an error occurs, the SEND-ERROR function is called to send the error back to the browser.
            any [
                ;if not exists? web_dir/:file [
                ;    send-error 404 file
                ;]
                if error? try [
                    ;data: read/binary web_dir/:file
                    data: copy controller_output
                ] [
                    send-error 400 file
                ]
                send-page data mime
            ]

            ; makes sure that the connection from the browser is closed, now that the requested web data has been returned.
            print "port closed"
        ]
    ] [
        send-error 404 file
    ]
    close http-port
]
