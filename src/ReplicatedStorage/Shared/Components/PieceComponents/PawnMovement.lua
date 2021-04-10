-- Pawn Movement
-- UnknownParabellum
-- February 26, 2021

--[[
	
	local pawnMovement = PawnMovement.new()
	

--]]
local BaseComponent = require(script.Parent.BaseComponent)


local PawnMovement = setmetatable({},BaseComponent)
PawnMovement.__index = PawnMovement

function PawnMovement:BeforeUpdate(changes)
	local isBlack = self.Piece.IsBlack
	local currentPos = self.Piece.Position
	local newPos = changes[2]
	local startingRow = self.StartingRow
	
	if currentPos.Y == startingRow then
		local doubleMoved = (isBlack and newPos.Y == (startingRow - 2)) or newPos.Y == (startingRow  + 2)
		if doubleMoved then
			self.Piece.EnPassent = true
			self._maid["Moved"] = self.Piece.Board.BeforeMoved:Connect(function()
				self._maid["Moved"] = nil
				self.Piece.EnPassent = false
			end)
		end
	end
end

function PawnMovement:ComputeLegalMoves()
	local piece = self.Piece
	local board = piece.Board.Board
	local piecePos = piece.Position
	local isBlack = piece.IsBlack
	local direct = isBlack and -1 or 1

	local frontPiece = piece:GetPiece(piecePos + Vector2.new(0,direct))
	
	local leftCrossPiece = piece:GetPiece(piecePos + Vector2.new(-1,direct))
	local rightCrossPiece = piece:GetPiece(piecePos + Vector2.new(1,direct))
	
	local leftPassent = piece:GetPiece(piecePos + Vector2.new(-1,0))
	local rightPassent = piece:GetPiece(piecePos + Vector2.new(1,0))

	if not frontPiece then
		piece:AddLegalMove(piecePos + Vector2.new(0,direct))
		
		local doubleFrontPiece = piece:GetPiece(piecePos + Vector2.new(0,2*direct))
		if (piecePos.Y == self.StartingRow) and not doubleFrontPiece then -- 2 steps forward
			piece:AddLegalMove(piecePos + Vector2.new(0,2*direct))
		end
	end
	
	piece:AddAttackingMove(piecePos + Vector2.new(-1,direct))
	piece:AddAttackingMove(piecePos + Vector2.new(1,direct))

	if leftCrossPiece then -- attacking left cross
		piece:AddLegalMove(piecePos + Vector2.new(-1,direct))
	end
	if rightCrossPiece then --attacking right cross
		piece:AddLegalMove(piecePos + Vector2.new(1,direct))
	end
	
	if leftPassent then
		if leftPassent.Type == "Pawn" and leftPassent.EnPassent then
			local changes = {piecePos,piecePos + Vector2.new(-1,direct),leftPassent.Position,nil}
			
			piece:AddLegalMove(piecePos + Vector2.new(-1,direct),changes)
			piece:AddAttackingMove(piecePos + Vector2.new(-1,direct))
		end
	end
	if rightPassent then
		if rightPassent.Type == "Pawn" and rightPassent.EnPassent then
			local changes = {piecePos,piecePos + Vector2.new(1,direct),rightPassent.Position,nil}
			
			piece:AddLegalMove(piecePos + Vector2.new(1,direct),changes)
			piece:AddAttackingMove(piecePos + Vector2.new(1,direct))
		end
	end
end

function PawnMovement.new(piece,config)
	local pieceYPos = piece.Position.Y	
	local base = BaseComponent.new(piece)
	local self = setmetatable(base, PawnMovement)
	
	self:AddTag("Movement")
	
	self.Piece.EnPassent = (config.EnPassent ~= nil)
	self.StartingRow = 0
	if self.Piece.IsBlack then
		self.StartingRow = 7
	else
		self.StartingRow = 2
	end
	return self
	
end


return PawnMovement