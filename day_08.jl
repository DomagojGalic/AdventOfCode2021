using Test

function sanatyzeCodes(pattern::String)
    sanatyzed_pattern = String.((x -> join(sort(split(x, "")))).(split(pattern)))
    return sanatyzed_pattern
end

function parseSignalPatterns(path::String)
    lines = readlines(path)
    input_patterns = Array{String, 1}[]
    output_patterns = Array{String, 1}[]

    for line in lines
        in_pattern, out_pattern = String.(split(line, " | "))
        push!(input_patterns, sanatyzeCodes(in_pattern))
        push!(output_patterns, sanatyzeCodes(out_pattern))
    end
    return input_patterns, output_patterns
end

function countUniqueDigits(patterns::Array{Array{String, 1}, 1})
    joint_patterns = length.(hcat(patterns...))
    return sum((x -> x in [2, 3, 4, 7]).(joint_patterns))
end

function setifyString(value::String)::Set{String}
    return Set(String.(split(value, "")))
end

function decodeDigits(input_pattern::Array{String, 1}, output_pattern::Array{String, 1})
    digit_codes = Dict{Int, String}()
    code_lengths = Dict([code => length(code) for code in unique(input_pattern)])
    code_lengths_inverted = Dict([value => key for (key, value) in code_lengths])
    decernable_by_length = Dict([2 => 1, 3 => 7, 4 => 4, 7 => 8])
    for k in [2, 3, 4, 7]
        if k in keys(code_lengths_inverted)
            digit_codes[decernable_by_length[k]] = code_lengths_inverted[k]
        end
    end
    digit_codes_inverted = Dict([value => key for (key, value) in digit_codes])

    length_six = [code for (code, len) in code_lengths if len == 6]
    # Assuming that all are present
    for code in length_six
        code_set = setifyString(code)
        if setifyString(digit_codes[4]) ⊆ code_set
            digit_codes[9] = code
            digit_codes_inverted[code] = 9
        elseif setifyString(digit_codes[7]) ⊆ code_set
            digit_codes[0] = code
            digit_codes_inverted[code] = 0
        else
            digit_codes[6] = code
            digit_codes_inverted[code] = 6
        end
    end

    length_five = [code for (code, len) in code_lengths if len == 5]
    for code in length_five
        code_set = setifyString(code)
        if setifyString(digit_codes[1]) ⊆ code_set
            digit_codes[3] = code
            digit_codes_inverted[code] = 3
        elseif length(setifyString(digit_codes[4]) ∩ code_set) == 2
            digit_codes[2] = code
            digit_codes_inverted[code] = 2
        else
            digit_codes[5] = code
            digit_codes_inverted[code] = 5
        end
    end
    # decode output digits
    output_number = parse(Int, join((x -> "$(digit_codes_inverted[x])").(output_pattern)))

    return output_number
end

function decodeOutput(input_patterns::Array{Array{String, 1}, 1}, output_patterns::Array{Array{String, 1}, 1})
    output_numbers = Int[]

    for (input_pattern, output_pattern) in zip(input_patterns, output_patterns)
        output_number = decodeDigits(input_pattern, output_pattern)
        push!(output_numbers, output_number)
    end
    return output_numbers
end

# Test
@test countUniqueDigits(parseSignalPatterns("../data/day_08_test_1.dat")[2]) == 26
@test sum(decodeOutput(parseSignalPatterns("../data/day_08_test_1.dat")...)) == 61229

# Results
println("Unique occurances: ", countUniqueDigits(parseSignalPatterns("../data/day_08_ch_1.dat")[2]))
println("Sum of outputs: ", sum(decodeOutput(parseSignalPatterns("../data/day_08_ch_1.dat")...)))