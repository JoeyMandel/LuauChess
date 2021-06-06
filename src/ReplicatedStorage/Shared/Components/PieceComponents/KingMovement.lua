-- King Movement
-- UnknownParabellum
-- February 20, 2021

--[[
--]]




local BaseComponent = require(script.Parent.BaseComponent)

local BoardUtil
local toInt 

local KingMovement = setmetatable({},BaseComponent)
KingMovement.__index = KingMovement

function KingMovement:BeforeUpdate(changes)

end

function KingMovement:ComputeLegalMoves()
	local piece = self.Piece
	local board = piece.Board.Board
	local piecePos = piece.Position
	local opColor = piece.IsBlack and "White" or "Black"
	for xOff = -1,1,1 do
		for yOff = -1,1,1 do
			local currentPos = piecePos + toInt(xOff,yOff)
			piece:AddAttackingMove(currentPos)
			if ((xOff == 0) and (yOff == 0)) or piece.Board:IsAttacking(opColor,currentPos) then
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

function KingMovement:Init(framework)
	BoardUtil = framework.Shared.Lib.BoardUtil
	toInt = BoardUtil.Vector2ToInt
end

return KingMovement