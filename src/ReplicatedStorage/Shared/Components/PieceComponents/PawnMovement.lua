-- Pawn Movement
-- UnknownParabellum
-- February 26, 2021

--[[
	
	local pawnMovement = PawnMovement.new()
	

--]]
local BaseComponent = require(script.Parent.BaseComponent)

local Action
local BoardUtil
local toInt
local toVec2

local PawnMovement = setmetatable({},BaseComponent)
PawnMovement.__index = PawnMovement

function PawnMovement:BeforeUpdate(changes)
	local isBlack = self.Piece:Get("IsBlack")
	local currentPos = self.Piece:Get("Position")
	local newPos = changes[2]
	local startingRow = self.StartingRow
	
	if BoardUtil:GetY(currentPos) == startingRow then
		local doubleMoved = (isBlack and BoardUtil:GetY(newPos) == (startingRow - 2)) or BoardUtil:GetY(newPos) == (startingRow  + 2)
		if doubleMoved then
			self.Piece:Set("EnPassent",true)
			self.__maid["Moved"] = self.Board.BeforeMoved:Connect(function()
				self.__maid["Moved"] = nil
				self.Piece:Set("EnPassent", false)
			end)
		end
	end
end

function PawnMovement:ComputeLegalMoves()
	local piece = self.Piece
	local piecePos = piece:Get("Position")
	local isBlack = piece:Get("IsBlack")
	local direct = isBlack and -1 or 1

	local frontPiece = piecePos + direct
	
	local leftCrossPos = piecePos + toInt(-1,direct)
	local rightCrossPos = piecePos + toInt(1,direct)
	local leftPassentPos = piecePos + toInt(-1,0)
	local rightPassentPos = piecePos + toInt(1,0)


	local leftCrossPiece = piece:GetPiece(leftCrossPos)
	local rightCrossPiece = piece:GetPiece(rightCrossPos)
	local leftPassent = piece:GetPiece(leftPassentPos)
	local rightPassent = piece:GetPiece(rightPassentPos)

	if not frontPiece then
		piece:AddLegalMove(piecePos + toInt(0,direct))
		
		local doubleFrontPiece = piece:GetPiece(piecePos + toInt(0,2*direct))
		if (BoardUtil:GetY(piecePos)== self.StartingRow) and not doubleFrontPiece then -- 2 steps forward
			piece:AddLegalMove(piecePos + toInt(0,2*direct))
		end
	end
	
	piece:AddAttackingMove(leftCrossPos)
	piece:AddAttackingMove(rightCrossPos)

	if leftCrossPiece then -- attacking left cross
		piece:AddLegalMove(leftCrossPos)
	end
	if rightCrossPiece then --attacking right cross
		piece:AddLegalMove(rightCrossPos)
	end
	
	if leftPassent then
		if leftPassent.Type == "Pawn" and leftPassent:Get("EnPassent") then
			local moveInfo = Action.new("Move",piecePos,leftCrossPos,"Destroy",leftPassent:Get("Position"))
			piece:AddLegalMove(leftCrossPos,moveInfo)
			piece:AddAttackingMove(leftCrossPos)
		end
	end
	if rightPassent then
		if rightPassent.Type == "Pawn" and rightPassent:Get("EnPassent") then
			local moveInfo = Action.new("Move",piecePos,rightCrossPos,"Destroy",rightPassent:Get("Position"))
			
			piece:AddLegalMove(rightCrossPos,moveInfo)
			piece:AddAttackingMove(rightCrossPos)
		end
	end
end

function PawnMovement.new(piece,config)
	local base = BaseComponent.new(piece)
	local self = setmetatable(base, PawnMovement)
	
	self:AddTag("Movement")
	
	self.Piece:Set("EnPassent", (config.EnPassent ~= nil))
	self.StartingRow = 0
	if self.Piece:Get("IsBlack") then
		self.StartingRow = 7
	else
		self.StartingRow = 2
	end
	return self
	
end


function PawnMovement:Init(framework)
	BoardUtil = self.Shared.Lib.BoardUtil
	toInt = BoardUtil.Vector2ToInt
	toVec2 = BoardUtil.IntToVector2

	Action = self.Shared.Action
end

return PawnMovement