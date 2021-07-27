-- TODO
-- UI
-- DONE Using chests
-- 80% Rednet messaging support
-- testing and optimizing
-- DONE checking if full
-- 90% going back when full 
-- 0% sending PM to multiple computers
-- 0% "back" command to return immediately


--litte rednet code for debugging
--CHANGE REDNET BROADCASTS INTO PM FOR SPECIFIC COMPUTER
rednet.open("left")

FIND_BOTTOM_BUFFER = 200
FINDBOTTOM = false
if arg[3] == 'b' then
    FINDBOTTOM = true
end
posX = 0
posZ = 0
posY = 0
cardinal, saveCardinal = 1, 1 -- cardinal direction ->from the perspective of the turtle!!<- 1 being north, 4 being west
rotationTracker = 1
collumn = arg[1] or 5
rows = arg[2] or arg[1] or 5

-- will track position after every movement 
local function movementTracker()
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
local function rotRight()
    turtle.turnRight()
    cardinal = cardinal + 1
    if cardinal == 5 then
        cardinal = 1
    end
end
--same as rotRight() but for left
local function rotLeft()
    turtle.turnLeft()
    cardinal = cardinal - 1
    if cardinal == 0 then
        cardinal = 4
    end
end

--move up and down and updates position
local function movDown()
    if turtle.down() then
        posY = posY + 1
    end
end
local function movUp()
    if turtle.up() then
        posY = posY - 1
    end
end

--returns to origin in a single dimension
local function origin(dir)
    for i = dir-1, 0, -1 do
        turtle.forward()
    end
end

--method for turning at a patter of right > right > left > left
local function rotate()
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
local function digStraight()
    turtle.dig()
    while not turtle.forward() do
        turtle.dig()
    end
    movementTracker()
    turtle.digUp()
    turtle.digDown()
end

--resumes digging
local function resume()
    while cardinal ~= 1 do
        rotRight()
    end
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
local function resurface()
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
end

--resurfaces and waits for fuel
local function fuelling()
    resurface()
    if not refuel() then
        io.write("Waiting for Fuel")
    end
    while not refuel() do
        term.clear()
        term.setCursorPos(1,1)
    end
    resume()
end

-- still clunky af
local function storeDump()
    local FULLCHESTBROADCASTTAG = false
    local fullchest = 1
    -- dude this code is so clunky like my god
    -- well its working
    while fullchest < 16 do
        for i = 1, 16, 1 do
            turtle.select(17-i)
            turtle.drop()
            fullchest = fullchest + 1
            if turtle.getItemCount(17-i) ~= 0 then
                fullchest = 1
                if FULLCHESTBROADCASTTAG == false then
                    rednet.broadcast("CHEST FULL")
                    FULLCHESTBROADCASTTAG = true
                end
                term.clear()
                term.setCursorPos(1,1)
                io.write("CHEST FULL")
            end
        end
    end
end

--CLUNKY AS FUCK but it works (i think)
local function storeItems()
    rednet.broadcast("GOING BACK TO STORE ITEMS")
    resurface()
    while cardinal ~= 3 do
        rotLeft()
    end
    if turtle.inspect() then
        storeDump()
    else
        rednet.broadcast("CANT FIND CHEST")
        while not turtle.inspect() do
        end
        storeDump()
    end
    resume()
end

--will check if computer has enough fuel to finish next row and come back
--if thats not the case it will try to refuel
local function checkFuel()
    if turtle.getFuelLevel() <= posX + posY + posZ + (cardinal == 3 and (2*rows-2) or 0) + 2 then --new version with ternaries
        rednet.broadcast("NOT ENOUGH POWER TO RETURN! CHECKING FOR SOURCE OF FUEL")
        return refuel()
    end
    return true
end

--checks if turtle's inventory is full
local function isFull()
    for i = 16, 1, -1 do    
        if turtle.getItemCount(i) == 0 then
            return false
        end
    end
    return true
end

--bool true if able to refuel
--refuel if empty--
local function refuel()
    for i = 1, 16, 1 do
        turtle.select(i)
        if turtle.refuel(0) then
            if i == 1 then
                rednet.broadcast("REFUELING")
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

--will use local function digStraight for digging a row
local function digCol(nBlocks)
    for i = 1, nBlocks - 1, 1 do
        digStraight()
    end
end

--will change rows
local function changeCol()
    rotate()
    digStraight()
    rotate()
end

--digs and goes down 3 blocks for mining another layer
local function changeHeightLevel()
    movDown()
    turtle.digDown()
    movDown()
    turtle.digDown()
    movDown()
    turtle.digDown()
    rotLeft()
    rotLeft()
end

function findBottom()
    while not turtle.inspectDown() do
        movDown()
    end
    movUp()
end

-- main
local function quarry()
    -- added FINDBOTTOM variable which makes the turtle resume a previously dug quarry
    -- this requires at least a 200 fuel + rows * collumn fuel to start
    if turtle.getFuelLevel() < rows * collumn + (FINDBOTTOM and (FIND_BOTTOM_BUFFER) or 0) then
        if FINDBOTTOM then
            print("THIS TURTLE IS SET TO RESUME A PRE-DUG QUARRY, IT NEEDS AT LEAST ".. FIND_BOTTOM_BUFFER + (rows * collumn) .." FUEL TO START")
        end
        rednet.broadcast("NOT ENOUGH FUEL TO START")
        print("NOT ENOUGH FUEL TO START")
        print("INSERT FUEL IN SLOT 1")
        while turtle.getFuelLevel() < rows * collumn + (FINDBOTTOM and (FIND_BOTTOM_BUFFER) or 0) do
            turtle.select(1)
            turtle.refuel()
        end
    end
    if isFull() then
        storeItems()
    end
    while cardinal ~= 1 do
        rotRight()
    end
    turtle.digDown()
    movDown()
    turtle.digDown()
    movDown()
    turtle.digDown()
    if FINDBOTTOM then
        findBottom()
    end
    while posY > 0 do
        digCol(rows)
        for i = 1, collumn-1, 1 do
            if not checkFuel() then
                fuelling()
            elseif isFull() then
                -- TODO if garbage then throw away garbage else
                storeItems()
            end
            changeCol()
            digCol(rows)
        end
        changeHeightLevel()
    end
end

quarry()
