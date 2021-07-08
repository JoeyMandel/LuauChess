local Knit = require(game:GetService("ReplicatedStorage").Knit)

local BoardUtil = require(Knit.Shared.Lib.BoardUtil)

local ColorHandler = {}
ColorHandler.__index = ColorHandler


function ColorHandler.new()
    local self = setmetatable({
        ["Pieces"] = {},
        ["Checking"] = {},
        ["LegalMoves"] = {},
        ["Attacking"] = {},
    }, ColorHandler)
    return self
end

function ColorHandler:IsAttacking(pos)
	return BoardUtil.Get(self.Attacking,pos)
end

function ColorHandler:IsLegalMove(pos)
    return BoardUtil.Get(self.LegalMoves,pos)
end

function ColorHandler:GetPiecesOfType(type)
    local piecesOfType = {}

    for _, piece in pairs(self.Pieces) do
        if piece:HasTag(type) then
            table.insert(piecesOfType, piece)
        end
    end

    return piecesOfType
end

function ColorHandler:Reset()
    self:Destroy()
end

function ColorHandler:Destroy()
    for name,tbl in pairs(self) do
        if name ~= "Pieces" then
            for index,_ in pairs(tbl) do
                tbl[index] = nil
            end
        end
    end
end


return ColorHandler