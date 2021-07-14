posX = 0
posZ = 0
posY = 0
rotation = 1 -- cardinal direction ->from the perspective of the turtle!!<- 1 being north, 4 being west


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

function rotate()
    -- rotate the turtle and ajusts its sense of direction
    turtle.turnRight()
    rotation = rotation + 1
    if rotation > 4 then
        rotation = 1
    end
end

function digStraight()
    turtle.dig()
    turtle.forward()
    turtle.digUp()
    turtle.digDown()
end

function refuel()
    for i = 1, 16, 1 do
        turtle.select(i)
        if turtle.refuel(0) then
            turtle.refuel(64)
            break
        end
    end
    turtle.select(1)
end

function digRow(nBlocks)
    for i = 1, nBlocks, 1 do
        digStraight()
    end
end

function changeRow()
    turtle.turnRight()
    turtle.forward()
    turtle.turnRight()
end