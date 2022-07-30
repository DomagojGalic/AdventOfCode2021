using Test
using DelimitedFiles
using DataStructures


function getBitMap(path)
    lines = readlines(path)
    bit_map = permutedims((x -> parse(Int, x[1])).(hcat(split.(lines, "")...)))
    return bit_map
end

function getMinOccurances(bit_array::Array{Int, 1})
    d = counter(bit_array)
    min_value = collect(keys(d))[argmin(collect(values(d)))]
    return min_value
end

function getMaxOccurances(bit_array::Array{Int, 1})
    d = counter(bit_array)
    max_value = collect(keys(d))[argmax(collect(values(d)))]
    return max_value
end

function getDecimalValue(bit_array::Array{Int, 2})
    return parse(Int, join((x -> "$(x)").(bit_array[:])), base = 2)
end

function computeGERates(bit_map::Array{Int, 2})
    gama_rate = getDecimalValue(mapslices(getMaxOccurances, bit_map, dims = 1))
    epsilon_rate = getDecimalValue(mapslices(getMinOccurances, bit_map, dims = 1))
    return gama_rate, epsilon_rate
end

function getOxyRate(bit_map::Array{Int, 2})
    _, no_bits = size(bit_map)
    for current_bit in 1:no_bits
        if size(bit_map)[1] == 1
            return bit_map
        else
            bit_array = bit_map[:, current_bit]
            d = counter(bit_array)
            masker = 1
            if d[0] != d[1]
                masker = getMaxOccurances(bit_array)
            end
            bit_map = bit_map[bit_array .== masker, :]
        end
    end
    if size(bit_map)[1] != 1
        throw(AssertionError("Final size > 1"))
    end
    return bit_map
end

function getCarbonRate(bit_map::Array{Int, 2})
    _, no_bits = size(bit_map)
    for current_bit in 1:no_bits
        if size(bit_map)[1] == 1
            return bit_map
        else
            bit_array = bit_map[:, current_bit]
            d = counter(bit_array)
            masker = 0
            if d[0] != d[1]
                masker = getMinOccurances(bit_array)
            end
            bit_map = bit_map[bit_array .== masker, :]
        end
    end
    if size(bit_map)[1] != 1
        throw(AssertionError("Final size > 1"))
    end
    return bit_map
end

function computeOCRates(bit_map::Array{Int, 2})
    oxy_rate = getDecimalValue(getOxyRate(bit_map))
    carbon_rate = getDecimalValue(getCarbonRate(bit_map))
    return oxy_rate, carbon_rate
end

# Test
@test prod(computeGERates(getBitMap("../data/day_03_test_1.dat"))) == 198
@test prod(computeOCRates(getBitMap("../data/day_03_test_1.dat"))) == 230


# Results
println("Power consumption: ", prod(computeGERates(getBitMap("../data/day_03_ch_1.dat"))))
println("Life support rating: ", prod(computeOCRates(getBitMap("../data/day_03_ch_1.dat"))))
