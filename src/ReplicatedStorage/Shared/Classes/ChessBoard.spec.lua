local Knit = require(game:GetService("ReplicatedStorage").Knit)

return function()
    local BoardUtil = require(Knit.Shared.Lib.BoardUtil)
    local ChessBoard = require(Knit.Shared.Classes.ChessBoard)
    local Constants = require(Knit.Shared.Constants)

    local board = ChessBoard.new(Constants.Layouts.Start)
    describe("ChessBoard", function()
        it("Returns a ChessBoard", function()
            expect(board.Class).to.equal("ChessBoard")
        end)

        local currentState = board.Board:getState()
        it("Has valid pawns", function()
            local valid = true
            for file = 1,8 do
                local position = BoardUtil.Vector2ToInt(7,file)
                local piece = currentState[position].Piece
                if not piece:HasTag("Pawn") or piece.IsBlack ~= true then
                    valid = false
                end
            end
            for file = 1,8 do
                local position = BoardUtil.Vector2ToInt(2,file)
                local piece = currentState[position].Piece
                if not piece:HasTag("Pawn") or piece.IsBlack == true then
                    valid = false
                end
            end
            expect(valid).to.equal(true)
        end)
    end)

end