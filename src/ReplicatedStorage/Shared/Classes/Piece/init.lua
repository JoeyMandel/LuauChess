-- Piece
-- UnknownParabellum
-- February 18, 2021

--[[
	
	local piece = Piece.new()
	

--]]
local Knit = require(game:GetService("ReplicatedStorage").Knit)

local HttpService = game:GetService("HttpService")

local PieceComponents
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
	self.Components[name] = PieceComponents.new(name,self,(config or {}))
	self.__maid:GiveTask(self.Components[name])
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
	local color = self:Get("IsBlack") and "Black" or "White"	
	--moveInfo = moveInfo or Action.new("Move",self:Get("Position"),position)

	BoardUtil.Set(self:Get("LegalMoves"),position,moveInfo)
	local legalMoves = BoardUtil.Get(self:Get("Board")[color].LegalMoves,position)
	if legalMoves then
		legalMoves[self] = true
	end
end

function Piece:RemoveLegalMove(position)
	local color = self:Get("IsBlack") and "Black" or "White"
	
	BoardUtil.Set(self:Get("LegalMoves"),position,nil)
	local legalMoves = BoardUtil.Get(self:Get("Board")[color].LegalMoves,position)
	if legalMoves then
		legalMoves[self] = nil
	end
end

function Piece:AddAttackingMove(position)
	local color = self:Get("IsBlack") and "Black" or "White"
	BoardUtil.Set(self:Get("Attacking"),position,true)
	BoardUtil.Set(self:Get("Board")[color].Attacking,position,true)
end

function Piece:AddToPath(position)
	BoardUtil.Set(self:Get("PathOfAttack"),position,true)
end
--//Pinning
function Piece:RemovePinning()
	for piece,_ in pairs(self:Get("Pinning")) do
		self:UnPin(piece)
	end
end
function Piece:Pin(pos)
	local board = self:Get("Board"):Get("Board") --// Ah Yes board get board
	local oppColor = BoardUtil.GetColor(not self:Get("IsBlack"))

	local piece = self:GetPiece(pos)
	if piece then
		warn("[Client Board]: "..piece.Type.." ,"..BoardUtil.ANFromVector2(piece:Get("Position")).." was pinned by "
			..self.Type.." ,"..BoardUtil.ANFromVector2(self:Get("Position")))
		self:Get("Pinning")[piece] = true
		piece:Get("PinnedBy")[self] = true
	end
end

function Piece:UnPin(piece)
	local board = self:Get("Board"):Get("Board")
	local oppColor = BoardUtil.GetColor(not self.IsBlack)

	self:Get("Pinning")[piece] = nil
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
			["PieceId"] = HttpService:GenerateGUID(false),
			["Components"] = {},
			["IsDead"] = false,
			["__maid"] = require(Knit.Shared.Lib.Maid).new()
		}, Piece)
		
		require(Knit.Shared.TagSystem).Include(base)
		
		base:AddComponent("GlobalPieceProperties")
		realPiece = require(mod).new(base)
	end
	
	return realPiece
end


function Piece:Destroy()
	local board = self:Get("Board")
	BoardUtil.Get(board:Get("Board"),self:Get("Position")).Piece = nil	
	local colorName = self:Get("IsBlack") and "Black" or "White"
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

function Piece:Init()
	BoardUtil = require(Knit.Shared.Lib.BoardUtil)
	PieceComponents = require(Knit.Shared.Components.PieceComponents)
end

Piece:Init()

return Piece