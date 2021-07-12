-- Castling
-- UnknownParabellum
-- March 6, 2021

--[[
	Castling.new()
		Creates a new Castling Component. Inherites from BaseComponent
	Castling:CheckIfIsValidPath(pos1: Vector2, pos2: Vector2)
		Checks if this the tiles between these two positions allow for castling

--]]

local Knit = require(game:GetService("ReplicatedStorage").Knit)

local BaseComponent = require(script.Parent.BaseComponent)

local BoardUtil = require(Knit.Shared.Lib.BoardUtil)
local toInt = BoardUtil.Vector2ToInt

local x_CastlingPositions = {
	["Rook"] = {
		[1] = true,
		[8] = true,
	},
	["King"] = {
		[5] = true,
	},
}

local function checkIfInCastlingPosition(piece)
	local isValid = false

	local y = piece.IsBlack and 8 or 1
	for x, _ in pairs(x_CastlingPositions[piece.Type]) do
		if piece.Position == Vector2.new(x,y) then
			isValid = true
		end
	end

	return isValid
end

local Castling = setmetatable({},BaseComponent)
Castling.__index = Castling

function Castling:BeforeUpdate()
	self.Piece:RemoveTag("CanCastle") 
end

function Castling:CheckIfIsValidPath(pos1: Vector2,pos2: Vector2)
	local valid = true
	local oppHandler = self.Board:GetColorState(not self.Piece.IsBlack)

	local board = self.Board.Board:getState()
	local collidingPieces = BoardUtil.FireRayToPoint(board, pos1, pos2, function(tile)
		if tile.Piece then
			return true
		end
		return false
	end)
	local attacking = BoardUtil.FireRayToPoint(oppHandler.Attacking, pos1, pos2, function(value)
		return value
	end)
	
	if #collidingPieces > 0 or #attacking > 0 then
		valid = false
	end

	return valid
end

function Castling:ComputeLegalMoves()
	local piece = self.Piece
	local board = self.Board
	local currentPos = piece.Position

	if piece:HasTag("King") and piece:HasTag("CanCastle") then

		local yVal = piece.IsBlack and 8 or 1
		local rookQ = board:GetPieceFromPosition(Vector2.new(1,yVal))
		local rookK = board:GetPieceFromPosition(Vector2.new(8,yVal))
		--//Check for both rooks
		if rookQ then	
			local pathClear = self:CheckIfIsValidPath(currentPos,currentPos - Vector2.new(3,0))
			--//Check all possibilities
			if rookQ:HasTag("Rook") and rookQ.IsBlack == piece.IsBlack and rookQ:HasTag("CanCastle") and pathClear then
				local newKingPos = currentPos - Vector2.new(2,0)
				piece:AddLegalMove(newKingPos)
			end
		end
		
		if rookK then
			local pathClear = self:CheckIfIsValidPath(currentPos,currentPos + Vector2.new(2,0))
			--//Check all possibilities
			if rookK:HasTag("Rook") and rookK.IsBlack == piece.IsBlack and rookK:HasTag("CanCastle") and pathClear then
				local newKingPos = currentPos + Vector2.new(2,0)
				piece:AddLegalMove(newKingPos)
			end
		end
	end
end

function Castling.new(piece)
	local base = BaseComponent.new(piece)
	local self = setmetatable(base, Castling)
	
	if checkIfInCastlingPosition(piece) then
		self.Piece:AddTag("CanCastle") 
	end
	
	self:AddTag("Movement")
	return self
end

return Castling