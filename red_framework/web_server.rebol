Rebol [
    Title: "Tiny Web Server"
    Documentation: http://www.rebol.net/cookbook/recipes/0057.html
]

web-dir: %.   ; the path to where you store your web files

port: 8000

listen-port: open/lines append tcp://: port  ; port used for web connections

errors: [
    400 "Forbidden" "No permission to access:"
    404 "Not Found" "File was not found:"
]

send-error: function [err-num file] [err] [
    err: find errors err-num
    insert http-port join "HTTP/1.0 " [
        err-num " " err/2 "^/Content-type: text/html^/^/" 
        <HTML> <TITLE> err/2 </TITLE>
        "<BODY><H1>SERVER-ERROR</H1><P>REBOL Webserver Error:"
        err/3 " " file newline <P> </BODY> </HTML>
    ]
]

send-page: func [data mime] [
    insert data rejoin ["HTTP/1.0 200 OK^/Content-type: " mime "^/^/"]
    write-io http-port data length? data
] 

; holds the request information which is printed out as connections are made
buffer: make string! 1024  ; will auto-expand if needed

; processes each HTTP request from a web browser. The first step is to wait for a connection on the listen-port. When a connection is made, the http-port variable is set to the TCP port connection and is then used to get the HTTP request from the browser and send the result back to the browser.
forever [
    http-port: first wait listen-port
    clear buffer

    ; gathers the browser's request, a line at a time. The host name of the client (the browser computer) is added to the buffer string. It is just for your own information. If you want, you could use the remote-ip address instead of the host name.
    while [not empty? request: first http-port][
        repend buffer [request newline]
    ]
    repend buffer ["Address: " http-port/host newline] 
    print buffer
    file: "index.html"
    mime: "text/plain"

    ;  parses the HTTP header and copies the requested file name to a variable. This is a very simple method, but it will work fine for simple web server requests.
    parse buffer ["GET" 
                    [
                        "http" 
                        | "/ " 
                        | copy file to " "
                    ]
                 ]

    print append copy "file is: " file

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
        if not exists? web-dir/:file [send-error 404 file]
        if error? try [data: read/binary web-dir/:file] [send-error 400 file]
        send-page data mime
    ]

    ; makes sure that the connection from the browser is closed, now that the requested web data has been returned.
    close http-port
    ]
