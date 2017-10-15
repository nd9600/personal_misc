Red [
    Title: "Simulated annealer"
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
        probability: exp (((to-float current_energy) - new_energy) / temperature)
        return (probability > random 1.0)
    ]
]

annealer: func [
    "The simulated annealer driver"
] [
    temperature: 10000.0
    cooling_rate: 0.03
    
    current_solution: 900
    
    while [temperature > 1] [
        new_solution: random 1000
        
        current_energy: current_solution
        new_energy: new_solution
        
        if (should_accept current_energy new_energy temperature) [
            current_solution: new_solution
        ]
        temperature: temperature * (1 - cooling_rate)
        
        probe ""
        probe append copy "temperature: " temperature
        probe append copy "new solution: " new_solution
        probe append copy "current solution: " current_solution
        do-events/no-wait
    ]
    
    print append copy "final solution: " current_solution
]