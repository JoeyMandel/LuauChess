-- Castling
-- UnknownParabellum
-- March 6, 2021

--[[
	
	local Castling = Castling.new()
	

	--]]
local Knit = require(game:GetService("ReplicatedStorage").Knit)

local BaseComponent = require(script.Parent.BaseComponent)

local BoardUtil = require(Knit.Shared.Lib.BoardUtil)
local toInt = BoardUtil.Vector2ToInt

local Action

local Castling = setmetatable({},BaseComponent)
Castling.__index = Castling

function Castling:BeforeUpdate()
	--//When a piece is moved remove castling rights
	self.Piece.CanCastle = false
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

	if piece:HasTag("King") and piece.CanCastle then

		local yVal = piece.IsBlack and 8 or 1
		local rookQ = board:GetPieceFromPosition(Vector2.new(1,yVal))
		local rookK = board:GetPieceFromPosition(Vector2.new(8,yVal))
		--//Check for both rooks
		if rookQ then	
			local pathClear = self:CheckIfIsValidPath(currentPos,currentPos - Vector2.new(3,0))
			--//Check all possibilities
			if rookQ:HasTag("Rook") and rookQ.IsBlack == piece.IsBlack and rookQ.CanCastle and pathClear then
				local newKingPos = currentPos - Vector2.new(2,0)
				local rookPos = rookQ.Position
				local newRookPos = rookPos + Vector2.new(2,0)
				piece:AddLegalMove(newKingPos,true)
			end
		end
		
		if rookK then
			local pathClear = self:CheckIfIsValidPath(currentPos,currentPos + Vector2.new(2,0))
			--//Check all possibilities
			if rookK:HasTag("Rook") and rookK.IsBlack == piece.IsBlack and rookK.CanCastle and pathClear then
				local newKingPos = currentPos + Vector2.new(2,0)
				local rookPos = rookQ.Position
				local newRookPos = rookPos - Vector2.new(2,0)
				piece:AddLegalMove(newKingPos,true)
			end
		end
	end
end

function Castling.new(piece)
	local base = BaseComponent.new(piece)
	local self = setmetatable(base, Castling)
	
	piece.CanCastle = false
	
	local currentPos = piece.Position
	local validPos = {}
	if piece:HasTag("Rook") then
		--//Determine if the rook is in a valid castling position and add position to valid positions
		if piece.IsBlack then
			validPos[toInt(1,8)] = true
			validPos[toInt(8,8)] = true
		else
			validPos[toInt(1,1)] = true
			validPos[toInt(8,1)] = true
		end
	elseif piece:HasTag("King") then
		--//Determine if the king is in a valid castling position
		if piece.IsBlack then
			validPos[toInt(5,8)] = true
		else
			validPos[toInt(5,1)] = true
		end
	end
	--// If valid then can castle :)
	if validPos[toInt(currentPos)] then
		piece.CanCastle = true
	end
	
	self:AddTag("Movement")
	return self
end

return Castling