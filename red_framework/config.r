Rebol [
    Title: "Tiny Framework - configuration"
]

config: make object! [
    port: 8000
    routing_dir: %routing/
    route_files: [%routes.r]
    controllers_dir: %controllers/
]