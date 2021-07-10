-- Two Axis Movement
-- UnknownParabellum
-- February 20, 2021

--[[
	
	local twoAxisMovement = TwoAxisMovement.new()
	

--]]

local Knit = require(game:GetService("ReplicatedStorage").Knit)

local BaseComponent = require(script.Parent.BaseComponent)

local BoardUtil = require(Knit.Shared.Lib.BoardUtil)

local TwoAxisMovement = setmetatable({},BaseComponent)
TwoAxisMovement.__index = TwoAxisMovement

function TwoAxisMovement:BeforeUpdate(changes)

end

function TwoAxisMovement:ComputeLegalMoves()
	local piece = self.Piece
	local board = self.Board.Board:getState()
	local piecePos = piece.Position

	local pieceColor = piece.IsBlack

	local function processPath(dir)
		local piecesHit = BoardUtil.FireRayInDirection(board, piecePos, dir, function(tile)
			if tile.Piece then
				return true
			end
			return false
		end)
		local path = BoardUtil.FireRayInDirection(board, piecePos, dir, function(tile)
			return true
		end)

		local checking
		local pinning 

		local firstHit = piecesHit[1] and piecesHit[1].Piece
		local secondHit = piecesHit[2] and piecesHit[2].Piece

		if firstHit then
			--Must be checking the enemy king!
			if firstHit:HasTag("King") and firstHit.IsBlack ~= pieceColor then
				checking = true
			end
		end
		if secondHit then
			--Must be pinning the first piece!
			if firstHit:HasTag("King") and firstHit.IsBlack ~= pieceColor and firstHit.IsBlack ~= pieceColor then
				pinning = true
			end
		end

		for _, tile in ipairs(path) do
			local pos = tile.Position

			if checking or pinning then
				piece:AddToPath(pos)
			end
			piece:AddAttackingMove(pos)

			if tile.Piece then
				if tile.Piece.IsBlack ~= pieceColor then
					piece:AddLegalMove(pos)
				end
				break
			else
				piece:AddLegalMove(pos)
			end
		end
	end
	
	processPath(Vector2.new(1,1))
	processPath(Vector2.new(-1,1))
	processPath(Vector2.new(1,-1))
	processPath(Vector2.new(-1,-1))
end

function TwoAxisMovement.new(piece,config)
	local base = BaseComponent.new(piece)
	local self = setmetatable(base, TwoAxisMovement)

	self:AddTag("Movement")
	
	return self
end

return TwoAxisMovement