-- Piece
-- UnknownParabellum
-- February 18, 2021

--[[
	
	Piece.new(config: table)
		config:
			Type = "Pawn",
			Position = Vector2.new(5,5),
			Board = Board,
			Color = true, 
		Creates a new piece

	Piece:Destroy()
		Destroys the piece, and cleans up all connections

	Piece:AfterUpdate(actions: table) 
		Goes through all components and if applicable, calls the component's :AfterUpdate() method
	Piece:BeforeUpdate(actions: table)
		Goes through all components and if applicable, calls the component's :BeforeUpdate() method

	Piece:ComputeLegalMoves()
		Goes through all movement components and calls its :CompueteLegalMoves() method. This determines all a pieces legal moves,
		all the tiles it is attacking, its path of attack.

	Piece:AddComponent(name: string, config: table)
		Adds the component of the inputted name. There can only be one of each type of component.
	Piece:RemoveComponent(name: string)
		Removes the component of the inputted name. 

	Piece:AddAttackingMove(position: Vector2)
		Sets the position in Piece.Attacking to true
	Piece:AddLegalMove(position: Vector2)
		Sets the position in Piece.LegalMoves to true
	Piece:RemoveLegalMove(position: Vector2)
		Sets the position in Piece.LegalMoves to nil
	Piece:AddToPath(position: Vector2)
		Sets the position in Piece.PathOfAttack to true

	Piece:Pin(pos: Vector2)
		Pins the piece on that position
	Piece:UnPin(pos: Vector2)
		Un Pins the piece on that position
	Piece:RemovePinning()
		Removes all pinnings that the piece if inflicting

	Piece:CleanState()
		Resets the state of the piece 
--]]
local Knit = require(game:GetService("ReplicatedStorage").Knit)

local HttpService = game:GetService("HttpService")

local PieceComponents = require(Knit.Shared.Components.PieceComponents)
local TagSystem = require(Knit.Shared.Classes.TagSystem)

local BoardUtil = require(Knit.Shared.Lib.BoardUtil)
local Maid = require(Knit.Shared.Lib.Maid)

local Piece = {}
Piece.__index = Piece

--//Class
function Piece.new(config: table)
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
			["Position"] = pos,
			["IsBlack"] = color,
			["Board"] = board,
			["MoveNum"] = 0,

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
	local board = self.Board.Board:getState()
	BoardUtil.Get(board,self.Position).Piece = nil	
	local colorName = self.IsBlack and "Black" or "White"
	for index,piece in pairs(board[colorName].Pieces) do
		if piece == self then
			warn("[Client Board]: Piece Destroyed: "..piece.Type.."! | "..tostring(piece.Position))	
			board[colorName].Pieces[index] = nil
		end
	end
	
	self:RemovePinning()
	self.IsDead = true
	self.__maid:DoCleaning()
end

--//Updates
function Piece:BeforeUpdate(actions: table)
	for _,component in pairs(self.Components) do
		if component.BeforeUpdate then
			component:BeforeUpdate(actions)
		end
	end
end

function Piece:AfterUpdate(actions: table)
	for _,component in pairs(self.Components) do
		if component.AfterUpdate then
			component:AfterUpdate(actions)
		end
	end
end

--//Components
function Piece:AddComponent(name: string,config: table)
	self.Components[name] = PieceComponents.new(name,self,(config or {}))
	self.__maid:GiveTask(self.Components[name])
end

function Piece:RemoveComponent(name: string)
	self.Components[name]:Destroy()
	self.Components[name] = nil
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

	self.MoveNum = self.Board.MoveNumber
	return self.LegalMoves
end

--// Utils
function Piece:AddLegalMove(position: Vector2)
	local colorState = self.Board:GetColorState(self.IsBlack)
	BoardUtil.Set(self.LegalMoves,position,true)
	BoardUtil.Set(colorState.LegalMoves,position,true)
end

function Piece:RemoveLegalMove(position: Vector2)	
	local colorState = self.Board:GetColorState(self.IsBlack)
	BoardUtil.Set(self.LegalMoves,position,nil)
	BoardUtil.Set(colorState.LegalMoves,position,nil)
end

function Piece:AddAttackingMove(position: Vector2)
	local colorState = self.Board:GetColorState(self.IsBlack)

	BoardUtil.Set(self.Attacking,position,true)
	BoardUtil.Set(colorState.Attacking,position,true)
end

function Piece:AddToPath(position: Vector2)
	BoardUtil.Set(self.PathOfAttack,position,true)
end

--//Pinning
function Piece:RemovePinning()
	for piece,_ in pairs(self.Pinning) do
		self:UnPin(piece)
	end
end

function Piece:Pin(pos: Vector2)
	local piece = self.Board:GetPieceFromPosition(pos)
	if piece then
		warn("[Client Board]: "..piece.Type.." ,"..BoardUtil.ANFromVector2(piece.Position).." was pinned by "
			..self.Type.." ,"..BoardUtil.ANFromVector2(self.Position))
		self.Pinning[piece] = true
		piece.PinnedBy[self] = true
	end
end

function Piece:UnPin(piece)
	self.Pinning[piece] = nil
	piece.PinnedBy[self] = nil
end

--//state
function Piece:CleanState()
	table.clear(self.LegalMoves)
	table.clear(self.Attacking)
	table.clear(self.PathOfAttack)
	self:RemovePinning()
end

return Piece