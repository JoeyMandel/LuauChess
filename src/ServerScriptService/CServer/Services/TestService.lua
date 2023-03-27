local Knit = require( game:GetService("ReplicatedStorage").Knit)

local TestService = Knit.CreateService({
    ["Name"] = "TestService",
    ["Client"] = {},
})


function TestService:KnitStart()
    
end


function TestService:KnitInit()
    
end


return TestService
