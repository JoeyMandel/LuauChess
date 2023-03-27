local PlayerClass = require(script.PlayerClass)

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

return ChessGameClass
