local Knit = require(game:GetService("ReplicatedStorage").Knit)
local TableUtil = require(script.Parent.TableUtil)

return function()
    local BoardUtil = require(script.Parent.BoardUtil)
    local ChessBoard = require(Knit.Shared.Classes.ChessBoard)

    local board = ChessBoard.new()
    describe("FireRayToPoint & ChessBoard", function()
        local collisions = BoardUtil.FireRayToPoint(board.Board:getState(), Vector2.new(1,1), Vector2.new(7,7), function(tile)
                return tile.IsDark == true
            end)
        it("Should return a table", function()
            expect(typeof(collisions)).to.equal("table")
        end)
        it("All collisions should be tiles", function()
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
    describe("FireRayInDirection & ChessBoard", function()
        local collisions = BoardUtil.FireRayInDirection(board.Board:getState(), Vector2.new(1,1), Vector2.new(1,1), function(tile)
                return tile.IsDark == true
            end)
        it("Should return a table", function()
            expect(typeof(collisions)).to.equal("table")
        end)
        it("All collisions should be tiles", function()
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
    describe("Ray Testings (no other dependencies)", function()
        it("FireRayInDirection returns the correct values", function()
            local Board = BoardUtil.Create(false)
            BoardUtil.Set(Board, Vector2.new(4,4), true)
            BoardUtil.Set(Board, Vector2.new(5,5), true)

            local collisions = BoardUtil.FireRayInDirection(Board, Vector2.new(1,1), Vector2.new(1,1), function(value)
                return value
            end)
            print(collisions) --> {[1] = true, [2] = true}
            expect(#collisions).to.equal(2)
        end)
        it("FireRayToPoint returns the correct values", function()
            local Board = BoardUtil.Create(false)
            BoardUtil.Set(Board, Vector2.new(4,4), true)
            BoardUtil.Set(Board, Vector2.new(5,5), true)
    
            local collisions = BoardUtil.FireRayToPoint(Board, Vector2.new(1,1), Vector2.new(8,8), function(value)
                return value
            end)
            print(collisions) --> {[1] = true, [2] = true}
            expect(#collisions).to.equal(2)
        end)
    end)
    describe("Proper Vector2 To Int Utils", function()
        it("Converting back and forth should return the same value", function()
            local orig = Vector2.new(8,8)
            local int = BoardUtil.Vector2ToInt(orig)
            expect(BoardUtil.IntToVector2(int)).to.equal(orig)
        end)
        it("All indexes must be unique", function()
            local array = BoardUtil.Create()

            local indexAlreadyExists = false

            for x = 1, 8 do
                for y = 1, 8 do
                    local pos = BoardUtil.Vector2ToInt(x,y)
                    if array[pos] then
                        indexAlreadyExists = true
                        break
                    end
                    array[pos] = true
                end
            end
            expect(indexAlreadyExists).to.equal(false)
        end)
        it("Getting the X value of an int equals the original value", function()
            local orig = Vector2.new(8,5)
            local int = BoardUtil.Vector2ToInt(orig)
            expect(BoardUtil.GetX(int)).to.equal(orig.X)
        end)
        it("Getting the Y value of an int equals the original value", function()
            local orig = Vector2.new(8,5)
            local int = BoardUtil.Vector2ToInt(orig)
            expect(BoardUtil.GetY(int)).to.equal(orig.Y)
        end)
    end)
end