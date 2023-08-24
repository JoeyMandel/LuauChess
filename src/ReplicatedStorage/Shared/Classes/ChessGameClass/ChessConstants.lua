local PieceEnum = {}
PieceEnum.__index = PieceEnum

function PieceEnum.new(...)
	local self = setmetatable({}, PieceEnum)

	for index, name in pairs({...}) do
		self[name] = index - 1
	end

	return self
end

function PieceEnum:GetEnumName(enum)
	for name, value in pairs(self) do
		if value == enum then
			return name
		end
	end

	return -1
end

function PieceEnum:IsPieceWhite(pieceType)
    if pieceType > self["B_KING"] then
        return true
    end

    return false
end

return {
    ["PIECES"] = PieceEnum.new(
        "B_PAWN",
        "B_ROOK",
        "B_BISHOP",
        "B_KNIGHT",
        "B_QUEEN",
        "B_KING",

		"W_PAWN",
        "W_ROOK",
        "W_BISHOP",
        "W_KNIGHT",
        "W_QUEEN",
        "W_KING"
    )
}