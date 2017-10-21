Red [
    Title: "Simulated annealer"
    Documentation: http://www.theprojectspot.com/tutorial-post/simulated-annealing-algorithm-for-beginners
]

convert_y_coords: func [
    height [number!]
    y [number!]
] [
    height - y
]

pprobe: func ['var][probe rejoin [mold/only var ": " do var]]

should_accept: func [
    "The simulated annealer acceptance function - accepts if new_energy > current_energy"
    current_energy [integer!] "the current solution's energy "
    new_energy [integer!] "the new solution's energy"
    temperature [float!] "the system's current temperature"
] [    
    either (new_energy < current_energy) [
        return true
    ] [
        acceptance_probability: exp (((to-float current_energy) - new_energy) / temperature)
        return (acceptance_probability > random 1.0)
    ]
]

{
called like:
gen: func [random 1000]
init: 9000
id: func [a][a]
annealer :gen init :id
}
annealer: func [
    "The simulated annealer driver"
    solution_generator [any-function!] "generates a solution"
    initial_solution [any-type!] "the initial solution"
    energy_puller [any-function!] "gets the energy from a solution"
    /graph "graph the solution energies"
] [
    randomize ; will print out exactly the same solutions everytime otherwise
    temperature: 10000.0
    cooling_rate: 0.03
    
    current_solution: initial_solution
    current_energy: energy_puller current_solution
    
    if graph [
        energies: copy []
        append energies current_energy
    ]
    
    while [temperature > 1] [
        new_solution: solution_generator/change current_solution
        new_energy: energy_puller new_solution
        
        acceptance: should_accept current_energy new_energy temperature        
        if acceptance [
            current_solution: new_solution
            current_energy: energy_puller current_solution
        ]
        temperature: temperature * (1 - cooling_rate)
        
        if graph [
            append energies (energy_puller current_solution)
        ]
    ]
    
    print append copy "final solution: " current_solution
    probe energies
    
    if graph [        
    
        ;;work out the graph sizes
        num_energies: length? energies
        sorted_energies: sort copy energies
        min_energy: first sorted_energies
        max_energy: last sorted_energies
        
        window_width: 500.0
        window_size: to-pair window_width
        graph_width: window_width - 100
        graph_size: to-pair graph_width
        
        x_difference: graph_width / num_energies
        y_scale: graph_width / max_energy
        
        ;;make the labels
        y_labels_size: as-pair 35 (graph_width + 10)
        y_labels_position: as-pair 25 (50 - 7)
        min_energy_y_coord: convert_y_coords graph_width (min_energy * y_scale)
        y_min_label_left_position: as-pair 0 min_energy_y_coord
        y_min_label_right_position: as-pair graph_width min_energy_y_coord
        y_min_label_positions: reduce [y_min_label_left_position y_min_label_right_position]
        
        pprobe y_min_label_positions
        pprobe [graph_width - min_energy]
        
        labels: compose/deep [
            line-width 1
            text (as-pair 0 min_energy_y_coord) (to-string min_energy)
            text 0x0 (to-string max_energy)
        ]
        
        ;;work out the border
        axis_length: graph_width - 1
        bottom_left: as-pair 0 axis_length
        bottom_right: as-pair axis_length axis_length
        top_right: as-pair axis_length 0
        top_left: as-pair 0 0
        border: reduce [bottom_left bottom_right top_right top_left]
        
        pprobe min_energy
        pprobe min_energy_y_coord
        pprobe max_energy
        
        ;;work out the actual points
        graph_points: copy []
        x: 0
        foreach y energies [
            x: x + x_difference
            location: as-pair x (convert_y_coords graph_width (y * y_scale))
            append graph_points location     
        ]
        
        ;;make the graph
        graph: compose/deep [
            line-width 1
            polygon (border)
            line (graph_points)
            line (y_min_label_positions)
        ] 
        
        view [
            size window_size
            below
            
                at 225x25
                    text "Annealer results"
                at 50x50
                    box graph_size draw graph
            return
                at y_labels_position
                    box y_labels_size draw labels
        ]
    ]
]

randomize: func [
    "Reseed the random number generator."
    /with seed "date, time, and integer values are used directly; others are converted."
][
    random/seed either find [date! time! integer!] type?/word seed [
        seed
    ] [
        to-integer checksum form any [seed now/precise] 'sha1
    ]
]

randomize

gen: func [
    /change "use the current solution to generate a new one" current_solution [any-type!]
] [
    either change [
        either (random 1.0 < 0.5) [
            return current_solution + random (current_solution / 10)
        ] [
            return current_solution - random (current_solution / 10)
        ]
    ] [
        random 1000
    ]
]
init: 300
id: func [a][a]
annealer/graph :gen init :id