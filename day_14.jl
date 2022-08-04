using Test
using DataStructures

function processPolyPairs(poly_pairs::Array{String, 1})
    poly_dict = Dict{String, String}()
    for poly_pair in poly_pairs
        poly_key, poly_value_single = String.(split(poly_pair, " -> "))
        poly_dict[poly_key] = poly_value_single
    end
    return poly_dict
end

function readPolymers(path::String)
    polymer_template, poly_pairs_gross = String.(split(String(read(path)), "\n\n"))
    poly_pairs_gross = String.(split(poly_pairs_gross, "\n"))
    poly_pairs = processPolyPairs(poly_pairs_gross)
    return polymer_template, poly_pairs
end

function polyPairsBreakUp(poly_pairs::Dict{String, String})
    poly_pairs_break = Dict{String, Array{String, 1}}()
    for (key, value) in poly_pairs
        poly_pairs_break[key] = [key[1:1] * value, value * key[2:2]]
    end
    return poly_pairs_break
end

function templateToPairsBreak(poly_template::String)
    template_pairs = String[]
    for i in 1:(length(poly_template) - 1)
        push!(template_pairs, poly_template[i:(i + 1)])
    end
    template_pairs_count = counter(template_pairs)
    return Dict(template_pairs_count)
end

function expansionStep(poly_template_pairs::Dict{String, Int}, poly_pairs_break::Dict{String, Array{String, 1}})
    poly_template_pairs_new = Dict{String, Int}()
    #println("break pairs: ", poly_pairs_break)
    for (key, value) in poly_template_pairs
        pair_breaks = get(poly_pairs_break, key, [key])
        for break_off in pair_breaks
            poly_template_pairs_new[break_off] = get(poly_template_pairs_new, break_off, 0) + value
        end
    end
    return poly_template_pairs_new
end

function getRangeDifference(poly_template::String, poly_pairs_count::Dict{String, Int})
    elements_count = Dict{String, Int}()
    for (key, value) in poly_pairs_count
        for i in 1:2
            elements_count[key[i:i]] = get(elements_count, key[i:i], 0) + value
        end
    end
    # didn't double count first and last element in pairs
    elements_count[poly_template[1:1]] += 1
    elements_count[poly_template[end:end]] += 1
    occurances = values(elements_count)
    # double counting in pairs
    return (maximum(occurances) - minimum(occurances)) ÷ 2
end

function quantityDifference(poly_template::String, poly_pairs::Dict{String, String}; steps::Int = 10)
    template_pairs_count = templateToPairsBreak(poly_template)
    poly_pairs_break = polyPairsBreakUp(poly_pairs)
    for _ in 1:steps
        template_pairs_count = expansionStep(template_pairs_count, poly_pairs_break)
    end
    #println(template_pairs_count)
    return getRangeDifference(poly_template, template_pairs_count)
end

#println("Element quantity difference: ", quantityDifference(readPolymers("../data/day_14_test_1.dat")..., steps = 2))
#println(templateToPairsBreak("NBCCNBBBCBHCB"))
#@test quantityDifference(readPolymers("../data/day_14_test_1.dat")..., steps = 2) == (x -> x[2] - x[1])(extrema(values(counter([i for i in "NBCCNBBBCBHCB"]))))

# Test
@test quantityDifference(readPolymers("../data/day_14_test_1.dat")...) == 1588
@test quantityDifference(readPolymers("../data/day_14_test_1.dat")..., steps = 40) == 2188189693529

# Results
println("Element quantity differences: ", quantityDifference(readPolymers("../data/day_14_ch_1.dat")...))
println("Element quantity differences: ", quantityDifference(readPolymers("../data/day_14_ch_1.dat")..., steps = 40))

