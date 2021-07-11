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
        
        it("Has only two kings", function()
            local numberOfKings = 0
            for _, piece in pairs(board.Pieces) do
                if piece:HasTag("King") then
                    numberOfKings += 1
                end
            end
            expect(numberOfKings).to.equal(2)
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
            for _, x in ipairs(whiteFiles) do
                if not isValidPos(Vector2.new(x, 1), pieceTag, false) then valid = false break end
                if not isValidPos(Vector2.new(x, 8), pieceTag, true) then valid = false break end
            end
            return valid
        end

        it("Has valid pawns", function()
            local valid = true
            for file = 1,8 do                
                if not isValidPos(Vector2.new(file ,7), "Pawn", true) then valid = false break end
            end
            for file = 1,8 do
                if not isValidPos(Vector2.new(file, 2), "Pawn", false) then valid = false break end
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
            local valid = checkValid("Bishop", 3,6)
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

    local white = board.White
    local black = board.Black
    describe("Correct Color Handlers", function()
        it("Should return only 1 king per handler", function()
            local valid = true
            if #white:GetPiecesOfType("King") ~= 1 or #black:GetPiecesOfType("King") ~= 1 then
                valid = false
            end
            expect(valid).to.equal(true)
        end)
        it("Should return only 2 rooks per handler", function()
            local valid = true
            if #white:GetPiecesOfType("Rook") ~= 2 or #black:GetPiecesOfType("Rook") ~= 2 then
                valid = false
            end
            expect(valid).to.equal(true)
        end)
    end)
    -- describe("Valid Basic Movement", function()
    
    -- end)
end