-- King Movement
-- UnknownParabellum
-- February 20, 2021

--[[
--]]




local BaseComponent = require(script.Parent.BaseComponent)


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
			piece:AddAttackingMove(piecePos + Vector2.new(xOff,yOff))
			if ((xOff == 0) and (yOff == 0)) or piece.Board:IsAttacking(opColor,piecePos + Vector2.new(xOff,yOff)) then
				continue
			end
			piece:AddLegalMove(piecePos + Vector2.new(xOff,yOff))
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