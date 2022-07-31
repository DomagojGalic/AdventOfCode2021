using Test
using DataStructures

function getInput(path::String)
    input = parse.(Int, split(String(read(path)), ","))
    input_breakdown = counter(input)
    for i in 0:8
        if !(i in keys(input_breakdown))
            input_breakdown[i] = 0
        end
    end
    return Dict(input_breakdown)
end

function step(state::Dict{Int, Int})
    new_state = Dict{Int, Int}()
    for i in 0:7
        new_state[i] = state[i + 1]
    end
    new_state[8] = state[0]
    new_state[6] += state[0]
    return new_state
end

function generations(initial_state::Dict{Int, Int}, steps::Int)
    new_state = initial_state
    for _ in 1:steps
        new_state = step(new_state)
    end
    return new_state
end

# Test
@test sum(values(generations(getInput("../data/day_06_test_1.dat"), 18))) == 26
@test sum(values(generations(getInput("../data/day_06_test_1.dat"), 80))) == 5934
@test sum(values(generations(getInput("../data/day_06_test_1.dat"), 256))) == 26984457539

# Results
println("Fish number: ", sum(values(generations(getInput("../data/day_06_ch_1.dat"), 80))))
println("Fish number, 256 days: ", sum(values(generations(getInput("../data/day_06_ch_1.dat"), 256))))
