-- Pawn Movement
-- UnknownParabellum
-- February 26, 2021

--[[
	
	local pawnMovement = PawnMovement.new()
	

--]]
local Knit = require(game:GetService("ReplicatedStorage").Knit)

local BaseComponent = require(script.Parent.BaseComponent)

local Action
local BoardUtil = require(Knit.Shared.Lib.BoardUtil)

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
			self.Piece.EnPassent =true
			self.__maid["Moved"] = self.Board.BeforeMoved:Connect(function()
				self.__maid["Moved"] = nil
				self.Piece.EnPassent = false
			end)
		end
	end
end

function PawnMovement:ComputeLegalMoves()
	local piece = self.Piece
	local board = self.Board
	local pos = piece.Position
	local isBlack = piece.IsBlack 

	local direction = isBlack and -1 or 1
	local isFirstMove = isBlack and pos.Y == 7 or pos.Y == 2

	--// Moving forward one
	local frontPos = pos + Vector2.new(0, direction)
	local canMoveForward = not board:GetPieceFromPosition(frontPos)

	if canMoveForward then
		piece:AddLegalMove(frontPos)
	end

	--// Jumping on first move
	local doubleFrontPos = pos + Vector2.new(0, 2 * direction)
	local canJump = isFirstMove and not board:GetPieceFromPosition(doubleFrontPos) or false

	if canJump then
		piece:AddLegalMove(doubleFrontPos)
	end

	--// Attacking right up
	local crossLeftPos = pos + Vector2.new(1,direction)
	local crossLeftPiece = board:GetPieceFromPosition(crossLeftPos)

	if crossLeftPiece then
		piece:AddLegalMove(crossLeftPos)
	end
	piece:AddAttackingMove(crossLeftPos)
	--// Attacking left up
	local crossRightPos = pos + Vector2.new(-1,direction)
	local crossRightPiece = board:GetPieceFromPosition(crossRightPos)

	if crossRightPiece then
		piece:AddLegalMove(crossRightPos)
	end
	piece:AddAttackingMove(crossRightPos)

	--// EN PASSENT

	--// Left Passent
	local leftPiece = board:GetPieceFromPosition(pos + Vector2.new(-1,0))

	if leftPiece then
		if leftPiece:HasTag("Pawn") and leftPiece:HasTag("EnPassent") then
			piece:AddLegalMove(pos + Vector2.new(-1, direction))
		end
	end
	--// Right Passent
	local rightPiece = board:GetPieceFromPosition(pos + Vector2.new(1,0))

	if rightPiece then
		if rightPiece:HasTag("Pawn") and rightPiece:HasTag("EnPassent") then
			piece:AddLegalMove(pos + Vector2.new(1, direction))
		end
	end
end

function PawnMovement.new(piece,config)
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