-- Knight Movement
-- UnknownParabellum
-- February 20, 2021

--[[
	

--]]
local Knit = require(game:GetService("ReplicatedStorage").Knit)

local BaseComponent = require(script.Parent.BaseComponent)

local BoardUtil = require(Knit.Shared.Lib.BoardUtil)

local KnightMovement = setmetatable({},BaseComponent)
KnightMovement.__index = KnightMovement

function KnightMovement:ComputeLegalMoves()
	local piece = self.Piece
	local board = self.Board:Get("Board")
	local piecePos = piece:Get("Position")

	--//For each axis, Y = -2, 2, X = -2,2, Go left or right one square and see if we can move to it
	for off1 = -2,2,4 do
		for off2 = -1,1,2 do
			local posX = BoardUtil.GetX(piecePos)
			local posY = BoardUtil.GetY(piecePos)

			local pos1 = BoardUtil.Vector2ToInt(posX + off1,posY + off2)
			local pos2 = BoardUtil.Vector2ToInt(posX + off2,posY + off2)


			piece:AddLegalMove(pos2) --//For X
			piece:AddAttackingMove(pos2)

			piece:AddLegalMove(pos1) --//For Y
			piece:AddAttackingMove(pos1)		
		end
	end
end

function KnightMovement.new(piece,config)
	local base = BaseComponent.new(piece)
	local self = setmetatable(base, KnightMovement)

	self:AddTag("Movement")
	return self
end

return KnightMovement