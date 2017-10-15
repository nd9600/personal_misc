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
] [
    temperature: 10000.0
    cooling_rate: 0.03
    
    current_solution: initial_solution
    
    while [temperature > 1] [
        new_solution: do solution_generator
        
        current_energy: energy_puller current_solution
        new_energy: energy_puller new_solution
        
        if (should_accept current_energy new_energy temperature) [
            current_solution: new_solution
        ]
        temperature: temperature * (1 - cooling_rate)
        
        ;print ""
        ;print append copy "temperature: " temperature
        ;print append copy "new solution: " new_solution
        ;print append copy "current solution: " current_solution
        ;do-events/no-wait
    ]
    
    print append copy "final solution: " current_solution
]