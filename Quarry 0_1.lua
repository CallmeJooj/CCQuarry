posX = 0
posZ = 0
posY = 0
rotation = 1 -- cardinal direction ->from the perspective of the turtle!!<- 1 being north, 4 being west

-- will track position after every movement 
tracker_tbl = {
    [1] = function ()
        posZ = posZ + 1
    end,
    [2] = function ()
        posX = posX + 1
    end,
    [3] = function ()
        posZ = posZ - 1
    end,
    [4] = function ()
        posX = posX + 1
    end
}
function movementTracker()
    tracker_tbl[rotation]()
end

--NOT WORKING
--still cant find a way to make it rotate right
function rotate()
    -- rotate the turtle and ajusts its sense of direction
    turtle.turnRight()
    rotation = rotation + 1
    if rotation > 4 then
        rotation = 1
    end
end

-- can dig straight
-- dig -> dig /\ dig \/  
function digStraight()
    turtle.dig()
    turtle.forward()
    movementTracker()
    turtle.digUp()
    turtle.digDown()
end

function checkFuel()
    if endturtle.getFuelLevel() == 0 then
        refuel()
    end
end

--bool true if able to refuel
--refuel if empty--
function refuel() 
    for i = 1, 16, 1 do
        turtle.select(i)
        if turtle.refuel(0) then
            turtle.refuel(64)
            turtle.select(1)
            return true
        end
    end
    turtle.select(1)
    return false
end

--will use function digStraight for digging a row, will try to refuel after every row
function digRow(nBlocks)
    for i = 1, nBlocks, 1 do
        digStraight()
    end
    refuel()
end

--NOT WORKING
--will change rows
function changeRow()
    rotate()
    digStraight()
    rotate()
end

-- NOT WORKING
function changeHeightLevel()
    if turtle.digDown() == false then
        -- return
    end
    if turtle.digDown() == false then
        -- return
    end
end