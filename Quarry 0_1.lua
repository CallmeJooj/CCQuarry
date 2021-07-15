-- TODO
-- Dig down
-- UI
-- Using chests
-- Rednet messaging support 
-- main function
-- testing and optimizing
posX = 0
posZ = 0
posY = 0
cardinal = 1 -- cardinal direction ->from the perspective of the turtle!!<- 1 being north, 4 being west
rotationTracker = 1
collumn = 0
rows = 0

collumn = io.read()
rows = io.read()

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
    tracker_tbl[cardinal]()
end

--rotates right and updates cardinal
function rotRight()
    turtle.turnRight()
    cardinal = cardinal + 1
    if cardinal == 5 then
        cardinal = 1
    end
end
--same as rotRight() but for left
function rotLeft()
    turtle.turnLeft()
    cardinal = cardinal - 1
    if cardinal == 0 then
        cardinal = 4
    end
end

--move up and down and updates position
function movDown()
    if turtle.down() then
        posY = posY + 1
    end
end
function movUp()
    if turtle.up() then
        posY = posY - 1
    end
end

function origin(dir)
    for i = dir-1, 0, -1 do
        turtle.forward()
        movementTracker()
    end
end

--method for turning at a patter of right > right > left > left
function rotate()
    rotation_tbl[rotationTracker]()
end
rotation_tbl = {  
    [1] = function ()
        rotRight()
        rotationTracker = rotationTracker + 1
        if rotationTracker == 5 then
            rotationTracker = 1
        end
    end,
    [2] = function ()
        rotRight()
        rotationTracker = rotationTracker + 1
        if rotationTracker == 5 then
            rotationTracker = 1
        end
    end,
    [3] = function ()
        rotLeft()
        rotationTracker = rotationTracker + 1
        if rotationTracker == 5 then
            rotationTracker = 1
        end
    end,
    [4] = function ()
        rotLeft()
        rotationTracker = rotationTracker + 1
        if rotationTracker == 5 then
            rotationTracker = 1
        end
    end
}

-- can dig straight
-- dig -> dig /\ dig \/  
function digStraight()
    turtle.dig()
    turtle.forward()
    movementTracker()
    turtle.digUp()
    turtle.digDown()
end

function resurface()
    --going west
    while cardinal ~= 4 do
        rotRight()
    end
    origin(posX)
    --the turtle rn is facing west so to face south it must only turn left
    rotLeft()
    origin(posZ)
    for i = posY, 1, -1 do
        movUp()
    end

end

--will check if computer has enough fuel to finish next row and come back
--if thats not the case it will try to refuel
function checkFuel()
    if turtle.getFuelLevel() <= posX + posY + posZ + (2*rows) then
        return refuel()
    end
    return true
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

--will use function digStraight for digging a row
function digCol(nBlocks)
    for i = 1, nBlocks - 1, 1 do
        digStraight()
    end
end
--will change rows
function changeRow()
    rotate()
    turlte.forward()
    movementTracker()
    rotate()
end

turtle.digDown()
movDown()
turtle.digDown()
movDown()
turtle.digDown()
digCol(rows)
for i = 1, collumn-1, 1 do
    if checkFuel() then
        rotate()
        digStraight()
        rotate()
        digCol(rows)
    else 
        break
    end
end
resurface()

-- NOT WORKING
function changeHeightLevel()
    if turtle.digDown() == false then
        -- return
    end
    if turtle.digDown() == false then
        -- return
    end
end