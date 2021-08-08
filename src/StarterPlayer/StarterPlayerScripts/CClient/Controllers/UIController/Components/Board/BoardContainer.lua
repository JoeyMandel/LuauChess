local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Roact = require(Knit.Client.Lib.Roact)

local e = Roact.createElement

local Themes = require(Knit.Client.Controllers.UIController.Themes)

local BoardContainer = Roact.Component:extend("BoardContainer")

function BoardContainer:init()
    local props = self.props
    local BoardStore = props.Board

    BoardStore.changed:Connect(function(newState)
        self:setState({
            ["BoardState"] = newState,
        }) 
    end)

    self:setState({
        ["BoardState"] = BoardStore:getState(),
    })
end

function BoardContainer:didMount()
    
end

function BoardContainer:render()
    
    return 
end

return BoardContainer