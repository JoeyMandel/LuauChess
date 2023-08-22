--[[

UnknownParabellum
8/19/2023
ChessGameClass:
    Acts as a simple front-end interface to internal chess game logic

]]

local PlayerClass = require(script.PlayerClass)

local ChessGameClass = {}
ChessGameClass.__index = ChessGameClass

function ChessGameClass.new()
    local self = setmetatable({}, ChessGameClass)

    return self
end

function ChessGameClass:Play()
    self:__init_board()

    
end

function ChessGameClass:Stop()
    
end

function ChessGameClass:MakeMove()
    
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
