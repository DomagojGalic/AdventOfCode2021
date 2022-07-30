using Test
using DelimitedFiles
using RollingFunctions

function ReadData(path::String)
    depths = readdlm(path, '\t', Int, '\n')[:]
    return depths
end

function RollingDepths(path::String)
    depths = ReadData(path)
    rolling_depths = Int.(rolling(sum, depths, 3))
    return rolling_depths
end

function IncreasingSeaFloor(depths::Array{Int, 1})
    differences = diff(depths)
    return sum(differences .> 0)
end

# Test
@test IncreasingSeaFloor(ReadData("../data/day_01_test_1.dat")) == 7
@test IncreasingSeaFloor(RollingDepths("../data/day_01_test_1.dat")) == 5

# Results
println("Number of Increases: ", IncreasingSeaFloor(ReadData("../data/day_01_ch_1.dat")))
println("Number of Increases with 3-rolling window: ", IncreasingSeaFloor(RollingDepths("../data/day_01_ch_1.dat")))