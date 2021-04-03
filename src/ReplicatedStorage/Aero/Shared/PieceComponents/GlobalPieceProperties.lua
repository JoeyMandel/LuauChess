-- Global Piece Properties
-- UnknownParabellum
-- February 20, 2021

--[[
	

--]]

local BoardUtil

local BaseComponent = require(script.Parent.BaseComponent)


local GlobalPieceProperties = setmetatable({},BaseComponent)
GlobalPieceProperties.__index = GlobalPieceProperties

function GlobalPieceProperties:FilterLegalMoves()

	local piece = self.Piece
	local board = piece.Board
	local legalMoves = piece.LegalMoves
	
	local oppColor = BoardUtil.GetColor(not piece.IsBlack)
	local color = BoardUtil.GetColor(piece.IsBlack)
	
	local opp = board[oppColor]
	local current = board[color]

	for pos,moveInfo in pairs(legalMoves) do
		local currentPos = BoardUtil.IntToVector2(pos)
		local currentPiece = piece:GetPiece(currentPos)
		local isValidPinnedMove = true	
		
		for pinningPiece,_ in pairs(piece.PinnedBy) do
			local pinningPath = pinningPiece.PathOfAttack --//Note: this assumes there is only one enemy king and you can only pin one piece at a time
			isValidPinnedMove = (isValidPinnedMove and BoardUtil.Get(pinningPath,currentPos))
		end
		
		if not isValidPinnedMove then
			piece:RemoveLegalMove(currentPos)
		end
		if currentPiece then
			if currentPiece.IsBlack == piece.IsBlack then
				piece:RemoveLegalMove(currentPos)
			end
		end
		if piece.Type ~= "King" then
			if #current.Checking >= 1 then
				for num,checker in pairs(current.Checking) do
					local attacking = checker.PathOfAttack
					if not BoardUtil.Get(attacking,currentPos) then
						piece:RemoveLegalMove(currentPos)
					end
				end
			end
		end
	end

	--// If attacking king then add to checking
	if BoardUtil.Get(piece.Attacking,opp.Pieces["King"].Position) then
		warn("[Client Board]:"..oppColor.." King is in check from "..piece.Type.."! | "..tostring(piece.Position))	
		table.insert(opp.Checking,piece)
	end
end

function GlobalPieceProperties.new(piece,config)
	local base = BaseComponent.new(piece)
	local self = setmetatable(base, GlobalPieceProperties)

	self:AddTag("MovementLast")
	return self
end

function GlobalPieceProperties:Init(framework)
	BoardUtil = framework.Shared.Utils.BoardUtil
end


return GlobalPieceProperties