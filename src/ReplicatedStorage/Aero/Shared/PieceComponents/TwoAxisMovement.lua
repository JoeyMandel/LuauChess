-- Two Axis Movement
-- UnknownParabellum
-- February 20, 2021

--[[
	
	local twoAxisMovement = TwoAxisMovement.new()
	

--]]



local BaseComponent = require(script.Parent.BaseComponent)
local BoardUtil

local TwoAxisMovement = setmetatable({},BaseComponent)
TwoAxisMovement.__index = TwoAxisMovement

function TwoAxisMovement:BeforeUpdate(changes)

end

function TwoAxisMovement:ComputeLegalMoves()
	local piece = self.Piece
	local board = self.Board:Get("Board")
	local piecePos = piece:Get("Position")
	local oppColor = BoardUtil.GetColor(not piece:Get("IsBlack"))
	
	local distFromLeft = BoardUtil.GetX(piecePos)
	local distFromRight = 8 - distFromLeft
	local distFromBottom = BoardUtil.GetY(piecePos)	
	local distFromTop = 8-distFromBottom
	
	local path = {}
	local isPinning = false
	local checking = false

	local function iterateThroughPath(dist,dirX,dirY)
		local piecesHit = 0
		local enemyPiecesHit = 0 
		local lastEnemyPiece
		local lastPieceHit 

		for offset = 1,dist do
			local currentPos = piecePos + (9*(dirX*offset)) + (offset*dirY)

			if piecesHit == 0 then
				piece:AddLegalMove(currentPos)
				piece:AddAttackingMove(currentPos)
			end

			if not isPinning and not checking then
				table.insert(path,currentPos)
			end
			local hitPiece = piece:GetPiece(currentPos)
			if hitPiece then
				piecesHit += 1

				lastPieceHit = true
				if hitPiece:Get("IsBlack") ~= piece:Get("IsBlack") then
					if enemyPiecesHit < 2 then
						enemyPiecesHit += 1
						if piecesHit == 2 then
							if hitPiece == (self.Board:Get(oppColor).Pieces["King"]) then
								piece:Pin(lastEnemyPiece:Get("Position"))
								isPinning = true
							end
							break
						elseif piecesHit == 1 then
							if hitPiece == (piece.Board[oppColor].Pieces["King"]) then
								checking = true
								local dir = dist > 1 and 1 or -1
								piece:AddAttackingMove(currentPos+piecePos + (9*(dirX*(offset+1))) + ((1+offset)*dirY))
								break
							else
								lastEnemyPiece = hitPiece
							end
						end
					else
						break
					end
				end
			end
		end
		if not isPinning and not checking then
			table.clear(path)
		end
	end
	--//To Right
	iterateThroughPath(distFromRight,1,0)
	--//To Left
	iterateThroughPath(distFromLeft,-1,0)
	--//To Top
	iterateThroughPath(distFromTop,0,1)
	--//To Bottom
	iterateThroughPath(distFromBottom,0,-1)
	
	for _,pos in pairs(path) do
		piece:AddToPath(pos)
	end
end

function TwoAxisMovement.new(piece,config)
	local base = BaseComponent.new(piece)
	local self = setmetatable(base, TwoAxisMovement)

	self:AddTag("Movement")
	self:AddTag("UpdateMovesAfterMove")
	
	return self
end

function TwoAxisMovement:Init(framework)
	BoardUtil = framework.Shared.Utils.BoardUtil
end
return TwoAxisMovement