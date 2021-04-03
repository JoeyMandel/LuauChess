-- Board Util
-- UnknownParabellum
-- March 6, 2021

--[[
	

--]]



local BoardUtil = {}

local numToRank = {"a","b","c","d","e","f","g","h"}
function BoardUtil.IsPositionValid(pos)	
	if (pos.X <= 8 and pos.X >= 1 ) and (pos.Y <= 8 and pos.Y >= 1) then
		return true
	end
	return false
end

function BoardUtil.ANFromVector2(pos)
	return (numToRank[pos.X]..tostring(pos.Y))
end

function BoardUtil.IntToVector2(intVal)
	local rank = intVal%9
	local file = ((intVal - rank)/9) + 1
	return Vector2.new(file,rank)   
end

function BoardUtil.Vector2ToInt(valX,valY) --// Allows you to use the X and Y values to create the pos. 
	local pos = valY and Vector2.new(valX,valY) or valX
	return ((pos.X-1)*9) + pos.Y    
end

function BoardUtil.GetColor(isBlack)
	return isBlack and "Black" or "White"
end

function BoardUtil.Get(board,pos)
	if BoardUtil.IsPositionValid(pos) then
		return board[BoardUtil.Vector2ToInt(pos)]
	end
end

function BoardUtil.Set(board,pos,val)
	if BoardUtil.IsPositionValid(pos) then
		board[BoardUtil.Vector2ToInt(pos)] = val
	end
end

function BoardUtil.Create()
	return BoardUtil.Reset({})
end

function BoardUtil.Reset(board)
	table.clear(board)
	return board
end

return BoardUtil