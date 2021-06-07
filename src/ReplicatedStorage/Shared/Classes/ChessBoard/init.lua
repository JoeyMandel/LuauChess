-- Chess Board
-- UnknownParabellum
-- February 13, 2021

--[[
	
	local chessBoardClass = ChessBoardClass.new()
	

--]]

--// Started Rewritting 3/29/2021
local Knit = require(game:GetService("ReplicatedStorage").Knit)

local BoardStore
local Piece
local Signal
local Maid
local Tile
local BoardUtil
local StringUtil

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

--// Key Fucntions
function ChessBoard.new(state)

	local self = setmetatable({
		["UpdateReceived"] = Signal.new(),
		["UpdateProcessed"] = Signal.new(),
		["Checked"] = Signal.new(),
		["PieceDestroyed"] = Signal.new(),

		["Board"] =  nil,
		["LastFENStates"] = {},
		["LastActions"] = {},

		["WhiteToNextMove"] = true,
		["MoveNumber"] = 1,

		["Pieces"] = {},
		["White"] = {
			["Checking"] = {},
			["Pieces"] = {},
			["LegalMoves"] = {},
			["Attacking"] = {},
		},
		["Black"] = {
			["Checking"] = {},
			["Pieces"] = {},
			["LegalMoves"] = {},
			["Attacking"] = {},
		},
		["__maid"] = Maid.new()
	}, ChessBoard)

	self.Board = BoardStore.new({
		["Board"] = self
	})

	if state then
		self:LoadFromFEN(state)
	end
	self.Board = BoardStore.new(self.Board)
	warn(self.Board)
--	self:UpdateMoves()
	return self
end

function ChessBoard:Initiate()
	
end

function ChessBoard:Step(actions)
	self:PreStep(actions)
	self:ProcessStep(actions)
	self:PostStep(actions)
end

function ChessBoard:Destroy()
	
end

--//Update sub-functions
function ChessBoard:PreStep(actions)
	self.UpdateReceived:Fire()
	self:CleanState()
end

function ChessBoard:ProcessStep(actions)
	for _, action in ipairs(actions) do
		self.Board:dispatch(action)
	end
end

function ChessBoard:PostStep(action)
	local pos1 = action[1].Orig
	local pos2 = action[1].Target
	local piece = self.Board[pos1]

	print("[Client Board]: Piece Moved: "..BoardUtil.GetColor(piece.IsBlack).." "..piece.Type.." : "
		..BoardUtil.ANFromVector2(pos1).." -> "..BoardUtil.ANFromVector2(pos2))	

	self.WhiteToNextMove = not self.WhiteToNextMove
	self.MoveNumber += 0.5
	self = "Idle"
	self:UpdateMoves()
	
	self.UpdateProcessed:Fire()
end

function ChessBoard:Move(piecePos, targetPos, input)
	local board = self.Board:getState()
	local piece = BoardUtil.Get(board, piecePos)

	if piece and self:IsLegalMove(piecePos, targetPos) and (not piece.IsBlack == self.WhiteToNextMove) then
		local actions = piece:GetActions(targetPos, input)
		self:Step(actions)
	end
end

--// Other functions

--[[
	How a chess move works:
		1. Moveinfo is found and determines if it is special or normal 
			Note: Normal is one piece moving to another position
			Special is when one piece moves to somewhere unexpected or moves/destroys another pieces
		2. BeforeMove event is fired
		3. MoveInfo is executed and the pieces are moved
		4. Changes next move to the opp color
		5. Confirms position by updating legal moves
		6. Fires AfterMoved
]]
function ChessBoard:Move(pos1,pos2,config)
	local board = self.Board
	local piece =  board[pos1].Piece
	local moveInfo = piece.LegalMoves[pos2]

	if moveInfo and (not piece.IsBlack == self.WhiteToNextMove) then
		if piece:HasTag("InputPossible") then
			warn("Input changed Changes")
			moveInfo = piece:ApplyInput(pos2,config)
		end
	
		self.BeforeMoved:Fire(moveInfo)
		piece:BeforeUpdate(moveInfo)
		warn(self:ANFromMoveInfo(moveInfo))

		for _,action in pairs(moveInfo) do
			local actionType = action.Type
			if actionType == "Move" then
				local origPos = action.Orig
				local targetPos = action.Target
				
				local origTile = board[origPos]
				local targetTile = board[targetPos]
				
				local firstPiece = origTile.Piece
				local targetPiece = targetTile.Piece

				targetPiece:Destroy()
				origTile.Piece = nil
				targetTile.Piece = firstPiece
			elseif actionType == "Create" then
			
			elseif  actionType == "Destroy" then
				local targetPos = action.Target
				local targetPiece = board[targetPos].Piece
				targetPiece:Destroy()
			end
  		end

		print("[Client Board]: Piece Moved: "..BoardUtil.GetColor(piece.IsBlack).." "..piece.Type.." : "
			..BoardUtil.ANFromVector2(pos1).." -> "..BoardUtil.ANFromVector2(pos2))	

		self.WhiteToNextMove = not self.WhiteToNextMove
		self.MoveNumber += 0.5
		self = "Idle"
		self:UpdateMoves()
		self.AfterMoved:Fire(moveInfo)
	end
end
--[[
function ChessBoard:ANFromMoveInfo(action) --// Done after update
	local firstPiece = BoardUtil.Get(self.Board.,action[1].Orig).Piece

	local color = BoardUtil.GetColor(firstPiece.IsBlack)	
	local takenPiece = false
	local castles = false
	
	for offset = 1,#moveInfo,2 do
		local origPos = moveInfo[offset]
		local targetPos = moveInfo[offset+1]

		local origTile = BoardUtil.Get(self.Board,origPos)
		local origPiece = origTile.Piece

		if targetPos then
			local targetTile = BoardUtil.Get(self.Board,targetPos)
			if targetTile.Piece then
				takenPiece = targetTile.Piece
			end
		else
			takenPiece = origTile.Piece
		end
	end
	
	local str = BoardUtil.ANFromVector2(moveInfo[2])
	
	for piece,_ in pairs(BoardUtil.Get(self[color].LegalMoves,moveInfo[2])) do
		if piece ~= firstPiece then
			str = nameToInitial[firstPiece.Type]..BoardUtil.ANFromVector2(firstPiece.Position)
		end		
	end
	if takenPiece then
		str = str.."x".. BoardUtil.ANFromVector2(moveInfo[2])
	end
	return str
end
]]
function ChessBoard:IsAttacking(color,pos)
	local attacking = self[color].Attacking
	return BoardUtil.Get(attacking,pos)
end

function ChessBoard:LoadFromFEN(FENString)
	local fields = string.split(FENString," ")  --Splits a fen string into its individual fields

	for index,rank in pairs(string.split(fields[1],"/") ) do
		local currentRank = 9-index
		local chars = StringUtil.ToCharArray(rank)
		local currentFile = 1
		for _,char in pairs(chars) do		
			local isNumber = (tonumber(char)~=nil)
			if isNumber then
				currentFile += tonumber(char) --Skips and adds if just a number
			else
				local realPiece = initialToName[string.lower(char)]
				local isBlack = (char == string.lower(char)) 
				local color = BoardUtil.GetColor(isBlack)

				local position = BoardUtil.Vector2ToInt(currentFile,currentRank)
				local newPiece = realPiece--Piece.new(realPiece,position,self,isBlack) 
				BoardUtil.Get(self.Board,Vector2.new(currentFile,currentRank)).Piece = newPiece

				if newPiece == "King" then--newPiece:HasTag("King") then
					self[color].Pieces["King"] = newPiece
				else
					table.insert((self[color].Pieces),newPiece)
				end				
				currentFile += 1
			end
		end
		currentFile = 1
	end

	self.WhiteToNextMove = (fields[2] == "w" and true) or false
end

function ChessBoard:SetBoardState(color)
	local colorTbl = self[color]
	local hasLegalMoves = false
	local isInCheck = #colorTbl.Checking > 0 

	for _,piece in pairs(colorTbl.Pieces) do
		if hasLegalMoves then
			break
		end
		for _,moveInfo in pairs(piece.LegalMoves) do
			hasLegalMoves = true
			break
		end
	end
	if not hasLegalMoves and isInCheck then
		warn("[Client Board]: ".. color.." has just been checkmated!")
		self:SetState("Checkmate")
	elseif not hasLegalMoves and not isInCheck then
		warn("[Client board]: "..color.." has been stalemated! How embarrassing...")
		self:SetState("Stalemate")
	end
end

function ChessBoard:SetState(newState)
	local currentVal = soundHierarchy[self]
	local newVal = soundHierarchy[newState] or 0
	if newVal >= currentVal then
		self = newState
	end
end

function ChessBoard:UpdateMoves()
	table.clear(self.White.Attacking)	
	table.clear(self.Black.Attacking)
	
	for _,tbl in pairs(self.White.LegalMoves) do
		for index, _ in pairs(tbl) do
			tbl[index] = nil
		end
	end
	for _,tbl in pairs(self.Black.LegalMoves) do
		for index, _ in pairs(tbl) do
			tbl[index] = nil
		end
	end
	for _,piece in pairs(self.White.Pieces) do
		piece:ComputeLegalMoves()
	end
	for _,piece in pairs(self.Black.Pieces) do
		piece:ComputeLegalMoves()
	end
	--//White pieces must be updated again because 
	--//when it was updated first it was uncertain to be valid [black pieces were not updated before]
	for _,piece in pairs(self.White.Pieces) do
		piece:ComputeLegalMoves()
	end
	
	self:SetBoardState("Black")
	self:SetBoardState("White")
	
	print("[Client Board]: All Legal Moves Updated")	
end

function ChessBoard:IsLegalMove(pos1,pos2)
	local board = self.Board
	local piece =  BoardUtil.Get(board,pos1).Piece

	local moveInfo = BoardUtil.Get(piece.LegalMoves,pos2)
	if moveInfo then
		return true
	end
	return false
end

function ChessBoard:Init()
	local _shared = Knit.Shared
	Signal = require(_shared.Lib.Signal)
	Maid = require(_shared.Lib.Maid)
	Tile = require(_shared.Classes.Tile)
	StringUtil = require(_shared.Lib.StringUtil)
	Piece = require(_shared.Classes.Piece)
	BoardUtil = require(_shared.Lib.BoardUtil)
	BoardStore = require(_shared.State.BoardStore)
end

ChessBoard:Init()

return ChessBoard