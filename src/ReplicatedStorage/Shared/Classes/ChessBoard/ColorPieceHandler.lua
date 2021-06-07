local Knit = require(game:GetService("ReplicatedStorage").Knit)

local BoardUtil = require(Knit.Shared.Lib.BoardUtil)

local ColorPieceHandler = {}
ColorPieceHandler.__index = ColorPieceHandler


function ColorPieceHandler.new()
    local self = setmetatable({
        ["Pieces"] = {},

        ["Checking"] = {},
        ["LegalMoves"] = {},
        ["Attacking"] = {},
    }, ColorPieceHandler)
    return self
end

function ColorPieceHandler:IsAttacking(pos)
	local attacking = self.Attacking
	return BoardUtil.Get(attacking,pos)
end

function ColorPieceHandler:GetPiecesOfType(type)
    local piecesOfType = {}

    for _, piece in pairs(self.Pieces) do
        if piece:HasTag(type) then
            table.insert(piecesOfType, piece)
        end
    end

    return piecesOfType
end

function ColorPieceHandler:CleanForStep()
    for name,tbl in pairs(self) do
        if name ~= "Pieces" then
            local checking = (name == "Checking")
            local legalMoves = (name == "LegalMoves")
            local attacking = (name == "Attacking")

            for index,val in pairs(tbl) do
                if checking or attacking then
                    tbl[index] = nil
                elseif legalMoves then
                    for i, _ in pairs(tbl[index]) do
                        val[i] = nil
                    end
                end
            end
        end
    end
end

function ColorPieceHandler:Destroy()
    
end


return ColorPieceHandler