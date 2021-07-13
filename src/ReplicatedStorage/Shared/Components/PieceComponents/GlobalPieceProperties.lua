-- Global Piece Properties
-- UnknownParabellum
-- February 20, 2021

--[[
	

--]]
local Knit = require(game:GetService("ReplicatedStorage").Knit)

local BoardUtil = require(Knit.Shared.Lib.BoardUtil)

local BaseComponent = require(script.Parent.BaseComponent)

local GlobalPieceProperties = setmetatable({},BaseComponent)
GlobalPieceProperties.__index = GlobalPieceProperties

function GlobalPieceProperties:FilterLegalMoves()
	local piece = self.Piece
	local board = self.Board
	local legalMoves = piece.LegalMoves
	
	local pieceIsBlack = piece.IsBlack
	local oppColor = BoardUtil.GetColor(not pieceIsBlack)
	local color = BoardUtil.GetColor(pieceIsBlack)
	
	local oppHandler = board[oppColor]
	local currentHandler = board[color]

	for pos, _ in pairs(legalMoves) do
		local movePos = BoardUtil.IntToVector2(pos)
		local pieceOfPos = board:GetPieceFromPosition(movePos)

		local isValidPinnedMove = true	
		
		for pinningPiece, _ in pairs(piece.PinnedBy) do
			local pinningPath = pinningPiece.PathOfAttack --//Note: this assumes there is only one enemy king and you can only pin one piece at a time
			isValidPinnedMove = (isValidPinnedMove and BoardUtil.Get(pinningPath,movePos))
		end
		
		if not isValidPinnedMove then
			piece:RemoveLegalMove(movePos)
		end
		if pieceOfPos then
			if pieceOfPos.IsBlack == pieceIsBlack then
				piece:RemoveLegalMove(movePos)
			end
		end
		if not piece:HasTag("King") then
			if #currentHandler.Checking >= 1 then
				for _,checker in pairs(currentHandler.Checking) do
					local attacking = checker.PathOfAttack
					if not BoardUtil.Get(attacking,movePos) then
						piece:RemoveLegalMove(movePos)
					end
				end
			end
		end
	end

	local oppKing = oppHandler:GetPiecesOfType("King")[1]
	
	if BoardUtil.Get(piece.Attacking,oppKing.Position) then
		warn("[Client Board]:"..oppColor.." King is in check from "..color.. " "..piece.Type.."! | "..tostring(piece.Position))
		table.insert(oppHandler.Checking,piece)
	end
end

function GlobalPieceProperties.new(piece,config)
	local base = BaseComponent.new(piece)
	local self = setmetatable(base, GlobalPieceProperties)

	self:AddTag("MovementLast")
	return self
end


return GlobalPieceProperties