local PlayerClass = require(script.PlayerClass)
local ChessConstants = require(script.Parent.ChessConstants)
local PIECES_CONSTS = ChessConstants.PIECES

local CONST_PAWN = PIECES_CONSTS.PAWN
local CONST_ROOK = PIECES_CONSTS.ROOK
local CONST_BISHOP = PIECES_CONSTS.BISHOP
local CONST_KNIGHT = PIECES_CONSTS.KNIGHT
local CONST_QUEEN = PIECES_CONSTS.QUEEN
local CONST_KING = PIECES_CONSTS.KING

local letterToPiece = {
    ["p"] = CONST_PAWN,
    ["r"] = CONST_ROOK,
    ["b"] = CONST_BISHOP,
    ["n"] = CONST_KNIGHT,
    ["q"] = CONST_QUEEN,
    ["k"] = CONST_KING
}

local ChessGameClass = {}
ChessGameClass.__index = ChessGameClass

function ChessGameClass.new()
    local self = setmetatable({
        ["White"] = PlayerClass.new(),
        ["Black"] = PlayerClass.new(), 
    }, ChessGameClass)

    return self
end

function ChessGameClass:Play()
    self:__init_board()

    
end

function ChessGameClass:Stop()
    
end


function ChessGameClass:__init_board()
    
end

--[[
    EXAMPLE FEN STRING:
    rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1
]]

function ChessGameClass:LoadFromFEN(fenString)
    local fields = fenString:split(" ")
    local piecePlacementData = fields[1]

    --Load all the pieces
    local positionIndex = 0
    for letterIndex = 1, piecePlacementData.len() do
        local letter = piecePlacementData:sub(letterIndex, letterIndex)
        local number = tonumber(letter)
        local piece = letterToPiece[string.lower(letter)]
        local isWhite = letter == string.upper(letter)
        local targetPlayer = isWhite and self.White or self.Black

        --Skip the gap
        if typeof(number) == "number" then
            positionIndex += number
            continue
        end
        -- Add piece
        targetPlayer.PiecesMaps[piece]:SetValueAt(positionIndex, true)
        positionIndex += 1
    end
end

return ChessGameClass
