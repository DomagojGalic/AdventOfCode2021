using Test
using DataStructures

function getInputs(path::String)
    inputs = permutedims((x -> parse(Int, x)).(
        hcat(split.(split(replace(String(read(path)), " -> " => ",")), ",")...)))
    return inputs
end

function getStraingtInputs(path::String)
    all_inputs = getInputs(path)
    mask = mapslices(row -> row[1] == row[3] || row[2] == row[4], all_inputs, dims = 2)
    return all_inputs[mask[:], :]
end

function minMaxRange(a::Int, b::Int)
    return min(a, b):max(a, b)
end

function interpolate(row::Array{Int, 1})
    interpolated_points = NTuple{2, Int}[]
    x1, y1, x2, y2 = row
    if x1 == x2 || y1 == y2
        for x in minMaxRange(x1, x2)
            for y in minMaxRange(y1, y2)
                push!(interpolated_points, (x, y))
            end
        end
    elseif ((x1 < x2 && y1 < y2) || (x1 > x2 && y1 > y2))
        y_min = min(y1, y2)
        for (k, x) in enumerate(minMaxRange(x1, x2))
            push!(interpolated_points, (x, y_min + k - 1))
        end
    else
        y_max = max(y1, y2)
        for (k, x) in enumerate(minMaxRange(x1, x2))
            push!(interpolated_points, (x, y_max - k + 1))
        end
    end

    return interpolated_points
end

function getAllIntermiditePoints(inputs::Array{Int, 2})
    intermediate_points = NTuple{2, Int}[]
    n, _ = size(inputs)
    for i in 1:n
        append!(intermediate_points, interpolate(inputs[i, :]))
    end
    return intermediate_points
end

function makeVulcanMap(all_points::Array{NTuple{2, Int}, 1})
    vulcan_map = DefaultDict{NTuple{2, Int}, Int}(0)
    for (x, y) in all_points
        vulcan_map[(x, y)] += 1
    end
    return vulcan_map
end

# Test
@test sum(values(makeVulcanMap(getAllIntermiditePoints(getStraingtInputs("../data/day_05_test_1.dat")))) .> 1) == 5
@test sum(values(makeVulcanMap(getAllIntermiditePoints(getInputs("../data/day_05_test_1.dat")))) .> 1) == 12

# Results
println("Dangerous: ", sum(values(makeVulcanMap(getAllIntermiditePoints(getStraingtInputs("../data/day_05_ch_1.dat")))) .> 1))
println("Dangerous all: ", sum(values(makeVulcanMap(getAllIntermiditePoints(getInputs("../data/day_05_ch_1.dat")))) .> 1))