using Test

function sanitizeInputs(path::String)
    lines = readlines(path)
    directions = String[]
    magnitudes = Int[]
    for line in lines
        direction, magnitude = split(line)
        push!(directions, direction)
        push!(magnitudes, parse(Int, magnitude))
    end
    return directions, magnitudes
end

function computePosition(directions::Array{String, 1}, magnitudes::Array{Int, 1})
    position_horizontal = 0
    position_vertical = 0

    for (direction, magnitude) in zip(directions, magnitudes)
        if direction == "forward"
            position_horizontal += magnitude
        elseif direction == "up"
            position_vertical -= magnitude
        elseif direction == "down"
            position_vertical += magnitude
        else
            throw(ArgumentError("\"$(direction)\" is invalid direction command"))
        end
    end
    return position_horizontal, position_vertical
end

function computePositionWithAim(directions::Array{String, 1}, magnitudes::Array{Int, 1})
    position_horizontal = 0
    position_vertical = 0
    aim = 0

    for (direction, magnitude) in zip(directions, magnitudes)
        if direction == "forward"
            position_horizontal += magnitude
            position_vertical += magnitude * aim
        elseif direction == "up"
            aim -= magnitude
        elseif direction == "down"
            aim += magnitude
        else
            throw(ArgumentError("\"$(direction)\" is invalid direction command"))
        end
    end
    return position_horizontal, position_vertical
end


# Test
@test prod(computePosition(sanitizeInputs("../data/day_02_test_1.dat")...)) == 150
@test prod(computePositionWithAim(sanitizeInputs("../data/day_02_test_1.dat")...)) == 900

# Results
println("Solution: ", prod(computePosition(sanitizeInputs("../data/day_02_ch_1.dat")...)))
println("Solution with aim: ", prod(computePositionWithAim(sanitizeInputs("../data/day_02_ch_1.dat")...)))
