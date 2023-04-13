local BoardClass = require(script.Parent.BoardClass)
local ChessConstants = require(script.Parent.ChessConstants)
local PIECES_CONSTS = ChessConstants.PIECES

local PlayerClass = {}
PlayerClass.__index = PlayerClass


function PlayerClass.new()
    local self = setmetatable({
        ["PiecesMaps"] = {},

        ["ThreatMap"] = BoardClass.new(),
        ["PinMap"] = BoardClass.new()
    }, PlayerClass)

    for _, piece in pairs(PIECES_CONSTS) do
        self.PiecesMaps[piece] = BoardClass.new() 
    end

    return self
end


function PlayerClass:Destroy()
    
end


return PlayerClass
