using Test
using DataStructures

function readCaveRisk(path::String)
    lines = readlines(path)
    cave_risk = permutedims(hcat((x -> parse.(Int, x)).(split.(lines, ""))...))
    return cave_risk
end

function readCaveRiskExpanded(path::String)
    cave_risk = readCaveRisk(path)
    m, n = size(cave_risk)
    expanded_cave_risk = zeros(Int, size(cave_risk) .* 5)
    for i in 1:(5 * m)
        for j in 1:(5 * n)
            addition =  (i ÷ m - (i % m == 0 ? 1 : 0) + j ÷ n - (j % n == 0 ? 1 : 0))
            expanded_cave_risk[i, j] = mod1(addition + cave_risk[mod1(i, m), mod1(j, n)], 9)
        end
    end
    return expanded_cave_risk
end

function followPath(predicessors::Dict{NTuple{2, Int}, NTuple{2, Int}}, end_point::NTuple{2, Int})
    path = NTuple{2, Int}[end_point]
    while true
        last_point = path[end]
        if !(last_point in keys(predicessors))
            break
        end
        push!(path, predicessors[last_point])
    end
    return path[end:-1:1]
end

function minimalRiskPathDijkstra(cave_risk::Array{Int, 2})
    upper_bound = sum(size(cave_risk)) * 10
    m, n = size(cave_risk)
    start = (1, 1)
    pq = PriorityQueue{NTuple{2, Int}, Int}()
    distances = Dict{NTuple{2, Int}, Int}()
    predecessor = Dict{NTuple{2, Int}, NTuple{2, Int}}()
    distances[start] = 0
    enqueue!(pq, start => 0)

    for i in 1:m
        for j in 1:n
            if (i, j) == start
                continue
            end
            enqueue!(pq, (i, j) => get(distances, (i, j), upper_bound))
        end
    end

    while !isempty(pq)
        current_point = dequeue!(pq)
        if !(current_point in keys(distances))
            continue
        end
        for step in [(-1, 0), (0, 1), (1, 0), (0, -1)]
            new_point = current_point .+ step
            if !(new_point in keys(pq))
                continue
            end
            proposed_distance = distances[current_point] + cave_risk[new_point...]
            if proposed_distance < get(distances, new_point, upper_bound)
                distances[new_point] = proposed_distance
                predecessor[new_point] = current_point
                pq[new_point] = proposed_distance
            end
        end
    end
    return distances[(m, n)]
end

# Test
@test minimalRiskPathDijkstra(readCaveRisk("../data/day_15_test_1.dat")) == 40

# Results
println("Minimal risk of a path: ", minimalRiskPathDijkstra(readCaveRisk("../data/day_15_ch_1.dat")))
println("Minimal risk of a path in exp matrix: ", minimalRiskPathDijkstra(readCaveRiskExpanded("../data/day_15_ch_1.dat")))