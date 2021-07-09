local Knit = require(game:GetService("ReplicatedStorage").Knit)

return function()
    local BoardUtil = require(Knit.Shared.Lib.BoardUtil)
    local ChessBoard = require(Knit.Shared.Classes.ChessBoard)
    local Constants = require(Knit.Shared.Constants)

    local board = ChessBoard.new(Constants.Layouts.Start)
    describe("Correct FEN Loading", function()
        it("Returns a ChessBoard", function()
            expect(board.Class).to.equal("ChessBoard")
        end)

        local currentState = board.Board:getState()

        local function isValidPos(pos, pieceTag, isBlack)
            local position = BoardUtil.Vector2ToInt(pos)
            local piece = currentState[position].Piece

            if not piece:HasTag(pieceTag) or piece.IsBlack ~= isBlack then
                return false
            end
            return true
        end

        local function checkValid(pieceTag, ...) 
            local whiteFiles = {...}
            local valid = true
            for _, pos in ipairs(whiteFiles) do
                if not isValidPos(Vector2.new(pos.X, 1), pieceTag, false) then valid = false break end
                if not isValidPos(Vector2.new(pos.X, 8), pieceTag, true) then valid = false break end
            end
        end

        it("Has valid pawns", function()
            local valid = true
            for file = 1,8 do                
                if not isValidPos(Vector2.new(file ,7), "Pawn", true) then valid = false break end
            end
            for file = 1,8 do
                if isValidPos(Vector2.new(file, 2), "Pawn", false) then valid = false break end
            end
            expect(valid).to.equal(true)
        end)
        it("Has valid rooks", function()
            local valid = checkValid("Rook", 1,8)
            expect(valid).to.equal(true)
        end)
        it("Has valid knights", function()
            local valid = checkValid("Knight", 2,7)
            expect(valid).to.equal(true)
        end)
        it("Has valid bishops", function()
            local valid = checkValid("Knight", 3,6)
            expect(valid).to.equal(true)
        end)
        it("Has valid queen", function()
            local valid = checkValid("Queen", 4)
            expect(valid).to.equal(true)
        end)
        it("Has valid king", function()
            local valid = checkValid("King", 5)
            expect(valid).to.equal(true)
        end)
    end)

end