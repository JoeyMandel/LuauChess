-- Board Util
-- UnknownParabellum
-- March 6, 2021

--[[
	function BoardUtil.ANFromVector2(pos: Vector2): string
		Returns the position in algebraic notation
			Vector2.new(2,2) --> a2
	function BoardUtil.GetColor(isBlack: boolean): string
		Returns the the corresponding string. 
			isBlack == true --> "Black"
			isBlack == false --> "white"
	function BoardUtil.GetPieceIndexFromArray(array: Array, piece: Piece):  number
		Gets a piece from an array of pieces
	function BoardUtil.IsPositionValid(pos: Vector2): boolean	
		Checks if a position is within the bounds of an 8x8 chess board
	function BoardUtil.GetX(int: number): number
		Gets solely the X value from the int, when it is converted to a Vecto2
	function BoardUtil.GetY(int: number): number
		Gets solely the Y value from the int, when it is converted to a Vecto2
	function BoardUtil.IntToVector2(intVal: number): Vector2
		Takes in an int value and returns a Vector2
	function BoardUtil.Vector2ToInt(valX: Vector2 | number, valY: number | nil): int 
		Takes in either a Vector2 or two numbers and converts it to its corresponding int value.
	function BoardUtil.FireRayInDirection(board: Array, orig: Vector2, dir: Vector2, collisionCheck: callBackFunction): Array
		Adds dir to orig until the new position is out of bounds.
		Returns an array of the values at the positions where the collisionCheck returned true

		local Board = BoardUtil.Create(false)
		BoardUtil.Set(Board, Vector2.new(4,4), true)
		BoardUtil.Set(Board, Vector2.new(5,5), true)

		BoardUtil.FireRayInDirection(Board, Vector2.new(1,1), Vector2.new(1,1), function(value)
			return value
		end)
		print(Board) --> {[1] = true, [2] = true}
		-- Typically your Board is populated with Tiles that give position information
	function BoardUtil.FireRayToPoint(board: Array, orig: Vector2, target: Vector2, collisionCheck: callBackFunction): Array
		Loops through all the positions between orig and target and calls the collisionCheck callBackFunction.
		Returns an array of the values at the positions where the collisionCheck returned true

		local Board = BoardUtil.Create(false)
		BoardUtil.Set(Board, Vector2.new(4,4), true)
		BoardUtil.Set(Board, Vector2.new(5,5), true)

		BoardUtil.FireRayToPoint(Board, Vector2.new(1,1), Vector2.new(8,8), function(value)
			return value
		end)
		print(Board) --> {[1] = true, [2] = true}
		-- Typically your Board is populated with Tiles that give position information
	function BoardUtil.Get(board: Array, pos: Vector2)
		Returns the value on the inputted position
	function BoardUtil.Set(board: Array, pos: Vector2, val: any)
		Sets the position of the board to the inputted value
	function BoardUtil.Create(defaultVal: any): Array
		This function returns an empty array with all 8x8 slots preallocated and set to the default value
	function BoardUtil.Reset(board: Array): Array
		This function is somewhat redundant. It simply calls table.clear(board). 
--]]

local BoardUtil = {}

local numToRank = {"a","b","c","d","e","f","g","h"}

function BoardUtil.ANFromVector2(pos: Vector2): string
	return (numToRank[pos.X]..tostring(pos.Y))
end

function BoardUtil.GetColor(isBlack: boolean): string
	return isBlack and "Black" or "White"
end

function BoardUtil.GetPieceIndexFromArray(array: Array, piece: Piece):  number
	for index, otherPiece in pairs(array) do
		if otherPiece.Id == piece.Id then
			return index
		end
	end
	return 0
end
----
function BoardUtil.IsPositionValid(pos: Vector2): boolean	
	if (pos.X <= 8 and pos.X >= 1 ) and (pos.Y <= 8 and pos.Y >= 1) then
		return true
	end
	return false
end

function BoardUtil.GetX(int: number): number
	return ((int - int%9)/9) + 1
end

function BoardUtil.GetY(int: number): number
	return int%9
end

function BoardUtil.IntToVector2(intVal: number): Vector2
	local rank = BoardUtil.GetY(intVal)
	local file = BoardUtil.GetX(intVal)
	return Vector2.new(file,rank)   
end

function BoardUtil.Vector2ToInt(valX: Vector2 | number, valY: number | nil): int --// Allows you to use the X and Y values to create the pos. 
	local y = typeof(valY) == "number" and valY or valX.Y
	local x = typeof(valX) == "number" and valX or valX.X

	return ((x-1)*9) + y  
end

function BoardUtil.FireRayInDirection(board: Array, orig: Vector2, dir: Vector2, collisionCheck: callBackFunction): Array
	local collisions = {}

	local delta_x = dir.X 
	local delta_y = dir.Y 
	
	local offset = Vector2.new()
	local next = nil

	local function getNext()
		return Vector2.new(math.floor(offset.X + delta_x), math.floor(offset.Y + delta_y))
	end

	repeat
		offset = getNext()
		next = orig + getNext()
		local value = board[BoardUtil.Vector2ToInt(orig + offset)]
		if value then
			if collisionCheck(value) then
				table.insert(collisions, value)
			end
		end
	until not BoardUtil.IsPositionValid(next)

	return collisions
end

function BoardUtil.FireRayToPoint(board: Array, orig: Vector2, target: Vector2, collisionCheck: callBackFunction): Array
	local collisions = {}

	local delta_x = target.X - orig.X
	local delta_y = target.Y - orig.Y
	local slope = delta_y/delta_x
	
	for x = 1, delta_x do
		local y = math.floor(math.abs(x) * slope)
		local currentPosition = Vector2.new(orig.X + x, orig.Y +  y)
		local value = board[BoardUtil.Vector2ToInt(currentPosition)]

		if value then
			if collisionCheck(value) then
				table.insert(collisions, value)
			end
		end
	end

	return collisions
end

function BoardUtil.Get(board: Array, pos: Vector2)
	if BoardUtil.IsPositionValid(pos) then
		return board[BoardUtil.Vector2ToInt(pos)]
	end
end

function BoardUtil.Set(board: Array, pos: Vector2, val: any)
	if BoardUtil.IsPositionValid(pos) then
		board[BoardUtil.Vector2ToInt(pos)] = val
	end
end

function BoardUtil.Create(default: any): Array
	return table.create(BoardUtil.Vector2ToInt(8,8), default)
end

function BoardUtil.Reset(board: Array): Array
	table.clear(board)
	return board
end

return BoardUtil