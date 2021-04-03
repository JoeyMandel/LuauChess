-- Diagonal Movement
-- UnknownParabellum
-- February 20, 2021

--[[
	

--]]


local BoardUtil

local BaseComponent = require(script.Parent.BaseComponent)


local DiagonalMovement = setmetatable({},BaseComponent)
DiagonalMovement.__index = DiagonalMovement


function DiagonalMovement:BeforeUpdate(changes)

end

function DiagonalMovement:ComputeLegalMoves()
	local piece = self.Piece
	local board = piece.Board.Board
	local piecePos = piece.Position
	local oppColor = BoardUtil.GetColor(not piece.IsBlack)

	local distFromLeft = piecePos.X
	local distFromRight = 8 - distFromLeft
	local distFromBottom = piecePos.Y	
	local distFromTop = 8-distFromBottom
	
	local path = {}
	local isPinning = false
	local checking = false
	
	local function iterateThroughPath(dist,off1,off2)
		local piecesHit = 0
		local enemyPiecesHit = 0 
		local lastEnemyPiece
		local lastPieceHit 
		
		for offset = 1,dist do
			local currentPos = piecePos + Vector2.new(offset*off1,offset*off2)
			
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
				if (hitPiece.IsBlack ~= piece.IsBlack) then
					if enemyPiecesHit < 2 then
						enemyPiecesHit += 1
						if enemyPiecesHit == 2 then
							if hitPiece == (piece.Board[oppColor].Pieces["King"]) then
								piece:Pin(lastEnemyPiece.Position)
								isPinning = true
							end
							break
						elseif enemyPiecesHit == 1 then
							if hitPiece == (piece.Board[oppColor].Pieces["King"]) then
								checking = true
								local dir = dist > 1 and 1 or -1
								piece:AddAttackingMove(currentPos+Vector2.new(dir*off1,dir*off2))
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
	--//To Top right corner
	iterateThroughPath(math.min(distFromRight,distFromTop),1,1)
	--//To Top left corner
	iterateThroughPath(math.min(distFromLeft,distFromTop),-1,1)
	--//To Bottom left corner
	iterateThroughPath(math.min(distFromLeft,distFromBottom),-1,-1)
	--//To Bottom left corner
	iterateThroughPath(math.min(distFromRight,distFromBottom),1,-1)
	
	for _,pos in pairs(path) do
		piece:AddToPath(pos)
	end
end

function DiagonalMovement.new(piece,config)
	local base = BaseComponent.new(piece)
	local self = setmetatable(base, DiagonalMovement)
	
	self:AddTag("Movement")
	return self
end

function DiagonalMovement:Init(framework)
	BoardUtil = framework.Shared.Utils.BoardUtil
end


return DiagonalMovement