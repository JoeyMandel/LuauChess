-- Diagonal Movement
-- UnknownParabellum
-- February 20, 2021

--[[
	

--]]


local BoardUtil
local toInt
local toVec2

local BaseComponent = require(script.Parent.BaseComponent)


local DiagonalMovement = setmetatable({},BaseComponent)
DiagonalMovement.__index = DiagonalMovement


function DiagonalMovement:BeforeUpdate(changes)

end

function DiagonalMovement:ComputeLegalMoves()
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
				if (hitPiece:Get("IsBlack") ~= piece:Get("IsBlack")) then
					if enemyPiecesHit < 2 then
						enemyPiecesHit += 1
						if enemyPiecesHit == 2 then
							if hitPiece == (self.Board:Get(oppColor).Pieces["King"]) then
								piece:Pin(lastEnemyPiece:Get("Position"))
								isPinning = true
							end
							break
						elseif enemyPiecesHit == 1 then
							if hitPiece == (self.Board:Get(oppColor).Pieces["King"]) then
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
	toVec2 = BoardUtil.IntToVector2
	toInt = BoardUtil.Vector2ToInt
end


return DiagonalMovement