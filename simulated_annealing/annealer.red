Red [
    Title: "Simulated annealer"
    Documentation: http://www.theprojectspot.com/tutorial-post/simulated-annealing-algorithm-for-beginners
]

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
        
        ;print ""
        ;print append copy "temperature: " temperature
        ;print append copy "acceptance: " acceptance
        ;print append copy "new solution: " new_solution
        ;print append copy "current solution: " current_solution
        ;do-events/no-wait
    ]
    
    print append copy "final solution: " current_solution
    probe energies
    
    if graph [        
        num_energies: length? energies
        max_energy: last sort copy energies
        
        window_width: 500.0
        graph_width: window_width - 100
        
        axis_length: graph_width - 1
        bottom_left: as-pair 0 axis_length
        bottom_right: as-pair axis_length axis_length
        top_right: as-pair axis_length 0
        top_left: as-pair 0 0
        border: reduce [bottom_left bottom_right top_right top_left]
        
        x_difference: graph_width / num_energies
        y_scale: graph_width / max_energy
        
        probe num_energies
        probe x_difference
        
        window_size: to-pair window_width

        graph_points: copy []
        x: 0
        foreach y energies [
            x: x + x_difference
            location: as-pair x (y * y_scale)
            append graph_points location     
        ]
                
        graph: compose/deep [
            ; pen pattern flip-y
            line-width 1
            polygon (border)
            line (graph_points) 
        ] 
        ;write %graph.txt graph

        view [
            size window_size
            at 225x25
                text "Annealer results"
            at 50x50
                box graph_size draw graph
        ]
    ]
]

randomize: func [
    "Reseed the random number generator."
    /with seed "date, time, and integer values are used directly; others are converted."
][
    random/seed either find [date! time! integer!] type?/word seed [seed] [
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