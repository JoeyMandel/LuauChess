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
	self.Piece:Set("CanCastle",false)
end

function Castling:CheckIfIsValidPath(pos1: number,pos2: number)
	local isValidPath = true
	local oppColor = BoardUtil.GetColor(not self.IsBlack)

	local board = self.Board.Board
	for offPos = pos1,pos2,(pos2 < pos1 and -1 or 1) do
		local tile = BoardUtil:Get(board,offPos)
		local attacking = BoardUtil:Get(self.Board:Get(oppColor).Attacking,offPos)
		if tile or attacking then
			if tile.Piece or attacking then
				isValidPath = false
				break
			end
		end
	end
end

function Castling:ComputeLegalMoves()
	local piece = self.Piece
	local board = self.Board
	local currentPos = piece.Position

	if piece:HasTag("King") and piece.CanCastle then
		local oppColor = BoardUtil.GetColor(not piece.IsBlack)
		local curColor = BoardUtil.GetColor(piece.IsBlack)

		local yVal = piece.IsBlack and 8 or 1
		local rookQ = piece:GetPiece(Vector2.new(1,yVal))
		local rookK = piece:GetPiece(Vector2.new(8,yVal))
		--//Check for both rooks
		if rookQ then	
			local pathClear = self:CheckIfIsValidPath(currentPos,currentPos - 3)
			--//Check all possibilities
			if rookQ:HasTag("Rook") and rookQ.IsBlack == piece.IsBlack and rookQ.CanCastle and pathClear then
				local newKingPos = currentPos - 2
				local rookPos = rookQ.Position
				local newRookPos = rookPos + 3
				piece:AddLegalMove(newKingPos,Action.new("Move",currentPos,newKingPos,"Move",rookPos,newRookPos))
			end
		end
		
		if rookK then
			local pathClear = self:CheckIfIsValidPath(currentPos,currentPos + 2)
			--//Check all possibilities
			if rookK:HasTag("Rook") and rookK.IsBlack == piece.IsBlack and rookK.CanCastle and pathClear then
				local newKingPos = currentPos + 2
				local rookPos = rookQ.Position
				local newRookPos = rookPos - 2
				piece:AddLegalMove(newKingPos,Action.new("Move",currentPos,newKingPos,"Move",rookPos,newRookPos))
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