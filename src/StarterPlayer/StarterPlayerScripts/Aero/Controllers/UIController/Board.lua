-- Board
-- Username
-- January 18, 2021
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Maid
local Thread
local Constants
local Palettes
local PieceStyles
local Signal 
local BoardUtil

local PlayerGui
local UI
local Templates
local VisBoard

local baseClass = require(script.Parent.BaseClass)
local Board = setmetatable({},baseClass)

Board.DisplayConfig = {}
Board.CanPickUp = true
Board.Highlighted = {}
Board.OrderedHighlighted = {}
Board.__index = Board

local base = baseClass.new()
Board = setmetatable(base, Board)

function Board:Load()
    if not self.Loaded then
        local UI = self:GetScreenUI(self.Name)
 
        self.Loaded = true
    end
end

function Board:Unload()
    if self.Loaded then

        self.Loaded = false
    end
end

function Board:SetBoard(boardObj)
	self.Board = boardObj
end

--//Highlighting Tiles
function Board:UnHighlight(tile,index)
	local colorPalette = self.DisplayConfig.Palette
	local tilePos = tile.Position
	local tileIndex = index or (tilePos.X*8) + tilePos.Y

	self.Highlighted[tileIndex] = tile
	self.OrderedHighlighted[tilePos.X*8 + tilePos.Y] = nil
	local visTile = VisBoard[tilePos.X][tilePos.Y]
	visTile.BackgroundColor3 = tile.IsDark and colorPalette.Dark or colorPalette.Light		
end

function Board:Highlight(tile,index)
	local colorPalette = self.DisplayConfig.Palette
	local tilePos = tile.Position
	local tileIndex = index or (tilePos.X*8) + tilePos.Y

	if self.OrderedHighlighted[tilePos.X*8 + tilePos.Y] then
		return 
	end
	self.Highlighted[tileIndex] = tile
	self.OrderedHighlighted[tilePos.X*8 + tilePos.Y] = true
	local visTile = VisBoard[tilePos.X][tilePos.Y]
	visTile.BackgroundColor3 = tile.IsDark and colorPalette.Highlight.Dark or colorPalette.Highlight.Light

	return tileIndex
end

--//Utils
function Board:GetVisTile(pos)
	return VisBoard[pos.X][pos.Y]
end

function Board:GetTargetTile(pos)
	local possibleFrames = PlayerGui:GetGuiObjectsAtPosition(pos.X,pos.Y)
	for _,object in pairs(possibleFrames) do
		for _,file in pairs(VisBoard:GetChildren()) do
			if object:IsDescendantOf(file) then
				for _,rank in pairs(file:GetChildren()) do
					if object:IsDescendantOf(rank) or object == rank then
						return BoardUtil.Get(self.Board.Board,Vector2.new(tonumber(file.Name),tonumber(rank.Name)))
					end
				end
			end
		end
	end
end

--//Legal Moves
function Board:ShowLegalMoves(legalMoves)
	for pos,val in pairs(legalMoves) do
		local currentPos = BoardUtil.IntToVector2(pos)
		local tile = self:GetVisTile(currentPos)
		local newDot
		if tile.Piece.Visible then
			local palette = self.DisplayConfig.Palette
			local isDark = BoardUtil.Get(self.Board.Board,currentPos).IsDark

			newDot = Templates.Attacking:Clone()
			newDot.Size = UDim2.fromScale(1,1)
			newDot.Circle.BackgroundColor3 = tile.BackgroundColor3
		else
			newDot = Templates.Circle:Clone()
		end
		newDot.Parent = tile
		newDot.Name = "LegalMove"
	end
end

function Board:HideLegalMoves(legalMoves)
	for pos,val in pairs(legalMoves) do
		local currentPos = BoardUtil.IntToVector2(pos)
		local tile = self:GetVisTile(currentPos)
		local dot =  tile:FindFirstChild("LegalMove")
		if dot then
			dot:Destroy()
		end
	end
end
--// Displaying 

function Board:RemoveOldBoard()
	for _,file in pairs(UI.Board:GetChildren()) do
		if file:IsA("Frame") then
			file:Destroy()
		end
	end
end

function Board:Display(paletteName,styleName,fromWhitePerspective)
	--//Display Base UI	
	local templateFile = Templates.File	
	local templateTile = Templates.Tile
	local templateLabel = Templates.TileLabel

	local board = self.Board.Board

	local style = PieceStyles[styleName] 
	local palette = Palettes[paletteName]
	self.DisplayConfig.Palette = palette
	self.DisplayConfig.PieceStyle = style

	self:RemoveOldBoard()
	
	local offset = fromWhitePerspective and 1 or -1
	local endNum = fromWhitePerspective and 8 or 1
	local startNum =  fromWhitePerspective and 1 or 8

	for file = startNum,endNum,offset do
		--//Create UI
		local newFile = templateFile:Clone()
		newFile.Parent = VisBoard
		newFile.Name = tostring(file)

		for rank = endNum,startNum,-1* offset do
			local tile = BoardUtil.Get(board,Vector2.new(file,rank))
			
			local newTile = templateTile:Clone()
			newTile.Parent = newFile
			newTile.BackgroundColor3 = tile.IsDark and palette.Dark or palette.Light
			newTile.Name = tostring(rank)
			
			--//Display labels [for first file]
			if (file == startNum) then
				local targetTileA = VisBoard[startNum][rank]
				
				local newLabelA = templateLabel:Clone()
				newLabelA.Parent = targetTileA
				newLabelA.TextColor3 = not tile.IsDark and palette.Dark or palette.Light
				newLabelA.Text = tostring(rank)
				newLabelA.Position = UDim2.new(0,0,0,0)
				
			end
			--//Display pieces
			local piece = tile.Piece
			if typeof(piece) == "table" then
				local realPiece = VisBoard[file][rank].Piece
				local id = piece.IsBlack and style.Black[piece.Type] or style.White[piece.Type]
				realPiece.Image = id 
				realPiece.Visible = true
			end
		end
		--/Create labels
		local targetTileB = VisBoard[file][startNum]
		local newLabelB = templateLabel:Clone()
		newLabelB.Parent = targetTileB
		newLabelB.TextColor3 = not BoardUtil.Get(board,Vector2.new(file,startNum)).IsDark and palette.Dark or palette.Light
		newLabelB.Text = tostring(BoardUtil.Get(board,Vector2.new(file,startNum)).File)
	end
end

function Board:UpdatePosition(changes)
	local board = self.Board.Board

	if self.Highlighted["OrigLast"] and self.Highlighted["TargetLast"] then 
		self:UnHighlight(self.Highlighted["OrigLast"],"OrigLast") 
		self:UnHighlight(self.Highlighted["TargetLast"],"TargetLast")
	end
	for index = 1,#changes,2 do
		local origPos = changes[index]
		local targetPos = changes[index+1]
		local origTile = BoardUtil.Get(board,origPos)
		local origPiece = origTile.Piece

		if targetPos then
			local targetTile = BoardUtil.Get(board,targetPos)
			if index == 1 then
				self:Highlight(origTile,"OrigLast")
				self:Highlight(targetTile,"TargetLast")
			end
			local visTargetPiece = self:GetVisTile(targetPos).Piece
			local visOrigPiece = self:GetVisTile(origPos).Piece

			visTargetPiece.Visible = true
			visTargetPiece.Image = visOrigPiece.Image

			visOrigPiece.Visible = false
		else
			self:GetVisTile(origPos).Piece.Visible = false
		end
	end
end

--//Picking up
function Board:PickUpPiece(tile,image)
	local id = image.Image
	local tempPiece = UI.Piece
	local tempImage = tempPiece.Image
	local highlighted = false
	local legalMoves = tile.Piece.LegalMoves

	image.Visible = false
	tempImage.Image = id
	tempPiece.Visible = true
	self.CanPickedUp = false
	
	
	
	local function setTempPos()
		local mousePos = UserInputService:GetMouseLocation()
		local targetPos = UDim2.fromOffset(mousePos.X-tempPiece.AbsoluteSize.X/2,mousePos.Y-tempPiece.AbsoluteSize.Y)
		tempPiece.Position = tempPiece.Position:Lerp(targetPos,0.4)
	end
	local function destroy()
		if highlighted then
			self:UnHighlight(tile)
		end
		self:HideLegalMoves(legalMoves)
		image.Visible = true
		tempPiece.Visible = false
		self.HoldingPiece = false
		self._maid.Movement = nil
		self._maid.NewInput = nil
		self.CanPickUp = true
	end
	if not self.OrderedHighlighted[tile.Position.X*8 + tile.Position.Y] then
		self:Highlight(tile) 
		highlighted = true
	end
	
	local firstPos =  UserInputService:GetMouseLocation()
	tempPiece.Position = UDim2.fromOffset(firstPos.X-tempPiece.AbsoluteSize.X/2,firstPos.Y-tempPiece.AbsoluteSize.Y)
	
	setTempPos()
	self:ShowLegalMoves(legalMoves)
	self._maid.Movement = Thread.DelayRepeat(0.01,function() --//Updates every frame
		setTempPos()
	end)
	self._maid.NewInput = UserInputService.InputEnded:Connect(function(input,gpe)
		local inputType = input.UserInputType
		if (inputType == Enum.UserInputType.MouseButton2) then
			destroy()
		elseif (inputType == Enum.UserInputType.MouseButton1) then
			local length = tempPiece.AbsoluteSize.X
			local offeset  = Vector2.new(length/2,length/2)
			local newTile = self:GetTargetTile(tempPiece.AbsolutePosition+offeset)
			destroy()
			if newTile then
				local canMove = self.Board:CheckIfIsLegalMove(tile.Position,newTile.Position)
				if canMove then
					self.Board:Move(tile.Position,newTile.Position)
				end
			end

		end
	end)
end

--// Activation
function Board:Activate()
	local board = self.Board.Board
	for pos,tile in pairs(board) do
		local currentPos = BoardUtil.IntToVector2(pos)
		local visTile = VisBoard[currentPos.X][currentPos.Y]
		self._maid:GiveTask(visTile.Piece.MouseButton1Down:Connect(function()
			if self.CanPickUp then
				self:PickUpPiece(tile,visTile.Piece)
			end
		end))
	end
	self.Board.AfterMoved:Connect(function(oldPos,newPos)
		self:UpdatePosition(oldPos,newPos)		
	end)
	self.Board.StartTime =  tick()

	self.Board.White.LastTime = tick()
	self.Board.Black.LastTime = tick()

	self.Board.White.ElapsedTime = 0
	self.Board.Black.ElapsedTime = 0
end

--//Basic 

function Board:Init(framework)
	local _shared = framework.Shared
	Constants = _shared.Constants
	PieceStyles = Constants.PieceStyles
	Palettes = Constants.Palettes

	Signal = _shared.Utils.Signal
	Maid = _shared.Utils.Maid
	BoardUtil = _shared.Utils.BoardUtil
	Thread = _shared.Utils.Thread
	
	PlayerGui = self.Player.PlayerGui 
	UI = PlayerGui.Game
	Templates = PlayerGui.HolderUI
	VisBoard = UI.Board
end

return Board