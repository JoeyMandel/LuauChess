local Knit = require( game:GetService("ReplicatedStorage").Knit)

local ChessGameClass = require(Knit.Shared.Classes.ChessGameClass)

local TestService = Knit.CreateService({
    ["Name"] = "TestService",
    ["Client"] = {},
})


function TestService:KnitStart()
    local startPosition = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    local game = ChessGameClass.new()
    game:Play(startPosition)
end


function TestService:KnitInit()
    
end


return TestService
