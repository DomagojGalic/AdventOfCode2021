using Test
using StatsBase

function getInput(path::String)
    input = parse.(Int, split(String(read(path)), ","))
    return input
end

function adjustmentCost(positions::Array{Int, 1}, target::Int)
    return sum(abs.(positions .- target))
end

function successiveSum(n::Int)
    return Int(n * (n + 1) / 2)
end

function nonConstantAdjustmentCost(positions::Array{Int, 1}, target::Int)
    return sum(successiveSum.(abs.(positions .- target)))
end

function getHorizontalAlignment(positions::Array{Int, 1})
    target_cost = Dict{Int, Int}()
    for target in (mode(positions) - 1):Int(ceil(mean(positions)))
        cost = adjustmentCost(positions, target)
        target_cost[cost] = target
    end
    minimal_cost = minimum(keys(target_cost))
    return minimal_cost
end

function getNonConstantHorizontalAlignment(positions::Array{Int, 1})
    target_cost = Dict{Int, Int}()
    for target in minimum(positions):maximum(positions)
        cost = nonConstantAdjustmentCost(positions, target)
        target_cost[cost] = target
    end
    minimal_cost = minimum(keys(target_cost))
    return minimal_cost
end


# Test
@test getHorizontalAlignment(getInput("../data/day_07_test_1.dat")) == 37
@test getNonConstantHorizontalAlignment(getInput("../data/day_07_test_1.dat")) == 168

# Results
println("Minimal fuel expenditure: ", getHorizontalAlignment(getInput("../data/day_07_ch_1.dat")))
println("Minimal non-constant fuel expenditure: ", getNonConstantHorizontalAlignment(getInput("../data/day_07_ch_1.dat")))