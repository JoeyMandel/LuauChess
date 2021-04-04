-- Piece
-- UnknownParabellum
-- February 18, 2021

--[[
	
	local piece = Piece.new()
	

--]]
local BoardUtil

local Piece = {}
Piece.__index = Piece

--//Updates
function Piece:BeforeUpdate(changes)
	for _,component in pairs(self.Components) do
		if component.BeforeUpdate then
			component:BeforeUpdate(changes)
			self.Position = changes[2]
		end
	end
end

function Piece:AfterUpdate(changes)
	for _,component in pairs(self.Components) do
		if component.AfterUpdate then
			component:AfterUpdate(changes)
		end
	end
end

--//Utils
function Piece:AddComponent(name,config)
	self.Components[name] = self.Shared.PieceComponents.new(name,self,(config or {}))
	self._maid:GiveTask(self.Components[name])
end

function Piece:RemoveComponent(name)
	self.Components[name]:Destroy()
	self.Components[name] = nil
end
--//state
function Piece:CleanState()
	table.clear(self:Get("LegalMoves"))
	table.clear(self:Get("Attacking"))
	table.clear(self:Get("PathOfAttack"))
	self:RemovePinning()
end

function Piece:Get(index)
	return self.State[index]
end

function Piece:Set(index,newVal)
	self.State[index] = newVal
end
--//Movement

function Piece:ComputeLegalMoves()
	self:CleanState()
	local doLast = {}
	
	for _,component in pairs(self.Components) do
		if component:HasTag("Movement") then
			component:ComputeLegalMoves()
		elseif component:HasTag("MovementLast") then
			table.insert(doLast,component)
		end
	end
	BoardUtil.Set(self:Get("PathOfAttack"),self:Get("Position"),true)

	for _,component in pairs(doLast) do
		component:FilterLegalMoves()
	end

	self:Set("MoveNum", self:Get("Board").MoveNumber)
	return self:Get("LegalMoves")
end

function Piece:AddLegalMove(position,moveInfo)
	local color = self.IsBlack and "Black" or "White"	
	BoardUtil.Set(self:Get("LegalMoves"),position,moveInfo)
	local legalMoves = BoardUtil.Get(self.Board[color].LegalMoves,position)
	if legalMoves then
		legalMoves[self] = true
	end
end

function Piece:RemoveLegalMove(position)
	local color = self.IsBlack and "Black" or "White"
	
	BoardUtil.Set(self.LegalMoves,position,nil)
	local legalMoves = BoardUtil.Get(self.Board[color].LegalMoves,position)
	if legalMoves then
		legalMoves[self] = nil
	end
end

function Piece:AddAttackingMove(position)
	local color = self.IsBlack and "Black" or "White"
	BoardUtil.Set(self.Attacking,position,true)
	BoardUtil.Set(self.Board[color].Attacking,position,true)
end

function Piece:AddToPath(position)
	BoardUtil.Set(self.PathOfAttack,position,true)
end
--//Pinning
function Piece:RemovePinning()
	for piece,_ in pairs(self.Pinning) do
		self:UnPin(piece)
	end
end
function Piece:Pin(pos)
	local board = self.Board.board
	local oppColor = BoardUtil.GetColor(not self.IsBlack)

	local piece = self:GetPiece(pos)
	if piece then
		warn("[Client Board]: "..piece.Type.." ,"..BoardUtil.ANFromVector2(piece.Position).." was pinned by "
			..self.Type.." ,"..BoardUtil.ANFromVector2(self.Position))
		self.Pinning[piece] = true
		piece.PinnedBy[self] = true
	end
end

function Piece:UnPin(piece)
	local board = self.Board.board
	local oppColor = BoardUtil.GetColor(not self.IsBlack)

	self.Pinning[piece] = nil
	piece.PinnedBy[self] = nil
end
--//General
function Piece.new(name,pos,board,color)
	local realPiece
	local mod = script:FindFirstChild(name)
	if mod then
		local base = setmetatable({
			["State"] = { --// State is anything variable and not related to the very basic functions of a piece
				["PinnedBy"] = {},
				["Pinning"] = {},
				["PathOfAttack"] = {},
				["LegalMoves"] = {},
				["Attacking"] = {},
				["MoveNum"] = 0,
				["Position"] = pos,
				["IsBlack"] = color,
				["Board"] = board,
			},
			["Components"] = {},
			["IsDead"] = false,
			["_maid"] = Piece.Shared.Utils.Maid.new()
		}, Piece)
		
		Piece.Shared.TagSystem.Include(base)
		
		base:AddComponent("GlobalPieceProperties")
		realPiece = require(mod).new(base)
	end
	
	return realPiece
end


function Piece:Destroy()
	BoardUtil.Get(self.Board.Board,self.Position).Piece = nil	
	local colorName = self.IsBlack and "Black" or "White"
	for index,piece in pairs(self.Board[colorName].Pieces) do
		if piece == self then
			warn("[Client Board]: Piece Destroyed: "..piece.Type.."! | "..tostring(piece.Position))	
			self.Board[colorName].Pieces[index] = nil
		end
	end
	
	self:RemovePinning()
	self.IsDead = true
	self._maid:DoCleaning()
end

function Piece:Init()
	BoardUtil = self.Shared.Utils.BoardUtil
end


return Piece