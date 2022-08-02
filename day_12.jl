using Test
using DataStructures

function makeTransitions(path::String)
    lines = readlines(path)
    transitions = DefaultDict{String, Array{String, 1}}(() -> String[])
    for line in lines
        a, b = String.(split(line, "-"))
        if a == "start" || b == "end"
            push!(transitions[a], b)
            # push!(get!(transitions, a, String[]), b)  instead of DefaultDict
        elseif a == "end" || b == "start"
            push!(transitions[b], a)
        else
            push!(transitions[a], b)
            push!(transitions[b], a)
        end
    end
    return Dict(transitions)
end

function findPossibleSteps(traversed::Array{String, 1}, last_point::String,
                           transitions::Dict{String, Array{String, 1}}, expanded::Bool = false)
    if !expanded
        double_used = true
    else
        double_used = maximum(values(counter(filter(x -> lowercase(x) == x, traversed)))) > 1
    end
    possible_steps = [step for step in transitions[last_point]
                      if (!double_used || ((lowercase(step) == step && !(step in traversed)))) || (uppercase(step) == step)]
    return possible_steps
end

function followTrail(traversed::Array{String, 1}, last_point::String,
                    transitions::Dict{String, Array{String, 1}}, all_paths::Array{String, 1},
                    expanded::Bool = false)
    new_traversed = copy(traversed)
    push!(new_traversed, last_point)
    if last_point == "end"
        push!(all_paths, join(new_traversed, ","))
        return nothing
    end

    possible_steps = findPossibleSteps(new_traversed, last_point, transitions, expanded)
    for step in possible_steps
        followTrail(new_traversed, step, transitions, all_paths, expanded)
    end
    return nothing
end

function pathFinder(transitions::Dict{String, Array{String, 1}}, expanded::Bool = false)
    all_paths = String[]
    followTrail(String[], "start", transitions, all_paths, expanded)
    return all_paths
end

# Test
@test length(pathFinder(makeTransitions("../data/day_12_test_1.dat"))) == 10
@test length(pathFinder(makeTransitions("../data/day_12_test_2.dat"))) == 19
@test length(pathFinder(makeTransitions("../data/day_12_test_3.dat"))) == 226
@test length(pathFinder(makeTransitions("../data/day_12_test_1.dat"), true)) == 36
@test length(pathFinder(makeTransitions("../data/day_12_test_2.dat"), true)) == 103
@test length(pathFinder(makeTransitions("../data/day_12_test_3.dat"), true)) == 3509

# Results
println("Number of paths: ", length(pathFinder(makeTransitions("../data/day_12_ch_1.dat"))))
println("Number of expanded paths: ", length(pathFinder(makeTransitions("../data/day_12_ch_1.dat"), true)))
