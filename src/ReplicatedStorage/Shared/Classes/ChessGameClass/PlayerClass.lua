local BitBoardClass = require(script.Parent.BitBoardClass)

local PlayerClass = {}
PlayerClass.__index = PlayerClass


function PlayerClass.new()
    local self = setmetatable({
        ["PiecesMaps"] = {},

        ["ThreatMap"] = BitBoardClass.new(),
        ["PinMap"] = BitBoardClass.new()
    }, PlayerClass)

    

    return self
end


function PlayerClass:Destroy()
    
end


return PlayerClass
