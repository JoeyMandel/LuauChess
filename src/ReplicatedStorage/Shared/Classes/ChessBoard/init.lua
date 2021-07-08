-- Chess Board
-- UnknownParabellum
-- February 13, 2021

--[[
	
	ChessBoard.new()
		Creates a new Chess board
	ChessBoard:LoadFromFen()

	ChessBoard:Destroy()
		Cleans up all connections and destroys the board

	ChessBoard:Move()
		Validates the move and if it is valid then it calls step with the proper actions

	ChessBoard:Step()
		Calls all Step related methods
	ChessBoard:PreStep(actions)
		Performs various actions before stepping through
	ChessBoard:ProcessStep(actions)
		Goes through and updates the board state
	ChessBoard:PostStep(actions)
		Completes the step and prepares things for the next step 

	
--]]

--// Started Rewritting 3/29/2021
local Knit = require(game:GetService("ReplicatedStorage").Knit)

local Signal = require(Knit.Shared.Lib.Signal)
local Maid = require(Knit.Shared.Lib.Maid)
local BoardUtil = require(Knit.Shared.Lib.BoardUtil) 
local StringUtil = require(Knit.Shared.Lib.StringUtil)

local Tile = require(Knit.Shared.Classes.Tile)
local Piece = require(Knit.Shared.Classes.Piece)
local ColorHandler = require(script.ColorHandler)

local BoardStore = require(Knit.Shared.State.BoardStore)


local initialToName = {["p"] = "Pawn",["n"] = "Knight",["b"] = "Bishop",["r"] = "Rook",["q"] = "Queen",["k"] = "King"}

local nameToInitial = {["Pawn"] = "P",["Knight"] = "N",["Bishop"] = "B", ["Rook"] = "R",["Queen"] = "Q",["King"] = "K"}
local soundHierarchy = {
	["Idle"] = 0,
	["Moved"] = 1,
	["Destroyed"] = 2,
	["Stalemate"] = 3,
	["Check"] = 4,
	["Checkmate"] = 5,
}
local ChessBoard = {}
ChessBoard.__index = ChessBoard

--// Key Functions
function ChessBoard.new(state)

	local self = setmetatable({
		["Board"] =  nil,
		["LastFENStates"] = {},
		["LastActions"] = {},
		
		["WhiteToNextMove"] = true,
		["MoveNumber"] = 1,
		
		["Pieces"] = {},
		["White"] = ColorHandler.new(),
		["Black"] = ColorHandler.new(),

		["OnPreStep"] = Signal.new(),
		["OnStep"] = Signal.new(),
		["OnPostStep"] = Signal.new(),

		["__maid"] = Maid.new()
	}, ChessBoard)

	self.Board = BoardStore.new(self)

	if state then
		self:LoadFromFEN(state)
	end
--	self:UpdateMoves()
	return self
end

function ChessBoard:Destroy()
	self.__maid:DoCleaning()
end

--//Update sub-functions
function ChessBoard:Step(actions)
	self:PreStep(actions)
	self:ProcessStep(actions)
	self:PostStep(actions)
end

function ChessBoard:PreStep(actions)
	self.White:Reset()
	self.Black:Reset()
	self.OnPreStep:Fire()
end

function ChessBoard:ProcessStep(actions)
	for _, action in ipairs(actions) do
		self.Board:dispatch(action)
	end
	self.OnStep:Fire()
end

local function getFirstMoveAction(actions)
	local moveAction

	for _, action in ipairs(actions) do
		if action.type == "Move" then
			moveAction = action
		end
	end

	return moveAction
end

function ChessBoard:PostStep(actions)
	local board = self.Board:getState()

	local moveAction = getFirstMoveAction(actions)
	local piece = BoardUtil.Get(board, moveAction.orig)

	print("[Client Board]: Piece Moved: "..BoardUtil.GetColor(piece.IsBlack).." "..piece.Type.." : "
		..BoardUtil.ANFromVector2(moveAction.orig).." --> "..BoardUtil.ANFromVector2(moveAction.target))	

	self.WhiteToNextMove = not self.WhiteToNextMove
	self.MoveNumber += 0.5
	
	self.OnPostStep:Fire()
end

function ChessBoard:Move(piecePos, targetPos, input)
	local board = self.Board:getState()
	local piece = BoardUtil.Get(board, piecePos)

	if piece and self:IsLegalMove(piecePos, targetPos) and (not piece.IsBlack == self.WhiteToNextMove) then
		local actions = piece:CreateAction(targetPos, input)
		self:Step(actions)
	end
end

--// Utils
function ChessBoard:LoadFromFen(state)

end

function ChessBoard:GetColorState(isBlack)
	local color = BoardUtil.GetColor(isBlack)
	return self[color]
end

return ChessBoard