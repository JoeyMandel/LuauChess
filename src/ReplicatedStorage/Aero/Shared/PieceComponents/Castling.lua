-- Castling
-- UnknownParabellum
-- March 6, 2021

--[[
	
	local Castling = Castling.new()
	

--]]
local BoardUtil
local BaseComponent = require(script.Parent.BaseComponent)


local Castling = setmetatable({},BaseComponent)
Castling.__index = Castling

function Castling:BeforeUpdate()
	--//When a piece is moved remove castling rights
	self.Piece.CanCastle = false
end

function Castling:ComputeLegalMoves()
	local piece = self.Piece
	local board = piece.Board
	local boardHolder = board.Board
	local currentPos = piece.Position

	if piece:HasTag("King") and piece.CanCastle then
		local oppColor = BoardUtil.GetColor(not piece.IsBlack)
		local curColor = BoardUtil.GetColor(piece.IsBlack)
		local rookQ 
		local rookK
		--//Change rook positions depending on side
		if piece.IsBlack then
			rookQ = piece:GetPiece(Vector2.new(1,8))
			rookK = piece:GetPiece(Vector2.new(8,8))
		else
			rookQ = piece:GetPiece(Vector2.new(1,1))
			rookK = piece:GetPiece(Vector2.new(8,1))
		end
		--//Check for both rooks
		if rookQ then	
			local pathClear = #board[curColor].Checking == 0 and true
			--//Check if the path to castling is clear and unattacked
			local offOne = currentPos - Vector2.new(1,0)
			local offTwo = currentPos - Vector2.new(2,0)
			if not board:IsAttacking(oppColor,offOne) and not BoardUtil.Get(boardHolder,offOne).Piece then
				if board:IsAttacking(oppColor,offTwo) or BoardUtil.Get(boardHolder,offTwo).Piece then
					pathClear = false
				else
					if BoardUtil.Get(boardHolder,currentPos - Vector2.new(3,0)).Piece then
						pathClear = false
					end
				end
			else
				pathClear = false
			end
			--//Check all possibilities
			if rookQ:HasTag("Rook") and rookQ.IsBlack == piece.IsBlack and rookQ.CanCastle and pathClear then
				local newKingPos = currentPos - Vector2.new(2,0)
				local newRookPos = rookQ.Position + Vector2.new(3,0)
				piece:AddLegalMove(newKingPos,{currentPos,newKingPos,rookQ.Position,newRookPos})
			end
		end
		
		if rookK then
			local pathClear = #board[curColor].Checking == 0 and true
			--//Path check
			local offOne = currentPos + Vector2.new(1,0)
			local offTwo = currentPos + Vector2.new(2,0)
			if not piece.Board:IsAttacking(oppColor,offOne) and not BoardUtil.Get(boardHolder,offOne).Piece then
				if piece.Board:IsAttacking(oppColor,offTwo) or BoardUtil.Get(boardHolder,offTwo).Piece then
					pathClear = false
				end
			else
				pathClear = false
			end
			--//Check all possibilities
			if rookK:HasTag("Rook") and rookK.IsBlack == piece.IsBlack and rookK.CanCastle and pathClear then
				local newKingPos = currentPos + Vector2.new(2,0)
				local newRookPos = rookK.Position - Vector2.new(2,0)
				piece:AddLegalMove(newKingPos,{currentPos,newKingPos,rookK.Position,newRookPos})
			end
		end
	end
end

function Castling.new(piece)
	local base = BaseComponent.new(piece)
	local self = setmetatable(base, Castling)
	
	local piece = self.Piece
	piece.CanCastle = false
	
	local currentPos = piece.Position
	local validPos = {}
	if piece:HasTag("Rook") then
		--//Determine if the rook is in a valid castling position and add position to valid positions
		if piece.IsBlack then
			validPos[BoardUtil.Vector2ToInt(1,8)] = true
			validPos[BoardUtil.Vector2ToInt(8,8)] = true
		else
			validPos[BoardUtil.Vector2ToInt(1,1)] = true
			validPos[BoardUtil.Vector2ToInt(8,1)] = true
		end
	elseif piece:HasTag("King") then
		--//Determine if the king is in a valid castling position
		if piece.IsBlack then
			validPos[BoardUtil.Vector2ToInt(5,8)] = true
		else
			validPos[BoardUtil.Vector2ToInt(5,1)] = true
		end
	end
	--// If valid then can castle :)
	if validPos[BoardUtil.Vector2ToInt(currentPos)] then
		piece.CanCastle = true
	end
	
	self:AddTag("Movement")
	return self
end

function Castling:Init(framework)
	BoardUtil = framework.Shared.Utils.BoardUtil
end

return Castling