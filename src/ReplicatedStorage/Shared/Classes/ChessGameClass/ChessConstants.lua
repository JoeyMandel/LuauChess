local CustomEnum = {}
CustomEnum.__index = CustomEnum

function CustomEnum.new(...)
	local self = setmetatable({}, CustomEnum)

	for index, name in pairs({...}) do
		self[name] = index - 1
	end

	return self
end

function CustomEnum:GetEnumName(enum)
	for name, value in pairs(self) do
		if value == enum then
			return name
		end
	end

	return -1
end

return {
    ["PIECES"] = CustomEnum.new(
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