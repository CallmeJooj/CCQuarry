-- TODO
-- UI
-- Using chests
-- KINDA Rednet messaging support KINDA
-- testing and optimizing
-- checking if full
-- going back when full

--litte rednet code for debugging
rednet.open("left")


posX = 0
posZ = 0
posY = 0
cardinal, saveCardinal = 1, 1 -- cardinal direction ->from the perspective of the turtle!!<- 1 being north, 4 being west
rotationTracker = 1
collumn = io.read()
rows = io.read()

-- will track position after every movement 
function movementTracker()
    tracker_tbl[cardinal]()
end
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
        posX = posX - 1
    end
}

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

--returns to origin in a single dimension
function origin(dir)
    for i = dir-1, 0, -1 do
        turtle.forward()
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
    while not turtle.forward() do
        turtle.dig()
    end
    movementTracker()
    turtle.digUp()
    turtle.digDown()
end

--resumes digging
function resume()
    rotLeft()
    rotLeft()
    for i = 1, posZ, 1 do
        turtle.forward()
    end
    rotRight()
    for i = 1, posX, 1 do
        turtle.forward()
    end
    while cardinal ~= saveCardinal do
        rotRight()
    end
    for i = 1, posY, 1 do
        turtle.down()
    end
end

--resurfaces
--goes back to its origin point
function resurface()
    rednet.broadcast("resurfacing")
    saveCardinal = cardinal
    for i = posY, 1, -1 do
        turtle.up()
    end
    --going west
    while cardinal ~= 4 do
        rotRight()
    end
    origin(posX)
    --the turtle rn is facing west so to face south it must only turn left
    rotLeft()
    origin(posZ)
    rednet.broadcast("Resurfaced")
end

--resurfaces and waits for fuel
function fuelling()
    resurface()
    rotRight()
    while not refuel() do
        term.clear()
        term.setCursorPos(1,1)
        io.write("Waiting for Fuel")
    end
end

function sDump()
    for i = 1, 16, 1 do
        if not turtle.drop() then
            rednet.broadcast("CHEST FULL")
            term.clear()
            term.setCursorPos(1,1)
            io.write("CHEST FULL")
            while not turtle.drop() do
                --waits :)
            end
        end
    end
end

function storeItems()
    resurface()
    if string.find(textutils.serialize(turtle.inspect()), "chest") ~=nil  then
        sDump()
    end
end

--will check if computer has enough fuel to finish next row and come back
--if thats not the case it will try to refuel
function checkFuel()
    if turtle.getFuelLevel() <= posX + posY + posZ + (cardinal == 3 and (2*rows-2) or 0) + 2 then --new version with ternaries
        rednet.broadcast("Not enough fuel")
        return refuel()
    end
    return true
end

--checks if turtle's inventory is full
function isFull()
    if turtle.getItemCount(16) == 0 then
        return false
    end
    return true
end

--bool true if able to refuel
--refuel if empty--
function refuel() 
    for i = 1, 16, 1 do
        turtle.select(i)
        if turtle.refuel(0) then
            if i == i then
                rednet.broadcast("Refueling")
            end
            turtle.refuel(64)
            turtle.select(1)
            return true
        end
    end
    turtle.select(1)
    rednet.broadcast("FAILED TO REFUEL")
    return false
end

--will use function digStraight for digging a row
function digCol(nBlocks)
    for i = 1, nBlocks - 1, 1 do
        digStraight()
    end
end

--will change rows
function changeCol()
    rotate()
    digStraight()
    rotate()
end

--digs and goes down 3 blocks for mining another layer
function changeHeightLevel()
    movDown()
    turtle.digDown()
    movDown()
    turtle.digDown()
    movDown()
    turtle.digDown()
    rotLeft()
    rotLeft()
end


-- main
function quarry()
    turtle.digDown()
    movDown()
    turtle.digDown()
    movDown()
    turtle.digDown()
    while posY > 0 do
        digCol(rows)
        for i = 1, collumn-1, 1 do
            if not checkFuel() then
                rednet.broadcast("FAILED CHECKFUEL")
                i = i - 1
                fuelling()
            elseif isFull() then
                -- TODO if garbage then throw away garbage else
                storeItems()
            end
        end
        if posZ >= rows or posX >= collumn then
            rednet.broadcast("IM GOING ROGUE")
            if not shell.run("shutdown") then
                break
            end
        end
        changeHeightLevel()
    end
end

quarry()
