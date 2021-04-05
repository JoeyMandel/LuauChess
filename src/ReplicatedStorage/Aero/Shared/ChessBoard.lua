-- Chess Board
-- UnknownParabellum
-- February 13, 2021

--[[
	
	local chessBoardClass = ChessBoardClass.new()
	

--]]

--// Started Rewritting 3/29/2021
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

		["State"] = {
			["Board"] =  {},
			["LastFENStates"] = {},
			["LastActions"] = {},

			["WhiteToNextMove"] = true,
			["MoveNumber"] = 1,
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
		},
		["_maid"] = Maid.new()
	}, ChessBoard)

	for file = 1,8 do --// Set up board 
		local isBlack = (file%2 ~= 0)
		for rank = 1,8 do
			local tile = Tile.new(Vector2.new(file,rank))
			tile.IsDark = isBlack
			BoardUtil.Set(self.Board,tile.Position,tile)
			BoardUtil.Set(self.Black.LegalMoves,tile.Position,{})
			BoardUtil.Set(self.White.LegalMoves,tile.Position,{})

			isBlack = not isBlack
		end
	end	
	if state then
		self:LoadFromFEN(state)
	end
	self:UpdateMoves()
	return self
end



function ChessBoard:Initiate()
	
end

function ChessBoard:Update(action)
	self:PreUpdate(action)
	self:ProcessUpdate(action)
	self:AfterUpdate(action)
end

function ChessBoard:Destroy()
	
end

--//Update sub-functions
function ChessBoard:PreUpdate(action)
	self.UpdateReceived:Fire()
	self:CleanState()
end

function ChessBoard:ProcessUpdate(action)

end

function ChessBoard:AfterUpdate(action)
	print("[Client Board]: Piece Moved: "..BoardUtil.GetColor(piece.IsBlack).." "..piece.Type.." : "
		..BoardUtil.ANFromVector2(action[1]).." -> "..BoardUtil.ANFromVector2(changes[2]))	

	self.WhiteToNextMove = not self.WhiteToNextMove
	self.MoveNumber += 0.5
	self.State = "Idle"
	self:UpdateMoves()
	
	self.UpdateProcessed:Fire()
end

function ChessBoard:CleanState()
	local state = self.State
	--// Clear legal moves, attacking and checking to prepare for next update
	-- I imagine the board cleaning out all the gunk
	for name,tbl in pairs(state.White) do
		if name ~= "Pieces" then
			local isChecking = (name == "Checking")
			local isLegalMoves = (name == "LegalMoves")
			local isAttacking = (name == "Attacking")

			for index,val in pairs(tbl) do
				if isChecking or isAttacking then
					tbl[index] = nil
				elseif isLegalMoves then
					for i, _ in pairs(tbl[index]) do
						val[i] = nil
					end
				end
			end
		end
	end
end

--// State

function ChessBoard:Get(index)
	return self.State[index]
end

function ChessBoard:Set(index,newVal)
	self.State[index] = newVal
end

--// Other functions


function ChessBoard:ANFromMoveInfo(moveInfo) --// Done after update
	local firstPiece = BoardUtil.Get(self.Board,moveInfo[1]).Piece

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
	local board = self:Get("Board")
	local piece =  BoardUtil.Get(board,pos1).Piece
	local moveInfo = BoardUtil.Get(piece.LegalMoves,pos2)

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
				
				local origTile = BoardUtil.Get(board,origPos)
				local targetTile = BoardUtil.Get(board,targetPos)
			elseif actionType == "Create" then
			
			elseif  actionType == "Destroy" then
				
			end
  		end

		for offset = 1,#changes,2 do
			local origPos = changes[offset]
			local targetPos = changes[offset+1]
			
			local origTile = BoardUtil.Get(board,origPos)
			local origPiece = origTile.Piece

			if targetPos then
				local targetTile = BoardUtil.Get(board,targetPos)
				if targetTile.Piece then
					targetTile.Piece:Destroy()
				end
				targetTile.Piece = origPiece
				targetTile.Piece.Position = targetPos
				origTile.Piece = nil
			else
				origTile.Piece:Destroy()
			end
		end
		print("[Client Board]: Piece Moved: "..BoardUtil.GetColor(piece.IsBlack).." "..piece.Type.." : "
			..BoardUtil.ANFromVector2(changes[1]).." -> "..BoardUtil.ANFromVector2(changes[2]))	

		self.WhiteToNextMove = not self.WhiteToNextMove
		self.MoveNumber += 0.5
		self.State = "Idle"
		self:UpdateMoves()
		self.AfterMoved:Fire(changes)
	end
end

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
				local newPiece = Piece.new(realPiece,position,self,isBlack) 
				BoardUtil.Get(self.Board,Vector2.new(currentFile,currentRank)).Piece = newPiece

				if newPiece:HasTag("King") then
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

function ChessBoard:UpdateIfCheckmated(color)
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
		self:UpdateState("Checkmate")
	elseif not hasLegalMoves and not isInCheck then
		warn("[Client board]: "..color.." has been stalemated! How embarrassing...")
	end
end

function ChessBoard:UpdateState(newState)
	local currentVal = soundHierarchy[self.State]
	local newVal = soundHierarchy[newState] or 0
	if newVal > currentVal then
		self.State = newState
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
	
	self:UpdateIfCheckmated("Black")
	self:UpdateIfCheckmated("White")
	
	print("[Client Board]: All Legal Moves Updated")	
end

function ChessBoard:CheckIfIsLegalMove(pos1,pos2)
	local board = self.Board
	local piece =  BoardUtil.Get(board,pos1).Piece

	if (piece.MoveNum ~= self.MoveNumber) then
		warn(self.MoveNumber)
		piece:ComputeLegalMoves()
	end
	local moveInfo = BoardUtil.Get(piece.LegalMoves,pos2)
	if moveInfo then
		return true
	end
	return false
end
function ChessBoard:Init()
	Signal = self.Shared.Utils.Signal
	Maid = self.Shared.Utils.Maid
	Tile = self.Shared.Tile
	StringUtil = self.Shared.Utils.StringUtil
	Piece = self.Shared.Piece
	BoardUtil = self.Shared.Utils.BoardUtil
end

return ChessBoard