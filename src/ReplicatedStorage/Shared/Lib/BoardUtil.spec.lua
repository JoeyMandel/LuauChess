local Knit = require(game:GetService("ReplicatedStorage").Knit)

return function()
    local BoardUtil = require(script.Parent.BoardUtil)
    local ChessBoard = require(Knit.Shared.Classes.ChessBoard)

    local board = ChessBoard.new()
    describe("FireRayToPoint", function()
        local collisions = BoardUtil.FireRayToPoint(board.Board:getState(), Vector2.new(1,1), Vector2.new(7,7), function(tile)
                return tile.IsDark == true
            end)
        it("Should return a table", function()
            expect(typeof(collisions)).to.equal("table")
        end)
        it("All collissions should be tiles", function()
            local allTiles = true
            for _, tile in pairs(collisions) do
                if typeof(tile) ~= "table" or tile.Class ~= "Tile" then
                    allTiles = false
                    break
                end
            end

            expect(allTiles).to.equal(true)
        end)
        it("All collisions must be Dark", function()
            local allDark = true
            for _, tile in pairs(collisions) do
                if not tile.IsDark then 
                    allDark = false
                    break
                end
            end

            expect(allDark).to.equal(true)
        end)
        it("Subsequent collisions' position's magnitudes are larger than the last", function()
            local allLarger = true
            for i, tile in ipairs(collisions) do
                if i ~= #collisions then
                    if tile.Position.Magnitude > collisions[i + 1].Position.Magnitude then 
                        allLarger = false
                        break
                    end
                end
            end
            expect(allLarger).to.equal(true)
        end)
    end)
    describe("FireRayInDirection", function()
        local collisions = BoardUtil.FireRayInDirection(board.Board:getState(), Vector2.new(1,1), Vector2.new(1,1), function(tile)
                return tile.IsDark == true
            end)
        it("Should return a table", function()
            expect(typeof(collisions)).to.equal("table")
        end)
        it("All collissions should be tiles", function()
            local allTiles = true
            for _, tile in pairs(collisions) do
                if typeof(tile) ~= "table" or tile.Class ~= "Tile" then
                    allTiles = false
                    break
                end
            end

            expect(allTiles).to.equal(true)
        end)
        it("All collisions must be Dark", function()
            local allDark = true
            for _, tile in pairs(collisions) do
                if not tile.IsDark then 
                    allDark = false
                    break
                end
            end

            expect(allDark).to.equal(true)
        end)
        it("Subsequent collisions' position's magnitudes are larger than the last", function()
            local allLarger = true
            for i, tile in ipairs(collisions) do
                if i ~= #collisions then
                    if tile.Position.Magnitude > collisions[i + 1].Position.Magnitude then 
                        allLarger = false
                        break
                    end
                end
            end
            expect(allLarger).to.equal(true)
        end)
    end)
end