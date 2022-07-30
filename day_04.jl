using Test

function getInputs(path::String)
    lines = split(String(read(path)), "\n\n")
    draws = parse.(Int, split(lines[1], ","))
    boards = (board -> permutedims(reshape(parse.(Int, split(
        replace(board, "\n" => " "))), (5, 5)))).(lines[2:end])
    return draws, boards
end

function checkBoardWinner(draw, board)
    candidates = Dict{NTuple{2, Int}, Array{Int, 1}}()
    for i in 1:5
        candidates[(i, -1)] = board[i, :]
        candidates[(-1, i)] = board[:, i]
    end

    for (key, candidate) in candidates
        if length(intersect(candidate, draw)) == 5
            return sum(setdiff(Set(board), draw)) * draw[end]
        end
    end
    return -1
end

function getWinningBoard(draws, boards)
    for i in 5:length(draws)
        for board in boards
            draw = draws[1:i]
            is_winner = checkBoardWinner(draw, board)
            if is_winner != -1
                return is_winner
            end
        end
    end
    return -1
end

function getLosingBoard(draws, boards)
    last_winner = -1
    for i in 5:length(draws)
        if length(boards) == 0
            break
        end
        for board in boards
            draw = draws[1:i]
            is_winner = checkBoardWinner(draw, board)
            if is_winner != -1
                last_winner = is_winner
                boards = filter(x -> !isequal(x, board), boards)
            end
        end
    end
    return last_winner
end


# Test
@test getWinningBoard(getInputs("../data/day_04_test_1.dat")...) == 4512
@test getLosingBoard(getInputs("../data/day_04_test_1.dat")...) == 1924

# Results
println("winning board: ", getWinningBoard(getInputs("../data/day_04_ch_1.dat")...))
println("Losing board: ", getLosingBoard(getInputs("../data/day_04_ch_1.dat")...))





