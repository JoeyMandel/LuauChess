-- Piece
-- UnknownParabellum
-- February 18, 2021

--[[
	
	local piece = Piece.new()
	

--]]
local Knit = require(game:GetService("ReplicatedStorage").Knit)

local HttpService = game:GetService("HttpService")


local PieceComponents = require(Knit.Shared.Components.PieceComponents)
local TagSystem = require(Knit.Shared.Classes.TagSystem)

local BoardUtil = require(Knit.Shared.Lib.BoardUtil)
local Maid = require(Knit.Shared.Lib.Maid)

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
	self.Components[name] = PieceComponents.new(name,self,(config or {}))
	self.__maid:GiveTask(self.Components[name])
end

function Piece:RemoveComponent(name)
	self.Components[name]:Destroy()
	self.Components[name] = nil
end
--//state
function Piece:CleanState()
	table.clear(self.LegalMoves)
	table.clear(self.Attacking)
	table.clear(self.PathOfAttack)
	self:RemovePinning()
end

function Piece:Get(index)
	return self[index]
end

function Piece:Set(index,newVal)
	self[index] = newVal
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
	BoardUtil.Set(self.PathOfAttack,self.Position,true)

	for _,component in pairs(doLast) do
		component:FilterLegalMoves()
	end

	self:Set("MoveNum", self.Board.MoveNumber)
	return self.LegalMoves
end

function Piece:AddLegalMove(position)
	local color = self.IsBlack and "Black" or "White"	
	--moveInfo = moveInfo or Action.new("Move",self.Position,position)

	BoardUtil.Set(self.LegalMoves,position,true)
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
	local board = self.Board:Get("Board") --// Ah Yes board get board
	local oppColor = BoardUtil.GetColor(not self.IsBlack)

	local piece = self:GetPiece(pos)
	if piece then
		warn("[Client Board]: "..piece.Type.." ,"..BoardUtil.ANFromVector2(piece:Get("Position")).." was pinned by "
			..self.Type.." ,"..BoardUtil.ANFromVector2(self.Position))
		self.Pinning[piece] = true
		piece:Get("PinnedBy")[self] = true
	end
end

function Piece:UnPin(piece)
	local board = self.Board:Get("Board")
	local oppColor = BoardUtil.GetColor(not self.IsBlack)

	self.Pinning[piece] = nil
	piece:Get("PinnedBy")[self] = nil
end
--//General
function Piece.new(config)
	local realPiece
	local type = config.Type
	local pos = config.Position
	local board = config.Board
	local color = config.Color

	local mod = script:FindFirstChild(type)
	if mod then
		local base = setmetatable({
			["PinnedBy"] = {},
			["Pinning"] = {},
			["PathOfAttack"] = {},
			["LegalMoves"] = {},
			["Attacking"] = {},
			["MoveNum"] = 0,
			["Position"] = pos,
			["IsBlack"] = color,
			["Board"] = board,

			["Id"] = HttpService:GenerateGUID(false),
			["Components"] = {},
			["IsDead"] = false,
			["__maid"] = Maid.new()
		}, Piece)
		
		TagSystem.Include(base)
		
		base:AddComponent("GlobalPieceProperties")
		realPiece = require(mod).new(base)
	end
	
	return realPiece
end


function Piece:Destroy()
	local board = self.Board
	BoardUtil.Get(board:Get("Board"),self.Position).Piece = nil	
	local colorName = self.IsBlack and "Black" or "White"
	for index,piece in pairs(board[colorName].Pieces) do
		if piece == self then
			warn("[Client Board]: Piece Destroyed: "..piece.Type.."! | "..tostring(piece:Get("Position")))	
			board[colorName].Pieces[index] = nil
		end
	end
	
	self:RemovePinning()
	self.IsDead = true
	self.__maid:DoCleaning()
end

return Piece