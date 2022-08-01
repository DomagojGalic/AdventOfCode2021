using Test
using DataStructures

function readSmokeMap(path::String)
    lines = readlines(path)
    interior_points = hcat((x -> parse.(Int, x)).(split.(lines, ""))...)
    padded_map = zeros(Int, size(interior_points) .+ 2) .+ 9
    padded_map[2:(end - 1), 2:(end - 1)] = interior_points
    return permutedims(padded_map)
end

function readBasinMap(smoke_map::Array{Int, 2})
    return (x -> x == 9 ? -1 : 0).(smoke_map)
end

function getNeighbours(map::Array{Int, 2}, i::Int, j::Int)
    neighbours = Int[]
    push!(neighbours, map[i + 1, j])
    push!(neighbours, map[i - 1, j])
    push!(neighbours, map[i, j + 1])
    push!(neighbours, map[i, j - 1])

    return neighbours
end

function findRiskPoints(smoke_map::Array{Int, 2})
    m, n = size(smoke_map)
    risk_points = Int[]
    for i in 2:(m - 1)
        for j in 2:(n - 1)
            center = smoke_map[i, j]
            neighbours = getNeighbours(smoke_map, i, j)
            if sum(center .>= neighbours) == 0
                push!(risk_points, center)
            end
        end
    end
    return risk_points, sum(risk_points .+ 1)
end

function getBasinSizeProd(basin_map::Array{Int, 2})
    basin_sizes = sort([value for (key, value) in counter(basin_map[:]) if key != -1], rev = true)
    basin_size_prod = prod(basin_sizes[1:3])
    return basin_size_prod
end

function findBasins(basin_map::Array{Int, 2})
    basin_label = 1
    m, n = size(basin_map)

    for i in 2:(m - 1)
        for j in 2:(n - 1)
            if basin_map[i, j] == -1
                continue
            end
            max_neighbour = basin_map[i - 1, j] > basin_map[i, j - 1] ? basin_map[i - 1, j] : basin_map[i, j - 1]
            if max_neighbour > 0
                basin_map[i, j] = max_neighbour
            elseif basin_map[i - 1, j - 1] != -1 && !(basin_map[i, j - 1] * basin_map[i - 1, j] == 1)
                basin_map[i, j] = basin_map[i - 1, j - 1]
            elseif basin_map[i - 1, j + 1] != -1 && !(basin_map[i, j + 1] * basin_map[i - 1, j] == 1)
                basin_map[i, j] = basin_map[i - 1, j + 1]
            else
                basin_map[i, j] = basin_label
                basin_label += 1
            end
        end
    end

    basin_size_prod_old = getBasinSizeProd(basin_map)
    while true
        for i in (m - 1):-1:2
            for j in (n - 1):-1:2
                if basin_map[i, j] == -1
                    continue
                end 
                neighbours = getNeighbours(basin_map, i, j)
                basin_map[i, j] = maximum(neighbours)
            end
        end

        for i in 2:(m - 1)
            for j in (n - 1):-1:2
                if basin_map[i, j] == -1
                    continue
                end 
                neighbours = getNeighbours(basin_map, i, j)
                basin_map[i, j] = maximum(neighbours)
            end
        end

        for i in (m - 1):-1:2
            for j in 2:(n - 1)
                if basin_map[i, j] == -1
                    continue
                end 
                neighbours = getNeighbours(basin_map, i, j)
                basin_map[i, j] = maximum(neighbours)
            end
        end

        basin_size_prod = getBasinSizeProd(basin_map)
        if basin_size_prod == basin_size_prod_old
            break
        end
        basin_size_prod_old = basin_size_prod
    end
    return basin_size_prod_old
end


# Test
@test findRiskPoints(readSmokeMap("../data/day_09_test_1.dat"))[2] == 15
@test findBasins(readBasinMap(readSmokeMap("../data/day_09_test_1.dat"))) == 1134

# Results
println("Risk score: ", findRiskPoints(readSmokeMap("../data/day_09_ch_1.dat"))[2])
println("biggest bassins: ", findBasins(readBasinMap(readSmokeMap("../data/day_09_ch_1.dat"))))