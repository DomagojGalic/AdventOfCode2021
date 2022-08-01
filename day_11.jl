using Test

function getStatusMatrix(path::String)
    lines = readlines(path)
    status_matrix = hcat((x -> parse.(Int, x)).(split.(lines, ""))...)
    return permutedims(status_matrix)
end

function step(status_matrix::Array{Int, 2})
    status_matrix_padded = zeros(Int, (12, 12)) .- 1000
    status_matrix_padded[2:11, 2:11] = status_matrix .+ 1
    flash_matrix = zeros(Int, (12, 12))

    flashes_previous = 0
    while true
        for i in 2:11
            for j in 2:11
                if flash_matrix[i, j] == 0 && status_matrix_padded[i, j] > 9
                    flash_matrix[i, j] = 1
                    for k in -1:1
                        for l in -1:1
                            status_matrix_padded[i + k, j + l] += 1
                        end
                    end
                end
            end
        end

        flashes = sum(flash_matrix)
        if flashes == flashes_previous
            break
        end
        flashes_previous = flashes
    end

    status_matrix = status_matrix_padded[2:11, 2:11]
    status_matrix[status_matrix .> 9] .= 0

    return status_matrix, flashes_previous
end

function countFlashes(status_matrix::Array{Int, 2}, steps = 100)
    flashes = Int[]
    for _ in 1:steps
        status_matrix, no_flashes = step(status_matrix)
        push!(flashes, no_flashes)
    end
    return sum(flashes)
end

function findSyncronisation(status_matrix::Array{Int, 2})
    step_counter = 1
    while true
        status_matrix, no_flashes = step(status_matrix)
        if no_flashes == 100
            return step_counter
        end
        step_counter += 1
    end
end


# Test
@test countFlashes(getStatusMatrix("../data/day_11_test_1.dat")) == 1656
@test findSyncronisation(getStatusMatrix("../data/day_11_test_1.dat")) == 195

# Results
println("Flashes: ", countFlashes(getStatusMatrix("../data/day_11_ch_1.dat")))
println("Synchronizing at step: ", findSyncronisation(getStatusMatrix("../data/day_11_ch_1.dat")))
                    
