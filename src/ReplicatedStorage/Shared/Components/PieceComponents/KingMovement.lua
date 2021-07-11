-- King Movement
-- UnknownParabellum
-- February 20, 2021

--[[
--]]


local Knit = require(game:GetService("ReplicatedStorage").Knit)

local BaseComponent = require(script.Parent.BaseComponent)

local BoardUtil = require(Knit.Shared.Lib.BoardUtil)
local toInt = BoardUtil.Vector2ToInt

local KingMovement = setmetatable({},BaseComponent)
KingMovement.__index = KingMovement

function KingMovement:ComputeLegalMoves()
	local piece = self.Piece
	local piecePos = piece.Position
	local oppHandler = self.Board:GetColorState(not piece.IsBlack)

	for xOff = -1,1,1 do
		for yOff = -1,1,1 do
			local currentPos = piecePos + Vector2.new(xOff,yOff)
			piece:AddAttackingMove(currentPos)
			if ((xOff == 0) and (yOff == 0)) or oppHandler:IsAttacking(currentPos) then
				continue
			end
			piece:AddLegalMove(currentPos)
		end
	end
end

function KingMovement.new(piece,config)
	local base = BaseComponent.new(piece)
	local self = setmetatable(base, KingMovement)
	self:AddTag("Movement")
	return self
end


return KingMovement