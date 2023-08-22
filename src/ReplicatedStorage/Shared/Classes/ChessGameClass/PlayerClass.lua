local MapClass = require(script.Parent.MapClass)
local ChessConstants = require(script.Parent.ChessConstants)
local PIECES_CONSTS = ChessConstants.PIECES

local PlayerClass = {}
PlayerClass.__index = PlayerClass


function PlayerClass.new()
    local self = setmetatable({
        ["PiecesMaps"] = {},
        ["ThreatMap"] = MapClass.new(),
        ["PinMap"] = MapClass.new()
    }, PlayerClass)

    for _, piece in pairs(PIECES_CONSTS) do
        self.PiecesMaps[piece] = MapClass.new() 
    end

    return self
end


function PlayerClass:Destroy()
    
end


return PlayerClass
