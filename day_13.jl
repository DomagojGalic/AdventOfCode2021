using Test

function readData(path::String)
    paper, instructions = String.(split(String(read(path)), "\n\n"))
    paper_x, paper_y = Int[], Int[]
    instruction_set = Array{Tuple{String, Int}, 1}()
    for line in String.(split(paper, "\n"))
        x, y = parse.(Int, split(line, ","))
        push!(paper_x, x + 1)
        push!(paper_y, y + 1)
    end
    for inst in String.(split(replace(instructions, "fold along " => ""), "\n"))
        tp, pos = split(inst, "=")
        push!(instruction_set, (String(tp), parse(Int, pos) + 1))
    end

    paper_matrix = zeros(Int, (maximum(paper_x), maximum(paper_y)))
    for (x, y) in zip(paper_x, paper_y)
        paper_matrix[x, y] = 1
    end
    return permutedims(paper_matrix), instruction_set
end

function preparePaper(paper::Array{Int, 2})
    m, n = size(paper)
    if m % 2 == 0
        paper = vcat(paper, zeros(Int, 1, n))
    end
    if n % 2 == 0
        paper = hcat(paper, zeros(Int, m))
    end
    return paper
end

function foldPaper(paper::Array{Int, 2}, instruction::Tuple{String, Int})
    tp, pos = instruction
    paper = preparePaper(paper)
    if tp == "x"
        left = paper[:, 1:(pos - 1)]
        right = paper[:, end:-1:(pos + 1)]
        return left + right
    else
        up = paper[1:(pos - 1), :]
        down = paper[end:-1:(pos + 1), :]
        return up + down
    end
end

function countFirstFold(paper::Array{Int, 2}, instructions::Array{Tuple{String, Int}, 1})
    instruction = instructions[1]
    folded = foldPaper(paper, instruction)
    return sum(folded .> 0)
end

function foldAll(paper::Array{Int, 2}, instructions::Array{Tuple{String, Int}, 1})
    for instruction in instructions
        paper = foldPaper(paper, instruction)
    end
    return paper
end

function printPaperCode(folded_paper::Array{Int, 2})
    folded_pretty = (x -> x ? "#" : " ").(folded_paper .> 0)
    for i in 1:size(folded_pretty)[1]
        println(join(folded_pretty[i, :]))
    end
    return nothing
end

# Test
@test countFirstFold(readData("../data/day_13_test_1.dat")...) == 17

# Results
println("Dots visible: ", countFirstFold(readData("../data/day_13_ch_1.dat")...))
println("Folded paper:")
printPaperCode(foldAll(readData("../data/day_13_ch_1.dat")...))
