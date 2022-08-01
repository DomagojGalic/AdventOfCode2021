using Test
using DataStructures
using StatsBase

function readNavigation(path::String)
    lines = (x -> String.(split(x, ""))).(readlines(path))
    return lines
end


function errorScore(syntax_line::Array{String, 1})
    closing_symbol = Dict(["(" => ")", "[" => "]", "{" => "}", "<" => ">"])
    error_points = Dict([")" => 3, "]" => 57, "}" => 1197, ">" => 25137])

    line_stack = Stack{String}()
    for symb in syntax_line
        if symb in keys(closing_symbol)
            push!(line_stack, symb)
        else
            previous_symb = pop!(line_stack)
            if symb != closing_symbol[previous_symb]
                return error_points[symb]
            end
        end
    end
    return 0
end

function completionScore(syntax_line::Array{String, 1})
    closing_symbol = Dict(["(" => ")", "[" => "]", "{" => "}", "<" => ">"])
    completion_points = Dict(["(" => 1, "[" => 2, "{" => 3, "<" => 4])
    current_score = 0

    line_stack = Stack{String}()
    for symb in syntax_line
        if symb in keys(closing_symbol)
            push!(line_stack, symb)
        else
            pop!(line_stack)
        end
    end

    while !isempty(line_stack)
        to_close = pop!(line_stack)
        #push!(syntax_line, closing_symbol[to_close])
        current_score = 5 * current_score + completion_points[to_close]
    end

    return current_score
end

function cumulativeErrorScore(program::Array{Array{String, 1}, 1})
    scores = errorScore.(program)
    return sum(scores)
end

function finalCompletionScore(program::Array{Array{String, 1}, 1})
    incomplete_programs = filter(x -> errorScore(x) == 0, program)
    completion_scores = completionScore.(incomplete_programs)
    return Int(median(completion_scores))
end


# Test
@test cumulativeErrorScore(readNavigation("../data/day_10_test_1.dat")) == 26397
@test finalCompletionScore(readNavigation("../data/day_10_test_1.dat")) == 288957

# Results
println("Cumulative error Score: ", cumulativeErrorScore(readNavigation("../data/day_10_ch_1.dat")))
println("Final completeion score: ", finalCompletionScore(readNavigation("../data/day_10_ch_1.dat")))