local Knit = require(game:GetService("ReplicatedStorage").Knit)

local TestController = Knit.CreateController({
    ["Name"] = "TestController",
    ["Client"] = {},
})


function TestController:KnitStart()
    local TestEZ = require(Knit.Shared.Lib.TestEZ)
    
    TestEZ.TestBootstrap:run({
        Knit.Shared.Lib,
    })
end

function TestController:KnitInit()

end


return TestController